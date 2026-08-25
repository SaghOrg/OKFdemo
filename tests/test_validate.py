#!/usr/bin/env python3
"""Tests for tools/validate.py.

    python3 tests/test_validate.py            # all of it
    python3 tests/test_validate.py -v         # case by case

Standard library only, like the validator itself, so a fresh clone can run this
with the system Python and no setup step.

Two layers. The unit layer calls the reader directly and pins the YAML subset it
implements. The end-to-end layer copies the validator, the real schema and one
fixture into a throwaway tree and runs it as a subprocess, so exit codes are
tested as a caller experiences them -- which is the part a push hook and CI
depend on.

Fixtures live in tests/fixtures/records/ as real .md files. `tests` is in the
validator's SKIP set: these records are deliberately broken and must never be
validated as knowledge. A fixture named pass-* must validate; a fixture named
fail-* must not, and every one of them asserts the reason as well, so a check
that starts failing for a new reason does not quietly keep passing.
"""

import json
import os
import pathlib
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest

REPO = pathlib.Path(__file__).resolve().parent.parent
RECORDS = REPO / "tests" / "fixtures" / "records"
SCHEMA = REPO / "schemas" / "concept.schema.json"

sys.path.insert(0, str(REPO / "tools"))
import validate                                              # noqa: E402
import check_secrets                                          # noqa: E402

EXIT_OK, EXIT_FAILED, EXIT_CANNOT_RUN = 0, 1, 2


def build_tree(records=(), schema_text=None, omit_schema=False):
    """A throwaway repo: tools/validate.py, a schema, and some records."""
    root = pathlib.Path(tempfile.mkdtemp(prefix="validate-test-"))
    (root / "tools").mkdir()
    (root / "schemas").mkdir()
    (root / "concepts").mkdir()
    shutil.copy(REPO / "tools" / "validate.py", root / "tools" / "validate.py")
    if not omit_schema:
        target = root / "schemas" / "concept.schema.json"
        target.write_text(schema_text if schema_text is not None
                          else SCHEMA.read_text(), encoding="utf-8")
    for name in records:
        shutil.copy(RECORDS / name, root / "concepts" / name)
    return root


def build_checks_tree(records, tools=("validate.py", "check_supersession.py")):
    """A throwaway repo carrying the resolution checks as well as the validator."""
    root = build_tree([])
    for name in tools:
        shutil.copy(REPO / "tools" / name, root / "tools" / name)
    (root / "decisions").mkdir(exist_ok=True)
    for name, text in records.items():
        (root / "decisions" / name).write_text(text, encoding="utf-8")
    return root


def run_check(root, script):
    done = subprocess.run([sys.executable, str(root / "tools" / script)],
                          capture_output=True, text=True)
    return done.returncode, done.stdout + done.stderr


def run_tree(root):
    done = subprocess.run([sys.executable, str(root / "tools" / "validate.py")],
                          capture_output=True, text=True)
    return done.returncode, done.stdout + done.stderr


def run_fixture(name):
    root = build_tree([name])
    try:
        return run_tree(root)
    finally:
        shutil.rmtree(root, ignore_errors=True)


def reasons(output):
    """Only the validator's detail lines.

    Asserting against the whole output lets a fixture pass by matching its own
    filename, which is how fail-contested-position-no-value.md passed while
    failing for an entirely unrelated reason.
    """
    return "\n".join(line for line in output.splitlines()
                      if line.startswith(" " * 6))


# ---------------------------------------------------------------------------
# Fail-closed. Every one of these must refuse to report success.
# ---------------------------------------------------------------------------

class TestFailsClosed(unittest.TestCase):

    def assert_cannot_run(self, root, because):
        code, output = run_tree(root)
        self.assertEqual(code, EXIT_CANNOT_RUN,
                         "expected exit 2, got %d:\n%s" % (code, output))
        self.assertIn("CANNOT RUN", output)
        self.assertIn(because, output)

    def test_schema_missing(self):
        root = build_tree(["pass-baseline.md"], omit_schema=True)
        self.addCleanup(shutil.rmtree, root, True)
        self.assert_cannot_run(root, "no schema at")

    def test_schema_unreadable(self):
        root = build_tree(["pass-baseline.md"])
        self.addCleanup(shutil.rmtree, root, True)
        path = root / "schemas" / "concept.schema.json"
        path.chmod(0)
        if os.access(path, os.R_OK):
            self.skipTest("cannot make a file unreadable as this user")
        self.addCleanup(path.chmod, stat.S_IRUSR | stat.S_IWUSR)
        self.assert_cannot_run(root, "cannot read")

    def test_schema_not_json(self):
        root = build_tree(["pass-baseline.md"], schema_text="{ not json")
        self.addCleanup(shutil.rmtree, root, True)
        self.assert_cannot_run(root, "cannot read")

    def test_schema_uses_an_unimplemented_keyword(self):
        schema = json.loads(SCHEMA.read_text())
        schema["properties"]["title"]["allOf"] = []
        root = build_tree(["pass-baseline.md"], schema_text=json.dumps(schema))
        self.addCleanup(shutil.rmtree, root, True)
        self.assert_cannot_run(root, "does not implement")

    def test_schema_uses_an_unchecked_format(self):
        schema = json.loads(SCHEMA.read_text())
        schema["properties"]["title"]["format"] = "uri"
        root = build_tree(["pass-baseline.md"], schema_text=json.dumps(schema))
        self.addCleanup(shutil.rmtree, root, True)
        self.assert_cannot_run(root, "does not check")

    def test_no_records_at_all(self):
        root = build_tree([])
        self.addCleanup(shutil.rmtree, root, True)
        self.assert_cannot_run(root, "found no records")

    def test_a_record_that_cannot_be_parsed_never_exits_zero(self):
        for name in ("fail-block-scalar.md", "fail-tab-indent.md",
                     "fail-unterminated-quote.md", "fail-anchor.md"):
            with self.subTest(fixture=name):
                code, output = run_fixture(name)
                self.assertNotEqual(code, EXIT_OK,
                                    "unparseable record exited 0:\n%s" % output)


# ---------------------------------------------------------------------------
# The YAML subset the reader implements.
# ---------------------------------------------------------------------------

class TestYamlSubset(unittest.TestCase):

    def read(self, block):
        return validate.read_frontmatter(block)

    def assert_rejects(self, block, because):
        with self.assertRaises(validate.YamlError) as caught:
            self.read(block)
        self.assertIn(because, str(caught.exception))

    # -- the step 1 defect: a block scalar must not be folded into a value ---
    def test_block_scalar_literal_is_rejected(self):
        self.assert_rejects("type: x\ndescription: |\n  text\n", "block scalar")

    def test_block_scalar_folded_is_rejected(self):
        self.assert_rejects("type: x\ndescription: >-\n  text\n", "block scalar")

    # -- the step 3 defect: trailing comments -------------------------------
    def test_trailing_comment_is_stripped(self):
        self.assertEqual(self.read("status: draft  # draft | accepted\n"),
                         {"status": "draft"})

    def test_comment_after_a_quoted_value_is_stripped(self):
        self.assertEqual(self.read('title: "ADR-002"   # the customer one\n'),
                         {"title": "ADR-002"})

    def test_comment_on_a_list_item_is_stripped(self):
        self.assertEqual(self.read("tags:\n  - etl   # the loader\n  - dq\n"),
                         {"tags": ["etl", "dq"]})

    def test_whole_line_comment_is_ignored(self):
        self.assertEqual(self.read("# a note\ntype: x\n"), {"type": "x"})

    # -- a # inside quotes, and a # with no space before it, both survive ---
    def test_hash_inside_double_quotes_survives(self):
        self.assertEqual(self.read('title: "Release #42 sign-off"\n'),
                         {"title": "Release #42 sign-off"})

    def test_hash_inside_single_quotes_survives(self):
        self.assertEqual(self.read("title: 'C# migration'\n"),
                         {"title": "C# migration"})

    def test_hash_without_a_preceding_space_survives(self):
        self.assertEqual(self.read("tag: build#2026\n"), {"tag": "build#2026"})

    def test_url_fragment_survives(self):
        self.assertEqual(self.read("resource: /_sources/a.md#appendix-b\n"),
                         {"resource": "/_sources/a.md#appendix-b"})

    # -- dates, quoted and not, after step 2b -------------------------------
    def test_quoted_and_unquoted_timestamps_read_alike(self):
        quoted = self.read('generated:\n  at: "2026-08-25T12:00:00Z"\n')
        bare = self.read("generated:\n  at: 2026-08-25T12:00:00Z\n")
        self.assertEqual(quoted, bare)
        self.assertIsInstance(bare["generated"]["at"], str,
                              "a timestamp must stay a string, never a datetime")

    def test_quoted_and_unquoted_dates_read_alike(self):
        self.assertEqual(self.read('updated: "2026-08-25"\n'),
                         self.read("updated: 2026-08-25\n"))

    def test_a_date_is_not_type_converted(self):
        self.assertEqual(self.read("updated: 2026-08-25\n"), {"updated": "2026-08-25"})

    # -- nested objects and arrays of objects, which sources[] and
    #    contested[] both depend on ----------------------------------------
    def test_nested_object(self):
        self.assertEqual(
            self.read("generated:\n  by: process:claude-sonnet/x\n  at: \"2026-01-01T00:00:00Z\"\n"),
            {"generated": {"by": "process:claude-sonnet/x", "at": "2026-01-01T00:00:00Z"}})

    def test_array_of_objects(self):
        self.assertEqual(
            self.read("sources:\n  - resource: /_sources/a.md\n    id: DOC-01\n"
                      "  - resource: /_sources/b.md\n"),
            {"sources": [{"resource": "/_sources/a.md", "id": "DOC-01"},
                         {"resource": "/_sources/b.md"}]})

    def test_array_of_objects_containing_an_array_of_objects(self):
        block = ("contested:\n"
                 "  - claim: which figure\n"
                 "    positions:\n"
                 "      - value: \"one\"\n"
                 "        held_by: summary\n"
                 "      - value: \"two\"\n"
                 "        held_by: detail\n"
                 "    resolution_owner: none recorded\n"
                 "    resolves_when: none recorded\n")
        self.assertEqual(self.read(block), {"contested": [{
            "claim": "which figure",
            "positions": [{"value": "one", "held_by": "summary"},
                          {"value": "two", "held_by": "detail"}],
            "resolution_owner": "none recorded",
            "resolves_when": "none recorded"}]})

    def test_sequence_flush_with_its_key(self):
        self.assertEqual(self.read("tags:\n- a\n- b\n"), {"tags": ["a", "b"]})

    def test_multiline_plain_scalar_is_folded_with_spaces(self):
        self.assertEqual(self.read("description: one\n  two\n  three\n"),
                         {"description": "one two three"})

    # -- empty flow collections, and only those ----------------------------
    def test_empty_flow_sequence_is_accepted(self):
        self.assertEqual(self.read("sources: []\n"), {"sources": []})

    def test_empty_flow_sequence_with_a_space_is_accepted(self):
        self.assertEqual(self.read("sources: [ ]\n"), {"sources": []})

    def test_empty_flow_mapping_is_accepted(self):
        self.assertEqual(self.read("generated: {}\n"), {"generated": {}})

    def test_empty_sources_reaches_the_provenance_rule(self):
        """The point of accepting []: a schema rule judges it, not the parser."""
        schema = json.loads(SCHEMA.read_text())
        problems = [m for kind, m in
                    validate.validate(self.read("type: x\nsources: []\n"), schema)]
        self.assertIn("sources: needs at least 1 item(s), found 0", problems)

    def test_populated_flow_sequence_is_still_rejected(self):
        self.assert_rejects("tags: [a, b]\n", "only empty flow collections")

    def test_populated_flow_mapping_is_still_rejected(self):
        self.assert_rejects("generated: {by: x}\n", "only empty flow collections")

    # -- constructs outside the subset are refused, not guessed at ----------
    def test_flow_sequence_is_rejected(self):
        self.assert_rejects("tags: [a, b]\n", "flow collection")

    def test_anchor_is_rejected(self):
        self.assert_rejects("title: &a x\n", "anchors")

    def test_tab_indentation_is_rejected(self):
        self.assert_rejects("generated:\n\tby: x\n", "tab in indentation")

    def test_unterminated_quote_is_rejected(self):
        self.assert_rejects('title: "no close\n', "unterminated")

    def test_junk_after_a_quoted_value_is_rejected(self):
        self.assert_rejects('title: "a" junk\n', "unexpected text")

    def test_duplicate_key_is_rejected(self):
        self.assert_rejects("status: draft\nstatus: accepted\n", "duplicate key")


# ---------------------------------------------------------------------------
# One passing and one failing fixture per schema rule.
# ---------------------------------------------------------------------------

FAILING = {
    # unreadable frontmatter
    "fail-no-frontmatter.md":                 "NO FRONTMATTER",
    "fail-block-scalar.md":                   "block scalar",
    "fail-block-scalar-folded.md":            "block scalar",
    "fail-flow-sequence.md":                  "flow collection",
    "fail-anchor.md":                         "anchors",
    "fail-tab-indent.md":                     "tab in indentation",
    "fail-unterminated-quote.md":             "unterminated",
    "fail-junk-after-quote.md":               "unexpected text",
    "fail-duplicate-key.md":                  "duplicate key",
    # schema rules
    "fail-missing-type.md":                   "missing required field 'type'",
    "fail-unknown-field.md":                  "unknown field 'deciders'",
    "fail-status-not-in-enum.md":             "status: 'proposed' is not one of",
    "fail-status-deprecated.md":              "status: 'deprecated' is not one of",
    "fail-by-slash-form.md":                  "generated.by",
    "fail-by-no-mode.md":                     "generated.by",
    "fail-at-space-separated.md":             "generated.at",
    "fail-at-bare-date.md":                   "generated.at",
    "fail-generated-missing-at.md":           "missing required field 'at'",
    "fail-sources-empty.md":                  "sources: needs at least 1",
    "fail-source-unknown-key.md":             "unknown field 'confidence'",
    "fail-tags-not-unique.md":                "tags: items must be unique",
    # contested
    "fail-contested-one-position.md":         "positions: needs at least 2",
    "fail-contested-missing-owner.md":        "missing required field 'resolution_owner'",
    "fail-contested-missing-resolves-when.md": "missing required field 'resolves_when'",
    "fail-contested-owner-nested.md":         "resolution_owner",
    "fail-contested-unknown-key.md":          "unknown field 'confidence'",
    "fail-contested-position-no-value.md":    "value",
    "fail-contested-empty-resolves-when.md":  "resolves_when: shorter than 1",
}


class TestSchemaRules(unittest.TestCase):

    def test_every_pass_fixture_validates(self):
        names = sorted(p.name for p in RECORDS.glob("pass-*.md"))
        self.assertTrue(names, "no pass fixtures found")
        for name in names:
            with self.subTest(fixture=name):
                code, output = run_fixture(name)
                self.assertEqual(code, EXIT_OK,
                                 "%s should validate:\n%s" % (name, output))

    def test_all_pass_fixtures_together_validate(self):
        names = sorted(p.name for p in RECORDS.glob("pass-*.md"))
        root = build_tree(names)
        self.addCleanup(shutil.rmtree, root, True)
        code, output = run_tree(root)
        self.assertEqual(code, EXIT_OK, output)
        self.assertIn("VALID=%d" % len(names), output)

    def test_every_fail_fixture_is_rejected_for_the_stated_reason(self):
        for name, because in sorted(FAILING.items()):
            with self.subTest(fixture=name):
                code, output = run_fixture(name)
                self.assertNotEqual(code, EXIT_OK,
                                    "%s should not validate:\n%s" % (name, output))
                self.assertIn(because, reasons(output),
                              "%s failed, but not for the expected reason:\n%s"
                              % (name, output))

    def test_every_fixture_on_disk_is_covered(self):
        on_disk = {p.name for p in RECORDS.glob("*.md")}
        claimed = set(FAILING) | {p.name for p in RECORDS.glob("pass-*.md")}
        self.assertEqual(on_disk - claimed, set(),
                         "fixtures exist that no test refers to")
        self.assertEqual(claimed - on_disk, set(),
                         "tests refer to fixtures that do not exist")


# ---------------------------------------------------------------------------
# tools/check_secrets.py -- the pre-commit credential scanner.
#
# Every value below is synthetic and invented for this file. None of them is a
# planted fixture from _canon/pii_plant_register.csv: a test suite quoting the
# real fixtures is exactly how they escaped into the QA reports in the first
# place. Each line carries an allowlist marker so the scanner does not flag its
# own test data when it walks the tracked tree; the marker is stripped by the
# time the value reaches scan_text().
# ---------------------------------------------------------------------------

MUST_BLOCK = {
    "password assignment":     "odi.stg.password=Sw0rdfish!2031",                     # pragma: allowlist secret
    "pwd assignment":          "db.pwd=hunter2xyz",                                   # pragma: allowlist secret
    "passwd with a colon":     "passwd: S3cr3tValue!",                                # pragma: allowlist secret
    "passphrase":              "passphrase = correct-horse-battery",                  # pragma: allowlist secret
    "client secret":           'client_secret = "a9f8e7d6c5b4a3f2e1d0"',              # pragma: allowlist secret
    "api key":                 "api_key=AbCdEf123456GhIjKl",                          # pragma: allowlist secret
    "aws secret access key":   "aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPx",   # pragma: allowlist secret
    "jdbc query-string creds": "url=jdbc:mysql://db:3306/app?user=root&password=r00tpass",  # pragma: allowlist secret
    "oracle thin user/pass":   "jdbc:oracle:thin:scott/tiger@//orion-db:1521/ORIONPRD",  # pragma: allowlist secret
    "url with embedded creds": "https://svcacct:Pa55w0rd@internal.example/api",       # pragma: allowlist secret
    "rsa private key header":  "-----BEGIN RSA PRIVATE KEY-----",  # pragma: allowlist secret
    "openssh private key":     "-----BEGIN OPENSSH PRIVATE KEY-----",  # pragma: allowlist secret
    "bare private key header": "-----BEGIN PRIVATE KEY-----",  # pragma: allowlist secret
    "putty private key":       "PuTTY-User-Key-File-2: ssh-rsa",  # pragma: allowlist secret
    "aws access key id":       "AKIAIOSFODNN7EXAMPLE",  # pragma: allowlist secret
    "github token":            "ghp_" + "A" * 36,  # pragma: allowlist secret
    "github fine-grained":     "github_pat_" + "B" * 30,  # pragma: allowlist secret
    "slack token":             "xoxb-123456789012-abcdefghijklm",  # pragma: allowlist secret
    "slack webhook":           "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX",  # pragma: allowlist secret
    "google api key":          "AIza" + "C" * 35,  # pragma: allowlist secret
    "stripe live key":         "sk_live_" + "D" * 24,  # pragma: allowlist secret
    "anthropic api key":       "sk-ant-" + "E" * 30,  # pragma: allowlist secret
    "npm token":               "npm_" + "F" * 36,  # pragma: allowlist secret
    "json web token":          "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc123",  # pragma: allowlist secret
    "azure account key":       "AccountKey=abcdefghijklmnopqrstuvwxyz0123456789ABCDEF==",  # pragma: allowlist secret
}

MUST_ALLOW = {
    "prose about passwords":   "Finance rotates the password every quarter.",
    "a heading":               "## Password policy and rotation",
    "angle-bracket holder":    "password=<your-password-here>",                       # pragma: allowlist secret
    "env var holder":          "password=${DB_PASSWORD}",                             # pragma: allowlist secret
    "changeme holder":         "password=changeme",                                   # pragma: allowlist secret
    "asterisk holder":         "password=********",                                   # pragma: allowlist secret
    "redacted holder":         "password=REDACTED",                                   # pragma: allowlist secret
    "jdbc without creds":      "jdbc:oracle:thin:@//edw-db-prd-01.example:1521/BCPLEDW",
    "wallet alias":            "orion.jdbc.walletAlias=orion_ro_prd",
    "username alone":          "odi.stg.user=ODI_STG_RD",
    "host and port":           "odi.agent.host=edw-app-prd-02.example:20910",
    "a table of table names":  "| `MAP_FACT_INVOICE_LINE` | rebuilt as a key-based merge |",
    "python token variable":   "    if token.startswith('\"'):",
    "a line already marked":   "password=NotReallyASecret1  # pragma: allowlist secret",
}

# Shapes the scanner does NOT catch. Asserted as they actually behave, not as we
# would like them to. Step 2c proved these escape: every planted value reached
# the QA reports in one of these two forms and no rule fired.
KNOWN_GAPS = {
    "bare value in a table cell": "| PII-9 | Password | Sw0rdfish!2031 | notes |",     # pragma: allowlist secret
    "credential quoted in prose": "The database password is Sw0rdfish!2031, rotate it.",  # pragma: allowlist secret
    "value in a backticked cell": "| PII-9 | Passwords | `Sw0rdfish!2031` | TECH |",   # pragma: allowlist secret
}


class TestCredentialScanner(unittest.TestCase):

    def found(self, text):
        return check_secrets.scan_text("case.txt", text)

    def test_every_credential_shape_is_blocked(self):
        for name, text in sorted(MUST_BLOCK.items()):
            with self.subTest(case=name):
                self.assertTrue(self.found(text),
                                "not detected: %s" % name)

    def test_every_lookalike_is_allowed(self):
        for name, text in sorted(MUST_ALLOW.items()):
            with self.subTest(case=name):
                self.assertEqual(self.found(text), [],
                                 "false positive on: %s" % name)

    def test_dangerous_filenames_are_refused_whatever_they_contain(self):
        for path in ("id_rsa", "deploy/id_ed25519", "certs/server.pem",
                     "keys/store.jks", ".env", "svc/.env.production"):
            with self.subTest(path=path):
                self.assertTrue(check_secrets.scan([path], lambda p: b"harmless\n"),
                                "%s should be refused on its name alone" % path)

    def test_example_env_files_are_allowed(self):
        for path in (".env.example", ".env.sample", ".env.template"):
            with self.subTest(path=path):
                self.assertEqual(check_secrets.scan([path], lambda p: b"KEY=\n"), [])

    def test_read_only_archives_are_excluded(self):
        blocked = MUST_BLOCK["password assignment"].encode()
        for path in ("_sources/technical/db.properties", "_canon/BRIEF.md"):
            with self.subTest(path=path):
                self.assertEqual(check_secrets.scan([path], lambda p: blocked), [],
                                 "%s must not be scanned -- it holds the fixtures" % path)
        self.assertTrue(check_secrets.scan(["notes/db.properties"], lambda p: blocked),
                        "a path outside the archives must still be scanned")

    def test_reported_values_are_redacted(self):
        findings = self.found(MUST_BLOCK["password assignment"])
        self.assertNotIn("Sw0rdfish!2031", check_secrets.redact(findings[0][3]))

    def test_exit_codes(self):
        clean = pathlib.Path(tempfile.mkdtemp()) / "clean.txt"
        clean.write_text("nothing to see\n")
        self.addCleanup(shutil.rmtree, clean.parent, True)
        dirty = clean.parent / "dirty.txt"
        dirty.write_text(MUST_BLOCK["password assignment"] + "\n")
        for label, args, expected in (
                ("clean file", [str(clean)], 0),
                ("file with a credential", [str(dirty)], 1),
                ("path that does not exist", [str(clean.parent / "nope.txt")], 2),
                ("no arguments", [], 2)):
            with self.subTest(case=label):
                done = subprocess.run(
                    [sys.executable, str(REPO / "tools" / "check_secrets.py")] + args,
                    capture_output=True, text=True)
                self.assertEqual(done.returncode, expected,
                                 "%s: %s" % (label, done.stdout + done.stderr))

    def test_staged_mode_reads_the_index_not_the_working_tree(self):
        root = pathlib.Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, root, True)
        for cmd in (["init", "-q"], ["config", "user.email", "t@example"],
                    ["config", "user.name", "t"]):
            subprocess.run(["git"] + cmd, cwd=root, capture_output=True)
        target = root / "conf.properties"

        target.write_text("harmless\n")
        subprocess.run(["git", "add", "conf.properties"], cwd=root, capture_output=True)
        target.write_text(MUST_BLOCK["password assignment"] + "\n")   # not staged
        done = subprocess.run([sys.executable, str(REPO / "tools" / "check_secrets.py"),
                               "--staged"], cwd=root, capture_output=True, text=True)
        self.assertEqual(done.returncode, 0,
                         "a secret only in the working tree must not block:\n" + done.stderr)

        subprocess.run(["git", "add", "conf.properties"], cwd=root, capture_output=True)
        target.write_text("harmless\n")                                # cleaned, not staged
        done = subprocess.run([sys.executable, str(REPO / "tools" / "check_secrets.py"),
                               "--staged"], cwd=root, capture_output=True, text=True)
        self.assertEqual(done.returncode, 1,
                         "a secret staged in the index must block even if the "
                         "working tree is clean")

    def test_the_tracked_tree_is_clean(self):
        done = subprocess.run([sys.executable, str(REPO / "tools" / "check_secrets.py"),
                               "--all"], cwd=str(REPO), capture_output=True, text=True)
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)


class TestCredentialScannerKnownFalsePositives(unittest.TestCase):
    """Shapes the scanner flags that are not secrets.

    Found while writing this suite, not fixed here -- this step's scope was the
    empty-flow-collection fix and porting the matrix. Asserted as it behaves so
    the defect is visible and so a fix turns this test red deliberately.
    """

    def test_a_redaction_marker_in_assignment_form_is_flagged(self):
        """`[REDACTED ...]` is not recognised as a placeholder because the
        placeholder pattern does not include a leading `[`.

        Step 2c wrote its markers inside backticks in tables and prose, so no
        tracked file trips this today. A file that redacted a secret sitting in
        assignment form, leaving the marker as the assigned value, would be
        blocked from commit for containing the redaction of the thing it
        removed.
        """
        flagged = check_secrets.scan_text(
            "case.md", "password=[REDACTED - planted fixture PII-N]")   # pragma: allowlist secret
        self.assertTrue(flagged, "the false positive has been fixed; "
                                 "move this case into MUST_ALLOW")
        self.assertEqual(flagged[0][2], "generic secret assignment")


class TestCredentialScannerKnownGaps(unittest.TestCase):
    """Shapes the scanner misses, asserted as they behave rather than as wished.

    These are not failures. They pin a real limitation so that it stays visible
    and so that anyone who narrows the gap sees these tests go red and has to
    decide deliberately. Closing them needs entropy heuristics, which
    false-positive on this corpus's table names and host:port strings -- and a
    hook that cries wolf gets bypassed, at which point it protects nothing.
    """

    def test_bare_values_in_prose_and_tables_are_not_detected(self):
        for name, text in sorted(KNOWN_GAPS.items()):
            with self.subTest(case=name):
                self.assertEqual(
                    check_secrets.scan_text("case.md", text), [],
                    "%s is now detected -- the gap has narrowed. Update this "
                    "test and the note above it." % name)

    def test_the_gap_is_specific_to_the_absence_of_an_assignment(self):
        """The same value in `key=value` form is caught, which is the boundary."""
        self.assertTrue(check_secrets.scan_text("case.md", "password=Sw0rdfish!2031"))  # pragma: allowlist secret


# ---------------------------------------------------------------------------
# tools/check_supersession.py -- supersession integrity.
# ---------------------------------------------------------------------------

def _record(status=None, superseded_by=None, supersedes=None):
    lines = ["---", "type: decision", 'title: "A record"',
             "description: A supersession fixture."]
    if status:
        lines.append("status: %s" % status)
    if superseded_by:
        lines.append("superseded_by: %s" % superseded_by)
    if supersedes:
        lines.append("supersedes: %s" % supersedes)
    lines += ["generated:", "  by: process:claude-sonnet/tests",
              '  at: "2026-08-25T12:00:00Z"',
              "sources:", "  - resource: /_sources/docs/DOC-01_example.docx",
              'updated: "2026-08-25"', "---", "", "Body.", ""]
    return "\n".join(lines)


OTHER = "/decisions/other.md"


class TestSupersessionCheck(unittest.TestCase):

    def check(self, records):
        root = build_checks_tree(records)
        self.addCleanup(shutil.rmtree, root, True)
        return run_check(root, "check_supersession.py")

    # -- superseded_by implies status: superseded, the enforced direction ----

    def test_superseded_by_with_matching_status_passes(self):
        code, output = self.check({
            "a.md": _record(status="superseded", superseded_by=OTHER),
            "other.md": _record(status="accepted", supersedes="/decisions/a.md")})
        self.assertEqual(code, 0, output)
        self.assertIn("broken=0", output)

    def test_superseded_by_with_status_accepted_is_rejected(self):
        code, output = self.check({
            "a.md": _record(status="accepted", superseded_by=OTHER),
            "other.md": _record(status="accepted")})
        self.assertEqual(code, 1, output)
        self.assertIn("superseded_by is set but status is 'accepted'", output)

    def test_superseded_by_with_status_draft_is_rejected(self):
        """The exact shape D2 had: a superseded record filterable as live."""
        code, output = self.check({
            "a.md": _record(status="draft", superseded_by=OTHER),
            "other.md": _record(status="accepted")})
        self.assertEqual(code, 1, output)
        self.assertIn("superseded_by is set but status is 'draft'", output)

    def test_superseded_by_with_no_status_at_all_is_rejected(self):
        code, output = self.check({
            "a.md": _record(superseded_by=OTHER),
            "other.md": _record(status="accepted")})
        self.assertEqual(code, 1, output)
        self.assertIn("superseded_by is set but status is None", output)

    # -- status: superseded with no superseded_by, the reported direction ---

    def test_superseded_without_a_replacement_is_reported_not_failed(self):
        code, output = self.check({"a.md": _record(status="superseded")})
        self.assertEqual(code, 0,
                         "an unpaired superseded record must not fail the run "
                         "while the question is open:\n" + output)
        self.assertIn("unpaired=1", output)
        self.assertIn("UNPAIRED", output)

    # -- target existence, from step 5, still holds -------------------------

    def test_superseded_by_pointing_nowhere_is_rejected(self):
        code, output = self.check({
            "a.md": _record(status="superseded", superseded_by="/decisions/ghost.md")})
        self.assertEqual(code, 1, output)
        self.assertIn("does not exist", output)

    def test_supersedes_pointing_nowhere_is_rejected(self):
        code, output = self.check({
            "a.md": _record(status="accepted", supersedes="/decisions/ghost.md")})
        self.assertEqual(code, 1, output)
        self.assertIn("does not exist", output)

    def test_a_record_with_no_supersession_fields_passes(self):
        code, output = self.check({"a.md": _record(status="accepted")})
        self.assertEqual(code, 0, output)

    # -- fail closed --------------------------------------------------------

    def test_fails_closed_without_the_shared_reader(self):
        root = build_checks_tree({"a.md": _record(status="accepted")})
        self.addCleanup(shutil.rmtree, root, True)
        (root / "tools" / "validate.py").unlink()
        code, output = run_check(root, "check_supersession.py")
        self.assertEqual(code, 2, output)
        self.assertIn("CANNOT RUN", output)

    def test_the_real_corpus_passes(self):
        done = subprocess.run(
            [sys.executable, str(REPO / "tools" / "check_supersession.py")],
            capture_output=True, text=True)
        self.assertEqual(done.returncode, 0, done.stdout + done.stderr)


class TestSkipSet(unittest.TestCase):

    def test_tests_directory_is_skipped(self):
        self.assertIn("tests", validate.SKIP,
                      "deliberately broken fixtures would be validated as knowledge")

    def test_the_real_repo_still_passes(self):
        done = subprocess.run([sys.executable, str(REPO / "tools" / "validate.py")],
                              capture_output=True, text=True)
        self.assertEqual(done.returncode, EXIT_OK, done.stdout + done.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
