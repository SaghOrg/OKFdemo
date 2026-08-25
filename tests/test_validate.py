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
    # KNOWN FAILING, left red deliberately. `minItems: 1` on `sources` is
    # unreachable: the only way to write an empty array in YAML is `sources: []`,
    # which is a flow collection and the reader rejects it before any schema rule
    # runs; `sources:` with no value parses as null and fails the type check
    # instead. So the rule can never fire, and an author following AGENTS.md line
    # 112 ("leave sources: []") gets told about flow collections rather than
    # about provenance. Reported, not fixed -- see _plan/PROGRESS.md step 4b.
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
