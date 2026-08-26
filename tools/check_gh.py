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
import platform
import re
import shutil
import socket
import subprocess
import sys
import urllib.parse

TIMEOUT = 20

# The read protocol calls `gh pr list --json ...` and `gh pr diff`. Distribution
# packages run years behind, and an old gh does not fail with a version error --
# it fails with an unrecognised-flag error, which reads like a broken command
# rather than a stale binary. Naming the floor turns that into one clear answer.
MIN_VERSION = (2, 0, 0)

# Set when the sweep cannot run. Each entry is (reason, remedy-lines).
problems = []


def find_gh():
    """Resolve the gh executable, including common Windows install locations.

    On Windows, GitHub CLI is often installed under Program Files by the MSI or
    package managers, but the current session PATH may not have picked up the
    shim yet. Reporting "not installed" in that case is wrong; the checker only
    needs an executable it can invoke, not a perfectly configured shell.
    """
    found = shutil.which("gh")
    if found is not None:
        return found

    if platform.system() != "Windows":
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


def shell_kind():
    """Which shell syntax the printed commands should be written in.

    platform.system() alone is not the answer on Windows. Git Bash and WSL are
    both common on Windows developer machines and both want the POSIX form;
    only a bare PowerShell or cmd session wants the other one. Git Bash sets
    MSYSTEM, and WSL reports Linux from platform.system() anyway, so the check
    is cheap.

    This matters more than it looks: `export X=y` and `cmd < file` are not
    merely unidiomatic in PowerShell, they are parse errors -- `<` is a
    reserved operator there. Advice that cannot be pasted is not advice.
    """
    if platform.system() != "Windows":
        return "posix"
    if os.environ.get("MSYSTEM") or os.environ.get("SHELL"):
        return "posix"
    return "powershell"


def is_root():
    """True when the process already has admin rights.

    os.geteuid does not exist on Windows -- calling it there is an
    AttributeError that takes the whole checker down, which is a poor way to
    report that gh is missing. Windows elevation is a UAC prompt rather than a
    command prefix, so there is nothing to prefix and False is the useful
    answer.
    """
    if not hasattr(os, "geteuid"):
        return False
    return os.geteuid() == 0


def set_env(name, value):
    """The env-var assignment for the shell we are talking to."""
    if shell_kind() == "powershell":
        return '$env:%s = "%s"' % (name, value)
    return 'export %s="%s"' % (name, value)


def platform_key():
    """(os, arch) in the spelling GitHub uses for release assets."""
    system = platform.system()
    machine = platform.machine().lower()
    arch = "arm64" if machine in ("arm64", "aarch64") else "amd64"
    if system == "Darwin":
        return "macOS", arch
    if system == "Windows":
        return "windows", arch
    return "linux", arch


def linux_family():
    """Which package manager this distribution actually uses.

    Several can be installed at once, so presence on PATH is not enough to pick
    between them -- os-release says which one owns the system.
    """
    try:
        with open("/etc/os-release", encoding="utf-8",
                  errors="replace") as handle:
            text = handle.read().lower()
    except OSError:
        return None
    fields = dict(
        (line.split("=", 1)[0], line.split("=", 1)[1].strip().strip('"'))
        for line in text.splitlines() if "=" in line
    )
    ident = " ".join((fields.get("id", ""), fields.get("id_like", "")))
    for family, markers in (
        ("apt", ("debian", "ubuntu", "mint", "pop")),
        ("dnf", ("fedora", "rhel", "centos", "rocky", "alma")),
        ("pacman", ("arch", "manjaro")),
        ("zypper", ("suse", "opensuse")),
        ("apk", ("alpine",)),
    ):
        if any(marker in ident for marker in markers):
            return family
    return None


def install_instructions():
    """The command for *this* machine, not a menu of commands for some machine.

    A list of six package managers is not an instruction; the reader still has
    to work out which line is theirs, and on a locked-down box the answer is
    often none of them. So: probe what is actually here, lead with that, and
    always carry the no-root path, because the machines that most need gh
    installed are the ones where you cannot become root to do it.
    """
    goos, arch = platform_key()
    has = lambda name: shutil.which(name) is not None
    root = "" if is_root() else ("sudo " if has("sudo") else "")

    preferred = []
    # Homebrew, winget, scoop and choco track upstream within days. The
    # distribution repositories are the ones that ship a gh old enough to fail
    # the version gate, so only they get the warning.
    lags = False
    if goos == "macOS":
        if has("brew"):
            preferred.append("brew install gh")
        elif has("port"):
            preferred.append("%sport install gh" % root)
            lags = True
    elif goos == "windows":
        for tool, command in (("winget", "winget install --id GitHub.cli"),
                              ("scoop", "scoop install gh"),
                              ("choco", "choco install gh")):
            if has(tool):
                preferred.append(command)
    else:
        family = linux_family()
        candidates = (
            ("apt", "%sapt install gh" % root),
            ("dnf", "%sdnf install gh" % root),
            ("yum", "%syum install gh" % root),
            ("pacman", "%spacman -S github-cli" % root),
            ("zypper", "%szypper install gh" % root),
            ("apk", "%sapk add github-cli" % root),
        )
        for tool, command in candidates:
            if tool == family and has(tool):
                preferred.append(command)
                lags = True
        if not preferred:
            for tool, command in candidates:
                if has(tool):
                    preferred.append(command)
                    lags = True
                    break

    lines = []
    if preferred:
        lines.append("This machine has a package manager. Ask the user to run:")
        for command in preferred:
            lines.append("  %s" % command)
        if any(command.startswith("sudo ") for command in preferred):
            lines.append("(That needs sudo and will prompt for a password, so the user must")
            lines.append(" run it themselves -- do not try to run it for them.)")
        if lags:
            lines.append("Distribution packages often ship a gh older than %d.%d.%d. If the"
                         % MIN_VERSION)
            lines.append("installed version fails this check, use the no-root install below.")
    else:
        lines.append("No package manager was found on this machine.")

    if shell_kind() == "powershell":
        # PowerShell 5.1 ships with Windows 10+, so Invoke-WebRequest,
        # Invoke-RestMethod and Expand-Archive are all present without
        # installing anything. Nothing here needs admin rights.
        lines.append("")
        lines.append("No-admin install into %LOCALAPPDATA%, in PowerShell:")
        lines.append('  $VER = (Invoke-RestMethod '
                     '"https://api.github.com/repos/cli/cli/releases/latest").tag_name.TrimStart("v")')
        lines.append('  $url = "https://github.com/cli/cli/releases/download/'
                     'v$VER/gh_${VER}_windows_%s.zip"' % arch)
        lines.append('  Invoke-WebRequest $url -OutFile "$env:TEMP\\gh.zip"')
        lines.append('  Expand-Archive "$env:TEMP\\gh.zip" '
                     '-DestinationPath "$env:LOCALAPPDATA\\gh" -Force')
        lines.append('  $env:PATH = "$env:LOCALAPPDATA\\gh\\bin;$env:PATH"'
                     '   # add via setx to persist')
        lines.append("That version lookup uses api.github.com. If the API is blocked but")
        lines.append("the web host is not, read the version off the releases page instead")
        lines.append("and substitute it, or download the .msi installer by hand.")
    elif shutil.which("curl") and (goos != "linux" or shutil.which("tar")):
        asset = "gh_${VER}_%s_%s.%s" % (goos, arch,
                                        "zip" if goos != "linux" else "tar.gz")
        lines.append("")
        lines.append("No-root install into ~/.local/bin -- needs no sudo, and is the one")
        lines.append("that works on a locked-down machine:")
        lines.append("  VER=$(curl -fsSI https://github.com/cli/cli/releases/latest \\")
        lines.append("        | awk -F'/v' '/^location:/{print $2}' | tr -d '\\r\\n')")
        lines.append("  mkdir -p ~/.local/bin")
        if goos == "linux":
            lines.append('  curl -fsSL "https://github.com/cli/cli/releases/download/v$VER/%s" \\'
                         % asset)
            lines.append("        | tar xz -C /tmp")
            lines.append("  mv /tmp/gh_${VER}_%s_%s/bin/gh ~/.local/bin/" % (goos, arch))
        else:
            # The macOS archive nests everything under gh_<ver>_macOS_<arch>/;
            # the Windows one does not -- it unpacks straight to bin/gh.exe.
            # Verified against the published archives, not assumed from the
            # naming, which is symmetric right up until it isn't.
            inner = ("bin/gh.exe" if goos == "windows"
                     else "gh_${VER}_%s_%s/bin/gh" % (goos, arch))
            lines.append("  curl -fsSL -o /tmp/gh.zip \\")
            lines.append('        "https://github.com/cli/cli/releases/download/v$VER/%s"' % asset)
            lines.append("  unzip -qo /tmp/gh.zip -d /tmp/ghx")
            lines.append("  mv /tmp/ghx/%s ~/.local/bin/" % inner)
        lines.append('  %s   # add to the shell rc to persist'
                     % set_env("PATH", "$HOME/.local/bin:$PATH"))
        lines.append("Both of those reach github.com. If egress is blocked they will fail too,")
        lines.append("and the answer is the git-only fallback in AGENTS.md, not a retry.")

    lines.append("")
    lines.append("Full instructions: https://github.com/cli/cli#installation")
    lines.append("Offline: download the %s %s package on a machine that has network"
                 % (goos, arch))
    lines.append("and copy it across; gh is a single static binary and needs no runtime.")
    return lines


def parse_version(text):
    match = re.search(r"gh version (\d+)\.(\d+)\.(\d+)", text)
    return tuple(int(part) for part in match.groups()) if match else None


def report(reason, *remedy):
    problems.append((reason, remedy))


def main():
    safe_console()
    token_var = next((v for v in ("GH_TOKEN", "GITHUB_TOKEN") if os.environ.get(v)), None)
    gh = find_gh()

    # 1. Is there a gh at all?
    if gh is None:
        report("gh is not installed -- it is not on PATH", *install_instructions())
        return finish()

    code, out = run(gh, "--version")
    if code is None or code != 0:
        report(
            "gh is on PATH but will not run (%s)" % first_line(out),
            "The binary is present but unusable -- often a sandbox blocking exec or a",
            "broken install. Reinstall, or use the git-only fallback in AGENTS.md.",
        )
        return finish()

    found = parse_version(out)
    if found is not None and found < MIN_VERSION:
        report(
            "gh %s is too old -- the sweep needs %s or newer"
            % (".".join(str(n) for n in found),
               ".".join(str(n) for n in MIN_VERSION)),
            *install_instructions()
        )
        return finish()

    # 2. Is it authenticated? This is local -- it reads config and keychain, and
    #    on a sandboxed machine the keychain read is itself a common failure.
    code, out = run(gh, "auth", "status")
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
                "  %s" % set_env("GH_TOKEN", "<fine-grained token, Pull requests: read>"),
                "Create one at https://github.com/settings/tokens",
            )
        else:
            # `<` is a reserved operator in PowerShell, so the redirect form
            # of --with-token is a parse error there rather than a command
            # that merely fails. Pipe instead.
            piped = ("Get-Content token.txt | gh auth login --with-token"
                     if shell_kind() == "powershell"
                     else "gh auth login --with-token < token.txt")
            report(
                "gh is installed but not authenticated (%s)" % first_line(out),
                "Interactive login -- the user must run this themselves, it opens a browser:",
                "  gh auth login",
                "Non-interactive, and the right one on a sandboxed or headless machine:",
                "  %s" % set_env("GH_TOKEN", "<fine-grained token, Pull requests: read>"),
                "  # or: %s" % piped,
                "Create a token at https://github.com/settings/tokens",
            )
        return finish()

    # 3. Does this directory resolve to a GitHub repo, and does the API answer?
    #    One call tests network egress, token validity and remote configuration
    #    together, which is fine -- they are distinguished by the error text.
    code, out = run(gh, "repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner")
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
    code, out = run(gh, "pr", "list", "--state", "open", "--limit", "1")
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
