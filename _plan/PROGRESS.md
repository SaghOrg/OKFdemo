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

---

## Step 2 — settle `schemas/concept.schema.json`

**Branch:** `schema/settle-concept-schema` (commit `ca5e8e1`), cut from
`tooling/validator-runnable-from-clone`. Not merged, no remote yet.
**Status:** done. No content file touched.

### What changed

Four changes, all in `schemas/concept.schema.json`.

1. **`status` enum → `["draft", "accepted", "superseded"]`.** `deprecated`
   dropped: AGENTS.md pairs it with a link to the replacement, which is
   `superseded` semantics under a second word, and nothing used it. `proposed`
   also dropped, for the same reason `rejected` was not added — it is a
   near-synonym of `draft` with zero usage outside the template placeholder, and
   the three `draft` records (the T-03 parking, the VAR-008 deferral, the VAR-003
   close date) are exactly the "open question awaiting decision" case, so `draft`
   demonstrably already carries it. Either value is one line to restore when a
   record needs it with a known referent. Keeping `proposed` would have required
   a distinguishing line in AGENTS.md, and AGENTS.md is steps 13–15 — writing
   that rule now would invert the sequence.

2. **`captured_by`** — optional string. The human who brought the knowledge in,
   distinct from `generated.by` (the agent that wrote the file) and from the git
   author, who may be neither.

3. **`contested`** — array of claim-level disputes, so a record stays `accepted`
   while one claim inside it is disputed. Per entry: `claim`, `positions`
   (minimum 2, each requiring `value`, with optional `source` and `held_by`),
   `resolution_owner`, `resolves_when`. `resolution_owner` and `resolves_when`
   sit at claim level as siblings of `claim` and `positions` — an owner is
   accountable for the dispute, not for one side of it. Both are required.
   `additionalProperties: false` throughout. The description states what the
   field is *not* for: superseded facts, open questions with no rival value, and
   rounding differences.

4. **`generated.by`** → `^[a-z][a-z-]*:[a-z0-9.-]+(/[a-z0-9-]+)?$`, and
   **`generated.at`** → an asserted RFC 3339 date-time pattern, replacing
   `format: date-time`. `format` is an annotation in JSON Schema 2020-12 and was
   never checked by anything; a pattern is the only mechanism that actually
   enforces it. Date-time only, no bare dates.

### How many existing files now fail

**31 of 71**, all on `generated.at`, all the same failure: a space-separated
timestamp (`2026-08-23 10:37:09+00:00`) where RFC 3339 is required. The other
three changes cost nothing on main — `status` had no `proposed` or `deprecated`
values, and all 71 records already fit the new `generated.by` shape.

On the `decision/adr-006-fact-credit-note` branch, that record now fails on both
`generated.by` (`live-capture/claude-opus`, slash where the grammar wants a
colon) and `generated.at` (bare date). Expected and accepted — it is a reference,
not a merge candidate.

### Verify by hand

- `python3 tools/validate.py` → `VALID=40 INVALID=31`, exit 1. Every failure
  line should name `generated.at`.
- The new patterns were unit-tested directly: `generated.by` admits
  `process:claude-sonnet/variances`, `live-capture:claude-opus`, `human:asha`,
  and rejects `live-capture/claude-opus`, `claude-opus`, `Process:claude-opus`,
  and a two-slash form. `generated.at` admits `Z`, fractional seconds and
  numeric offsets, and rejects the space-separated form, a bare date, and
  lowercase `t`/`z`.
- A `contested` block was exercised end to end in a scratch tree using the
  `.vtt`-vs-`.txt` attribution case. Confirmed rejected: `resolution_owner`
  nested under a position, a single position, an omitted `resolution_owner`, an
  unknown key inside a position, an empty `resolves_when`.

### One correction to the step 1 report

**Step 1 as shipped exits 1, not 0.** `_plan/PROGRESS.md` has no frontmatter and
`_plan` is not in the validator's `SKIP` set, so the progress file fails the
validator. I ran the validator before committing that file and reported the
exit code I had seen rather than re-checking after the final commit; the step 1
entry above overstates it. The fix is one entry in `SKIP` — but `SKIP` changes
were explicitly reserved, and this step is schema-only, so it is logged and not
fixed. **This must be resolved before step 4**, or the first push hook blocks
every commit.

### Noticed, deliberately not fixed

1. **`20260324-var008-february-reload-deferred.md` has `status: draft` with
   `superseded_by` populated**, so any status filter returns a superseded record
   as live. Content-pass fix. Worth noting for later: once corrected, "if
   `superseded_by` is present then `status` must be `superseded`" is mechanically
   checkable, which by the governing principle makes it schema work rather than
   an AGENTS.md line. It needs a JSON Schema keyword the validator does not yet
   implement, so it is validator work first.

2. **`templates/decision.md` carries `status: proposed`**, now not a legal value,
   and a comment listing the old five-value vocabulary. `templates` is in `SKIP`
   so it does not fail today. This is step 3's named work.

3. **AGENTS.md:127 says `status: deprecated`**, which the schema now rejects.
   Steps 13–15.

4. **`stale_after`, `updated` and `sources[].last_modified` still use
   `format: date`**, which is annotation-only and therefore unenforced — the same
   fail-open just removed from `generated.at`. All three are clean across all 71
   records today, so converting them to patterns would cost nothing. Not done:
   it is a fifth change and this step named four.

5. **The corpus contains no live, unadjudicated dispute**, so `contested` ships
   unexercised. Every conflict found is one of: superseded (2.40 Cr → 3.11 Cr,
   the go-live dates); already adjudicated (the `.vtt` attributes a line to Priya
   Nair, the circulated `.txt` to Vikram Sethi, and the glossary rules for the
   `.vtt`; the VAR-004 owner, where the tracker and a later email disagree and
   the email wins); an open question with no competing value (drill-down, VAR-003
   close date); or precision (XL-01's 3.10 Cr vs 3,11,20,000). The adjudicated
   pair are the closest structural fit and would be the honest worked example if
   one is ever needed — but both are resolved, and `contested` is for live
   disputes. No reference example was written into the schema.

### Deviation from what was approved

`resolution_owner` and `resolves_when` were specified as "required but explicitly
nullable, so an agent must write `none recorded`". They are implemented as
**required non-empty strings, not nullable**. Allowing YAML null lets an agent
write `resolution_owner:` with an empty value, which is not writing
`none recorded` — and it re-creates two spellings for one state, which is the
exact thing just removed from the `status` enum. `minLength: 1` forces the
convention the sentence asked for. One line to widen if the nullable form is
wanted.

### Does the plan still look right

Two sequencing points.

- **Step 2b is now a hard prerequisite, not a nicety.** Main fails its own
  validator by 31 records, and the `_plan/PROGRESS.md` defect makes it 32
  failures across two causes. Both must clear before step 4 wires validation
  into a push hook. Per the S4 note in LEARNINGS.md, the content pass should
  **quote** every date and date-time in frontmatter, not merely reformat them —
  unquoted values are what PyYAML auto-types and re-serialises space-separated,
  which is the root cause. The new pattern is the tripwire that catches the
  round-trip recurring.
- **Item 1 above points at validator work before step 11.** Enforcing the
  `superseded_by` ⇒ `status` dependency needs a schema keyword
  `tools/validate.py` does not implement, and the validator still has no tests.
