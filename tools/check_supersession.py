#!/usr/bin/env python3
"""Every supersedes / superseded_by target must exist.

    python3 tools/check_supersession.py

Exit codes
  0  the check ran and every supersession target resolves
  1  the check ran and something does not resolve
  2  the check could not run

Standard library only. Checks that the target file exists, which is what breaks
a reader following the chain. It deliberately does not check that the pair
points back at each other, nor that status agrees -- those are decisions still
open, and a check that guesses at them would be enforcing an unmade decision.
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


def die(message):
    sys.stderr.write("check_supersession: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


def main():
    problems, checked, files = [], 0, 0
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
        for key in KEYS:
            target = data.get(key)
            if target is None:
                continue
            checked += 1
            if not isinstance(target, str) or not target.startswith("/"):
                problems.append((rel, "%s is not a bundle path: %r" % (key, target)))
            elif not (ROOT / target.lstrip("/")).exists():
                problems.append((rel, "%s does not exist: %s" % (key, target)))

    print("SUPERSESSION  links=%d  files=%d  unresolved=%d"
          % (checked, files, len(problems)))
    for rel, detail in problems:
        print("  %s\n      %s" % (rel, detail))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
