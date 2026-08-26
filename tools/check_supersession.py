#!/usr/bin/env python3
"""Supersession integrity.

    python3 tools/check_supersession.py

Enforced:
  * every `supersedes` / `superseded_by` target exists
  * `superseded_by` present implies `status: superseded`

Reported, not enforced:
  * `status: superseded` with no `superseded_by`

Exit codes
  0  the check ran and every enforced rule holds
  1  the check ran and an enforced rule is broken
  2  the check could not run

Standard library only.

Why the second rule lives here and not in the schema: it is one of a family of
four supersession invariants, and only two of them are expressible in JSON
Schema at all. `dependentRequired` can say "superseded_by implies status", but
it cannot reach into another document to check that the record being superseded
points back. Splitting a coherent family across a schema keyword and a script
would put half the rule in each place. One script per invariant family keeps it
together, and keeps the tool count down.
"""

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

try:
    from validate import FRONTMATTER, SKIP, SKIP_NAMES, YamlError, read_frontmatter
except ImportError as exc:                                   # pragma: no cover
    sys.stderr.write("check_supersession: CANNOT RUN: cannot import validate.py: %s\n" % exc)
    raise SystemExit(2)

ROOT = pathlib.Path(__file__).resolve().parent.parent
RESOLUTION_SKIP = SKIP | {"templates"}       # see the note in check_sources.py
KEYS = ("supersedes", "superseded_by")
SUPERSEDED = "superseded"


def die(message):
    sys.stderr.write("check_supersession: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


def main():
    problems, unpaired, checked, files = [], [], 0, 0
    for path in sorted(ROOT.rglob("*.md")):
        rel = path.relative_to(ROOT)
        if rel.parts[0] in RESOLUTION_SKIP or rel.name in SKIP_NAMES:
            continue
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError as exc:
            die("cannot read %s: %s" % (rel, exc))
        match = FRONTMATTER.match(text)
        if not match:
            continue
        try:
            data = read_frontmatter(match.group(1))
        except YamlError as exc:
            die("%s has unreadable frontmatter (%s). Run tools/validate.py." % (rel, exc))
        files += 1

        status = data.get("status")
        if data.get("superseded_by") is not None and status != SUPERSEDED:
            problems.append((rel, "superseded_by is set but status is %r, not %r. "
                                  "A record that names its replacement is superseded."
                                  % (status, SUPERSEDED)))
        elif status == SUPERSEDED and data.get("superseded_by") is None:
            unpaired.append(rel)

        for key in KEYS:
            target = data.get(key)
            if target is None:
                continue
            checked += 1
            if not isinstance(target, str) or not target.startswith("/"):
                problems.append((rel, "%s is not a bundle path: %r" % (key, target)))
            elif not (ROOT / target.lstrip("/")).exists():
                problems.append((rel, "%s does not exist: %s" % (key, target)))

    if not files:
        die("found no records to check under %s" % ROOT)

    print("SUPERSESSION  links=%d  files=%d  broken=%d  unpaired=%d"
          % (checked, files, len(problems), len(unpaired)))
    for rel, detail in problems:
        print("  %s\n      %s" % (rel, detail))
    if unpaired:
        print("\nUNPAIRED (reported, not enforced -- a record may legitimately be\n"
              "retired with no named replacement; `deprecated` was folded into\n"
              "`superseded`, so this state has no other spelling. Needs a decision):")
        for rel in unpaired:
            print("   %s" % rel)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
