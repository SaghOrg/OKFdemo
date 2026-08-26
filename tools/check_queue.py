#!/usr/bin/env python3
"""No open pull request has already landed by some other route.

    python3 tools/check_queue.py

Exit codes
  0  the check ran and every open pull request still has work to do
  1  the check ran and at least one open PR is already in main -- it was
     cherry-picked or retyped rather than merged, and is now dead weight
  2  the check could not run

Standard library only. Uses git transport, not the API, so it still works
where check_gh.py reports the network is blocked.

Why this exists
---------------
The read protocol sends you to the queue before you write, so you will find
the pull request that already does what you were about to do. The tempting
move at that point is to take its content -- cherry-pick the commit, or just
retype the file -- and carry on in your own branch.

That produces a repository where the content is in main and the pull request
is still open, and nothing about the queue shows that the second fact is now
meaningless. The PR cannot be reviewed into anything; it just sits there. Do
it a few times and the queue is mostly ghosts, which is how a queue stops
being read at all.

It also skips the review. In this repository the merge IS the verification
event -- see AGENTS.md -- and content that arrives by cherry-pick arrives
having been approved by nobody, while looking exactly like ordinary work.

Two signals, because one is not enough
--------------------------------------
  patch-id   `git cherry` marks a commit `-` when an equivalent patch is
             already upstream. Catches a literal `git cherry-pick`.
  content    every file the PR changed is now byte-identical to main.
             Catches a retype, which has a different patch-id and which
             `git cherry` therefore misses completely.
"""

import json
import os
import re
import shutil
import subprocess
import sys

TIMEOUT = 60
MAIN = "origin/main"


def find_gh():
    found = shutil.which("gh")
    if found is not None:
        return found

    if sys.platform != "win32":
        return None

    candidates = []
    for base in filter(None, (
        os.environ.get("ProgramFiles"),
        os.environ.get("ProgramW6432"),
    )):
        candidates.append(os.path.join(base, "GitHub CLI", "gh.exe"))

    local = os.environ.get("LOCALAPPDATA")
    if local:
        candidates.extend((
            os.path.join(local, "Programs", "GitHub CLI", "gh.exe"),
            os.path.join(local, "Microsoft", "WinGet", "Links", "gh.exe"),
            os.path.join(local, "gh", "bin", "gh.exe"),
        ))

    seen = set()
    for candidate in candidates:
        folded = os.path.normcase(candidate)
        if folded in seen:
            continue
        seen.add(folded)
        if os.path.isfile(candidate):
            return candidate
    return None


def safe_console():
    """Make stdout survive text this console cannot encode.

    A Windows console still defaults to a legacy code page, and printing a
    pull-request title or a gh error message containing one character it
    cannot represent raises UnicodeEncodeError. The checker would then die
    reporting somebody else's punctuation instead of reporting the queue --
    a check that did not run, wearing the costume of a crash.
    """
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, OSError, ValueError):
            pass  # Python without reconfigure, or a redirected non-tty stream.


def die(message):
    sys.stderr.write("check_queue: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


def run(*args, **kwargs):
    check = kwargs.pop("check", True)
    try:
        done = subprocess.run(args, capture_output=True, timeout=TIMEOUT)
    except FileNotFoundError:
        die("%s not found on PATH" % args[0])
    except subprocess.TimeoutExpired:
        die("%s timed out after %ds" % (args[0], TIMEOUT))
    out = done.stdout.decode("utf-8", "replace")
    err = done.stderr.decode("utf-8", "replace")
    if check and done.returncode != 0:
        die("%s failed: %s" % (" ".join(args[:3]), err.strip() or out.strip()))
    return done.returncode, out, err


def git(*args, **kwargs):
    return run("git", *args, **kwargs)


def open_pull_requests():
    """(number, title, author) for each open PR.

    Prefers gh, because only the API knows which refs are *open*. Falls back
    to refs/pull, which cannot tell open from closed-unmerged and so
    over-reports -- stated in the output rather than hidden, since a false
    alarm here is much cheaper than a missed ghost.
    """
    gh = find_gh()
    if gh:
        code, out, _ = run(gh, "pr", "list", "--state", "open",
                           "--json", "number,title,author", check=False)
        if code == 0:
            try:
                return [(pr["number"], pr["title"],
                         (pr.get("author") or {}).get("login", "unknown"))
                        for pr in json.loads(out)], "gh"
            except (ValueError, KeyError):
                pass

    git("fetch", "--quiet", "origin", "+refs/pull/*/head:refs/remotes/origin/pr/*",
        check=False)
    _, out, _ = git("for-each-ref", "--format=%(refname)", "refs/remotes/origin/pr/")
    numbers = []
    for ref in out.splitlines():
        match = re.search(r"/pr/(\d+)$", ref.strip())
        if match:
            numbers.append(int(match.group(1)))
    return [(n, "(title needs gh)", "(author needs gh)")
            for n in sorted(numbers)], "refs/pull"


def head_of(number, source):
    ref = "refs/remotes/origin/pr/%d" % number
    code, _, _ = git("rev-parse", "--verify", "--quiet", ref, check=False)
    if code != 0:
        git("fetch", "--quiet", "origin",
            "+refs/pull/%d/head:%s" % (number, ref), check=False)
    code, out, _ = git("rev-parse", "--verify", "--quiet", ref, check=False)
    return out.strip() if code == 0 else None


def changed_files(base, head):
    _, out, _ = git("diff", "--name-only", "%s...%s" % (base, head))
    return [line for line in out.splitlines() if line.strip()]


def blob_of(rev, path):
    code, out, _ = git("rev-parse", "%s:%s" % (rev, path), check=False)
    return out.strip() if code == 0 else None


def main():
    safe_console()
    git("rev-parse", "--git-dir")
    git("fetch", "--quiet", "origin", "main", check=False)

    code, _, _ = git("rev-parse", "--verify", "--quiet", MAIN, check=False)
    if code != 0:
        die("no %s -- this clone has no GitHub remote to compare against" % MAIN)

    prs, source = open_pull_requests()
    if not prs:
        print("QUEUE  open=0  landed=0   (source: %s)" % source)
        return 0

    landed = []
    skipped = []

    for number, title, author in prs:
        head = head_of(number, source)
        if head is None:
            skipped.append((number, "head ref could not be fetched"))
            continue

        code, _, _ = git("merge-base", "--is-ancestor", head, MAIN, check=False)
        if code == 0:
            continue  # genuinely merged; if gh says it is open, that is gh's business

        _, base, _ = git("merge-base", MAIN, head)
        base = base.strip()
        files = changed_files(base, head)
        if not files:
            skipped.append((number, "changes nothing against its own base"))
            continue

        # Signal 1 -- an equivalent patch is already upstream.
        _, out, _ = git("cherry", MAIN, head, check=False)
        picked = [line for line in out.splitlines() if line.startswith("-")]
        by_patch_id = bool(picked) and len(picked) == len(
            [line for line in out.splitlines() if line[:1] in "+-"])

        # Signal 2 -- every file it touches already matches main byte for byte.
        by_content = all(blob_of(head, path) == blob_of(MAIN, path)
                         for path in files)

        if by_patch_id or by_content:
            # Report the evidence, not a story about intent. A faithful retype
            # of a whole change produces the same patch-id as a cherry-pick of
            # it, so these two signals cannot tell you which route was taken --
            # only that the content arrived without this PR being merged.
            how = ("an equivalent patch is already upstream" if by_patch_id
                   else "every file it touches already matches main")
            landed.append((number, title, author, how, len(files)))

    print("QUEUE  open=%d  landed=%d  skipped=%d   (source: %s)"
          % (len(prs), len(landed), len(skipped), source))

    for number, title, author, how, count in landed:
        print("  #%d is already in main -- %s" % (number, how))
        print("      %s" % title)
        print("      opened by %s; %d file(s); merging it would change nothing"
              % (author, count))
        print("      The review this PR was waiting for never happened.")
        print("      Closing it is the author's or the user's call, not yours.")

    for number, reason in skipped:
        print("  #%d not assessed -- %s" % (number, reason))

    if source == "refs/pull":
        print("  NOTE: gh was unavailable, so this used refs/pull, which cannot")
        print("  tell an open PR from a closed-unmerged one. Expect over-reporting.")

    return 1 if landed else 0


if __name__ == "__main__":
    sys.exit(main())
