#!/usr/bin/env python3
"""Scan for credentials. Used by the pre-commit hook and, later, by CI.

    python3 tools/check_secrets.py --staged    # what is about to be committed
    python3 tools/check_secrets.py --all       # every tracked file
    python3 tools/check_secrets.py FILE...     # specific paths

Exit codes
  0  the scan ran and found nothing
  1  the scan ran and found something
  2  the scan could not run

Exit 0 never means "could not check". Anything unexpected -- a git command that
fails, a file that cannot be read -- exits 2, so a hook wired to this blocks
rather than waves the commit through.

/_sources/ and /_canon/ are excluded. They are read-only archives that already
contain planted credential fixtures; scanning them would fail every commit.
"""

import re
import subprocess
import sys

EXCLUDED_PREFIXES = ("_sources/", "_canon/")

# A line carrying this marker is skipped. It leaves an auditable, greppable
# record in the file, unlike `git commit --no-verify`, which silently disables
# every hook at once.
ALLOWLIST_MARKER = "pragma: allowlist secret"

# Keys whose assigned value is a secret. Split rather than written as one
# literal so that this file does not match its own generic rule.
SECRET_KEYS = [
    "password", "passwd", "pwd", "passphrase",
    "secret", "client[_-]?secret", "secret[_-]?key",
    "api[_-]?key", "apikey", "access[_-]?key",
    "auth[_-]?token", "access[_-]?token", "refresh[_-]?token",
    "private[_-]?key", "aws[_-]?secret[_-]?access[_-]?key",
    "accountkey", "sas[_-]?token",
]

# Values that are obviously not real. Matched against the captured value.
PLACEHOLDER = re.compile(
    r"""^(?:
          [<{$%]                      # <yours>, ${VAR}, %s, {{ }}
        | \*+$ | x{3,}$ | \.{3,}$
        | (?:change[_-]?me|placeholder|redacted|example|sample|dummy|todo
           |your[_-]?\w+|fake|test|none|null|nil|empty|unset|n/?a)$
    )""",
    re.I | re.X,
)

RULES = [
    # --- generic: an assignment whose key names a secret ----------------
    ("generic secret assignment",
     re.compile(r"\b(?:" + "|".join(SECRET_KEYS) + r")\b\s*[:=]\s*"
                r"[\"']?(?P<value>[^\s\"';,#|]{4,})", re.I)),

    # --- credentials inline in a connection string -----------------------
    ("jdbc url with inline credentials",
     re.compile(r"jdbc:[a-z0-9]+:[^\s\"']*[?;&](?:user|username|password|pwd)\s*=\s*"
                r"(?P<value>[^\s;&\"']+)", re.I)),
    ("oracle thin url with user/password",
     re.compile(r"jdbc:oracle:thin:(?P<value>[^/@\s\"']+/[^@\s\"']+)@")),
    ("url with embedded credentials",
     re.compile(r"\b[a-z][a-z0-9+.\-]*://[^/\s:@\"']+:(?P<value>[^/\s@\"']+)@")),

    # --- key material ----------------------------------------------------
    ("private key header",
     re.compile(r"(?P<value>-----BEGIN(?: [A-Z0-9]+)* PRIVATE KEY(?: BLOCK)?-----)")),
    ("PuTTY private key",
     re.compile(r"(?P<value>PuTTY-User-Key-File-\d)")),

    # --- provider tokens -------------------------------------------------
    ("AWS access key id", re.compile(r"\b(?P<value>(?:AKIA|ASIA)[0-9A-Z]{16})\b")),
    ("GitHub token", re.compile(r"\b(?P<value>gh[pousr]_[A-Za-z0-9]{36,})\b")),
    ("GitHub fine-grained token",
     re.compile(r"\b(?P<value>github_pat_[A-Za-z0-9_]{22,})\b")),
    ("Slack token", re.compile(r"\b(?P<value>xox[abprs]-[A-Za-z0-9-]{10,})\b")),
    ("Slack webhook",
     re.compile(r"(?P<value>https://hooks\.slack\.com/services/[A-Za-z0-9/+_-]{20,})")),
    ("Google API key", re.compile(r"\b(?P<value>AIza[0-9A-Za-z_\-]{35})\b")),
    ("Stripe key", re.compile(r"\b(?P<value>[sr]k_(?:live|test)_[A-Za-z0-9]{16,})\b")),
    ("Anthropic API key", re.compile(r"\b(?P<value>sk-ant-[A-Za-z0-9_\-]{20,})\b")),
    ("OpenAI-style API key", re.compile(r"\b(?P<value>sk-[A-Za-z0-9]{32,})\b")),
    ("npm token", re.compile(r"\b(?P<value>npm_[A-Za-z0-9]{36})\b")),
    ("JSON web token",
     re.compile(r"\b(?P<value>eyJ[A-Za-z0-9_-]{8,}\.eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]+)")),
]

# Files that should not be committed whatever is inside them.
FILENAME_RULES = [
    ("private key file",
     re.compile(r"(?:^|/)id_(?:rsa|dsa|ecdsa|ed25519)$")),
    ("key or keystore file",
     re.compile(r"\.(?:pem|p12|pfx|jks|keystore|ppk|asc)$", re.I)),
    ("environment file",
     re.compile(r"(?:^|/)\.env(?!\.(?:example|sample|template|dist)$)(?:\..+)?$")),
]


def die(message):
    sys.stderr.write("check_secrets: CANNOT RUN: %s\n" % message)
    raise SystemExit(2)


def git(*args):
    try:
        done = subprocess.run(("git",) + args, capture_output=True)
    except OSError as exc:
        die("could not run git: %s" % exc)
    if done.returncode != 0:
        die("git %s failed: %s" % (" ".join(args), done.stderr.decode("utf-8", "replace").strip()))
    return done.stdout


def staged_paths():
    out = git("diff", "--cached", "--name-only", "-z", "--diff-filter=ACMR")
    return [p.decode("utf-8", "replace") for p in out.split(b"\0") if p]


def tracked_paths():
    out = git("ls-files", "-z")
    return [p.decode("utf-8", "replace") for p in out.split(b"\0") if p]


def staged_blob(path):
    return git("show", ":" + path)


def scan_text(path, text):
    findings = []
    for number, line in enumerate(text.splitlines(), 1):
        if ALLOWLIST_MARKER in line:
            continue
        for label, rule in RULES:
            match = rule.search(line)
            if not match:
                continue
            value = match.group("value")
            if PLACEHOLDER.match(value):
                continue
            findings.append((path, number, label, value))
            break          # one finding per line is enough to block it
    return findings


def scan(paths, read):
    findings = []
    for path in sorted(paths):
        if path.startswith(EXCLUDED_PREFIXES):
            continue
        for label, rule in FILENAME_RULES:
            if rule.search(path):
                findings.append((path, 0, label, path.rsplit("/", 1)[-1]))
        try:
            blob = read(path)
        except OSError as exc:
            die("cannot read %s: %s" % (path, exc))
        if b"\0" in blob:
            continue       # binary; the filename rules above still applied
        findings.extend(scan_text(path, blob.decode("utf-8", "replace")))
    return findings


def redact(value):
    if len(value) <= 8:
        return value[:2] + "*" * (len(value) - 2)
    return value[:4] + "*" * (len(value) - 8) + value[-4:]


def main(argv):
    if argv[:1] == ["--staged"]:
        paths, read = staged_paths(), staged_blob
    elif argv[:1] == ["--all"]:
        paths, read = tracked_paths(), lambda p: open(p, "rb").read()
    elif argv and not argv[0].startswith("-"):
        paths, read = argv, lambda p: open(p, "rb").read()
    else:
        die("usage: check_secrets.py [--staged | --all | FILE...]")

    findings = scan(paths, read)
    if not findings:
        return 0

    sys.stderr.write(
        "\nCOMMIT BLOCKED: %d credential-shaped string(s) found in staged content.\n\n"
        % len(findings))
    for path, number, label, value in findings:
        where = "%s:%d" % (path, number) if number else path
        sys.stderr.write("  %s\n      %s: %s\n" % (where, label, redact(value)))
    sys.stderr.write(
        "\nRemove the value, or move it to a secret store and reference it.\n"
        "If it is genuinely not a secret, append this to the line:  %s\n"
        "Do not reach for --no-verify; it disables every hook, and CI checks this too.\n\n"
        % ALLOWLIST_MARKER)
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
