#!/usr/bin/env python3
"""`gh` can actually sweep the open-pull-request queue from this machine.

    python3 tools/check_gh.py

Exit codes
  0  the check ran and the queue is reachable
  1  the check ran and the queue is NOT reachable -- the reason and the remedy
     are printed, one per line, and are meant to be relayed to the user verbatim
  2  the check could not run

Standard library only.

Why this exists
---------------
The read protocol makes the open-PR sweep a read step. On a locked-down machine
that step fails in at least five different ways -- `gh` absent, `gh` present but
never logged in, credentials in a keychain the sandbox will not open, outbound
network denied, no GitHub remote at all -- and every one of them produces the
same thing at the call site: an error on stderr and no pull requests.

An unchecked queue and an empty queue look identical downstream. That is the
failure this repository keeps describing, and the sweep is where it bites
hardest, because the natural recovery -- fall back to searching the working
tree -- is exactly the wrong move and looks exactly like success.

So the check runs first, separates the five cases, and names the remedy for the
one it found. What it cannot do is decide what to do about it; that judgement
belongs to the agent and to the user, and lives in AGENTS.md.
"""

import os
import shutil
import socket
import subprocess
import sys
import urllib.parse

TIMEOUT = 20

# Set when the sweep cannot run. Each entry is (reason, remedy-lines).
problems = []


def die(message):
    sys.stderr.write("check_gh: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


def run(*args):
    """Return (returncode, stdout+stderr). A missing binary is not fatal here."""
    try:
        done = subprocess.run(args, capture_output=True, timeout=TIMEOUT)
    except FileNotFoundError:
        return None, "not found on PATH"
    except subprocess.TimeoutExpired:
        return None, "timed out after %ds" % TIMEOUT
    except OSError as exc:
        return None, str(exc)
    out = (done.stdout + done.stderr).decode("utf-8", "replace").strip()
    return done.returncode, out


def looks_like_network(text):
    lowered = text.lower()
    return any(marker in lowered for marker in (
        "dial tcp", "no such host", "connection refused", "network is unreachable",
        "i/o timeout", "timed out", "tls", "proxy", "certificate", "eof",
        "temporary failure in name resolution", "could not resolve",
    ))


def api_reachable():
    """Can a TCP connection to the API endpoint be opened at all?

    This exists because `gh auth status` cannot tell the two apart. With
    outbound traffic blocked it reports "The token in keyring is invalid" --
    a confident, specific, wrong diagnosis that sends someone to re-run
    `gh auth login`, which cannot succeed either and for the same reason.

    A plain TCP connect answers the question gh is guessing at. The host is
    api.github.com; a GitHub Enterprise host will show as unreachable here,
    which is a false alarm worth having over a silent misdiagnosis.
    """
    host, port = "api.github.com", 443
    proxy = next((os.environ[v] for v in ("HTTPS_PROXY", "https_proxy",
                                          "ALL_PROXY", "all_proxy")
                  if os.environ.get(v)), None)
    if proxy:
        parsed = urllib.parse.urlparse(proxy if "://" in proxy else "http://" + proxy)
        host = parsed.hostname or host
        port = parsed.port or (443 if parsed.scheme == "https" else 80)
    try:
        socket.create_connection((host, port), timeout=5).close()
        return True, "%s:%d" % (host, port)
    except OSError as exc:
        return False, "%s:%d unreachable (%s)" % (host, port, exc)


def report_network(detail):
    proxy_set = any(os.environ.get(v) for v in ("HTTPS_PROXY", "https_proxy",
                                                "ALL_PROXY", "all_proxy"))
    report(
        "gh cannot reach the GitHub API -- outbound network denied (%s)" % detail,
        "This is the usual sandbox case, and no login will fix it. Note that gh",
        "itself misreports this as an invalid token, so do not follow that advice.",
        ("The proxy in HTTPS_PROXY/ALL_PROXY is the thing refusing the connection."
         if proxy_set else
         "Ask the user whether api.github.com egress can be allowed for this session,"),
        ("Check it is running and correct." if proxy_set else
         "or set HTTPS_PROXY if the machine has an approved proxy."),
        "If it cannot be opened, use the git-only fallback in AGENTS.md and say the",
        "queue is unswept.",
    )


def report(reason, *remedy):
    problems.append((reason, remedy))


def main():
    token_var = next((v for v in ("GH_TOKEN", "GITHUB_TOKEN") if os.environ.get(v)), None)

    # 1. Is there a gh at all?
    if shutil.which("gh") is None:
        report(
            "gh is not on PATH",
            "Install it: `brew install gh` (macOS), `sudo apt install gh` (Debian/Ubuntu),",
            "or see https://github.com/cli/cli#installation for an offline package.",
            "If the sandbox forbids installing, use the git-only fallback in AGENTS.md.",
        )
        return finish()

    code, out = run("gh", "--version")
    if code is None or code != 0:
        report(
            "gh is on PATH but will not run (%s)" % first_line(out),
            "The binary is present but unusable -- often a sandbox blocking exec or a",
            "broken install. Reinstall, or use the git-only fallback in AGENTS.md.",
        )
        return finish()

    # 2. Is it authenticated? This is local -- it reads config and keychain, and
    #    on a sandboxed machine the keychain read is itself a common failure.
    code, out = run("gh", "auth", "status")
    if code != 0:
        ok, detail = api_reachable()
        if not ok:
            report_network(detail)
        elif token_var:
            report(
                "%s is set but gh does not accept it (%s)" % (token_var, first_line(out)),
                "Check the token has not expired and carries the `repo` scope.",
                "Verify with: `gh auth status`",
            )
        elif any(m in out.lower() for m in ("keychain", "keyring", "secret")):
            report(
                "gh has credentials it cannot read -- a sandboxed keychain (%s)" % first_line(out),
                "A sandbox usually cannot open the OS keychain even when the login",
                "succeeded outside it. Use a token in the environment instead:",
                "  export GH_TOKEN=<a fine-grained token with `repo` read scope>",
                "Create one at https://github.com/settings/tokens",
            )
        else:
            report(
                "gh is installed but not authenticated (%s)" % first_line(out),
                "Interactive login -- the user must run this themselves, it opens a browser:",
                "  gh auth login",
                "Non-interactive, and the right one on a sandboxed or headless machine:",
                "  export GH_TOKEN=<a fine-grained token with `repo` read scope>",
                "  # or: gh auth login --with-token < token.txt",
                "Create a token at https://github.com/settings/tokens",
            )
        return finish()

    # 3. Does this directory resolve to a GitHub repo, and does the API answer?
    #    One call tests network egress, token validity and remote configuration
    #    together, which is fine -- they are distinguished by the error text.
    code, out = run("gh", "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner")
    if code != 0:
        ok, detail = api_reachable()
        if looks_like_network(out) or not ok:
            report_network(first_line(out) if looks_like_network(out) else detail)
        elif "no git remotes" in out.lower() or "not a git repository" in out.lower():
            report(
                "no GitHub remote is configured here (%s)" % first_line(out),
                "The queue lives on a remote this clone does not have.",
                "  git remote -v          # what this clone points at",
                "  gh repo set-default    # if there are several",
            )
        else:
            report(
                "gh cannot resolve this repository (%s)" % first_line(out),
                "  gh repo set-default    # pick the upstream this clone belongs to",
            )
        return finish()

    repo = out.strip()

    # 4. And the actual call the read protocol makes. Authentication can be
    #    valid while the token lacks the scope to list pull requests.
    code, out = run("gh", "pr", "list", "--state", "open", "--limit", "1")
    if code != 0:
        report(
            "gh is authenticated for %s but cannot list pull requests (%s)" % (repo, first_line(out)),
            "Usually a token missing the `repo` (or Pull requests: read) scope.",
            "  gh auth refresh -s repo      # for an OAuth login",
            "  # or reissue the token with Pull requests: read",
        )
        return finish()

    print("GH  ok  repo=%s  auth=%s  queue=reachable"
          % (repo, token_var or "gh login"))
    return 0


def first_line(text):
    """The most informative line, not merely the first.

    `gh auth status` leads with the hostname and puts the diagnosis several
    lines down, so taking line one reports "github.com" as if it were a reason.
    """
    if not text:
        return "no output"
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    if not lines:
        return "no output"
    markers = ("error", "failed", "missing", "not logged in", "denied",
               "invalid", "expired", "could not", "unable", "x ")
    for line in lines:
        lowered = line.lower().lstrip("x ").strip()
        if any(m in line.lower() for m in markers) and lowered:
            return line
    return lines[-1]


def finish():
    print("GH  UNAVAILABLE  problems=%d" % len(problems))
    for reason, remedy in problems:
        print("  %s" % reason)
        for line in remedy:
            print("      %s" % line)
    print("  The open-PR sweep did NOT run. Say so in your answer -- an unswept")
    print("  queue and an empty queue are not the same claim.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
