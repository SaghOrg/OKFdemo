# Enforcement layer — progress

One entry per step. Sessions do not share memory; this file is the handover.
Newest entry at the bottom.

---

## Step 1 — validator runnable from a fresh clone

**Branch:** `tooling/validator-runnable-from-clone` (commit `76f4171`)
**Status:** done. Not merged, no remote yet (expected until step 7).

### What changed

- **`_build/validate_concepts.py` → `tools/validate.py`, tracked.** The old file
  is gone from `_build/`. A copy of the original is in this session's scratchpad
  only; it is not recoverable from git, because it was never tracked.
- **Rewritten to use the standard library only.** No `requirements.txt` was
  added and none is needed. The old file imported `yaml` and `jsonschema` from
  the gitignored `.venv-synth`. Two small readers replace them:
  - a YAML frontmatter reader covering the subset this KB actually uses —
    nested mappings, sequences of scalars and of mappings, quoted and plain
    scalars, plain scalars folded across continuation lines;
  - a JSON Schema reader implementing exactly the keywords
    `concept.schema.json` uses.
- **Both readers fail closed.** A YAML construct outside the supported subset
  (block scalar, flow collection, anchor, alias, tab indentation) is an error,
  not a guess. A schema keyword or `format` value that `tools/validate.py` does
  not implement stops the run with exit 2 — so extending the schema in step 3
  without extending the validator fails loudly instead of quietly checking less.
- **Exit codes now mean something.** `0` checks ran and passed; `1` checks ran
  and a record failed; `2` checks could not run. The old file ended in an
  unconditional `sys.exit(0)`: it could not fail, ever.
- **`.gitignore`:** the rule excluding the validator was the directory rule
  `_build/`. Moving the file out of `_build/` is what removes the exclusion —
  `_build/`, `_snapshots/` and `.venv-synth/` all stay ignored, verified with
  `git check-ignore`. Only a comment was added, pointing at the new location so
  nobody re-adds a check under `_build/`.
- **The `SKIP` set is carried over unchanged**, `templates` included, as
  instructed. So is the filename exclusion list and the `MISSING_TITLE`
  convention report.

### The command

From a fresh clone, with no setup step of any kind:

```
python3 tools/validate.py
```

Expected today: `VALID=71  INVALID=0  NO_FRONTMATTER=0  MISSING_TITLE=0  FORMAT_NOTES=31`, exit `0`.

### Verify by hand

- Clone the branch to a temp directory and run the command above. `_build/` and
  `.venv-synth/` will not be in the clone; it should still exit 0.
- Confirm exit 2 on a broken setup: delete `schemas/concept.schema.json` in the
  clone and re-run. It must refuse, not pass.
- Confirm exit 1 on a bad record: add a stray frontmatter key to any concept in
  the clone and re-run.

Already run here: clean clone passes on Python 3.9.6 (`/usr/bin/python3`, the
macOS system Python), 3.12, 3.13 and 3.14; passes with `yaml` and `jsonschema`
imports forcibly blocked; passes when invoked from an unrelated working
directory. Every fail-closed path above was exercised in a scratch tree.

The rewrite was differential-tested against the old `PyYAML` + `jsonschema`
chain on all 71 records: identical parse results, modulo timestamp spelling —
see the first drift item below.

### Noticed, deliberately not fixed

1. **`generated.at` is written two different ways.** 31 of 71 records use
   `2026-08-23 10:37:09+00:00` (space separator, numeric offset); the other 40
   use `2026-08-23T10:37:09Z`. Neither the old chain nor this one *fails* on it:
   `format` is an annotation in JSON Schema 2020-12 and `Draft202012Validator`
   was constructed without a format checker, so `date` and `date-time` were
   never asserted at all. PyYAML additionally parsed both spellings into
   `datetime` objects and re-serialised them identically, so the difference was
   invisible even on inspection. `tools/validate.py` keeps the literal bytes and
   **reports** these as `FORMAT_NOTES` without failing, matching the old
   pass/fail behaviour exactly. **Step 3 decision required:** make `format` an
   assertion and normalise the 31 timestamps, or drop `format` from the schema.
   Reporting-but-not-enforcing is the one place this validator knowingly checks
   less than it appears to, and it should not survive step 3.

2. **The reference ADR on `decision/adr-006-fact-credit-note` does not validate.**
   Read via `git show`, not checked out. Its
   `generated.by: live-capture/claude-opus` fails the schema pattern
   `^process:claude-[a-z0-9.-]+/[a-z0-9-]+$`, and its `generated.at: 2026-10-31`
   is a date where the schema wants a date-time. This matters more than a
   normal drift item: that branch is the worked example AGENTS.md cites for the
   un-minuted-decision convention, and a live capture is exactly the case the
   `process:` pattern has no spelling for. Step 3 input.

3. **The schema and AGENTS.md contradict each other on `sources`.** The schema
   sets `sources.minItems: 1`. AGENTS.md line 112 instructs that where nothing
   is evidenced you `leave sources: []`. A record following the written
   protocol would be rejected by the validator. No record in the KB does this
   today, so nothing fails right now. Step 3 input.

4. **`tools/validate.py` is not the only check in `_build/`.** `check_sources.py`
   (asserts every `sources[].resource` is an existing path under `/_sources/`)
   is a real second check, still gitignored, still requiring PyYAML. `verify.py`
   is corpus-generation QA and hardcodes an absolute path to this machine —
   probably not something to track. The step brief called the validator "the
   repo's only mechanical check"; `check_sources.py` is arguably a second one
   and is a candidate for `tools/` later.

5. **`.claude/` is gitignored.** Steps 4–6 track git hooks; if any agent-facing
   config needs to be version-controlled alongside them, that rule needs a
   carve-out.

6. **`.github/copilot-instructions.md` exists** — a second agent-instruction
   file that can drift from AGENTS.md. Relevant to steps 13–15.

7. **`LEARNINGS.md` has an uncommitted working-tree modification** that predates
   this session. Left untouched and out of the commit.

### Does the plan still look right

Yes, with one adjustment to sequencing. Step 1 as written assumes the validator
currently *checks* what the schema says; it does not. Enforcing `format` would
have failed 31 pre-existing records, so this step preserved the old pass/fail
behaviour and deferred the decision — but that means the honest statement of
where things stand is "exit 0 means everything the validator asserts passed",
not "everything the schema says passes". Step 3 has to close that gap before
step 4 wires the validator into a push hook, or the first hook ships with a
known blind spot. Items 1, 2 and 3 above are all step-3 work and all point the
same way: the schema has never been tested against the records it governs.

No test file was committed. The validator now has hand-rolled YAML and schema
readers and zero automated tests, which is thin for something about to become a
required CI check. Not in scope for this step; worth naming as a step before 11.
