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

---

## Step 3 — make `templates/decision.md` schema-conformant

**Branch:** `template/decision-schema-conformant` (commit `cb1727f`), cut from
`schema/settle-concept-schema`. Not merged, no remote yet.
**Status:** done. None of the thirteen decision records was modified.

### New counts

```
VALID=41  INVALID=31  NO_FRONTMATTER=1  MISSING_TITLE=0  FORMAT_NOTES=0
exit 1
```

`VALID` rose 40 → 41: the template now validates and is now being checked.
`INVALID` is unchanged at 31 — still the `generated.at` timestamps, still
pending step 2b. `NO_FRONTMATTER=1` is `_plan/PROGRESS.md`, carried over from
step 1. The template contributes nothing to either failure count and produces no
format notes.

### What changed

**Frontmatter** is now exactly the shape the thirteen records use, in their
order: `type, title, description, tags, status, generated, sources, updated`.
Verified programmatically against all thirteen. The old template was missing
`description` and `tags`, which every record carries, as well as declaring six
keys the schema rejects.

**The six undeclared keys.** `deciders`, `consulted` and `informed` moved to a
body block under the H1, where the records already put them; `consulted` and
`informed` default to `none recorded`, matching the un-minuted-decision
convention and the ADR-006 worked example. `id` is folded into `title`, which is
where the ADR number lives in the records that have one (five of thirteen do;
the rest are "Go-live…" and "Open question…" records with no ADR number, which is
why `id` could never have been required). `affects` becomes the
`## Related concepts` section, present in all thirteen.

**`date`** was not named in the brief as having a destination. It is dropped from
frontmatter and appears as `**Date:**` in the body block, following ADR-006.
This is a judgement call worth flagging: `updated` means "date this record last
changed" and will legitimately drift on every edit, so it cannot carry the date
the decision was taken. The thirteen records lose that date the first time
someone edits them. ADR-006, the newest and most carefully written record, keeps
both. Say if you would rather the template not carry it.

### How the empty `sources` and blank supersession keys were handled

Neither needed a schema allowance.

- **`sources: []`** → one entry carrying the required `resource` field with an
  obvious placeholder, `/_sources/<folder>/<artifact>`, in the same `<...>` idiom
  the rest of the template already uses. A full-line comment above it names the
  optional subfields and restates the un-minuted rule: cite the context, mark the
  decision line unsourced in the body, never name an artifact that did not
  produce the decision. A placeholder was chosen over relaxing `minItems` because
  relaxing it would let a real record ship with no provenance and no complaint,
  which is the opposite of what the field is for.
- **`supersedes:` / `superseded_by:`** → both keys removed entirely, matching the
  seven of thirteen records that use neither. A full-line comment says when to add
  `supersedes`, and what to set on the other record (`superseded_by` plus
  `status: superseded`). A blank key is invalid under the schema and always was;
  omitting is the convention the records already follow.

Note this step did **not** resolve the standing `sources` contradiction logged in
step 1: the schema sets `minItems: 1` while AGENTS.md says to leave `sources: []`
where nothing at all is evidenced. The template sidesteps it rather than settling
it. Worth knowing: ADR-006, the worked example for the un-minuted convention,
carries five sources — the un-minuted-ness is handled by marking the decision
*line* unsourced in the body while `sources` carries the surrounding context. On
that evidence `sources: []` may never be the right answer, and the AGENTS.md
clause may be the thing that is wrong. Steps 13–15.

### Verify by hand

- `python3 tools/validate.py` → counts above. No line should name `templates/`.
- The template's frontmatter parses **identically** under PyYAML and under
  `tools/validate.py` — checked explicitly, because comment handling differs
  between them (below).
- Round-trip tested in a scratch tree: the template copied verbatim into
  `decisions/` validates unfilled (exit 0), and a filled copy — real title, tags,
  `status: accepted`, a `supersedes` key added per the comment, a
  `live-capture:claude-opus` stamp and a real source path — also validates.
- `git status --short decisions/` is empty.

### Noticed, deliberately not fixed

1. **`tools/validate.py` does not strip inline YAML comments.** PyYAML reads
   `status: draft   # draft | accepted` as `draft`; the step-1 reader returns
   `"draft   # draft | accepted"` and the enum check then fails. No record uses
   inline comments and `templates` was in SKIP, so this was invisible until now —
   the old template used them on four lines. The new template uses full-line
   comments only, which both readers handle identically. **This is a real defect
   in the validator, not a template quirk**, and it should be fixed before the
   push hook: a contributor adding a trailing comment to any record will get a
   confusing enum or pattern error. Fixing it needs care — a `#` inside a quoted
   string must survive, and YAML only starts a comment at a `#` preceded by
   whitespace. It belongs with the validator-test work already logged in step 2.

2. **`## Referenced by` is in twelve of thirteen records** and was added to the
   template, since it is part of the convention being matched. It is a backlink
   section, so it starts empty on a new record and is populated by the backlink
   pass. Flagging it because it is the one section added that is not the
   destination of a dropped frontmatter key.

3. **`_plan/PROGRESS.md` still fails**, unchanged from step 2. `_plan` is not in
   `SKIP`. This step removed an entry from `SKIP` rather than adding one, and
   adding `_plan` is not what was asked, so it stands. Still blocking for step 4.

### Does the plan still look right

Yes. One observation about ordering: this step removed `templates` from `SKIP`,
which means the `SKIP` set is now live territory rather than frozen. The
`_plan` entry is the obvious remaining item and could ride along with step 2b —
both are "make main pass its own validator", and step 4 needs both done.

The validator has now been changed in two of three steps (fail-closed rewrite,
SKIP edit) and still has no tests. That gap is compounding: item 1 above is a
defect that a single test over the template file would have caught in step 1.

---

## Step 4 — tracked pre-commit hook blocking credentials

**Branch:** `hooks/pre-commit-credential-block` (commit `0903ba6`), cut from
`template/decision-schema-conformant`. Not merged, no remote yet.
**Status:** done. No pre-push hook added — that is step 5.

### The setup command

```
git config core.hooksPath .githooks
```

Run once per clone. I set it while testing and **unset it again afterwards**, so
it is not currently enabled in this working copy.

### What changed

Two new tracked files.

- **`.githooks/pre-commit`** — a POSIX `sh` wrapper, stored `100755` so a fresh
  clone gets it executable. It resolves the repo root, checks the scanner exists
  and that `python3` is on `PATH`, and refuses the commit if any of that fails.
- **`tools/check_secrets.py`** — the scan itself, standard library only. Split
  out from the hook deliberately: CI in steps 11–12 can run the identical check
  without going through git's hook machinery, which is what "CI mirroring the
  hooks" needs to mean if it is to be worth anything.

**Coverage** is weighted towards generic secrets, as asked. Assignments of
`password` / `passwd` / `pwd` / `passphrase` / `secret` / `client_secret` /
`api_key` / `access_key` / `auth_token` / `aws_secret_access_key` and similar;
JDBC URLs carrying inline credentials in the query string; the Oracle
`thin:user/password@host` form; any URL with `user:pass@host`; PEM and PuTTY
private key headers. Provider tokens are covered too — AWS, GitHub (classic and
fine-grained), Slack tokens and webhooks, Google, Stripe, Anthropic,
OpenAI-shaped, npm, JWT, Azure `AccountKey`. Filenames `id_rsa`/`id_dsa`/
`id_ecdsa`/`id_ed25519`, `*.pem|p12|pfx|jks|keystore|ppk|asc` and `.env` are
refused whatever they contain, with `.env.example`/`.sample`/`.template`/`.dist`
allowed through.

**Scope.** Staged content only, read from the **index** via `git show :path`,
not from the working tree — so what gets scanned is exactly what is being
committed. `_sources/` and `_canon/` are excluded by path prefix.

**Escape hatches.** Placeholder values (`<yours>`, `${VAR}`, `changeme`,
`REDACTED`, `****`, …) are recognised and allowed. A line can be exempted with
an inline `pragma: allowlist secret` marker, which is greppable and shows up in
review — unlike `--no-verify`, which silently disables every hook at once.

### Test results

**The live test asked for.** Staged a throwaway `.properties` file carrying a
JDBC URL, a user and a password assignment copied from the planted fixture.
`git commit` was refused with exit 1, the value redacted in the hook's output,
`HEAD` unchanged. Unstaged and deleted; never committed.

**Detection matrix — 37 cases, 0 wrong.** 23 credential shapes all blocked
(every generic form above, all provider tokens, all key headers). 14 lookalikes
all passed: prose about passwords, a "Password policy" heading, five placeholder
forms, a JDBC URL with no credentials, `walletAlias=`, `user=` on its own,
a host:port line, a markdown table of table names, an allowlisted line, and a
line of `tools/validate.py` containing the word `token`.

**The real fixture.** Copied `_sources/technical/db_config_snippet.properties`
to a path outside the exclusion: all three passwords detected, including the
commented-out one. At its real path it is correctly skipped. The fixture was
read only, never modified or moved.

**Index vs working tree.** A secret present only in the working tree, with a
clean index, commits fine. A secret staged and then cleaned from the working
tree still blocks. Both correct.

**Fail-closed paths, all verified non-zero:** scanner missing (commit exit 1),
`python3` absent from `PATH` (hook exit 1), scanner run outside a repository
(exit 2), unreadable path (exit 2). A clean commit still succeeds.

**No false positive anywhere:** `python3 tools/check_secrets.py --all` over every
tracked file exits 0, the scanner included.

### Two fail-open gaps this hook cannot close from inside

1. **`core.hooksPath` is opt-in.** A clone that never runs the setup command has
   no protection, and nothing in the repository can force it. This is inherent
   to git, not a defect in the hook. CI is the only real backstop, which is an
   argument for steps 11–12 mattering more than they might look.
2. **A non-executable hook is silently skipped, not failed.** Verified: `chmod -x`
   the hook and git commits happily with exit 0. The mode is stored `100755` so a
   fresh clone is fine, but anything that strips the bit — a bad `chmod -R`, a
   filesystem without exec bits — disables the check invisibly. Again only CI
   catches it.

### Noticed, deliberately not fixed

1. **The planted credentials are duplicated in tracked files outside the
   read-only archives, and this hook will not catch them.**
   `_qa/realism_review.md` (lines 146, 161) and `_qa/transform_validation.md`
   (line 35) carry both of the fixture's passwords as bare literal values in
   markdown table cells and prose — not reproduced here. They are not
   assignment-shaped, so no generic rule fires. I scanned `_qa/` rather than excluding it — the brief named only
   `_sources/` and `_canon/` — so those files pass today but would need attention
   if the same values ever appeared in `key=value` form. **This is a decision for
   you:** redact the `_qa/` copies, exclude `_qa/` explicitly, or accept it.
   Catching a bare password in a table cell needs entropy heuristics, which
   false-positive badly on this corpus's table names and host:port strings — and
   a hook that cries wolf gets bypassed, at which point it protects nothing.

2. **`.githooks/` is not in the validator's `SKIP` set.** Harmless right now,
   because the validator only reads `*.md` and the hook has no extension. But a
   `README.md` in `.githooks/` would be validated as a knowledge record and fail.
   I deliberately did not add one; the usage notes live in the hook's own comment
   header instead.

3. **`_build/check_sources.py` is still stranded and still needs PyYAML** —
   carried over from step 1, unchanged.

4. **`_plan/PROGRESS.md` still fails the validator**, and 31 records still fail
   on `generated.at`. Unchanged from steps 2 and 3. Step 5 wires validation into
   pre-push, so **both must be resolved first or every push is blocked**.

### Something I broke and repaired

While testing the hook I used `git reset --hard HEAD~1` to unwind a throwaway
commit. That discarded the uncommitted two-line edit to `LEARNINGS.md` that had
been sitting in the working tree since before step 1 — the `S11` bullet on the
two mechanisms of staleness. I restored it verbatim from the diff captured in
step 1; `git diff --stat LEARNINGS.md` reads `2 insertions(+)` again, matching
the original exactly. Please eyeball the last paragraph of `LEARNINGS.md` and
confirm it is what you wrote. `--hard` was careless in a tree with unrelated
uncommitted work in it; the throwaway commits should have been unwound with
`reset --soft` and an explicit `git restore` of only the test file.

### Does the plan still look right

Yes, and step 4 landing before step 5 was the right order — the credential block
is useful on its own and does not depend on the validator.

One thing worth stating plainly. Steps 4–6 buy less than the plan implies,
because of the two gaps above: hooks are opt-in, silently skippable, and
bypassable with `--no-verify`. They are a good developer-experience layer that
catches mistakes early, but they are not enforcement. The enforcement in this
plan is steps 11–12, and the value of building the checks as reusable scripts
under `tools/` — as done here — is that CI can run the same code rather than a
drifting reimplementation of it.

### Postscript: the hook blocked this report

Writing this file up, I quoted the test credential verbatim to describe the live
test. The pre-commit hook refused the commit of `_plan/PROGRESS.md` itself,
naming the line. The value has been replaced with a description of it. That was
an unplanned end-to-end test on a real commit rather than a staged fixture, and
it is the more convincing of the two.

It also makes a point worth carrying into steps 13–15: documentation about
credentials is a place credentials leak, and the check has to cover prose files,
not just config.

---

## Step 2b — content pass and validator fix

**Branch:** `content/quote-dates-and-parser-fix`, cut from
`hooks/pre-commit-credential-block`. Four commits: `e000237` validator,
`eab2107` content pass, `975d473` D2, `9223e01` LEARNINGS.md.
**Status:** done. **Main now passes its own validator.**

### Before and after

```
before   VALID=41  INVALID=31  NO_FRONTMATTER=1   exit 1
after    VALID=72  INVALID=0   NO_FRONTMATTER=0   exit 0
```

The record count moves 72 → 72, not 71 → 72: `_plan/PROGRESS.md` left the
denominator when `_plan` joined `SKIP`, and `templates/decision.md` was already
in it from step 3. 71 concept files plus the template.

Verified from a fresh clone on `/usr/bin/python3` (3.9.6, the macOS system
Python), not just in this working copy.

### Confirmation: no `generated.at` instant changed

**None.** All 72 compared against `HEAD` by parsing both forms into aware
datetimes: every one equal. Every offset in the corpus was exactly `+00:00`, so
`Z` is the same instant with no arithmetic and nothing to round. All 245 other
date values (`updated`, `stale_after`, `sources[].last_modified`) are
byte-identical once quotes are ignored.

No date was ambiguous. Every value in the corpus matched one of three exact
shapes before the pass, and the transform refused to touch anything that did
not — it was written to stop rather than guess.

### What changed

**1 + 2. Quoting and normalisation.**

```
generated.at    31  normalised to YYYY-MM-DDTHH:MM:SSZ, and quoted
generated.at    40  already RFC 3339, quoted
date values     34  bare values quoted (all sources[].last_modified)
               212  already quoted, left alone
```

71 files rewritten; the template was already fully quoted. **Frontmatter only** —
checked explicitly that every file's body is byte-identical to `HEAD`.

Why quoting rather than reformatting, demonstrated rather than asserted:

```
at: 2026-08-23T10:37:09Z      -> loads as datetime -> re-serialises as  2026-08-23 10:37:09+00:00
at: "2026-08-23T10:37:09Z"    -> loads as str      -> re-serialises as '2026-08-23T10:37:09Z'
```

That is the S4 round-trip, closed. The schema pattern is now a tripwire for it
rather than the only defence.

Single- and double-quoted values were both left as they stood. The mix is
cosmetic, and normalising it would have buried a 105-line diff in a 350-line one.

**3.** `_plan` added to `SKIP`, with a comment saying why.

**4.** Trailing comments are now stripped, implementing YAML's actual rule: a
`#` opens a comment only at the start of a scalar or when preceded by
whitespace, and never inside a quoted string. Both cases you named are covered
and tested — `[REDACTED — planted fixture PII-4, see _canon/pii_plant_register.csv]` keeps its hash, `/_sources/doc.md#section-3` keeps its
fragment, `"C#"` is untouched, and `draft  # draft | accepted` is trimmed. Text
after a closing quote that is not a comment is rejected rather than guessed at.
Checked against PyYAML on eleven comment cases and on all 72 records: identical.

**5.** `20260324-var008-february-reload-deferred.md` set to
`status: superseded`. Its `superseded_by` was already populated and its
replacement already carried the matching `supersedes`. The only status value
changed. Corpus status counts are now `accepted 8, draft 2, superseded 3` across
the thirteen records, plus the template at `draft`.

**6.** The S11 bullet in `LEARNINGS.md` committed verbatim — two insertions, zero
deletions, no rewording, no co-author trailer since it was not written in this
session.

### Verify by hand

- `python3 tools/validate.py` → `VALID=72 INVALID=0 NO_FRONTMATTER=0`, exit 0.
- `git diff HEAD~4 --stat` → 73 files: 71 records, `LEARNINGS.md`,
  `tools/validate.py`.
- `git log --oneline -4` → the four commits are separable; the content pass and
  the D2 status change are deliberately in different commits even though they
  touch the same file, so the one status change can be reviewed on its own.
- `python3 tools/check_secrets.py --all` → exit 0.

### Noticed, deliberately not fixed

1. **Quote style is mixed** — 125 double-quoted, 71 single-quoted date values,
   now joined by 105 newly double-quoted ones. All valid, all matching the
   schema. Left alone deliberately; if you want one style it is a separate
   mechanical pass, and it is the kind of thing a formatter should own rather
   than a human.
2. Everything in section D of `~/Downloads/OKFdemo-open-decisions.md` still
   stands, except **D2**, which this step closed.
3. **C1 and C2 from that document are still open** and neither is affected by
   this step: the `sources: minItems: 1` versus AGENTS.md `sources: []`
   contradiction, and the credential copies in `_qa/`.

### Does the plan still look right

Yes, and step 5 is now unblocked — main passes, so a pre-push hook running the
validator will not refuse every push.

Two things worth carrying into step 5. First, the validator has been modified in
four of the five steps so far and **still has no tests**; this step fixed a
parser bug found by accident in step 3, which is the second such bug. Before it
becomes a push gate, a test file over the YAML subset, the fail-closed exits and
one fixture per schema rule is cheap insurance. Second, `D1` is now the obvious
next tightening: `stale_after`, `updated` and `sources[].last_modified` still use
`format: date`, which is annotation-only and therefore unenforced. Every one of
those 246 values is clean and quoted as of this commit, so converting them to
patterns costs nothing today and closes the last fail-open in the schema.

---

## Step 4b — test suite for `tools/validate.py`

**Branch:** `tests/validator-test-suite` (commit `5deed0e`), cut from
`content/quote-dates-and-parser-fix`. Nothing else touched except one line of
`SKIP`.
**Status:** done. **One test fails, deliberately left failing — see below.**

### The command

```
python3 tests/test_validate.py          # all of it
python3 tests/test_validate.py -v       # case by case
```

Standard library only. Verified from a clean clone on `/usr/bin/python3` (3.9.6).
`37 tests`, currently `FAILED (failures=1)`.

### What is there

Two layers.

- **Unit** — calls `read_frontmatter()` directly and pins the YAML subset the
  reader implements, including what it must *refuse*.
- **End-to-end** — copies `tools/validate.py`, the real schema and one fixture
  into a throwaway tree and runs it as a subprocess, so exit codes are tested
  the way a hook experiences them. That is the layer a push gate depends on.

**44 fixtures** in `tests/fixtures/records/` as real `.md` files — 16 `pass-*`,
28 `fail-*`. `tests` is now in the validator's `SKIP` set; these records are
deliberately broken and must never be validated as knowledge.

Coverage against what was asked:

| Area | Cases |
|---|---|
| Fail-closed | schema missing, schema unreadable (`chmod 0`, skipped if the user can still read it), schema not JSON, schema using an unimplemented keyword, schema using an unchecked format, no records at all, unparseable record |
| Step 1 defect | block scalar `\|` and folded `>-` both rejected |
| Step 3 defect | trailing comment stripped after a plain value, after a quoted value, on a list item; whole-line comment ignored |
| `#` that must survive | inside double quotes, inside single quotes, with no preceding space, in a URL fragment |
| Dates post-2b | quoted and unquoted timestamps read alike; a date is not type-converted to `datetime` |
| Nesting | nested object, array of objects, array of objects containing an array of objects (`contested[].positions[]`), sequence flush with its key, folded multi-line scalar |
| Outside the subset | flow collection, anchor, tab indent, unterminated quote, junk after a quoted value, duplicate key |
| Schema rules | pass and fail fixture each for the status enum, `generated.by`, `generated.at`, `sources`, `contested` structure and its required fields, `additionalProperties`, `uniqueItems`, required `type` |

Every `fail-*` fixture asserts the **reason**, not just the failure, so a check
that starts failing for a different reason cannot quietly keep passing. A
completeness test also asserts that no fixture exists which no test refers to,
and no test refers to a fixture that does not exist.

### The failing test — a real defect, reported not fixed

```
FAIL: test_every_fail_fixture_is_rejected_for_the_stated_reason
      (fixture='fail-sources-empty.md')
AssertionError: 'sources: needs at least 1' not found in
      '      YAML PARSE ERROR  line 10: flow collections are not supported'
```

**`minItems: 1` on `sources` is unreachable. It can never fire.**

The only way to write an empty array in YAML is `sources: []`, which is a flow
collection, and the reader rejects flow collections before any schema rule runs.
The alternative, `sources:` with no value, parses as null and fails the type
check instead. Probed both:

```
sources: []      -> reader rejects it: line 2: flow collections are not supported
sources:         -> ['sources: expected array, found null']
```

Neither path reaches `minItems`. The rule is dead schema.

This is worse than a tidiness problem, because it collides with C1. AGENTS.md
line 112 tells an author to leave `sources: []` where nothing at all is
evidenced. Following that instruction produces an error message about **flow
collection syntax** — which says nothing about provenance and gives the author
no idea what the actual rule is or that a rule was even involved.

Three ways out, all of them decisions rather than repairs, and none taken here:

1. Delete `minItems: 1` and the AGENTS.md clause together, on the C1 reasoning
   already recorded — ADR-006 shows the un-minuted case carries context sources
   anyway, so an empty array may never be correct.
2. Keep `minItems: 1`, delete the AGENTS.md clause, and accept that the rule is
   unreachable but harmless — it documents intent even though nothing enforces
   it. That is precisely the "claims a rule it does not check" pattern this
   build-out exists to remove, so it is the weakest option.
3. Teach the reader to accept `[]` and `{}` as empty flow collections only. Small
   and well-defined, and it makes `minItems` fire with the right message. This
   is the one I would pick, but it is a change to the validator's YAML subset and
   belongs in its own step.

### Two defects in my own tests, found and fixed here

Both were mine, not the validator's, so fixing them was in scope.

1. **A fixture was passing by matching its own filename.**
   `fail-contested-position-no-value.md` asserted the substring `value` against
   the validator's whole output — which includes the filename. It failed for an
   entirely unrelated reason (malformed indentation) and the test still passed.
   Assertions are now narrowed to the validator's detail lines only. This is the
   exact failure mode the suite exists to prevent, found in the suite itself
   within an hour of writing it.
2. **That fixture was also malformed** rather than testing what it claimed. It
   now carries a position with `source` and `held_by` but no `value`, and fails
   with `contested[0].positions[1]: missing required field 'value'`.

### Verify by hand

- `python3 tests/test_validate.py` → 37 tests, 1 failure, the one described above.
- `python3 tools/validate.py` → `VALID=72 INVALID=0`, exit 0. A test asserts this,
  so the suite fails loudly if the real corpus ever stops validating.
- `git show --stat HEAD` → `tests/` plus one line of `tools/validate.py`.

### Noticed, deliberately not fixed

1. **`fail-sources-empty.md` is left red.** A permanently failing suite is
   corrosive — people stop reading it. This must be resolved by a decision, not
   left as ambient noise, and it should be resolved before step 11 makes the
   suite a required check.
2. **`tools/check_secrets.py` has no tests.** It was verified by a 37-case matrix
   run by hand in step 4 but nothing pins that behaviour. It becomes a CI check
   at the same time the validator does. Same argument, same risk.
3. Section C of `~/Downloads/OKFdemo-open-decisions.md` still stands; the failing
   test above is new evidence for **C1** specifically.
4. Step 2c is still mid-flight: the sweep was reported and the redaction of the
   29 unexpected planted-value copies is awaiting a go-ahead. Two of those copies
   are in `tools/validate.py` and `_plan/PROGRESS.md`. The fixtures written this
   session deliberately use neutral values (`build#2026`, `Release #42`, `C#`)
   and add no new copies.

### Does the plan still look right

Yes. This step paid for itself immediately — it found a false-passing test in its
own first run and an unreachable schema rule that four sessions of manual
checking had missed, including the session that wrote the rule.

The argument that justified this step now applies unchanged to
`tools/check_secrets.py`, which is the other script steps 11–12 will make
required. Worth a short step before then, or folding its matrix into this suite.
