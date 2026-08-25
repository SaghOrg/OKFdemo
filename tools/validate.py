#!/usr/bin/env python3
"""Validate the YAML frontmatter of every knowledge-base record against schemas/concept.schema.json.

Runs from a fresh clone with the system Python. Standard library only -- no
virtualenv, no pip install, nothing to set up.

Exit codes
  0  checks ran and every record passed
  1  checks ran and at least one record failed
  2  checks could NOT run (missing schema, unreadable schema, schema feature
     this validator does not implement, unsupported Python)

Exit code 0 never means "could not check". Both the YAML reader and the schema
reader below refuse anything they do not fully understand rather than skipping
it, so an unhandled construct surfaces as exit 2, not as a silent pass.
"""

import datetime as _dt
import json
import pathlib
import re
import sys

MIN_PYTHON = (3, 8)

# Directories and filenames excluded from validation. `templates` was removed
# from this set once templates/decision.md was made schema-conformant: a
# template that cannot be validated is a template that drifts from the schema
# it is supposed to seed. `_plan` is process scaffolding for the enforcement
# build-out, not knowledge, and holds no frontmatter.
SKIP = {"_sources", "_canon", "_qa", "_build", "_snapshots", ".git",
        ".venv-synth", "schemas", ".github", ".cursor", "_plan", "tests"}
SKIP_NAMES = {"AGENTS.md", "CLAUDE.md", "README.md", "LEARNINGS.md"}

FRONTMATTER = re.compile(r"\A---\s*\n(.*?)\n---\s*\n", re.S)


def die(message):
    """Report that the checks could not be run, and exit non-zero."""
    sys.stderr.write("validate.py: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


# --------------------------------------------------------------------------
# YAML frontmatter reader
#
# A deliberately small reader for the subset of YAML this knowledge base uses:
# nested mappings, sequences of scalars, sequences of mappings, plain and
# quoted scalars, and plain scalars folded across continuation lines. Anything
# outside that subset -- block scalars, flow collections, anchors, aliases,
# multi-document streams, tabs -- raises YamlError rather than being guessed at.
# --------------------------------------------------------------------------

class YamlError(Exception):
    pass


KEY_RE = re.compile(r"^([A-Za-z0-9_][A-Za-z0-9_.\-]*)\s*:(?:\s+(.*))?$")
# Empty flow collections only. A populated flow collection stays unsupported:
# parsing one properly means quoting, escaping and nesting rules, and the corpus
# writes every non-empty collection in block style. `[]` and `{}` are admitted
# because they are the only way YAML can express an emptiness that a schema rule
# should then judge -- without them `sources: []` died as a syntax error and the
# `minItems` rule it was meant to trip could never fire.
EMPTY_SEQ_RE = re.compile(r"^\[\s*\]$")
EMPTY_MAP_RE = re.compile(r"^\{\s*\}$")
INT_RE = re.compile(r"^[-+]?[0-9]+$")
FLOAT_RE = re.compile(r"^[-+]?(?:[0-9]*\.[0-9]+|[0-9]+\.[0-9]*)(?:[eE][-+]?[0-9]+)?$")


class _Line(object):
    __slots__ = ("indent", "text", "no")

    def __init__(self, indent, text, no):
        self.indent = indent   # None for a blank line
        self.text = text
        self.no = no


def _scan(block):
    lines = []
    for no, raw in enumerate(block.split("\n"), 1):
        raw = raw.rstrip()
        if not raw.strip():
            lines.append(_Line(None, "", no))
            continue
        lead = raw[:len(raw) - len(raw.lstrip(" \t"))]
        if "\t" in lead:
            raise YamlError("line %d: tab in indentation" % no)
        stripped = raw.strip()
        if stripped.startswith("#"):
            continue
        lines.append(_Line(len(lead), raw.lstrip(" "), no))
    return lines


def _next_content(lines, i):
    while i < len(lines) and lines[i].indent is None:
        i += 1
    return i


def _scalar(token, no):
    """Convert one scalar token. Quoted stays a string; plain is resolved."""
    if token.startswith('"'):
        if len(token) < 2 or not token.endswith('"'):
            raise YamlError("line %d: unterminated double-quoted string" % no)
        try:
            return json.loads(token)
        except ValueError:
            raise YamlError("line %d: cannot read double-quoted string" % no)
    if token.startswith("'"):
        if len(token) < 2 or not token.endswith("'"):
            raise YamlError("line %d: unterminated single-quoted string" % no)
        return token[1:-1].replace("''", "'")
    if EMPTY_SEQ_RE.match(token):
        return []
    if EMPTY_MAP_RE.match(token):
        return {}
    if token[:1] in "[{":
        raise YamlError("line %d: only empty flow collections ([] and {}) "
                        "are supported" % no)
    if token[:1] in "&*!":
        raise YamlError("line %d: anchors, aliases and tags are not supported" % no)
    if token in (">", "|", ">-", "|-", ">+", "|+"):
        raise YamlError("line %d: block scalars are not supported" % no)
    if token in ("null", "~", "Null", "NULL"):
        return None
    if token in ("true", "True", "TRUE"):
        return True
    if token in ("false", "False", "FALSE"):
        return False
    if INT_RE.match(token):
        return int(token)
    if FLOAT_RE.match(token):
        return float(token)
    return token


BLOCK_HEADER_RE = re.compile(r"^[|>][-+]?[0-9]*$")


def _strip_comment(text, no):
    """Drop a trailing YAML comment from one scalar.

    YAML opens a comment at a `#` only when it starts the scalar or is preceded
    by whitespace, and never inside a quoted string -- so `release#42` keeps
    its hash and `draft  # draft | accepted` does not.
    """
    if not text:
        return text

    quote = text[0]
    if quote in "\"'":
        i = 1
        while i < len(text):
            char = text[i]
            if quote == '"' and char == "\\":
                i += 2
                continue
            if char == quote:
                if quote == "'" and text[i + 1:i + 2] == "'":
                    i += 2          # '' is an escaped quote inside '...'
                    continue
                break
            i += 1
        else:
            raise YamlError("line %d: unterminated quoted string" % no)
        rest = text[i + 1:].strip()
        if rest and not rest.startswith("#"):
            raise YamlError("line %d: unexpected text after a quoted value" % no)
        return text[:i + 1]

    at = 0
    while True:
        at = text.find("#", at)
        if at == -1:
            return text.rstrip()
        if at == 0 or text[at - 1] in " \t":
            return text[:at].rstrip()
        at += 1


def _plain_continuation(lines, i, indent, first, no):
    """Fold a plain scalar across following more-indented lines."""
    if BLOCK_HEADER_RE.match(first):
        raise YamlError("line %d: block scalars are not supported" % no)
    parts = [first]
    quoted = first[:1] in "\"'"
    while i < len(lines):
        ln = lines[i]
        if ln.indent is None:
            j = _next_content(lines, i)
            if j < len(lines) and lines[j].indent is not None and lines[j].indent > indent:
                raise YamlError(
                    "line %d: blank line inside a multi-line value is not supported" % lines[j].no)
            break
        if ln.indent <= indent:
            break
        if quoted:
            raise YamlError("line %d: multi-line quoted strings are not supported" % ln.no)
        parts.append(_strip_comment(ln.text, ln.no))
        i += 1
    if len(parts) == 1:
        return _scalar(first, no), i
    return " ".join(p.strip() for p in parts), i


def _parse_block(lines, i, indent):
    if lines[i].text.startswith("-"):
        return _parse_seq(lines, i, indent)
    return _parse_map(lines, i, indent)


def _parse_map(lines, i, indent):
    out = {}
    while i < len(lines):
        ln = lines[i]
        if ln.indent is None:
            i += 1
            continue
        if ln.indent < indent:
            break
        if ln.indent > indent:
            raise YamlError("line %d: unexpected indentation" % ln.no)
        if ln.text.startswith("- "):
            raise YamlError("line %d: list item where a key was expected" % ln.no)
        m = KEY_RE.match(ln.text)
        if not m:
            raise YamlError("line %d: cannot read %r as a key" % (ln.no, ln.text[:60]))
        key = m.group(1)
        value_text = _strip_comment((m.group(2) or "").strip(), ln.no)
        if key in out:
            raise YamlError("line %d: duplicate key %r" % (ln.no, key))
        i += 1
        if value_text:
            out[key], i = _plain_continuation(lines, i, indent, value_text, ln.no)
            continue
        j = _next_content(lines, i)
        if j < len(lines) and (
                lines[j].indent > indent
                or (lines[j].indent == indent and lines[j].text.startswith("-"))):
            out[key], i = _parse_block(lines, j, lines[j].indent)
        else:
            out[key] = None
    return out, i


def _parse_seq(lines, i, indent):
    out = []
    while i < len(lines):
        ln = lines[i]
        if ln.indent is None:
            i += 1
            continue
        if ln.indent < indent:
            break
        if ln.indent > indent:
            raise YamlError("line %d: unexpected indentation" % ln.no)
        if not ln.text.startswith("-"):
            break
        rest = ln.text[1:]
        spaces = len(rest) - len(rest.lstrip(" "))
        rest = _strip_comment(rest.strip(), ln.no)
        if rest and spaces == 0:
            raise YamlError("line %d: '-' must be followed by a space" % ln.no)
        item_indent = indent + 1 + spaces
        if not rest:
            i += 1
            j = _next_content(lines, i)
            if j < len(lines) and lines[j].indent is not None and lines[j].indent > indent:
                value, i = _parse_block(lines, j, lines[j].indent)
            else:
                value = None
            out.append(value)
            continue
        if KEY_RE.match(rest):
            # A mapping opening on the dash line; its remaining keys sit at
            # item_indent on the lines that follow.
            sub = [_Line(item_indent, rest, ln.no)]
            i += 1
            while i < len(lines):
                nxt = lines[i]
                if nxt.indent is None:
                    sub.append(nxt)
                    i += 1
                    continue
                if nxt.indent < item_indent:
                    break
                sub.append(nxt)
                i += 1
            value, _ = _parse_map(sub, 0, item_indent)
            out.append(value)
            continue
        i += 1
        value, i = _plain_continuation(lines, i, indent, rest, ln.no)
        out.append(value)
    return out, i


def read_frontmatter(block):
    """Parse a frontmatter block into Python data. Raises YamlError."""
    lines = _scan(block)
    i = _next_content(lines, 0)
    if i >= len(lines):
        return {}
    if lines[i].indent != 0:
        raise YamlError("line %d: frontmatter must start at column 0" % lines[i].no)
    data, i = _parse_block(lines, i, 0)
    i = _next_content(lines, i)
    if i < len(lines):
        raise YamlError("line %d: trailing content after the top-level block" % lines[i].no)
    return data


# --------------------------------------------------------------------------
# JSON Schema reader
#
# Implements exactly the keywords concept.schema.json uses. A keyword outside
# KNOWN_KEYWORDS is a hard stop (exit 2), so extending the schema without
# extending this file fails loudly instead of validating less than it appears to.
# --------------------------------------------------------------------------

ANNOTATION_KEYWORDS = {"$schema", "$id", "title", "description", "examples", "default", "$comment"}
ASSERTION_KEYWORDS = {"type", "required", "properties", "additionalProperties",
                      "items", "enum", "const", "minLength", "maxLength",
                      "minItems", "maxItems", "uniqueItems", "pattern", "format"}
KNOWN_KEYWORDS = ANNOTATION_KEYWORDS | ASSERTION_KEYWORDS
KNOWN_TYPES = {"object", "array", "string", "number", "integer", "boolean", "null"}
KNOWN_FORMATS = {"date", "date-time"}


def check_schema_supported(schema, where="(root)"):
    if not isinstance(schema, dict):
        die("schema at %s is not an object" % where)
    for key in schema:
        if key not in KNOWN_KEYWORDS:
            die("schema at %s uses %r, which this validator does not implement. "
                "Implement it in tools/validate.py before adding it to the schema."
                % (where, key))
    types = schema.get("type")
    for t in ([types] if isinstance(types, str) else (types or [])):
        if t not in KNOWN_TYPES:
            die("schema at %s uses unknown type %r" % (where, t))
    fmt = schema.get("format")
    if fmt is not None and fmt not in KNOWN_FORMATS:
        die("schema at %s uses format %r, which this validator does not check" % (where, fmt))
    for name, sub in (schema.get("properties") or {}).items():
        check_schema_supported(sub, "%s.%s" % (where, name))
    items = schema.get("items")
    if isinstance(items, dict):
        check_schema_supported(items, "%s[]" % where)
    elif items is not None:
        die("schema at %s uses a non-object 'items'" % where)
    extra = schema.get("additionalProperties")
    if isinstance(extra, dict):
        check_schema_supported(extra, "%s.additionalProperties" % where)


def _type_matches(value, wanted):
    if wanted == "object":
        return isinstance(value, dict)
    if wanted == "array":
        return isinstance(value, list)
    if wanted == "string":
        return isinstance(value, str)
    if wanted == "boolean":
        return isinstance(value, bool)
    if wanted == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if wanted == "number":
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    if wanted == "null":
        return value is None
    return False


def _type_name(value):
    for name in ("null", "boolean", "integer", "number", "string", "array", "object"):
        if _type_matches(value, name):
            return name
    return type(value).__name__


def _check_format(value, fmt):
    if fmt == "date":
        try:
            _dt.date(*[int(p) for p in re.match(r"^(\d{4})-(\d{2})-(\d{2})$", value).groups()])
        except (AttributeError, TypeError, ValueError):
            return "%r is not an ISO 8601 date (YYYY-MM-DD)" % value
        return None
    if fmt == "date-time":
        m = re.match(r"^(\d{4})-(\d{2})-(\d{2})[Tt](\d{2}):(\d{2}):(\d{2})(\.\d+)?"
                     r"([Zz]|[-+]\d{2}:\d{2})$", value)
        if not m:
            return "%r is not an RFC 3339 date-time" % value
        try:
            _dt.datetime(*[int(m.group(n)) for n in range(1, 7)])
        except ValueError:
            return "%r is not a real date-time" % value
        return None
    return None


def _canonical(value):
    return json.dumps(value, sort_keys=True, default=str)


def validate(value, schema, path=""):
    """Yield (kind, message) for every way value fails schema.

    kind is "error" for a schema assertion, or "format" for a `format`
    mismatch. `format` is an annotation in JSON Schema 2020-12 and the previous
    validator did not assert it, so the driver reports those separately and does
    not fail the run on them. Deciding whether `format` becomes an assertion is
    schema work, not plumbing work.
    """
    where = path or "(root)"

    wanted = schema.get("type")
    if isinstance(wanted, str):
        wanted = [wanted]
    if wanted and not any(_type_matches(value, t) for t in wanted):
        yield "error", "%s: expected %s, found %s" % (
            where, " or ".join(wanted), _type_name(value))
        return

    if "enum" in schema and not any(
            _canonical(value) == _canonical(option) for option in schema["enum"]):
        yield "error", "%s: %r is not one of %s" % (where, value, schema["enum"])
    if "const" in schema and _canonical(value) != _canonical(schema["const"]):
        yield "error", "%s: %r is not %r" % (where, value, schema["const"])

    if isinstance(value, str):
        if "minLength" in schema and len(value) < schema["minLength"]:
            yield "error", "%s: shorter than %d characters" % (where, schema["minLength"])
        if "maxLength" in schema and len(value) > schema["maxLength"]:
            yield "error", "%s: longer than %d characters" % (where, schema["maxLength"])
        if "pattern" in schema and not re.search(schema["pattern"], value):
            yield "error", "%s: %r does not match %s" % (where, value, schema["pattern"])
        if "format" in schema:
            problem = _check_format(value, schema["format"])
            if problem:
                yield "format", "%s: %s" % (where, problem)

    if isinstance(value, dict):
        for name in schema.get("required", []):
            if name not in value:
                yield "error", "%s: missing required field %r" % (where, name)
        properties = schema.get("properties") or {}
        extra = schema.get("additionalProperties", True)
        for name in sorted(value):
            child = "%s.%s" % (path, name) if path else name
            if name in properties:
                for problem in validate(value[name], properties[name], child):
                    yield problem
            elif extra is False:
                yield "error", "%s: unknown field %r" % (where, name)
            elif isinstance(extra, dict):
                for problem in validate(value[name], extra, child):
                    yield problem

    if isinstance(value, list):
        if "minItems" in schema and len(value) < schema["minItems"]:
            yield "error", "%s: needs at least %d item(s), found %d" % (
                where, schema["minItems"], len(value))
        if "maxItems" in schema and len(value) > schema["maxItems"]:
            yield "error", "%s: allows at most %d item(s), found %d" % (
                where, schema["maxItems"], len(value))
        if schema.get("uniqueItems") and len(
                {_canonical(v) for v in value}) != len(value):
            yield "error", "%s: items must be unique" % where
        item_schema = schema.get("items")
        if isinstance(item_schema, dict):
            for n, item in enumerate(value):
                for problem in validate(item, item_schema, "%s[%d]" % (path or "(root)", n)):
                    yield problem


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------

def main():
    if sys.version_info < MIN_PYTHON:
        die("needs Python %d.%d or newer, running %s"
            % (MIN_PYTHON[0], MIN_PYTHON[1], ".".join(map(str, sys.version_info[:3]))))

    root = pathlib.Path(__file__).resolve().parent.parent
    schema_path = root / "schemas" / "concept.schema.json"
    if not schema_path.is_file():
        die("no schema at %s" % schema_path)
    try:
        schema = json.loads(schema_path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        die("cannot read %s: %s" % (schema_path, exc))
    check_schema_supported(schema)

    ok = bad = nofm = 0
    rows = []
    untitled = []
    format_notes = []

    for path in sorted(root.rglob("*.md")):
        rel = path.relative_to(root)
        if rel.parts[0] in SKIP or rel.name in SKIP_NAMES:
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError as exc:
            die("cannot read %s: %s" % (rel, exc))
        match = FRONTMATTER.match(text)
        if not match:
            nofm += 1
            rows.append((str(rel), "NO FRONTMATTER", ""))
            continue
        try:
            data = read_frontmatter(match.group(1))
        except YamlError as exc:
            bad += 1
            rows.append((str(rel), "YAML PARSE ERROR", str(exc)[:130]))
            continue
        if data is None:
            data = {}
        if not isinstance(data, dict):
            bad += 1
            rows.append((str(rel), "YAML PARSE ERROR", "frontmatter is not a mapping"))
            continue
        problems = list(validate(data, schema))
        errors = [m for kind, m in problems if kind == "error"]
        format_notes.extend((str(rel), m) for kind, m in problems if kind == "format")
        if errors:
            bad += 1
            for problem in errors[:6]:
                rows.append((str(rel), "SCHEMA", problem))
        else:
            ok += 1
        if not data.get("title"):
            untitled.append(str(rel))

    if ok == 0 and bad == 0 and nofm == 0:
        die("found no records to validate under %s" % root)

    print("VALID=%d  INVALID=%d  NO_FRONTMATTER=%d  MISSING_TITLE=%d  FORMAT_NOTES=%d"
          % (ok, bad, nofm, len(untitled), len(format_notes)))
    for name, kind, detail in rows:
        print("  %s\n      %s  %s" % (name, kind, detail))
    if untitled:
        print("\nCONVENTION (title required locally, not by schema):")
        for name in untitled:
            print("   %s" % name)
    if format_notes:
        print("\nFORMAT (reported, not enforced -- `format` is an annotation in "
              "JSON Schema 2020-12\nand the previous validator did not assert it "
              "either; these do not fail the run):")
        for name, detail in format_notes:
            print("   %s\n      %s" % (name, detail))

    return 1 if (bad or nofm) else 0


if __name__ == "__main__":
    sys.exit(main())
