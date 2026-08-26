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
python3 tools/check_gh.py          # the open-PR queue is reachable from this machine
python3 tools/check_queue.py       # no open PR's content has already landed in main
```

**On Windows, `python3` is usually not the name.** A default install gives you
`python` and the `py` launcher; `python3` is absent, and Git Bash inherits that.
Substitute `py -3` or `python` in every command above. The hooks resolve this
themselves — they try `python3`, `python` and `py -3` and probe each one for
actually being Python 3, since a `python` can still be Python 2 and the
Microsoft Store ships a `python.exe` stub that exists and does nothing. They
still fail closed when none of them proves itself; the list of names got
longer, not laxer.

The checkers adapt their own output too: `check_gh.py` prints PowerShell when
that is the shell, and POSIX commands under Git Bash or WSL. This matters
because `export X=y` and `cmd < file` are not merely unidiomatic in PowerShell,
they are parse errors.

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
5. The open pull requests — `python3 tools/check_gh.py`, then
   `gh pr list --state open`. Titles only, one call. Run the preflight first:
   on a locked-down machine the sweep fails in five different ways that all
   look identical at the call site. See below for why this is a read step and
   not a write step, and what to do when the preflight fails.

## Where to look, in order

1. `/index.md` and `/context/` to orient
2. `/concepts/` — the answer to most questions lives here
3. `/decisions/` for why something was chosen
4. `/log.md` for whether a fact has changed
5. `/meetings/` for what was said and when
6. The open pull requests, for what is written but not yet merged

**Stop when you have the answer — from a source you have confirmed is
current.** The knowledge base is the answer, not a pointer to the answer.
But step 6 is what establishes that steps 2–5 are current, so it is not a
step you reach only after the others fail. Stopping at the first file that
answers the question is right; stopping before you know whether an open pull
request rewrites that file is how you deliver a stale answer confidently.

## The working tree is not the whole repository

Everything above is a path. Every tool you have — `rg`, `cat`, the validators —
reads the branch you happen to have checked out, and is blind by construction to
work that exists but has not landed. On this engagement that gap is not
theoretical: concepts get written, decisions get recorded, `/log.md` gets its
line, and then the whole thing sits in an open pull request for a day or a week
waiting on a reviewer. During that window the knowledge exists, the author
believes it is captured, and every search you run returns nothing.

**So a clean search proves the answer is not merged. It does not prove the
answer does not exist.** Those are different claims and the second one is the
one people hear.

Sweep the queue:

```
gh pr list --state open            # titles and branches — the once-per-task sweep
gh pr view <n> --json title,body   # what a promising one claims to do
gh pr diff <n>                     # what it actually changes
git branch --no-merged main        # work that never even reached a PR
```

Read a pull request with `gh pr diff`. Do not check the branch out to look at
it — you will strand whatever the user was working on. And if what you find is
the change you were about to make yourself, do not copy it out of the diff —
see *When the queue already has your change* in the write protocol.

**If `gh` is missing, unauthenticated, or errors, say so in your answer.** Not
as an aside; as part of the answer. An unchecked queue and an empty queue
produce the same silence, and a reader cannot tell them apart unless you tell
them. This is the same failure the rest of this file keeps describing: a check
that did not run looks exactly like a check that passed.

### When `gh` cannot run — check first, then help fix it

Run `python3 tools/check_gh.py` before the sweep, not after it fails. It exits
0 when the queue is reachable and 1 with a named reason and a remedy when it is
not. On a heavily sandboxed machine the second outcome is the common one, and
the five causes need five different answers:

| What is wrong | What fixes it |
|---|---|
| `gh` not on PATH | install it — the preflight prints the command for this machine |
| installed but older than 2.0.0 | the sweep's `--json` flags do not exist there; reinstall |
| installed, never logged in | `gh auth login`, or `GH_TOKEN` |
| logged in, but the credential sits in a keychain the sandbox will not open | `GH_TOKEN` — the login cannot be reused |
| authenticated, but outbound network denied | nothing local fixes it; ask about egress, or fall back to git |
| authenticated and online, but the token lacks scope | `gh auth refresh -s repo` |
| no GitHub remote configured | `git remote -v`, `gh repo set-default` |

**Do not route around a failed preflight.** The tempting recovery — fall back to
searching the working tree and answer from what is merged — is the exact failure
this whole section exists to prevent, and it is worse than doing nothing because
it produces a confident answer. Stop, tell the user which of the above you hit,
and offer to walk them through it.

**When `gh` is missing, install it — but do not install it silently.** The
preflight does the awkward part for you: it detects the platform, the
architecture and which package manager is actually present, and prints the one
command that will work here rather than a menu of six for someone else's
machine. It also always prints a no-root install into `~/.local/bin`, because
the machines that most need `gh` are the ones where you cannot become root to
get it.

Relay what it printed and ask before running anything. Installing software
changes the user's machine, and that is their call, not a step you take on the
way to answering a question. Two of them are not yours to run at all:

- **Anything with `sudo`.** It prompts for a password you do not have and
  should not see. Hand it over.
- **Anything on a machine where you were not asked to install things.** Offer
  the command and the one-line reason; if they decline, use the git-only
  fallback below and say the queue went unswept.

A version too old to run the sweep is the same problem wearing a disguise: an
old `gh` fails on the `--json` flags with an unrecognised-flag error, which
reads like a broken command rather than a stale binary. The preflight names the
floor so that turns into one clear answer.

**Hand interactive commands to the user; do not try to run them yourself.**
`gh auth login` opens a browser and waits on a device code. You cannot complete
it, and attempting it inside a sandbox hangs until it times out. Give the user
the command to run in their own shell and wait for them to confirm. The
non-interactive path is the one to prefer on these machines anyway:

```
export GH_TOKEN=<fine-grained token, Pull requests: read>   # or gh auth login --with-token
python3 tools/check_gh.py                                    # confirm before re-sweeping
```

**Trust the preflight over `gh`'s own diagnosis on the network case.** With
outbound traffic blocked, `gh auth status` reports `The token in keyring is
invalid` and tells you to re-authenticate. That is wrong, and following it costs
a login that cannot succeed for the same reason the first call didn't.
`check_gh.py` opens a TCP connection itself and separates the two.

**The git-only fallback**, when the API is unreachable but git transport is not:

```
git fetch origin
git ls-remote origin 'refs/pull/*/head'      # every PR ref, over git, no API
git merge-base --is-ancestor <sha> origin/main   # exit 0 = merged, 1 = not
git branch --no-merged main
```

This is strictly worse than `gh` and you must say so when you use it: `refs/pull`
persists after a pull request closes, so a ref that is not an ancestor of `main`
is *unmerged*, which covers both open and closed-without-merge. It over-reports
rather than missing things, which is the right direction for this failure, but
it gives you no title, no author, no state and no body — so you can report that
unmerged work touching a file exists, and not what it claims to do.

**A checker now owns part of this rule, and it is important to know which
part.** `check_gh.py` can confirm the queue is *reachable*. Nothing can confirm
you swept it, read what you found, or let it change your answer — a validator
runs against the tree it is handed, and asking it to account for what is not in
that tree is asking it to read a repository it cannot see. Reachability is
mechanical. Whether you looked is not.

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
- **Say when you don't know — after checking the queue, not before.** A
  missing concept file is normal; this KB is incomplete by design. But
  "there is no record" and "there is no *merged* record" are different
  statements, and on a repository with pull requests open at any given moment
  the second one is usually the true one. Confirm no open PR fills the gap
  before you report it as a gap. Then do not fill gaps by inference: a gap you
  admit and a gap you quietly fill produce records that look identical to every
  check that exists; only the second one is a lie.
- **A question about a person is a question about the queue.** "Did someone
  set this?", "has anyone updated it?", "is anybody looking at this?", "would a
  team member have decided this already?" — these are asking where the work is,
  not what a file says, and the place work sits before it lands is a pull
  request. Treat that phrasing as a direct instruction to run the sweep and
  name what you find, including who opened it and when. It reads like
  conversation rather than a retrieval request, which is exactly why it gets
  answered out of the working tree and comes back wrong.
- **Cite an unmerged answer as unmerged.** Give the PR number, its author and
  its state — "PR #11, opened by X, not merged" — and keep it visibly separate
  from what the knowledge base already holds. A pull request is a proposal
  under review; presenting its contents as settled fact skips the review that
  has not happened yet.
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

### The reviewer merges, not the author

**[declared, not enforced]** Whoever approves the pull request is the one who
merges it. If you approved it, merge it — do not hand it back to the author to
merge.

The reason, because the rule on its own tends to lose to instinct:

**In this design the merge is the verification event.** The author cannot approve
their own pull request, so the approval and the merge together are the only
record that a second person looked at the work. An author who merges their own
approved change records themselves verifying themselves, and the log cannot tell
that apart from a genuine two-person pass. The signal the whole review layer
exists to produce is destroyed by the last click.

Nothing can enforce this. GitHub's refusal stops the *approval*, not the *merge*
— the author is free to merge a PR someone else approved, and no check can see
the difference afterwards. That is precisely why it is written here rather than
implemented somewhere.

**On the usual objection:** merging does not put your name on someone else's
work. `git blame` attributes each line to the commit that wrote it, and merging
does not move that. Demonstrated in this repository, by two different
people — PR #6 was authored in `5d4b374` by one person and merged in `37a9126`
by another, and `git blame` on the file it changed assigns every line to
`5d4b374` and **zero** lines to the merge commit. Declining to merge on blame
grounds costs the verification record and buys nothing.

### When the queue already has your change, merge it — do not take its contents

The read protocol sends you to the queue *before* you write, so the queue will
sometimes already hold the thing you were about to do. That is the sweep
working. What happens next is where it goes wrong.

**Do not take the content out of an open pull request.** Not `git cherry-pick`
onto your branch, and not retyping what `gh pr diff` showed you into a file of
your own. Both feel like progress — the change is correct, you have it in front
of you, and reproducing it is faster than waiting on a reviewer. Both are the
same mistake in different clothes.

**It skips the review, which is the same defect as merging your own work.** The
section above exists because the merge is the verification event. Content that
arrives by cherry-pick arrives having been approved by nobody, and it arrives
looking exactly like ordinary authored work — there is no marker on it, and no
check that can find one. Self-merging at least leaves an approval record with
the wrong name on it. This leaves none at all.

**It strands the pull request, and the queue fills with ghosts.** The content is
now in `main` and the PR is still open, and nothing about the queue shows that
the second fact has stopped meaning anything. It cannot be reviewed into
anything; merging it would change nothing. Do this a few times and the queue is
mostly dead entries, and a queue that is mostly dead entries is one nobody
sweeps — which disables the read protocol that sent you there in the first
place.

**And it moves the attribution that merging preserves.** The section above
demonstrates that merging leaves `git blame` pointing at the authoring commit.
Cherry-picking does the opposite, measured on this repository: PR #11's decision
record is 167 lines, and after a cherry-pick every one of them is attributed to
the new commit and **zero** to `5fafb1c0`, the commit that actually wrote them.
The objection that does not apply to merging applies squarely here.

So, when the sweep finds it:

- **Say what you found, before doing anything.** "PR #N, opened by X, already
  does this" — number, author, state, per the citation rule above.
- **If it is complete, it needs review and a merge, not a rewrite.** You cannot
  approve it; that refusal is the control. Stop and hand it to the user. Your
  change is done — it is sitting in someone's queue.
- **If it is incomplete, add to that branch.** Branch from the PR head and
  target the PR, or push to it. One reviewable unit stays one reviewable unit.
  Starting a parallel branch forks the review and guarantees a conflict.
- **If it is wrong or abandoned, say so and stop.** Then it needs closing, and
  closing someone else's pull request is the user's call, not yours. Say that
  plainly rather than routing around it with a fresh PR.

The one legitimate reason to take a PR's commits is that you need its work *as a
base* to build on. Then branch from the PR head and target the PR — that keeps
the dependency visible. Copying it into a branch that targets `main` hides it.

`python3 tools/check_queue.py` finds the aftermath: an open pull request whose
content is already in `main`, by patch-id or by file-for-file comparison, so
the two routes above are both caught. It reports the evidence, not the intent —
a faithful retype and a cherry-pick are indistinguishable afterwards, which is
itself the point. **It will not catch a partial copy**, where some of the PR's
files were taken and some were not: the PR still has real work left, so it is
not yet a ghost, and telling those apart needs a judgement no check makes.

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
- Cherry-pick or retype content out of an open pull request instead of getting
  it merged — it lands unreviewed work and leaves the PR open forever

## Engagement quick facts

Client: BCPL (FMCG, Mumbai). Source: Oracle 19c "ORION" OLTP
(`OMS_PROD`, `FIN_PROD`). Target: `BCPL_EDW` star schema. ETL: ODI 12c.
BI: OBIEE 11g → Power BI. Scheduling: Control-M.

Workstreams: variance root-cause, data quality, dashboard build.
Eight tracked variances, VAR-001 to VAR-008.
