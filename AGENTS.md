# Project Bharadwaj — Engagement Knowledge Base

You are working in the knowledge base for Northlane Analytics'
OLTP→warehouse engagement with Bharadwaj Consumer Products Ltd (BCPL).

Everything here is synthetic demo data. No real entity is depicted.

## What this file is, and what it deliberately leaves out

**This file contains only what a machine cannot check.**

Anything mechanically checkable lives in `schemas/concept.schema.json` or in a
script under `tools/`, and is not repeated here. If you break one of those rules
you will be told, precisely, by `tools/validate.py`, `check_sources.py`,
`check_links.py`, `check_supersession.py`, `check_secrets.py` or the test suite.
Run them yourself:

```
python3 tools/validate.py          # frontmatter against the schema
python3 tools/check_sources.py     # every cited source file exists
python3 tools/check_links.py       # every in-bundle link resolves
python3 tools/check_supersession.py
python3 tools/check_secrets.py --all
```

### First, once per clone

```
git config core.hooksPath .githooks
```

**Do this before you write anything.** The hooks in `.githooks/` are tracked, but
git does not use them until you point it at them — `core.hooksPath` is per-clone
local config and cannot be set by the repository. A fresh clone has no
protection at all until you run that line.

This is not a hypothetical. The hooks sat in this repository for eight sessions
with nobody having run it, and roughly a dozen pushes went through unchecked
because of it. The hook cannot tell you it is missing; that is the whole problem
with it. `python3 tools/check_hooks.py` confirms the hooks are present and
executable, but nothing can confirm that *you* enabled them.

What you get for the one line: `pre-commit` refuses a commit containing anything
credential-shaped, and `pre-push` refuses a push whose content fails validation,
source resolution, link resolution or supersession integrity.

So the absence of a rule here does not mean it does not exist. It usually means
a checker owns it.

What is left is the part no checker can decide, because every one of these is a
question about **meaning**: whether a source says what you claim it says,
whether you actually know something or are filling a gap, whether two statements
genuinely conflict. A validator reads shape. It cannot read truth.

**This distinction has been tested.** An adversarial review of this corpus caught
a systemic sourcing defect, a mislabelled constraint, an invented date and a
false backlink claim — all in files that schema validation reported as
completely clean. Passing every check means your record is well-formed. It says
nothing about whether it is true.

A third category is marked **[declared, not enforced]** where it appears. Those
are rules this repository states and the platform does not currently apply.
Follow them; just do not assume something will stop you.

## Read protocol — do this at the start of EVERY task

Read these if present. A missing file here is not an error — it means
that knowledge hasn't been written yet. Say so rather than inferring.

1. `/context/project-brief.md`
2. `/context/active-context.md`
3. `/context/glossary.md` — REQUIRED. The client, the consultants,
   and finance use different words for the same things.
4. `/index.md`

## Where to look, in order

1. `/index.md` and `/context/` to orient
2. `/concepts/` — the answer to most questions lives here
3. `/decisions/` for why something was chosen
4. `/log.md` for whether a fact has changed
5. `/meetings/` for what was said and when

**Stop when you have the answer.** The knowledge base is the answer,
not a pointer to the answer.

## `/_sources/` is an archive, not a search target

`/_sources/` holds the raw artifacts this knowledge base was built
from — transcripts, decks, emails, brain dumps. It is unprocessed,
contradictory, and largely superseded. **Do not search it to answer
questions.**

Every concept carries its provenance in its `sources` frontmatter
array. That array is your citation trail — you cite source files by
naming them from the concept's frontmatter, without opening them.

Open a file under `/_sources/` only when one of these is true:
- You need a verbatim quote
- The user asks you to go to the source explicitly

If you do open one, say why in your answer.

**Never edit anything under `/_sources/` or `/_canon/`.** Nothing checks this.
No script compares those directories against a baseline, so a modification there
is silent and permanent. They are the record of what was actually said; editing
one rewrites history rather than correcting it.

## How this knowledge base is organised

- `/concepts/tables/` — one file per OLTP or warehouse table
- `/concepts/variances/` — one file per known discrepancy (VAR-NNN)
- `/concepts/metrics/` — metric and KPI definitions
- `/concepts/dashboards/` — dashboard specs
- `/decisions/` — decision records, `YYYYMMDD-slug.md`, MADR format
- `/meetings/` — meeting notes derived from transcripts
- `/context/` — the rehydration set above
- `/_sources/` — raw untransformed artifacts. Read-only. Cite, never edit.
- `/_canon/`, `/_qa/` — build inputs and prototype QA output. Historical.
- `/_learnings/prototype.md` — how this corpus was generated. History, not instruction.

Links are written as bundle-relative absolute paths, e.g.
`/concepts/tables/fact-invoice-line.md`. A link that resolves in another form
will pass the checker, but write them this way so they survive a file moving.

**One concept per file.** Nothing enforces this. A file covering two things gets
retrieved for one of them and silently answers about the other.

## Answering rules

- **Cite the concept, and its sources.** Name the concept file you
  answered from, then name the `_sources/` files listed in its
  `sources` frontmatter. You are citing provenance recorded in the
  knowledge base, not files you opened.
- **Prefer the most recent statement of a fact.** Dates and scope changed
  repeatedly during this engagement. Check `updated` frontmatter and
  `/log.md` before trusting an early document.
- **Translate vocabulary through the glossary.** "Scheme discount",
  "trade promotion accrual", and "TPR" are the same thing. "Stockist"
  and "channel partner" both mean distributor.
- **Say when you don't know.** A missing concept file is normal — this
  KB is incomplete by design. Do not fill gaps by inference. A gap you admit
  and a gap you quietly fill produce records that look identical to every
  check that exists; only the second one is a lie.
- **If two sources conflict and you cannot tell which is current, say so
  and show both.** If the disagreement is live rather than settled, record it
  with `contested` — see below.

## Staleness has two mechanisms, and they are not interchangeable

`stale_after` is **time-based and whole-file**: nobody has reviewed this record
recently, so distrust all of it. Put it on files that decay by the calendar —
active context, status, anything narrating "now". Exactly one file carries it
today, which is correct.

A supersession note in the body is **fact-based and claim-specific**: this
particular claim is wrong, and here is where the current value lives. Put one
wherever a specific figure was superseded, *including inside otherwise-stable
documents*. `/context/project-brief.md` carries one — it does not go stale as a
whole, but it held a single fossilised go-live date, and the note names the wrong
value explicitly so a reader knows what to distrust.

**A stable file is where a stale fact hides best, because nothing about the file
looks old.** Neither mechanism substitutes for the other, and a schema check
finds neither: nothing is missing in either case.

## Write protocol

You may write to this repo. You must follow this exactly.

### Branch, then open a pull request

**[declared, not enforced]** Nothing currently prevents a direct push to `main`.
Do it anyway: branch, make the change, open a PR.

One part of this **is** mechanically enforced, and it is the important part:
**GitHub will not let you approve your own pull request.** The API refuses with
`422 Review Can not approve your own pull request`. That is what makes the split
real — an agent opens the PR, a human approves it — rather than a convention
anyone can quietly skip. Do not look for a way around it; the refusal is the
control.

Code owners are declared in `.github/CODEOWNERS`. **[declared, not enforced]**
on this repository, which has a single owner.

### When a decision is made

1. Create `/decisions/YYYYMMDD-slug.md` from `/templates/decision.md`
2. Link it from every concept it affects
3. Add a line to `/log.md`
4. Update `/context/active-context.md` if the current focus changed

**Use the template. If it does not fit, fix the template.** The decision template
was once not schema-conformant, and thirteen records each improvised their own
way around it — independently, consistently, and invisibly, because every one of
them validated. A template that is wrong does not produce one error; it produces
a convention nobody agreed to.

### When a decision has no source artifact

Verbal sign-offs, corridor calls and decisions nobody minuted are the
common case on a live engagement, not the edge case. Capture them — but
never attach one to a meeting that did not happen. A fabricated meeting
citation is invisible to a reader; an admitted gap is not.

- **Do not invent provenance.** No transcript, deck, mail or tracker may
  appear in `sources` as the origin of a decision that was not captured
  from one. The checker confirms the file you cited exists. It cannot confirm
  the file says what you claim — that gap is the whole reason this rule is here.
- **Say so in the record.** State plainly that the decision was taken
  verbally and un-minuted, and captured live into this knowledge base
  rather than derived from an artifact.
- **Name the decider, claim nobody else.** `Deciders:` is whoever
  actually signed off. `Consulted:` and `Informed:` are `none recorded`
  unless you know otherwise. Never reconstruct an attendee list. A fabricated
  attendee list and `none recorded` are indistinguishable to every check.
- **Separate context provenance from decision provenance.** Cite the
  context that surrounds the decision — the prior discussion, the
  analysis, the emails leading up to it. Mark the decision line itself
  as unsourced in the body. Every record needs at least one source; the
  un-minuted case is handled by sourcing the *context* and saying in prose
  that the decision line itself rests on a capture.
- **Flag it in `/log.md`.** Carry the verbal sign-off, the decider and
  the date in the Notes column, so a reader scanning the log can tell
  which rows rest on an artifact and which rest on a capture.

The worked example this convention was taken from: a verbal sign-off
from the client's Head of Finance Systems, with no minuted meeting
behind it. It was recorded with `sources` carrying only the context —
the surrounding discussion and analysis — with the decision line itself
marked unsourced, the decider named and nobody else claimed, and the
absence of evidence for that line stated in the record body and again
in the `/log.md` Notes column.

### When a fact changes

**Supersede, do not overwrite.** Create the new record, and on the old one set
`status: superseded` and point `superseded_by` at the replacement. The history of
a wrong belief is valuable here.

The judgement is *whether this is a new belief at all*. A correction to a typo is
an edit. A change in what the engagement believes to be true is a new record,
even when the diff would be one line. Nothing can decide that for you.

### When a claim inside a record is disputed

Use `contested` when two sources assert **incompatible facts** and the
disagreement is still live.

- **It is claim-level, not file-level.** The record stays `accepted` while one
  claim inside it is contested. Do not demote a whole file over one disputed
  figure.
- **Every position carries a value**, and `held_by` where you know it — that is
  what separates two positions citing the same document, which is the common
  case. A deck's headline and its own appendix disagree far more often than two
  separate artifacts do.
- **`resolution_owner` and `resolves_when` are required.** Write `none recorded`
  when nobody has been named or nothing has been identified. A dispute with no
  owner should be visible as unowned, not silently absent.

**Do not use it for:**
- a fact that was simply replaced by a later one — that is `supersedes` /
  `superseded_by`
- an open question where nobody asserts a rival value — that is `status: draft`
- **two statements of the same figure that differ only in rounding or
  precision.** 3.10 Cr and 3,11,20,000 are not a disagreement about what is
  true. If you treat precision differences as disputes, the field fills with
  noise and stops meaning anything.

**This corpus currently contains no live example**, which is why none is given
here. Every conflict in it is one of: superseded, already adjudicated (the
`.vtt` and `.txt` of one meeting disagree on who said a line, and the glossary
rules for the `.vtt`), an open question with no rival value, or a rounding
artifact. If you find a genuine one, it is the first.

### When adding a concept

**Cross-link it in both directions.** Nothing enforces this — link *resolution*
is checked, link *symmetry* is not. A one-directional link is invisible to every
tool here.

Two things follow from that:

**Re-establish symmetry after every link-editing change, not once.** Repairing
links creates new one-directional edges of its own. Symmetry is a property you
re-establish, not a job you finish.

**Cross-links are not navigation convenience. They are the mechanism by which a
risk nobody asked about becomes visible.** The most valuable thing this knowledge
base has produced was not an answer to any question: it was a scheduling
conflict that existed only because a 2022 operational decision, an unbuilt 2026
remediation, an SLA figure and a go-live date were separate records that linked
to each other. No single source document contained that connection. Retrieval
that stops at the one document answering the question asked will never surface
it.

## A verification field only counts if something fails when it is absent

If you add a field that records that a check happened — `verified`, a QA column,
a sign-off marker — make sure something breaks when it is empty or stale.
Otherwise it is decoration that reads as assurance.

Two failures of this kind are already in this repository. `_canon`'s plant
register certifies that each planted value appears "exactly once and nowhere
else"; it appears in 29 other places, and the reports doing the verifying were
themselves the leak. The schema's own `verified` key is declared, described as
where human review is recorded, and used by zero records. Nobody reads a
verification field and asks whether it was filled — its presence is taken as
evidence the check happened.

## Never use a real fixture value as an illustrative example

Including in a comment, a docstring, a test, or a document explaining how the
check works. This corpus contains planted credentials and PII by design. They are
realistic on purpose, which is exactly why they get copied: a value good enough
to test with is good enough to quote, and every quotation is a fresh copy in a
file nobody classified as holding secrets. Substitute something inert at the
moment of writing. `check_secrets.py` catches assignment forms; it does not catch
a password sitting in a table cell or in prose.

## Never

- Edit anything under `/_sources/` or `/_canon/`
- Delete a concept or decision file
- Commit media, or personal data that is not already in the fixtures
- Invent a table name, person, date, or figure not present in the repo
- Attribute a decision to a meeting, mail or deck that did not produce it

## Engagement quick facts

Client: BCPL (FMCG, Mumbai). Source: Oracle 19c "ORION" OLTP
(`OMS_PROD`, `FIN_PROD`). Target: `BCPL_EDW` star schema. ETL: ODI 12c.
BI: OBIEE 11g → Power BI. Scheduling: Control-M.

Workstreams: variance root-cause, data quality, dashboard build.
Eight tracked variances, VAR-001 to VAR-008.
