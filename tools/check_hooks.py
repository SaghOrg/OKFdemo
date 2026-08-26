#!/usr/bin/env python3
"""The hooks are present, and a fresh clone will get them executable.

    python3 tools/check_hooks.py

Exit codes
  0  the check ran and the hooks are as declared
  1  the check ran and a hook is missing or would arrive non-executable
  2  the check could not run

Standard library only.

This is one of the two things CI can assert that a hook cannot, because a hook
cannot verify its own absence. Step 4 established that git skips a hook without
its executable bit **silently, with exit 0** -- so a stripped permission bit
disables the check invisibly, and the only place that can be noticed is a job
running somewhere the author does not control.

Both the working-tree permission and git's recorded mode are checked. The
recorded mode is the one that matters: it is what a fresh clone receives.
"""

import os
import pathlib
import platform
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
HOOKS_DIR = ROOT / ".githooks"

# The hooks this repository declares. A hook that disappears is as much a
# problem as one that is not executable, and neither is visible from inside a
# hook that did not run.
EXPECTED = ("pre-commit", "pre-push")

EXECUTABLE_MODE = "100755"


def die(message):
    sys.stderr.write("check_hooks: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


def git(*args):
    try:
        done = subprocess.run(("git",) + args, capture_output=True, cwd=str(ROOT))
    except OSError as exc:
        die("could not run git: %s" % exc)
    if done.returncode != 0:
        die("git %s failed: %s" % (" ".join(args),
                                   done.stderr.decode("utf-8", "replace").strip()))
    return done.stdout.decode("utf-8", "replace")


def main():
    if not HOOKS_DIR.is_dir():
        die("no .githooks directory at %s" % HOOKS_DIR)

    recorded = {}
    for line in git("ls-files", "-s", ".githooks").splitlines():
        if not line.strip():
            continue
        mode, _, rest = line.partition(" ")
        path = rest.split("\t", 1)[-1]
        recorded[pathlib.PurePosixPath(path).name] = mode

    problems = []
    unchecked = []

    for name in EXPECTED:
        if name not in recorded:
            problems.append("%s is declared but not tracked in .githooks/" % name)

    present = sorted(p for p in HOOKS_DIR.iterdir() if p.is_file())
    if not present:
        die("%s contains no files" % HOOKS_DIR)

    for path in present:
        name = path.name
        mode = recorded.get(name)
        if mode is None:
            problems.append("%s is present but untracked, so no clone will get it" % name)
            continue
        if mode != EXECUTABLE_MODE:
            problems.append("%s is recorded as %s, not %s -- a fresh clone would "
                            "get it non-executable and git would skip it silently"
                            % (name, mode, EXECUTABLE_MODE))
        # os.access(..., X_OK) is meaningless on Windows: NTFS has no execute
        # bit, and the call returns True for anything that exists. Running it
        # there would be a check that cannot fail, which reads as assurance and
        # provides none -- the failure this repository warns about elsewhere.
        # The recorded mode above is the one that matters anyway; it is what a
        # fresh clone receives, on any platform.
        if platform.system() == "Windows":
            unchecked.append(name)
        elif not os.access(str(path), os.X_OK):
            problems.append("%s is not executable in the working tree" % name)

    print("HOOKS  expected=%d  present=%d  problems=%d"
          % (len(EXPECTED), len(present), len(problems)))
    for detail in problems:
        print("  %s" % detail)
    if unchecked:
        print("  NOTE: on Windows the working-tree executable bit is not a real")
        print("  property, so it was not checked for: %s" % ", ".join(unchecked))
        print("  The recorded git mode was checked, and that is the one a clone gets.")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
