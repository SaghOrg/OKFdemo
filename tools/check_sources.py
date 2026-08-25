#!/usr/bin/env python3
"""Every sources[].resource must be a path into /_sources/ that exists.

    python3 tools/check_sources.py

Exit codes
  0  the check ran and every reference resolves
  1  the check ran and something does not resolve
  2  the check could not run

Standard library only. The frontmatter reader is imported from validate.py
rather than reimplemented -- two readers would drift, and the drift would be
silent.

Moved here from _build/, which is gitignored, so a fresh clone could not run it.
The original used PyYAML from a gitignored virtualenv.
"""

import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

try:
    from validate import FRONTMATTER, SKIP, SKIP_NAMES, YamlError, read_frontmatter
except ImportError as exc:                                   # pragma: no cover
    sys.stderr.write("check_sources: CANNOT RUN: cannot import validate.py: %s\n" % exc)
    raise SystemExit(2)

ROOT = pathlib.Path(__file__).resolve().parent.parent
PREFIX = "/_sources/"

# Types exempt from carrying provenance at all. An `index` record is generated
# from the file tree and has no /_sources/ origin; requiring one would force a
# fabricated citation, which is the thing the provenance rule exists to stop.
# Everything else must cite something.
NO_PROVENANCE_TYPES = {"index"}

# `templates` is validated for schema conformance but excluded from resolution:
# it is an exemplar, and its references are placeholders on purpose. Excluding
# the template rather than teaching the checker to recognise placeholder syntax
# means an unfilled *copy* of it, sitting in decisions/, is still caught.
RESOLUTION_SKIP = SKIP | {"templates"}


def die(message):
    sys.stderr.write("check_sources: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


def records():
    for path in sorted(ROOT.rglob("*.md")):
        rel = path.relative_to(ROOT)
        if rel.parts[0] in RESOLUTION_SKIP or rel.name in SKIP_NAMES:
            continue
        yield rel, path


def main():
    problems, checked, files = [], 0, 0
    for rel, path in records():
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
            # validate.py owns reporting malformed frontmatter; refuse to guess.
            die("%s has unreadable frontmatter (%s). Run tools/validate.py." % (rel, exc))
        files += 1

        sources = data.get("sources")
        if not sources and data.get("type") not in NO_PROVENANCE_TYPES:
            problems.append((rel, -1, "no `sources` key: a record that omits it "
                                      "entirely cites nothing, and the schema's "
                                      "minItems cannot fire on an absent key"))
        for n, source in enumerate(sources or []):
            resource = (source or {}).get("resource")
            checked += 1
            if not isinstance(resource, str) or not resource:
                problems.append((rel, n, "sources[%d].resource is missing" % n))
            elif not resource.startswith(PREFIX):
                problems.append((rel, n, "not under %s: %s" % (PREFIX, resource)))
            elif not (ROOT / resource.lstrip("/")).exists():
                problems.append((rel, n, "does not exist: %s" % resource))

    print("SOURCES  refs=%d  files=%d  unresolved=%d" % (checked, files, len(problems)))
    for rel, _, detail in problems:
        print("  %s\n      %s" % (rel, detail))
    if not files:
        die("found no records to check under %s" % ROOT)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
