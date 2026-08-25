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
and tested — `release#42` keeps its hash, `/_sources/doc.md#section-3` keeps its
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

---

## Step 2c — redact the escaped fixture values

**Branch:** `redaction/planted-fixture-values` (commit `4b518eb`), cut from
`main`. **`main` was fast-forwarded to the step 4b tip first — see below.**
**Status:** done. No history rewritten. No entropy detection added to the hook.

### Count redacted, per file

| File | Occurrences redacted | Treatment |
|---|---|---|
| `_qa/transform_validation.md` | 13 | marker |
| `_qa/realism_review.md` | 9 | marker; grep commands kept, their output redacted |
| `_qa/mechanical_checks.md` | 5 | marker |
| `tools/validate.py` | 1 | replaced with `release#42`, not marked |
| `_plan/PROGRESS.md` | 1 | marker |
| **total** | **29** | |

Occurrence counts exceed line counts in two files because a single table cell
held two values of one plant — PII-3's account and IFSC fragments, PII-4's two
passwords. Each such cell takes one marker, since the register defines them as
one plant.

### `_sources/` and `_canon/` were not touched — confirmed

`git status --porcelain -- _sources _canon` returns nothing. The step 2c sweep
was re-run after the edits:

- **Outside the archives: zero occurrences remain.** Was 29.
- **Inside the archives: 37 occurrences, unchanged.** `_canon/BRIEF.md` 12,
  `_canon/pii_plant_register.csv` 12, `_canon/fact_ownership.csv` 5, and one or
  two in each of the five registered `_sources/` homes.

### Verify by hand

- `python3 tools/validate.py` → `VALID=72 INVALID=0`, exit 0.
- `python3 tests/test_validate.py` → 37 tests, 1 failure, still only the known
  `fail-sources-empty.md` one. The `release#42` substitution does not weaken the
  docstring's claim: the property is pinned by
  `test_hash_without_a_preceding_space_survives` and by
  `tests/fixtures/records/pass-hash-no-leading-space.md`.
- `python3 tools/check_secrets.py --all` → exit 0.
- `git diff HEAD~1 --stat` → five files, 24 insertions, 24 deletions.

### `main` was merged as a precondition, not as part of this step

The instruction said to branch from the merged `main`, but `main` was still at
`ac03fa9` — the pre-enforcement fossil. The six-branch chain was linear, so
`git merge --ff-only` brought all 15 commits with no merge commit and no rewrite.
`main` is now `b8240fe`, and it passes its own validator (`VALID=72 INVALID=0`,
exit 0) and carries its own test suite. Flagged because it is a change to `main`
that this step did not itself name; it matched the recommendation in
`~/Downloads/OKFdemo-open-decisions-step4b.md` section B, which the instruction
appeared to be answering.

### Finding for the LEARNINGS pass in 13–15

**An unfilled verification field is not a neutral default — it reads as a passed
check.** Two instances, and they are not the same shape. The distinction matters
for how the rule gets written.

1. **`_canon/pii_plant_register.csv` — filled, and wrong.** Its trailing note
   says *"verified stays 'pending' until the QA phase confirms each plant is
   present exactly once and nowhere else."* Every row's `verified` column reads
   **`yes`**, not `pending`. So the check was recorded as performed, and the
   assertion it certifies was already false when it was recorded — the three
   QA reports doing the verifying were themselves the leak. A filled
   verification field that was never actually verified is worse than an empty
   one, because it is affirmative: a reader has to disprove it rather than
   notice its absence.

2. **The schema's `verified` key — defined, never used.** `verified` is declared
   in `schemas/concept.schema.json` with required `by` and `at` subfields, and is
   used by **zero** of the 72 records. Its own description says human review is
   "NOT to be written by any transform stage" — so the field exists precisely to
   record the thing that has never once been recorded. This is the shape the rule
   as originally stated describes: a channel that exists but is never exercised,
   which reads as "human review happens here" to anyone looking at the schema.

The general rule for the rewrite should cover both: **a verification field is
only worth having if something fails when it is absent or stale.** Neither of
these has that property today. The register's `yes` was never checked against the
corpus; the schema's `verified` is never required, never dated against
`stale_after`, and never blocks anything.

Worth noting this is directly checkable and therefore, by the governing
principle, schema or CI work rather than an AGENTS.md sentence — a check that
"every plant in the register appears exactly once outside `_qa/`" is roughly the
step 2c sweep, already written, and could be a third script under `tools/`.

### Noticed, deliberately not fixed

1. **`_canon/` still re-registers all five values across three files** —
   `pii_plant_register.csv`, `BRIEF.md`, `fact_ownership.csv`. Left untouched as
   instructed. The fixture has four homes inside the archives rather than one,
   which is why the register's "exactly once and nowhere else" claim cannot be
   true even of `_canon/` itself.
2. **`_qa/transform_validation.md` still concludes** *"No PII leaks. All five
   planted values remain contained in `_sources/`."* — immediately below the
   table that was leaking them. The sentence is now false in a second way: the
   values are contained, but only because they were just redacted. Left alone
   because rewriting QA findings is not redaction, and that document's wrongness
   is itself evidence for the finding above.
3. Everything in `~/Downloads/OKFdemo-open-decisions-step4b.md` sections A2, A3
   and C still stands.

### Does the plan still look right

Yes, and step 5 is now genuinely unblocked: `main` passes its own validator, so a
pre-push hook can be developed and tested against it.

One thing this step changes about the plan's shape. The credential hook from step
4 would not have caught any of these 29 — they are bare values in prose and table
cells, not assignments — and per instruction it stays that way. So the containment
story for planted values is not the hook; it is the sweep, which currently exists
only as a script I wrote inline twice and did not keep. If that check matters
going forward it should become `tools/check_plants.py` alongside the other two,
and run in CI at steps 11–12. Raising it rather than doing it.

---

## Step 2c — re-issued, found already complete. No action taken.

Step 2c was issued a second time. The work already existed on
`redaction/planted-fixture-values` (`4b518eb` redaction, `df6ac63` report),
branched from `main` and **still unmerged**, which is why `main` still shows the
values and the step looked outstanding.

Verified the existing branch against every specification in the re-issued
instruction before concluding it needed no work:

| Requirement | State |
|---|---|
| `tools/validate.py` — neutral token, not a marker | `release#42`, no marker |
| `_plan/PROGRESS.md` — redaction marker | marker present |
| `realism_review.md:153`/`:171` — keep command, redact output | grep command intact, output replaced |
| `_qa/*` — `[REDACTED — planted fixture PII-N, …]` | exact format, 24 markers |
| `_sources/` and `_canon/` untouched | `git diff main..branch -- _sources _canon` empty |
| Verification-field finding recorded | present, both shapes |
| No history rewrite | two ordinary commits |
| No entropy detection added to the hook | `check_secrets.py` unchanged |

**Nothing was redone.** Re-running the redaction would have produced a second
divergent branch doing the same work.

### Correction to the re-issued instruction's premise

The instruction states that `pii_plant_register.csv` "carries `verified:
pending`". It does not. All five rows read **`verified = yes`**. The word
`pending` appears only in the file's trailing comment — *"verified stays
'pending' until the QA phase confirms each plant is present exactly once and
nowhere else"* — which describes the intended protocol, not the recorded state.

This makes the finding stronger than the rule as stated, and the rule for 13–15
needs to cover both shapes rather than only the unfilled one:

- **Filled and false** (`pii_plant_register.csv`): the check was recorded as
  performed, and the assertion it certifies was already untrue when recorded —
  the three QA reports doing the verifying were themselves the leak. An
  affirmative false verification is worse than an absent one, because a reader
  must disprove it rather than notice a gap.
- **Defined and never exercised** (the schema's `verified` key): declared with
  required `by`/`at`, used by zero of 72 records. This is the shape the stated
  rule describes.

The general rule already recorded stands and covers both: **a verification field
is only worth having if something fails when it is absent or stale.**

### Still outstanding

`redaction/planted-fixture-values` is **not merged**. Until it is, `main` carries
planted fixture values in five files. Merging it touches `main`, which the
standing rule reserves, so it is left for an explicit instruction.

---

## Step 4c — make existing checks fire

**Branch:** `fix/empty-flow-collections-and-scanner-tests`, cut from
`redaction/planted-fixture-values`. Two commits: `96e014b` reader fix,
`7107a13` scanner tests.
**Status:** done. Suite is green.

### Full suite

```
python3 tests/test_validate.py     ->  Ran 55 tests   OK
python3 tools/validate.py          ->  VALID=72 INVALID=0, exit 0
python3 tools/check_secrets.py --all ->  exit 0
```

Verified from a clean clone on `/usr/bin/python3` (3.9.6). **55 tests, 55
passing, 0 failing.** The step 4b known failure is gone.

| Class | Tests | What |
|---|---|---|
| `TestYamlSubset` | 30 | the reader's YAML subset, including the six new empty-collection cases |
| `TestCredentialScanner` | 9 | the ported matrix and the scanner's integration behaviour |
| `TestFailsClosed` | 7 | every path that must refuse to report success |
| `TestSchemaRules` | 4 | fixture-driven, 16 pass and 28 fail fixtures |
| `TestSkipSet` | 2 | `tests` is skipped; the real corpus still validates |
| `TestCredentialScannerKnownGaps` | 2 | **documents gaps, not passing behaviour** |
| `TestCredentialScannerKnownFalsePositives` | 1 | **documents a defect, not passing behaviour** |

Matrix sizes inside those tests: 25 must-block, 14 must-allow, 3 known-gap,
28 failing fixtures.

### 1. `sources: minItems: 1` is now reachable

The reader accepts `[]` and `{}`, with optional inner whitespace, and nothing
else. `sources: []` now reports:

```
SCHEMA  sources: needs at least 1 item(s), found 0
```

It names the provenance rule. The known-failing test passes and its annotation
is removed.

**Why the scope is narrow**, as recorded in the commit message: emptiness is the
only thing a flow collection expresses that block style cannot — there is no way
to write an empty sequence in block YAML — so `[]` is not a stylistic
alternative to something already supported, it is the sole spelling of a state a
schema rule needs to judge. A populated flow collection is a different problem
entirely (quoting, escaping, nesting, commas) that the reader would have to get
right or silently misparse, and every non-empty collection in this corpus is
written in block style. Rejecting the populated form keeps the fail-closed
property, and the message now names the restriction rather than implying flow
collections are wholly unsupported.

One consequence: an empty array is now legal wherever the schema permits one, so
`tags: []` validates. That is correct — the schema should decide which
collections may be empty, not the parser.

### 2. Credential scanner folded into the same suite

Same file, same harness, stdlib only. Beyond the ported matrix it pins the
filename rules, the `_sources/`//`_canon/` exclusion, redaction of reported
values, exit codes 0/1/2, and `--staged` against a real temporary git repository
in both directions — a secret only in the working tree must not block, a secret
staged then cleaned from the working tree must still block.

**Every value in the suite is synthetic and invented for it.** None is a planted
fixture. A test suite quoting the real ones is precisely how they reached the QA
reports, and step 2c had just finished removing them.

### The three tests that document known behaviour we do not want

Asserted as they behave, not as we wish, and written so that narrowing the gap
turns them **red** and forces a deliberate decision.

1. **`KnownGaps`** — a bare value in a markdown table cell, in a backticked
   table cell, and quoted in prose are all missed. These are exactly the shapes
   step 2c proved escape: every planted value reached the QA reports in one of
   them and no rule fired. A companion test pins the boundary — the same value
   in `key=value` form *is* caught — so the gap is characterised, not just
   noted. Not closed: entropy heuristics false-positive on this corpus's table
   names and `host:port` strings, and a hook that cries wolf gets bypassed.
2. **`KnownFalsePositives`** — a redaction marker in assignment form is itself
   flagged as a credential, because the placeholder pattern has no leading `[`.
   **Found while writing this suite.** No tracked file trips it today, because
   step 2c wrote its markers inside backticks; a file that redacted a secret in
   assignment form would be blocked from commit for containing the redaction of
   the thing it removed. Out of scope here; one character in the placeholder
   pattern would fix it.

### Found while writing the tests

The suite's own `test_the_tracked_tree_is_clean` caught **four credential-shaped
lines in the test file itself** — unmarked provider-token data, a variable
literally named `secret`, whose assignment matched the generic rule, and a
docstring quoting an assignment. All fixed by marking the data lines, renaming
the variable and rewording the prose. The scanner testing its own test file is
not a trick: it is the same mechanism that caught the step 4 progress report.

### Noticed, deliberately not fixed

1. The `[REDACTED …]` false positive above.
2. `redaction/planted-fixture-values` is still unmerged, and this branch now sits
   on top of it. `main` still carries planted fixture values in five files.
3. Sections C and D of `~/Downloads/OKFdemo-open-decisions-step4b.md` stand,
   minus the `minItems` item, which this step closed.

### Does the plan still look right

Yes. Both of this step's items were consequences of the step 4b suite existing,
which is an argument for having built it when we did rather than at step 11.

For step 5: both checks now have tests, so wiring the validator into pre-push is
a mechanical change to a covered component. Worth deciding before then whether
the pre-push hook runs the **test suite** as well as the validator — the suite
is the thing that catches a validator regression, and it takes two seconds.

---

## Step 5 — pre-push hook running the content checks

**Branch:** `hooks/pre-push-content-checks` (`706ca1d`), cut from
`fix/empty-flow-collections-and-scanner-tests`.
**Status:** done, but **the hook blocks every push on `main` as it stands** —
see below. Gate check passed before starting: `main` (`b8240fe`) validates
`VALID=72 INVALID=0`, exit 0.

### Which checks pass on `main` today

| Check | Exit | Result |
|---|---|---|
| `tools/validate.py` | 0 | `VALID=72 INVALID=0 NO_FRONTMATTER=0` |
| `tools/check_sources.py` | 0 | `refs=230 files=71 unresolved=0` |
| **`tools/check_links.py`** | **1** | **`checked=444 files=71 unresolved=18`** |
| `tools/check_supersession.py` | 0 | `links=6 files=71 unresolved=0` |

**Three of four pass. Link resolution fails on 18 pre-existing broken links.**

### Run time

**0.27s** for all four checks; **0.84s** wall for the hook including shell
startup. Nowhere near the point where anyone would reach for `--no-verify` out of
impatience. Worth re-measuring when CI runs them over a larger corpus, but the
work is linear in file count and the corpus is 71 files.

### The 18 broken links — found, not fixed

They are all the same defect: **the link is inverted.** The bundle path sits in
the link *text* and a table name sits in the *target*.

```
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](FACT_INVOICE_LINE)
                                                   ^ target: no such file
```

It should be `[FACT_INVOICE_LINE](/concepts/tables/bcpl-edw-fact-invoice-line.md)`.
Rendered, each one is a dead link whose visible text is a path — so it reads as
navigable and is not. Across 6 files in `concepts/tables/`.

Not repaired: the step said to add a link check, not to fix link drift. Proved
repairable in a scratch copy — inverting the 18 takes the check to
`unresolved=0`, exit 0 — but that scratch copy was discarded.

**This is a prerequisite for enabling the hook.** Until those 18 are fixed,
turning on `core.hooksPath` means no one can push anything.

### Design notes

- **Four separate scripts**, each runnable alone, because steps 11–12 run these
  same files. A hook and a CI job holding their own copies of the logic drift,
  and the drift is silent.
- **`check_sources.py` was moved, not reimplemented** (closes D4). It dropped
  PyYAML and now imports the frontmatter reader from `validate.py`. The other two
  do the same — one reader, not four.
- **Unreadable frontmatter is deferred, not guessed.** The resolution checks
  exit 2 and name `validate.py` as the tool that owns the diagnosis, rather than
  silently skipping a file they cannot parse.
- **`templates` is excluded from resolution** but still schema-validated. Its
  references are placeholders on purpose. Excluding the template rather than
  teaching the checkers to recognise placeholder syntax means an unfilled *copy*
  in `decisions/` is still caught — which is the failure that actually matters.
- **`check_supersession` checks only that the target exists.** Whether the pair
  must point back at each other, and whether `status` must agree, are open
  decisions (D3). A check that assumed an answer would enforce an unmade one.
- **Backlink symmetry is not included**, as instructed.

Fail-closed paths all verified non-zero: missing script (1), absent `python3`
(1), nothing found to check (2), reader unimportable (2), unreadable frontmatter
(2).

### These hooks are not the enforcement layer

Stating it plainly because the report above could be misread as a control being
put in place. It is not one. All four gaps from step 4 remain, and step 5 adds a
fifth:

1. `core.hooksPath` is opt-in. A clone that never runs the setup command has no
   hooks at all, and nothing in the repository can compel it.
2. A hook without its executable bit is **silently skipped with exit 0**.
3. `git push --no-verify` bypasses it, as `git commit --no-verify` bypasses
   pre-commit.
4. Nothing verifies that the person pushing ran anything.
5. **New, and specific to pre-push: the checks run against the working tree, not
   against the commits being pushed.** If your working tree differs from what you
   are pushing, the hook checked the wrong thing. It is documented in the hook's
   own header rather than papered over.

Steps 4–6 are an early-catch layer that saves people from their own mistakes
quickly and cheaply. **The control is steps 11–12**, where the same four scripts
run on the pushed ref, on a machine the author does not own, with the result
made a required check. Gap 5 above is closed there and only there.

### Noticed, deliberately not fixed

1. **The 18 inverted links.** Blocking for enabling the hook.
2. **The three new scripts have no tests.** `validate.py` and
   `check_secrets.py` each got a suite in 4b/4c precisely because untested
   checks are the risk; three more checks just shipped without one. Not in scope
   here — the step named four checks and their constraints — but it is the same
   argument, and these become required CI checks at the same moment as the other
   two.
3. **The pre-push hook does not run the test suite.** Raised at the end of 4c
   and still worth deciding: the suite is what catches a regression *in the
   checks themselves*, and it takes two seconds.
4. `redaction/planted-fixture-values` and everything above it is still unmerged;
   `main` still carries planted fixture values in five files.

### Does the plan still look right

Yes, with one ordering point. Step 6 should be the link repair, or the link
repair should precede whatever step 6 turns out to be — because until the 18 are
fixed the hook cannot be switched on, and a hook nobody has enabled provides
exactly as much protection as no hook.

---

## Step 6 — `superseded_by` implies `status: superseded` (D3)

**Branch:** `checks/supersession-status-invariant` (`e1600ca`), cut from
`hooks/pre-push-content-checks`.
**Status:** done. Suite green at **65 tests**, verified from a clean clone.

### Which direction fires on `main` today

**Neither.**

| Direction | On `main` | Treatment |
|---|---|---|
| `superseded_by` present, status is not `superseded` | **0** | enforced — exit 1 |
| `status: superseded` with no `superseded_by` | **0** | reported, does not fail |

Direction A fired until step 2b: `20260324-var008-february-reload-deferred.md`
carried `status: draft` alongside a populated `superseded_by`, so any status
filter returned a superseded record as a live open question. That was the D2 fix.
This step is what stops it recurring silently.

Direction B is reported rather than enforced, per the instruction not to assume.
It is worth stating why it might be legitimate: **`deprecated` was folded into
`superseded` in step 2**, on the reasoning that they named one state under two
words. A record retired with no named replacement therefore has no other
spelling available — it must be `superseded`, and it has nothing to point at.
Whether that is a real state this KB needs is an open question, and the check
prints the unpaired records rather than deciding.

### Where it was built, and why not in the schema

**Extended `tools/check_supersession.py`** rather than adding a new script. The
rule is one of a family, and the family belongs together.

Cross-field rules found while looking, as asked:

| # | Rule | Holds on `main` | Expressible in JSON Schema? |
|---|---|---|---|
| 1 | `superseded_by` ⇒ `status: superseded` | yes | yes, `dependentRequired` |
| 2 | `status: superseded` ⇒ `superseded_by` | yes | yes, `dependentRequired` |
| 3 | `supersedes` ⇒ target's `superseded_by` points back | yes, 0 violations | **no** — needs a second document |
| 4 | `supersedes` ⇒ target's `status` is `superseded` | yes, 0 violations | **no** — needs a second document |

**This changes the calculus in the opposite direction to the one anticipated.**
Finding three more rules would normally argue for implementing the keyword
properly. It does not here, because **half the family is out of JSON Schema's
reach entirely** — it validates one document at a time and cannot follow
`supersedes` into the record being superseded. Implementing `dependentRequired`
would buy rules 1 and 2 and leave 3 and 4 needing a script anyway, so the schema
engine would grow, get its own tests, and the family would still be split across
two places.

The answer to "a growing pile of one-off scripts" is not a schema keyword. It is
**one script per invariant family**: `check_supersession.py` owns all four
supersession rules, `check_links.py` owns link resolution, `check_sources.py`
owns provenance resolution. That keeps the tool count flat as rules are added.

**Rules 3 and 4 were found, not built** — the instruction was to stop and say so.
Both hold on `main` today. They are one small function in the script that
already loads every record, and they close the supersede protocol's remaining
mechanical claims.

### Two other schema claims that are not enforced

Not cross-field, so out of scope here, but they are the same fail-open pattern
and each is one line in `schemas/concept.schema.json`:

- **`generated`** — the schema's own description says "Required on every
  authored concept". It is not in `required`. All 71 records carry it.
- **`title`** — "required by local convention". Not in `required`. All 71 carry
  it. `validate.py` reports `MISSING_TITLE` without failing.

Both would cost nothing to enforce today and both currently claim a rule nothing
checks.

### Hook and timing

**No hook change was needed** — `check_supersession` was already in the pre-push
list from step 5, so extending that script extended the hook. That is the
argument for grouping by family rather than by rule, made concrete.

All four checks: **0.25s**. Unchanged.

| Check | Exit | Result |
|---|---|---|
| `validate.py` | 0 | `VALID=72 INVALID=0` |
| `check_sources.py` | 0 | `refs=230 unresolved=0` |
| **`check_links.py`** | **1** | **`unresolved=18`** — still the 18 inverted links |
| `check_supersession.py` | 0 | `links=6 broken=0 unpaired=0` |

### Noticed, deliberately not fixed

1. **The 18 inverted links.** Still the only thing standing between this hook and
   being switchable on. Unchanged from step 5.
2. **Rules 3 and 4 above**, found and not built, per the instruction.
3. **A third instance of the same phenomenon**: the step 5 progress report tripped
   the credential scanner, because it described a variable named `secret` in
   assignment form. Step 4's report did it with a quoted password, step 4c's test
   file did it with test data. **Writing about credentials keeps producing
   credential-shaped prose.** Worth a line in the 13–15 LEARNINGS pass: the
   scanner is right to be blunt about it, and the cost is one reword each time.
4. `check_links.py` and `check_sources.py` still have no tests;
   `check_supersession.py` now has ten. The gap named in step 5 is two-thirds
   still open.

### Does the plan still look right

Yes. One observation for step 11: the family-per-script shape means CI wires four
stable script names, not a list that grows with every rule. That is worth
locking in before CI is written, because a CI config enumerating rules would have
to change every time a rule is added, and would drift from the hook.

---

## Step 2c (reduced scope) — two of three items were already done

**Branch:** `docs/progress-quote-corrected-docstring`, cut from
`checks/supersession-status-invariant`, **not** from `main`. See the state
corrections below.
**Status:** one edit made. Nothing else needed doing.

### Item by item

1. **`tools/validate.py` — neutral token.** Already done, in the original 2c
   commit `4b518eb`. The docstring reads `` `release#42` `` and now sits at line
   147, not 134; the line numbers moved when step 4c added empty-flow-collection
   handling above it. No change.
2. **`_plan/PROGRESS.md` — neutral token.** **This was the one outstanding item,
   and it was a real inconsistency.** The original 2c pass gave this line a
   redaction marker while giving the docstring a neutral token, so the report
   quoted a version of the code that did not exist. It now quotes
   `` `release#42` ``, matching `tools/validate.py:147`. One line changed.
3. **The register finding.** Already recorded, at lines 877–915 of this file,
   from the original 2c report. It carries both shapes of the rule rather than
   only the stated one — see the correction repeated below.

### `_qa/` was left as it is, which means left redacted

The reduced scope says not to redact `_qa/`, on the reasoning that it is
prototype output that will be discarded. The original 2c pass had already
redacted it — 22 markers across three files — and that work is in the chain
under this branch.

**Left alone deliberately.** The instruction's reasoning is about not spending
effort on a throwaway artifact, and reverting would spend more effort than the
redaction did, to put fixture values back into files. Nothing is gained by
undoing it. Flagging rather than deciding silently: say if you want it reverted
and it is one `git revert` of the `_qa/` hunks.

### Three corrections to the instruction's premises

1. **`main` is not merged.** It sits at `b8240fe`, which is where the step 1–4b
   chain was fast-forwarded to before the original 2c. It does not contain 2c,
   4c, 5 or 6. Branching from `main` as instructed would have produced a branch
   missing four sessions of work and would have re-done items 1 and 3 that
   already exist. This branch is cut from the chain tip instead.
2. **The test suite is not 37 tests with a red `minItems`.** That was the state
   at the end of step 4b. Step 4c fixed the `minItems` failure by teaching the
   reader empty flow collections, then folded in the credential scanner's
   matrix; steps 5 and 6 added more. **The suite is 65 tests, all passing.**
3. **The register's `verified` column does not read `pending`.** All five rows
   read **`yes`**. `pending` appears only in the file's trailing comment,
   describing the intended protocol. This makes the finding stronger than the
   rule as stated, and it needs both shapes:
   - **filled and false** — the check was recorded as performed, and the
     assertion it certifies was already untrue when recorded, because the three
     QA reports doing the verifying were themselves the leak;
   - **defined and never exercised** — the schema's `verified` key, declared
     with required `by`/`at`, used by zero of 72 records.

   The rule that covers both, already recorded above for the 13–15 pass: **a
   verification field is only worth having if something fails when it is absent
   or stale.**

### Verify by hand

```
python3 tools/validate.py       ->  VALID=72 INVALID=0 NO_FRONTMATTER=0, exit 0
python3 tests/test_validate.py  ->  Ran 65 tests, OK
```

Both unchanged by this edit, which touched one line of prose in a file the
validator skips.

---

## Step 7 — remote created, `main` pushed, scanner experiment run

**Branch:** `remote/create-origin-and-push`, cut from
`docs/progress-quote-corrected-docstring`.
**Remote:** `https://github.com/shsagnik/OKFdemo` — **private**, created empty
with no README, .gitignore or licence, so no unrelated-histories merge.

Repo name was not specified in the instruction; `OKFdemo` was chosen to match the
local directory. Renaming it later costs one command and a remote URL update.

### Gate check before starting

`main` (`b8240fe`) validates `VALID=72 INVALID=0`, exit 0. Its test suite runs 37
tests with 1 failure — the known `minItems` red, which is **main's expected
state**, because `main` predates step 4c. Gate satisfied.

### The experiment — a negative result, and a stronger one than expected

**Did push protection block the push? No.**
**Did secret scanning raise an alert afterwards? No.**

But not for the reason anticipated. The hypothesis was that GitHub's scanners
match provider-specific token formats and would skim past a generic
`password=` in a properties file. **We never got far enough to test that.**

```
PATCH /repos/shsagnik/OKFdemo  security_and_analysis[secret_scanning][status]=enabled
  -> HTTP 422  "Secret scanning is not available for this repository."

GET  /repos/shsagnik/OKFdemo/secret-scanning/alerts
  -> HTTP 404  "Secret scanning is disabled on this repository."
```

**Secret scanning could not be switched on at all.** On a private repository it
requires GitHub Advanced Security / Secret Protection, which this account does
not carry (`plan: null`). Push protection depends on secret scanning, so it
stayed `disabled` too — the PATCH returned success but the resulting object
still reads `"secret_scanning_push_protection": {"status": "disabled"}`.

The planted credential is confirmed present in the pushed history:
`origin/main:_sources/technical/db_config_snippet.properties` carries two
`odi.stg.password` lines.

**Three layers to the finding, in increasing order of importance:**

1. **Availability, not pattern matching, is the binding constraint.** The
   platform control is not weak here — it is absent. Nothing scanned anything.
2. **Even where it is available, generic secrets are a separate opt-in.** The
   settings object exposes `secret_scanning_non_provider_patterns`, GitHub's
   scanner for exactly the kind of secret planted here, and it reads
   `disabled`. So the original hypothesis survives as a second-order finding:
   under GHAS, generic patterns still need deliberate enabling.
3. **Visibility and safety pull in opposite directions.** Secret scanning is
   free on *public* repositories. The configuration that protects the content —
   private — is the configuration that removes the scanner. Going public to gain
   the scanner would publish the thing the scanner is meant to protect. Not
   tested here, deliberately: flipping the repo public to observe it would have
   published the corpus.

### So what is actually standing there

**On this repository today: nothing.**

- Platform secret scanning: unavailable, cannot be enabled.
- Push protection: unavailable, depends on the above.
- `tools/check_secrets.py`: exists, tested by 25 must-block cases — but
  `core.hooksPath` is **still unset**, so the pre-commit hook does not run.
- CI: does not exist yet. Steps 11–12.

This answers the question the step posed. It is not that our hook is a
belt-and-braces backup to a platform control. **On a private repository on a
standard plan, the local hook is the only mechanism that exists at all** — and
it is currently switched off. That makes steps 11–12 load-bearing rather than
confirmatory, because a CI job runs regardless of what any individual has
configured on their machine.

It also retroactively justifies the weighting in step 4. Building the scanner
around generic `password=` / JDBC / private-key shapes rather than provider
tokens was the right call, and not because GitHub's provider patterns are
redundant — because on this repository they are not running.

### What is on the remote

`main` plus the six merged branches. `git ls-remote --heads origin`:

```
b8240fe  refs/heads/main
90adb5c  refs/heads/tooling/validator-runnable-from-clone
66bde15  refs/heads/schema/settle-concept-schema
08d3110  refs/heads/template/decision-schema-conformant
cee128b  refs/heads/hooks/pre-commit-credential-block
d96ce8a  refs/heads/content/quote-dates-and-parser-fix
b8240fe  refs/heads/tests/validator-test-suite
```

### Not pushed, and worth knowing

`main` on the remote is at the end of **step 4b**. Four sessions of work exist
only locally, on five unpushed branches:

| Branch | Contains |
|---|---|
| `redaction/planted-fixture-values` | step 2c fixture redaction |
| `fix/empty-flow-collections-and-scanner-tests` | step 4c — `minItems` fix, scanner tests |
| `hooks/pre-push-content-checks` | step 5 — pre-push hook, three check scripts |
| `checks/supersession-status-invariant` | step 6 — D3 |
| `docs/progress-quote-corrected-docstring` | step 2c reduced scope |

Consequence: the remote's default branch still carries the known-red `minItems`
test and the pre-4c validator. Anyone cloning it gets the step 4b state. Also
still unpushed: `decision/adr-006-fact-credit-note`, the reference branch that
must never be merged, and `transform/okf-knowledge-base`, which predates all of
this.

### Does the plan still look right

Yes, with one emphasis change. Steps 8–10 declare CODEOWNERS, roles and a
ruleset. Those are review controls and worth having. But this step establishes
that **there is no automated content control on this remote at all** until CI
exists, and that the hooks cannot supply one because they run on machines nobody
else can see. If anything is going to be reordered, moving CI earlier does more
than any of 8–10.

---

## Step 8 — authority declared in the repo

**Merged to `main` as PR #1** (`61b3778`), from
`governance/codeowners-and-maintainers`, branched from `origin/main` rather than
from the local chain — see the divergence note at the end.
**Status:** done. Ordering constraint satisfied: CODEOWNERS is on `main` **before**
step 10 turns on "require review from Code Owners".

### What was added

- **`.github/CODEOWNERS`** — path-scoped, broad rule first since the last
  matching pattern wins. `/schemas/`, `/tools/` and `/.githooks/` are owned
  separately from the corpus because changing them changes what CI enforces.
  `/.github/` owns the declaration of authority itself.
- **`.okf/maintainers.yml`** — `primary: shsagnik`, `deputy: null`,
  `steward: shsagnik`, `effective_from: 2026-08-25`. The limitation below is
  restated inside the file, because that file is the one an agent reads.

**PR #1 is also the first merge commit this repository has ever had.** Every
prior change was rebased, cherry-picked or fast-forwarded.

### `.okf/` needs no SKIP entry

Checked rather than assumed: `tools/validate.py` globs `*.md` only
(`root.rglob("*.md")`), so `maintainers.yml` is never read. Adding `.okf` to
`SKIP` would have been a no-op edit that also conflicts with the chain's copy of
`validate.py`. **If anyone later puts a `.md` under `.okf/`, the entry becomes
necessary** — that is the trigger to watch for.

### Verification: the code owner was NOT assigned, and that is the finding

Opened PR #2 touching `schemas/concept.schema.json`, inspected it, closed it
unmerged and deleted its branch. Nothing landed — `git diff origin/main --
schemas/` is empty.

```
author         : shsagnik
files          : ["schemas/concept.schema.json"]
reviewRequests : []          <- empty
```

The file is not broken. GitHub's own resolver validates it:
`GET /repos/shsagnik/OKFdemo/codeowners/errors` returns `{"errors": []}`, which
is the endpoint that reports an unknown username or one without write access —
the failure mode that otherwise happens silently.

**No reviewer was requested because GitHub never requests review from the pull
request author, and the author is the sole code owner.** On this repository
CODEOWNERS is correctly configured and cannot produce an observable effect. The
verification demonstrates the limitation rather than confirming the mechanism,
which is the more useful result: we now know the control is untested here, not
that it works.

### Transplant requirement — the client repo must be in an organisation

Recorded as instructed, and the verification above is the evidence for it.

On a personal repository there is no second admin, no teams, and CODEOWNERS can
name only individual users. So:

- The primary/deputy split in `maintainers.yml` has nowhere real to live.
  `deputy: null` is honest rather than lazy — there is no one to name.
- If the primary is unavailable, nothing merges.
- If the primary leaves, nobody can reassign ownership.
- Self-review is impossible, so a required-review rule either blocks the sole
  owner entirely or is satisfied by nobody reviewing anything.

Acceptable for a prototype whose purpose is to prove the shape. **Not acceptable
on the client machine.** The client repository must be in an organisation, so
that ownership is a team reference rather than a person, and so that a second
admin exists. When that happens: switch CODEOWNERS to team references and add
the deputy as a second owner on every path.

This is the second control in two steps that cannot be exercised on a personal
private repository — step 7 found secret scanning unavailable for the same class
of reason. The pattern is worth naming for 13–15: **several of the controls this
plan installs are organisation features, and a personal repo can hold the
declaration but not the enforcement.**

### Divergence between `main` and the local chain — needs resolving

`main` and the working chain have now diverged in both directions.

- **`main` has** the governance commit and PR #1's merge. It does not have steps
  2c, 4c, 5, 6 or 7.
- **The chain has** those five sessions, including this `PROGRESS.md` entry. It
  does not have CODEOWNERS.

The governance PR was deliberately cut from `origin/main` to keep it minimal —
merging the chain under a "declare authority" title would have landed four
sessions of unreviewed work in a governance PR. That was the right call for the
PR, and it leaves a merge to do.

`PROGRESS.md` will conflict when they meet: both sides appended different
entries after step 4b. It is an append conflict, resolvable by keeping both in
order, but somebody has to do it deliberately.

### Does the plan still look right

Yes, with the ordering constraint honoured. One thing to decide before step 10:
**a required-review rule on this repository will block the only person who can
merge.** With one admin and no second reviewer, "require review from Code Owners"
makes `main` unmergeable except by admin bypass — at which point the rule
records an intention rather than enforcing anything. Worth deciding whether step
10 enables it and documents the bypass, or declares it and defers enabling until
the org move.

---

## Step 9 — bot identity: BLOCKED, and one option in the brief does not work

**Branch:** `identity/record-step-9-blocked`, cut from
`governance/record-step-8`.
**Status:** **not done.** No identity was created. Nothing was configured. The
verification was run against the existing account instead, and it produced a
useful result — see below.

### Why it is blocked

Neither option can be created from here. This is a platform constraint, not a
tooling gap:

- **Fine-grained PAT** — GitHub exposes no API for minting tokens. `POST
  /user/personal-access-tokens` returns `404 Not Found`; a token that can mint
  tokens would defeat the point of scoping them. They are created only at
  `github.com/settings/personal-access-tokens`.
- **Machine user** — a separate GitHub account requires an interactive signup
  with its own distinct email address and verification.
- **GitHub App** — the third option, not in the brief, also requires the web UI
  or a browser-based manifest flow.

Current state: the only collaborator is `shsagnik` (admin), and no GitHub App is
installed.

### The correction that matters: a fine-grained PAT does not give the separation

The brief says either option is acceptable "as long as it is deliberate". **A
fine-grained PAT owned by you is not a separate identity.** It authenticates as
you. Every PR it opens is authored by `shsagnik`.

Run against the current account, which is exactly what a PAT would reproduce:

```
PR author: shsagnik

gh pr review --approve
  GraphQL: Review Can not approve your own pull request (addPullRequestReview)

POST /repos/shsagnik/OKFdemo/pulls/3/reviews  event=APPROVE
  HTTP 422 Unprocessable Entity
  {"errors": ["Review Can not approve your own pull request"]}
```

That is the exact refusal the step asked for, and it fires. But read what it
means with a user-owned PAT in play:

- The agent opens a PR using your PAT → **the PR is authored by you**.
- GitHub then refuses **your** approval of it, because you are the author.
- You are the sole code owner and sole admin, so nobody else can approve.
- The PR is unmergeable except by admin bypass.

So a fine-grained PAT does not merely fail to enforce the split — on this
repository it **inverts** it. Instead of the platform distinguishing who decided
from who executed, it prevents the decider from recording a decision at all. The
merge log would show every agent-opened PR merged by admin bypass, which is
strictly less informative than the honour system it was meant to replace.

**Only a genuinely separate actor delivers the stated goal**: a machine user, or
a GitHub App acting as `name[bot]`. Both make the PR author someone other than
you, which is what leaves you free to approve.

### What is needed from you

Pick one and create it; everything downstream is then a short session.

| | Option | Trade-off |
|---|---|---|
| **a** | **GitHub App** *(recommended)* | Acts as `name[bot]`, a distinct actor. No extra email, no seat, no password to hold. Repo-scoped permissions, and installation tokens expire hourly rather than living on disk indefinitely. More setup than a PAT. |
| b | Machine user | Simplest mental model, one account one token. Needs a separate email address, and GitHub's terms treat machine accounts as a permitted exception rather than the norm — worth reading before relying on it for the client. |
| c | Fine-grained PAT | **Does not achieve the goal.** Recorded only because it was offered; the evidence above is the argument against it. |

For either (a) or (b): grant **write**, not admin — enough to push branches and
open PRs, not enough to change rulesets, CODEOWNERS or settings. **Do not add it
to CODEOWNERS**, so its approval can never satisfy a review requirement.
`.github/CODEOWNERS` on `main` currently contains zero bot entries, which is the
correct starting state.

### Where the credential should live, once it exists

Not yet configured, since there is nothing to configure. The intended shape,
recorded now so it is not improvised later:

- **Not in the repository**, under any circumstance. `tools/check_secrets.py`
  would block it at commit, which is the correct outcome.
- **Not in `~/.gitconfig`** or any file that gets copied between machines.
- A separate credential store entry, or an environment variable sourced from one
  — held locally like a dev secret, but **unlike a dev secret it is not shared
  between people**. One human, one account, one token; the bot gets its own.
- For a GitHub App, the private key is the thing held; installation tokens are
  minted from it per-run and expire, so nothing long-lived sits on disk.

### Verification performed, and cleanup

PR #3 opened with a trivial change, self-approval attempted, refusal captured
verbatim above, then closed unmerged with its branch deleted. `main` is unchanged
at `61b3778`; no open PRs remain.

### Does the plan still look right

This is the **third** consecutive step where a control turns out to need an
organisation or a paid tier: step 7 secret scanning, step 8 code-owner review,
step 9 a separate actor. That is now a pattern rather than three coincidences,
and it is the single most important thing to carry into 13–15.

The prototype can hold every *declaration* — CODEOWNERS, `maintainers.yml`, the
hooks, the checks. It can enforce almost none of them. The transplant note
should say so plainly: **this repository proves the shape of the controls; the
client repository is where they first actually bind.**

That also sharpens the step 10 question raised at the end of step 8. With no bot
identity, no second reviewer and no second admin, a required-review rule has
nobody who can satisfy it. Step 10 should probably declare the ruleset and
document what it will do once the org and the bot exist, rather than enabling
something whose only possible outcome is admin bypass on every merge.

---

## Step 10 — enforcement: BLOCKED. Nothing was enabled.

**Branch:** `enforcement/record-step-10-blocked`, cut from
`identity/record-step-9-blocked`.
**Status:** **stopped before making any change**, as instructed. No ruleset, no
branch protection, no settings altered.

### Prerequisite: satisfied

`.github/CODEOWNERS` is on `origin/main` and GitHub's resolver reports
`errors: 0`.

### Plan tier: worse than the fallback assumed

The brief anticipated dropping to legacy branch protection on a free plan.
**Both are gated identically.**

```
GET /repos/shsagnik/OKFdemo/rulesets
  "Upgrade to GitHub Pro or make this repository public to enable this feature."

GET /repos/shsagnik/OKFdemo/branches/main/protection
  "Upgrade to GitHub Pro or make this repository public to enable this feature."

GET /repos/shsagnik/OKFdemo/branches/main
  {"name": "main", "protected": false}
```

Legacy branch protection on **private** repositories has always required Pro;
rulesets inherited the same gate. So the fallback in the brief does not exist
either. There is no enforcement mechanism available on this repository at all.

(`user.plan` reads empty because the token carries `gist, read:org, repo,
workflow` and not `read:user`. The two 403-class messages above are the
authoritative answer regardless.)

### The consequence the brief did not anticipate: step 12 is blocked too

This is the part worth acting on.

- **Step 11 is fine.** Actions is enabled (`{"enabled": true}`) and private repos
  on Free carry a monthly minutes allowance. CI can be written and will run.
- **Step 12 cannot be done.** "Make those checks required" means marking a status
  check as required, and that is a property of a ruleset or branch protection —
  the exact thing unavailable here.

So CI can be built and will report, but its result cannot gate anything. A red
check will sit next to a green merge button. That is the same advisory posture
as the hooks, arrived at from the other direction.

### Four steps, one cause

| Step | Control | Status |
|---|---|---|
| 7 | Secret scanning / push protection | Unavailable — needs GHAS on private |
| 8 | Code-owner review | Declarable, not enforceable — no second human |
| 9 | Separate bot actor | Blocked — no API to mint an identity |
| 10 | Ruleset / branch protection | Unavailable — needs Pro, or public |
| 12 | Required status checks | Blocked by the same gate as 10 |

This is no longer a series of coincidences. **The plan's enforcement layer —
everything from step 7 onward — is a set of paid or organisation features.** The
prototype has been able to build every mechanism and enable almost none of them.

That is not a failure of the work. Steps 1–6 produced a validator, a test suite,
four check scripts and two hooks, all of which run anywhere and are the portable
part. What steps 7–12 establish is that **the enforcement is bought, not built**,
and that is a genuine finding for the client conversation.

### Three ways forward — your call, none of them taken

| | Option | Cost | Consequence |
|---|---|---|---|
| **a** | **GitHub Pro** | ~$4/month, one seat | Rulesets and branch protection on private repos. Step 10 and 12 proceed as written. Does **not** fix secret scanning (needs GHAS) or the missing second human. |
| b | Make the repository public | Free | Rulesets, plus free secret scanning and push protection — which would finally let step 7's experiment run properly. **Publishes the corpus**, including the planted fixtures. Reversible in the settings sense, not in the "it was on the internet" sense. |
| c | Move to an organisation | Free org, or Team at ~$4/user/month | The right destination regardless — step 8 already recorded that the client repo must be in an org. Whether a **Free** org lifts the private-repo gate needs verifying rather than assuming; historically it did not, and Team was required. |

I did not take any of them. (b) in particular is exactly the publication we
deliberately avoided in step 7, and it is not mine to trade away for a feature.

### The deputy gap, now concrete

Worth recording even though the ruleset was not created, because it is the thing
that would have bitten immediately.

Had the ruleset been enabled exactly as specified — one approval, code-owner
review, **no bypass actors** — then on this repository:

- The sole code owner is `shsagnik`.
- GitHub refuses self-approval (verified verbatim in step 9, HTTP 422).
- There is no second human with write access, and step 9 established there is no
  bot either.
- Therefore **no pull request could ever be approved**, and `main` would accept
  nothing.

Not "constrained until a second human reviews" — closed, until somebody with
admin edits or deletes the ruleset. Recoverable, but the only route back is the
administrative act the ruleset exists to prevent.

The brief says this constraint is correct and intended, and it is — with a
second human. **The second human is the missing precondition, not the ruleset.**
Step 15's two-person test needs two people; step 9's bot needs creating; and
until one of those exists, enabling step 10 would produce a repository where
every merge is an admin override, which records less than the honour system it
replaces.

### Unmerged work now waiting on this

Seven local branches carry steps 2c, 4c, 5, 6, 7, and the step 8–10 records.
`origin/main` is at `61b3778` and still holds the step 4b validator. None of it
can land through a reviewed PR until there is somebody to review it.

### Does the plan still look right

No, not from step 10 onward, and this is the point to say so rather than at 13.

Steps 1–6 are done and portable. Steps 7–9 are done to the extent the platform
permits, with the gaps recorded. **Steps 10 and 12 are not doable on this
repository as configured**, and no amount of care in step 11 changes that.

The plan's own governing principle applies to the plan itself: every rule is
either enforced or explained, never both. Right now every rule from step 7
onward is explained and none is enforced. The honest options are to buy the tier,
publish the repository, or accept that the prototype demonstrates the shape and
that first real enforcement happens on the client's organisation — and to write
steps 13–15 around that last reading, which is what the evidence supports.

---

## Step 11 — CI running the same scripts the hooks run

**Branch:** `ci/github-actions-validate` (`9e66c1f`), cut from
`enforcement/record-step-10-blocked`. **Open as PR #4.**
**Status:** done. CI runs, and it is red — on the 18 links, exactly as expected.

### Does every check pass on `main`

**Six of seven. `check_links` fails.**

| Step | Result |
|---|---|
| Hooks present and executable | success |
| Schema conformance | success — `VALID=72 INVALID=0` |
| Source resolution | success — `refs=230 unresolved=0` |
| **Link resolution** | **failure — `checked=444 unresolved=18`** |
| Supersession integrity | success — `links=6 broken=0 unpaired=0` |
| Credentials across the diff | success — `scanned=10 found=0` |
| Test suite | success — 71 tests |

The 18 are the pre-existing inverted links found in step 5 and deliberately not
repaired. CI reports identical numbers to the local run, which is the point of
calling the same scripts: no drift to reconcile.

**The `if: !cancelled()` guard earned its place on the first run.** Supersession,
the credential scan and the test suite all executed *after* the link failure
rather than being hidden behind it. A fail-fast job would have reported one
problem and concealed six passes.

### Run time — not annoying

```
job execution only  :  8s
queued -> finished  : 11s
the same checks locally: ~3.0s
```

The 5-second gap is runner startup, checkout at `fetch-depth: 0` and installing
the pinned interpreter — fixed cost, not proportional to the corpus. Nothing here
is slow enough that anyone would want to skip it, which matters: the failure mode
for a slow check is that people route around it, and then it protects nothing.

Worth watching rather than acting on: `fetch-depth: 0` grows with history, not
with corpus size. On a repository with years of commits that step dominates. If
it ever does, the fix is to fetch only the merge base rather than to weaken the
`--diff` scoping.

### What was added, and why it is not YAML

The "no reimplementation in YAML" constraint drove two additions rather than
shell inside the workflow:

- **`tools/check_hooks.py`** — the two assertions CI can make and a hook cannot,
  because a hook cannot verify its own absence. It checks the declared hooks
  exist and that **git records them `100755`**, which is the mode a fresh clone
  receives. Proved against both failure modes in a scratch clone: a stripped
  executable bit and a deleted hook are each caught. Step 4 established git skips
  a non-executable hook silently with exit 0; this is the only place that becomes
  visible.
- **`--diff REF` on `check_secrets.py`** — so pull-request scoping lives in the
  scanner, not in workflow shell. Three-dot against the merge base, so unrelated
  commits landing on the base branch are not attributed to this change. Fails
  closed on a missing or unknown ref (exit 2, both tested).

**The step 6 cross-field invariant needed no step of its own** — it lives inside
`check_supersession.py`. The one-script-per-invariant-family shape from step 6
pays off here: adding a rule does not add a job step, so the workflow does not
change when the rules do. A workflow enumerating rules would have drifted from
the hook the first time a rule was added.

Pinned: `ubuntu-24.04`, not `ubuntu-latest`; Python `3.11`. Neither moves under
the checks without this file changing. `permissions: contents: read`.
Eleven test cases added; suite is now **71**.

### The thing this step cannot do, stated plainly

PR #4 reports `FAILURE` to a reviewer. It is also **`mergeable: MERGEABLE`,
`mergeStateStatus: UNSTABLE`** — not `BLOCKED`.

**The red check does not stop the merge.** The button is green next to it. Making
a check required is a property of a ruleset or branch protection, which step 10
established is unavailable on this tier. So CI has achieved the thing a hook
could not — a result a second person can see — and has not achieved the thing
that makes it binding.

That is the honest state: **visible, not enforcing.** It is still a real gain over
the hooks, because a reviewer can now tell the difference between "the checks
passed" and "the author says the checks passed". But step 12 remains blocked by
the same gate as step 10.

### Noticed, deliberately not fixed

1. **The 18 inverted links.** Now failing in three places rather than one: the
   pre-push hook, a local run, and every CI run on every PR from here on. Whatever
   the merge story turns out to be, this is the one piece of content drift that
   makes every future check red.
2. **Actions are pinned by tag, not by SHA.** `actions/checkout@v4` and
   `actions/setup-python@v5` are mutable references. For a repository whose whole
   subject is "enforced or explained", that is a supply-chain gap worth closing —
   `sha_pinning_required` is available in repo settings and currently `false`.
3. **CI tests one interpreter.** `validate.py` declares `MIN_PYTHON = (3, 8)` and
   the corpus is checked locally on 3.9 through 3.14, but CI pins 3.11 only. A
   matrix over the declared floor and the current release would cost seconds and
   would catch a stdlib assumption that only holds on newer versions.

### Does the plan still look right

Step 11 was doable and is done. Step 12 is not, for the reason recorded in step
10. The sequence now has a working, visible, fast CI job whose result binds
nothing — which is a fair description of where the whole enforcement layer stands
on a private repository on this tier.

---

## Step 12 — required checks: BLOCKED. The loop does not close.

**Branch:** `enforcement/record-step-12-blocked`, cut from
`ci/github-actions-validate`.
**Status:** **nothing was changed.** There is no ruleset to add required checks
to, because step 10 could not create one.

### Prerequisites

- `validate.yml` has run — twice, on PR #4. Prerequisite satisfied.
- **The step 10 ruleset does not exist.** Re-checked in case the tier had
  changed; it has not:

```
GET /repos/shsagnik/OKFdemo/rulesets
GET /repos/shsagnik/OKFdemo/branches/main/protection
  both -> "Upgrade to GitHub Pro or make this repository public"
GET /repos/shsagnik/OKFdemo/branches/main -> {"protected": false}
```

Required status checks and "require branches to be up to date" are both
properties of a ruleset or branch protection. Neither can be created, so neither
setting has anywhere to live.

### The verification, run anyway — and it is the finding

Opened PR #5 carrying a record with `status: proposed`, a value dropped from the
enum in step 2.

**Three checks caught it**, which is more than the one the brief predicted:

```
FAILED: Schema conformance
   status: 'proposed' is not one of ['draft', 'accepted', 'superseded']
FAILED: Link resolution        (the standing 18)
FAILED: Test suite             (its assertion that the real corpus validates)
```

And then:

```
mergeable        : MERGEABLE
mergeStateStatus : UNSTABLE
```

**`UNSTABLE`, not `BLOCKED`.** A pull request containing a record that fails
schema validation, with three red checks against it, can be merged. The button
is green. Closed unmerged; branch deleted.

That is the verification the step asked for, returning the opposite of the
intended result. The detection works perfectly — every layer fired, including one
nobody designed for this case. Nothing acts on the detection.

### The point in the loop where it opens

The chain is: **write → hook → push → CI → review → merge.**

Every link works except the last. The checks run, agree with each other, and
report to a place a second person can see. What is missing is the single setting
that makes a report a gate — and it is the one setting this tier does not sell.

**"Require branches to be up to date" deserves a specific note**, because the
brief is right about why it matters and it is the least replaceable thing lost
here. Nothing else in the stack catches it: a PR that validated cleanly at open,
a supersession merged in behind it, and now its citations point at a superseded
fact. The PR is green, the base is wrong, and no check on either side is looking
at the combination. A hook cannot see it — the hook ran before the other merge
existed. CI cannot see it either, because CI validated a merge result that was
correct at the time it was computed. **That failure mode is invisible to
everything we built and is only caught by the setting we cannot enable.**

---

## What is mechanically enforced, and what rests on judgement

Written for step 14. The editorial rule there is that AGENTS.md keeps only what
CI cannot check, so this is the boundary.

Read the first table with the caveat above: these checks **run and report**, and
on this repository nothing stops a merge that ignores them. They are enforced in
the sense that a machine decides the answer and a human cannot quietly disagree
with it — the answer is on the record. They are not enforced in the sense of
being a gate.

### Mechanically checked — remove from AGENTS.md

| Rule | Where | Since |
|---|---|---|
| `type` is required on every record | schema | step 2 |
| No undeclared frontmatter fields | schema `additionalProperties: false` | step 2 |
| `status` is one of `draft` / `accepted` / `superseded` | schema enum | step 2 |
| `generated.by` matches `<mode>:<agent>[/<stage>]` | schema pattern | step 2 |
| `generated.at` is an RFC 3339 UTC date-time | schema pattern | step 2 |
| `sources` has at least one entry | schema `minItems`, reachable since 4c | steps 2, 4c |
| `contested` shape, and its four required fields | schema | step 2 |
| `tags` are unique | schema `uniqueItems` | step 2 |
| Frontmatter parses at all | `validate.py` | step 1 |
| Every `sources[].resource` exists under `/_sources/` | `check_sources.py` | step 5 |
| Every in-bundle markdown link resolves | `check_links.py` | step 5 |
| Every supersession target exists | `check_supersession.py` | step 5 |
| `superseded_by` present implies `status: superseded` | `check_supersession.py` | step 6 |
| No credential-shaped strings in a commit or a diff | `check_secrets.py` | steps 4, 11 |
| The hooks exist and would arrive executable | `check_hooks.py` | step 11 |
| The checks themselves still behave | `tests/test_validate.py`, 71 cases | steps 4b, 4c |

### Rests on judgement — AGENTS.md keeps these

No machine can decide any of these. Every one is a question about *meaning*.

| Rule | Why a checker cannot decide it |
|---|---|
| **Do not invent provenance** | The schema checks a cited file exists. It cannot check the file *says* what the record claims. This is the single most important rule in the document and the least checkable. |
| **Separate context provenance from decision provenance** | Whether a source evidences the surrounding discussion or the decision itself is a reading of the source. |
| **Name the decider, claim nobody else** | `Consulted: none recorded` and a fabricated attendee list are identical to every check we have. |
| **Say when you don't know** | A gap admitted and a gap silently filled produce the same valid record. |
| **Prefer the most recent statement of a fact** | `updated` is checkable; whether two statements actually conflict is not. |
| **Translate vocabulary through the glossary** | "Scheme discount" and "TPR" being the same thing is domain knowledge. |
| **Show both when two sources conflict and you cannot tell which is current** | `contested`'s *shape* is enforced; whether a genuine dispute exists, and whether it is a dispute rather than a rounding difference, is judgement. Step 4b found the corpus contains no live one. |
| **`/_sources/` is an archive, not a search target** | Nothing observes what an agent read. |
| **Stop when you have the answer** | Not observable. |
| **Supersede, do not overwrite** | The link and status are checked; whether a *new belief* warranted a new record or an edit is judgement. |
| **A verification field only counts if something fails when it is absent** | The 2c finding. `verified` is schema-shaped and used zero times; the register's `verified: yes` certified a false assertion. |

### The third category — declared, not enforceable here

Neither mechanical nor judgement. These are controls the repository *states* and
the platform does not apply, and step 14 should say so rather than implying
either of the other two categories.

| Control | State |
|---|---|
| Code-owner review | CODEOWNERS valid on `main`; no reviewer assignable — sole owner cannot self-approve (step 8) |
| Human decides / agent executes | No separate bot actor exists; a user-owned PAT inverts the split (step 9) |
| No direct pushes to `main` | No ruleset, no branch protection (step 10) |
| Required status checks | Blocked by the same gate (step 12) |
| Branch up to date before merging | Same, and it is the one failure mode nothing else catches |
| Secret scanning / push protection | Unavailable on a private repo at this tier (step 7) |

### Does the plan still look right

Steps 13–15 are content and instructions, and all three are doable. But step 15
is a **two-person test run** and there is one person, no second reviewer and no
bot; it cannot be run as written until an organisation exists.

The honest summary going into step 14: **the mechanical layer is complete and
portable, the judgement layer is what AGENTS.md is for, and the platform layer is
declared but inert.** All three belong in the rewrite, clearly separated, because
a reader who cannot tell which is which will assume the third category behaves
like the first.

---

## Step 13 — LEARNINGS.md split

**Branch:** `learnings/split-prototype-archaeology`, cut from
`enforcement/record-step-12-blocked`.
**Status:** done. AGENTS.md untouched.

### Final counts

| File | Lines | Words | Entries |
|---|---|---|---|
| `/LEARNINGS.md` | **18** | 1,160 | 7 (5 kept + 2 new) |
| `/_learnings/prototype.md` | 35 | 1,303 | 7 moved |

Was 28 lines / ~1,900 words / 12 entries. The read path is now roughly 40% smaller
by line count and carries only forward-looking rules.

### Byte-identity of the seven moved entries — confirmed

Extracted by exact line range and hashed before and after; each blob was then
confirmed present in `prototype.md`:

```
S1 glossary              identical
S2 tables                identical
S3 variances             identical
S6 context               identical
S7 mechanics             identical      (multi-line, all four lines)
S9 review (validation)   identical
S5 repair                identical
```

Also verified: no moved entry still appears in `LEARNINGS.md`, none was lost, and
all twelve originals are accounted for in exactly one of the two files. The five
kept entries were checked verbatim against `HEAD:LEARNINGS.md` as well.

The two `S9 review` entries needed care — line 19 is the Stage 8 validation
report, which is archaeology, and line 23 is the adversarial-read finding, which
is the rule. Line 19 moved, line 23 stayed.

### Order in LEARNINGS.md

S11, S5 follow-up, S10, S9 review, S4, then S12 and S13 appended. As specified.

### One correction carried into the new entry

The brief describes the register as "carrying `verified: pending`". It does not —
all five rows read **`verified: yes`**; `pending` appears only in the file's
trailing comment describing the intended protocol. This has come up twice before
and is noted again only because S13 is now a permanent record, and writing the
weaker claim into it would have been writing something false.

The entry as written covers **both** shapes, which is stronger than the rule as
stated: a register that certified an assertion already false, and a schema key
declared for human review and never once used. Absent and affirmative-but-false
are different failures, and the affirmative one is worse — a reader must disprove
it rather than notice a gap.

### `_learnings` added to SKIP

Needed, not optional. `prototype.md` is markdown with no frontmatter and would
have counted as `NO_FRONTMATTER=1`, failing validation on `main` — the same
defect `_plan/PROGRESS.md` caused in step 1.

### All checks after the split

```
validate            exit=0   VALID=72 INVALID=0
check_sources       exit=0   refs=230 unresolved=0
check_links         exit=1   unresolved=18      <- the standing 18
check_supersession  exit=0   broken=0 unpaired=0
check_hooks         exit=0   problems=0
check_secrets --all exit=0
tests               71 passing
```

Unchanged except that `VALID=72` now excludes `prototype.md` by SKIP rather than
counting it.

### Does the plan still look right

Step 14 has what it needs: the step 12 inventory gives the boundary, and the read
path is now small enough that adding the judgement rules to AGENTS.md will not
bloat it.

Worth flagging for step 14: the inventory has **three** categories, not two.
Mechanically checked, rests on judgement, and declared-but-inert. The editorial
rule as stated — keep only what CI cannot check — collapses the second and third
together, and they are not the same thing. A reader who cannot tell "no machine
can decide this" from "a machine could decide this but nothing here is running"
will assume the second is as safe as the first.

---

## Step 14 — AGENTS.md rewritten to judgement only

**Branch:** `agents/rewrite-to-judgement-only` (`6838e36`), cut from
`learnings/split-prototype-archaeology`.
**Status:** done. All checks unchanged.

### Line counts

| | Lines | Words |
|---|---|---|
| Before | 149 | 1,019 |
| After | **315** | **2,462** |

**It got longer, and that is worth explaining rather than hiding.** Roughly 40
lines of enforced rules came out. Far more went in, all of it required by the
brief: the enforced/explained split had to be explained or a reader would think
rules had simply been lost; staleness and `contested` are two conventions the
schema has always had and this file never described; and five LEARNINGS entries
were promoted with their reasoning intact rather than compressed to a line.

The measure that matters is not length. It is that **every line now earns its
place by being unenforceable.** A shorter file achieved by cutting explanation
would have been worse — a rule stated without its reason is a rule the next
agent will optimise away.

### Removed, paired with the check that now enforces it

| Removed from AGENTS.md | Now enforced by |
|---|---|
| "`type` is the only required field" | schema `required: ["type"]` |
| "Every concept file is markdown with YAML frontmatter" | `validate.py` — no frontmatter is `NO_FRONTMATTER`, exit 1 |
| "Fill every frontmatter field" | schema `required` + `additionalProperties: false` |
| "Copy the closest existing file's frontmatter shape" | schema, plus `templates/decision.md` now being conformant (step 3) |
| `status: deprecated` and the status vocabulary | schema `enum: [draft, accepted, superseded]` |
| "add a link to the replacement" | `check_supersession.py` — target existence, and `superseded_by` implies `status: superseded` |
| "If nothing at all is evidenced, leave `sources: []`" | schema `minItems: 1`, reachable since step 4c. Deleted, not moved — the instruction was wrong |
| "Commit … credentials" | `check_secrets.py`, pre-commit hook and CI |
| "A concept's `sources` array is empty and you must establish provenance" (a reason to open `/_sources/`) | schema `minItems: 1` makes the state impossible |

### Three the brief expected me to remove, which stayed

Checked against the step 12 inventory rather than the brief's list, as
instructed. **No check enforces any of these**, so removing them would have
deleted a real rule:

| Kept | Why |
|---|---|
| **Never edit `/_sources/`** (and `/_canon/`) | Nothing compares those directories to a baseline. `check_sources.py` verifies cited files *exist*, not that they are unmodified. A modification there is silent and permanent — the rule now says so explicitly. |
| **Cross-link in both directions** | Link *resolution* is checked; link *symmetry* is not. Step 5 deliberately excluded backlink symmetry because it needs the S5 ordering rule. A one-directional link is invisible to every tool here. |
| **One concept per file** | Nothing enforces it. Added the consequence: a file covering two things gets retrieved for one and silently answers about the other. |

"Bundle-relative link format" also stayed, softened to a convention: `check_links.py`
enforces that a link *resolves*, not that it is written absolute.

### Stale lines fixed

- **Line 127** — `status: deprecated` is gone; zero occurrences remain.
- **`sources: []`** — clause deleted; zero occurrences remain.
- **Branch and PR** — rewritten to what actually holds. Nothing prevents a direct
  push to `main` (marked `[declared, not enforced]`), but **GitHub's refusal to
  let an author approve their own PR is real** — `422 Review Can not approve your
  own pull request`, verified in step 9 — and that refusal is named as the thing
  that makes the human-decides / agent-executes split enforceable rather than
  conventional.

### The third category, marked in the file

Step 13 flagged that the editorial rule collapses "no machine can decide this"
with "a machine could, but nothing here is running". The rewrite marks the
second kind **`[declared, not enforced]`** inline. Without it a reader assumes a
declared control is as safe as a checked one — which is precisely the mistake
steps 7 to 12 spent six sessions establishing.

### Five LEARNINGS entries promoted inline

- **S11** → a new section on staleness having two mechanisms. AGENTS.md had
  nothing on staleness at all.
- **S5 follow-up** and **S10** → both appended to the cross-linking rule, two
  sentences each, not a section.
- **S9** → into the opening section, as the evidence that passing every check
  says nothing about truth.
- **S4** → beside "use the template", as why a wrong template produces a
  convention nobody agreed to rather than one error.

Plus the two step 13 entries, as short rules: verification fields, and never
using a real fixture value as an illustration.

### `contested` documented, with no worked example

Covered: claim-level not file-level, the record stays `accepted`, every position
carries a value with `held_by` where known, and both `resolution_owner` and
`resolves_when` are required with `none recorded` as the honest empty value.
Also what it is **not** for — supersession, open questions, and rounding.

**No example is given, and the file says why.** The corpus contains no live
two-sources-assert-incompatible-facts case: every conflict in it is superseded,
already adjudicated, an open question with no rival value, or a precision
artifact. The XL-01 discrepancy was excluded explicitly and named in the file as
the shape *not* to flag.

### D6 — already fixed, no change made

`.github/copilot-instructions.md` is a single line reading "Follow the
instructions in AGENTS.md at the repository root." It already redirects and
contains nothing else, matching `CLAUDE.md` and `.cursor/rules/kb.mdc`. Nothing
to do. D6 can be closed.

### All checks after the rewrite

Unchanged: `VALID=72 INVALID=0`, sources/supersession/hooks/secrets clean, 71
tests passing, `check_links` still failing on the standing 18. AGENTS.md is in
`SKIP_NAMES`, so the rewrite could not affect the corpus checks — and did not.

### Does the plan still look right

Step 15 is a two-person test run. There is one person, no second reviewer, and no
bot identity. **It cannot be run as written.** What can be run is the half that
does not need a second human: open a PR from a branch, confirm CI reports,
confirm the author cannot approve it, and stop at the point where a second person
would act. That demonstrates the mechanism up to the boundary and documents
exactly where the boundary is — which, given steps 7 to 12, is the honest
deliverable.
