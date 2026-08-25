#!/usr/bin/env python3
"""Every markdown link to a file inside this bundle must resolve.

    python3 tools/check_links.py

Exit codes
  0  the check ran and every in-bundle link resolves
  1  the check ran and something does not resolve
  2  the check could not run

Standard library only.

Scope. Links are bundle-relative absolute paths by convention -- /concepts/... ,
rooted at the repository, not at the file. External URLs and pure anchors are
not this check's business. A target that is neither absolute nor external is
resolved relative to the linking file's directory, so an inverted link, with the
path in the text and something else in the target, is caught rather than skipped
for not matching the convention.
"""

import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

try:
    from validate import SKIP, SKIP_NAMES
except ImportError as exc:                                   # pragma: no cover
    sys.stderr.write("check_links: CANNOT RUN: cannot import validate.py: %s\n" % exc)
    raise SystemExit(2)

ROOT = pathlib.Path(__file__).resolve().parent.parent
RESOLUTION_SKIP = SKIP | {"templates"}       # see the note in check_sources.py

# [text](target). Targets containing spaces or nested parens are out of scope.
LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
EXTERNAL = re.compile(r"^(?:[a-z][a-z0-9+.-]*:|//|mailto:|#)", re.I)


def die(message):
    sys.stderr.write("check_links: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


def target_path(rel, target):
    """Where a link target points, or None if it is not ours to check."""
    target = target.split("#", 1)[0]
    if not target or EXTERNAL.match(target):
        return None
    if target.startswith("/"):
        return ROOT / target.lstrip("/")
    return (ROOT / rel).parent / target


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
        files += 1
        for number, line in enumerate(text.split("\n"), 1):
            for target in LINK.findall(line):
                resolved = target_path(rel, target)
                if resolved is None:
                    continue
                checked += 1
                if not resolved.exists():
                    kind = "dangling" if target.startswith("/") else "not a bundle path"
                    problems.append((rel, number, kind, target))

    print("LINKS  checked=%d  files=%d  unresolved=%d" % (checked, files, len(problems)))
    for rel, number, kind, target in problems:
        print("  %s:%d\n      %s: %s" % (rel, number, kind, target))
    if not checked:
        die("found no in-bundle links under %s" % ROOT)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
