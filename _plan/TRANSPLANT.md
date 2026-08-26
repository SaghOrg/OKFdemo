# Transplant checklist

**What this is.** Steps 7–12 of the enforcement build-out did not produce
enforcement. They produced knowledge of what enforcement requires, learned by
hitting each wall in sequence on a private repository on a personal free plan.
This document is that knowledge, extracted so it can be executed against a real
organisation rather than re-derived.

**Read this before creating the client repository, not after.** Several items
below are ordering constraints: doing them in the wrong sequence produces a
repository that looks configured and is not.

**Status of each section is marked.** Some of this was verified here.
Some of it could not be, and saying which is the point.

---

## 1. What crosses, exactly

### Crosses — the framework

| Path | What | Notes |
|---|---|---|
| `tools/validate.py` | Schema validation, and the shared YAML frontmatter reader | The other four import their reader from it. Moves as a unit. |
| `tools/check_sources.py` | Provenance: every cited artifact exists, and every record cites something | |
| `tools/check_links.py` | Every in-bundle markdown link resolves | |
| `tools/check_supersession.py` | Supersession targets exist; `superseded_by` implies `status: superseded` | |
| `tools/check_secrets.py` | Credential scanning: `--staged`, `--diff REF`, `--all`, or paths | |
| `tools/check_hooks.py` | The hooks exist and git records them `100755` | |
| `tests/test_validate.py` | 87 cases across all six checks | See the caveat in §8 |
| `tests/fixtures/records/` | 50 fixtures, one per rule, pass and fail | |
| `schemas/concept.schema.json` | The frontmatter contract | Adapt `type` values to the engagement |
| `.githooks/pre-commit` | Blocks credentials at commit | |
| `.githooks/pre-push` | Blocks malformed content at push | |
| `.github/workflows/validate.yml` | CI running the same scripts | |
| `AGENTS.md` | The protocol — only what a machine cannot check | Rewrite the engagement-specific parts |
| `CLAUDE.md`, `.cursor/rules/kb.mdc`, `.github/copilot-instructions.md` | One-line redirects to `AGENTS.md` | Keep all three; they cost nothing and prevent a second instruction file drifting |
| `.okf/maintainers.yml` | Machine-readable merge authority | Replace the names |
| `README.md` | Human entry point | Rewrite for the engagement |
| `.gitignore`, `.ignore` | Strip the prototype-specific entries | |

Everything above is **standard library only**. No virtualenv, no `pip install`.
That constraint exists so the checks run on a locked-down client machine with
whatever Python is already present, and it is verified in CI against 3.8, 3.9,
3.11 and 3.13.

### Stays behind

| Path | Why |
|---|---|
| `concepts/`, `decisions/`, `meetings/`, `context/`, `index.md`, `log.md` | The corpus. Synthetic. The client's own records replace it entirely. |
| `_sources/` (67 files, 2.2 MB) | Raw artifacts of a fictional engagement. Contains the planted credential and PII fixtures. |
| `_canon/` (14 files) | Build inputs for generating the synthetic corpus. Meaningless elsewhere. |
| `_qa/` (8 files) | Prototype QA output. Also carries copies of the planted fixture values. |
| `_plan/` | Including this file and `PROGRESS.md`. Build archaeology of the prototype. |
| `_learnings/prototype.md` | How the synthetic corpus was generated. History, not instruction. |
| `LEARNINGS.md` | **Judgement call.** The nine forward-looking entries are engagement-agnostic and worth carrying; strip anything referring to this prototype's specifics. Decide deliberately rather than copying wholesale. |
| `templates/decision.md` | Carry the *shape*, rewrite the content. |

**Do not copy `_sources/` or `_qa/` "just to have an example."** They contain
deliberately planted credentials and PII. They are fake, but a client repository
containing anything credential-shaped is a conversation nobody needs to have.

### Known adaptation points

Verified by transplanting the framework into an empty repository and running it
against three states (Session A). Four assumptions are baked in:

- **`SKIP` in `validate.py` names prototype directories** (`_canon`, `_qa`,
  `_snapshots`, `.venv-synth`). Harmless dead entries on a client. **The real
  problem is the opposite direction:** the model is *scan every `.md` except an
  exclusion list*, so an ordinary `CONTRIBUTING.md` or `docs/runbook.md` fails
  with `NO FRONTMATTER`. Verified. A client repository has far more non-record
  markdown than this prototype does. **Recommend inverting to an allow-list** —
  declare the record directories, and everything else is silently not a record.
  This is the single change that most affects whether the framework lands well.
- **`PREFIX = "/_sources/"` in `check_sources.py`** is a naming convention this
  engagement chose. A client using `/_raw/` gets `not under /_sources/`, exit 1 —
  loud, not silent. Document it as a required convention rather than
  parameterising it.
- **`NO_PROVENANCE_TYPES = {"index"}` in `check_sources.py`** exists because this
  corpus has exactly one generated catalogue. A client with a generated glossary
  or registry must either edit the script or fabricate provenance — and
  fabricating is what the rule exists to prevent. **Make this configurable.**
- **`EXPECTED = ("pre-commit", "pre-push")` in `check_hooks.py`.** Leave
  hardcoded; the list *is* the declaration. Verified to tolerate an extra hook
  and to catch a missing declared one.

---

## 2. Ordering — do these in this sequence

Getting this wrong produces a repository that reports configured and enforces
nothing. Each of these cost a session to learn.

1. **Create the repository in an organisation.** Not a personal account. Nearly
   every control below is an organisation or paid feature; see §7.
2. **Create the bot identity** (§5) before anything requires it.
3. **Merge `CODEOWNERS` to the default branch.** Before enabling any rule that
   requires code-owner review — see the gotcha in §7.
4. **Land the CI workflow on the default branch.** A workflow that is not on the
   default branch does not run on pull requests targeting it, and its check name
   cannot be selected as required.
5. **Let CI run at least once.** Check names do not appear in the ruleset UI
   until a run has reported them.
6. **Then create the ruleset** (§3) and mark the checks required (§4).
7. **Then run the first-day verification** (§8).

---

## 3. Ruleset settings

Target the default branch by explicit ref pattern. Note that `~DEFAULT_BRANCH`
and `refs/heads/main` behave differently if the default branch is ever renamed;
prefer the explicit ref unless you want the rule to follow a rename.

- [ ] **Require a pull request before merging**
- [ ] **Require at least 1 approval**
- [ ] **Require review from Code Owners**
- [ ] **Dismiss stale approvals when new commits are pushed**
- [ ] **Require approval of the most recent reviewable push**
- [ ] **Block force pushes**
- [ ] **Restrict deletions**
- [ ] **Require branches to be up to date before merging** — see below
- [ ] **Bypass list: empty.** Including the repository owner and organisation
      admins, which the UI adds by default when a ruleset is created through it.
      A bypass list with an admin on it makes the control advisory again.
- [ ] **Enforcement status: `active`, not `evaluate`.** Evaluate mode is dry-run:
      it reports violations and blocks nothing, and it is easy to select by
      accident.

**"Require branches to be up to date" deserves its own note.** It is the least
replaceable item on the list, because it is the only one catching a failure mode
nothing else can see: a pull request that validated cleanly at open, a
supersession merged in behind it, and now its citations point at a superseded
fact. The PR is green and the base is wrong. A hook cannot see it — the hook ran
before the other merge existed. CI cannot see it either — it validated a merge
result that was correct when computed. Only this setting catches it.

---

## 4. Required check names

**The matrix changes them.** With a Python version matrix the job reports as:

```
checks (python 3.8)
checks (python 3.9)
checks (python 3.11)
checks (python 3.13)
```

**not** `checks`. Requiring `checks` matches nothing and silently requires
nothing — a ruleset with a required check that never matches is indistinguishable
from one with no required checks at all.

- [ ] Require **every** matrix leg, not a subset. A subset means a version can
      break unnoticed, which defeats the reason the matrix exists.
- [ ] Re-check these names after any change to the workflow's job name or matrix
      dimensions. Changing either silently unrequires the old names.
- [ ] The name is the **job** name, not the workflow name. The workflow here is
      called `validate`; the job is `checks`.

---

## 5. Bot identity: a GitHub App, not a PAT

**Use a GitHub App.** Optionally a machine user. **Do not use a fine-grained
personal access token.**

### Why a PAT does not work — verified here

A fine-grained PAT owned by a human **authenticates as that human**. It is not a
separate identity. So:

- The agent opens a pull request using the token → **the PR is authored by that
  human.**
- GitHub then refuses **their own** approval of it. Verified verbatim:
  ```
  POST /repos/{owner}/{repo}/pulls/{n}/reviews  event=APPROVE
    HTTP 422 Unprocessable Entity
    {"errors": ["Review Can not approve your own pull request"]}
  ```
- With a single code owner, nobody else can approve, so the PR is mergeable only
  by admin bypass.

A PAT therefore does not merely fail to enforce the human-decides /
agent-executes split — **it inverts it.** Instead of the platform distinguishing
who decided from who executed, it prevents the decider from recording a decision
at all, and every agent-opened PR merges by admin override. That records strictly
less than the honour system it was meant to replace.

### Setting it up

- [ ] Create a GitHub App. It acts as `name[bot]`, a genuinely distinct actor, so
      the human is free to approve.
- [ ] **Grant write, not admin.** Enough to push branches and open pull requests;
      not enough to change rulesets, `CODEOWNERS` or repository settings.
- [ ] **Do not add it to `CODEOWNERS`.** Its approval must never satisfy a review
      requirement.
- [ ] Hold only the App's private key. Installation tokens are minted per run and
      expire hourly, so nothing long-lived sits on disk.
- [ ] The key goes in a credential store or CI secret. **Never in the
      repository** — `check_secrets.py` will block it at commit, which is the
      correct outcome.
- [ ] Unlike a shared dev secret, this is **not shared between people**. One
      human, one account; the bot gets its own.

There is no API for minting a PAT or creating an App (`POST
/user/personal-access-tokens` returns 404 by design). Both need the web UI. Budget
a human for this step.

---

## 6. CODEOWNERS shape

Use **team references**, not individual users. That is the main thing an
organisation buys you here.

```
# Last matching pattern wins, so the broad rule goes first.

*                       @org/kb-maintainers
/.github/               @org/kb-maintainers
/CODEOWNERS             @org/kb-maintainers
/AGENTS.md              @org/kb-maintainers
/schemas/               @org/kb-maintainers
/tools/                 @org/kb-maintainers
/.githooks/             @org/kb-maintainers
```

- [ ] **At least two people in the team.** With one, nothing is reviewable —
      GitHub never requests review from a pull request's own author, so a sole
      owner is assigned to nothing and can approve nothing. Verified here: a PR
      touching an owned path returned `reviewRequests: []` while the CODEOWNERS
      file was valid the whole time.
- [ ] **`/.github/` owns the declaration of authority itself.** Without it,
      `CODEOWNERS` is editable unreviewed by exactly the people it was written to
      constrain.
- [ ] `/schemas/`, `/tools/` and `/.githooks/` are owned separately from the
      corpus because changing them changes what CI enforces. A schema change is a
      governance event, not a content change.
- [ ] Validate it: `GET /repos/{owner}/{repo}/codeowners/errors` returns
      `{"errors": []}` when the file parses and every owner has access. This is
      the only thing that catches the silent failure in §7.

---

## 7. Gotchas — each of these cost a session

**Code owners need write access, or the entry fails silently.** A mistyped
username or someone without access is ignored — no error, no warning, no
requested reviewer. Use the `codeowners/errors` endpoint above; it is the only
signal.

**CODEOWNERS must be merged to the default branch before the rule requires it.**
Enable "require review from Code Owners" first and GitHub treats the repository
as unowned. Merge first, require second.

**GitHub reads CODEOWNERS from the *base* branch.** A pull request that adds or
changes `CODEOWNERS` cannot trigger its own rule — the new entries take effect
only after merge. Verified here: adding a second owner assigned no reviewer to
the PR that added them.

**Rulesets and legacy branch protection layer, they do not replace.** Both apply
and the most restrictive wins. A half-configured pair is confusing to reason
about; pick one.

**A non-executable hook is silently skipped, with exit 0.** `chmod -x` the hook
and git commits happily. Nothing reports it. This is why `check_hooks.py` exists
and why it checks git's recorded mode (`100755`) rather than the working-tree
permission — the recorded mode is what a fresh clone receives.

**`core.hooksPath` is per-clone, opt-in, and the repository cannot set it.** A
fresh clone has no hooks until someone runs the line, and nothing will tell them
it is missing. In this prototype the hooks sat unenabled for eight sessions while
roughly a dozen pushes went through unchecked. Put the command in the README, and
say it out loud during onboarding.

**`git commit --no-verify` and `git push --no-verify` bypass everything.** Hooks
are fast feedback for the author, not a control. CI is the only check whose
result a second person can see.

**Secret scanning on a private repository needs GitHub Advanced Security.**
Without it the endpoint returns `422 Secret scanning is not available for this
repository`, and no scanning happens at all. Note also that
`secret_scanning_non_provider_patterns` — the feature that would match a generic
`password=` — is a **separate toggle and off by default even where available**.
Generic secrets are exactly what a hosted scanner misses, which is why
`check_secrets.py` is weighted towards them rather than provider tokens.

**Rulesets and branch protection on private repositories require Pro/Team.** On a
free plan both endpoints return `Upgrade to GitHub Pro or make this repository
public`. There is no fallback: the legacy branch-protection path is gated
identically.

**A required status check is a property of a ruleset.** So required checks are
gated behind the same paywall as the ruleset itself. Without it CI reports and
binds nothing: a pull request with failing checks reads `MERGEABLE` /
`UNSTABLE`, not `BLOCKED`, and the merge button stays green.

---

## 8. First-day verification

> ### ⚠ This section has never been executed
>
> **Nothing in this prototype has confirmed that a human approval is actually
> required.** PR #6 here was approved because a colleague was asked to approve
> it, not because GitHub made him. No ruleset existed then or now. Every control
> in §3 and §4 is, in this repository, **declared and inert.**
>
> Treat every item below as untested. The whole point is that a settings screen
> showing the right toggles proves nothing — the prototype had a valid
> `CODEOWNERS`, a working CI job and two hooks, and not one of them ever blocked
> anything on the server.

**The method: attempt the forbidden action, confirm the refusal, record it
verbatim.** Not a screenshot of the settings page. A settings page shows intent;
only a refusal shows behaviour. The distinction is the most expensive lesson in
this build-out — see the `S12 follow-up` entry in `LEARNINGS.md`.

Run each of these against the real repository, in order, and paste the actual
output into a record.

- [ ] **Direct push to the default branch is refused.**
      `git push origin HEAD:main` from a branch. Expect a rejection naming the
      ruleset. *(A `--dry-run` first is safe and changes nothing.)*
- [ ] **A pull request with no approval cannot merge.**
      Open one, attempt the merge, confirm the API refuses. `mergeStateStatus`
      must read `BLOCKED`. **`UNSTABLE` means the check is advisory and the rule
      is not doing anything.**
- [ ] **A pull request with a failing check cannot merge.**
      Push a record with a deliberately invalid `status` value. Confirm CI goes
      red and the merge is `BLOCKED`, not merely marked with a red X.
- [ ] **A pull request touching an owned path requires the code owner
      specifically.** Confirm the code owner is auto-assigned as a reviewer, and
      that an approval from a non-owner does not satisfy the requirement.
- [ ] **The bot cannot approve its own pull request.** Have the App open one and
      attempt to approve it. Expect `422 Review Can not approve your own pull
      request`.
- [ ] **A human approval on a bot-opened PR does satisfy the requirement.** This
      is the one that proves the whole design, and it is the one that has never
      been tested.
- [ ] **A stale approval is dismissed by a new push.** Approve, push another
      commit, confirm the approval is cleared and the merge blocks again.
- [ ] **An out-of-date branch cannot merge.** Merge something else to the default
      branch, then confirm the open PR must update before it can merge.
- [ ] **Admin bypass is not available.** Attempt each of the above as an
      organisation admin. If any succeeds, the bypass list is not empty.
- [ ] **The hooks fire on a fresh clone after setup.** Clone, run
      `git config core.hooksPath .githooks`, stage a credential-shaped string,
      confirm the commit is refused. Then push a record failing validation and
      confirm the push is refused.
- [ ] **The checks fail closed on an empty repository.** Run each script before
      any records exist. Every one should exit 2 with a message, not 0.
      *(Known: `check_supersession.py` currently exits 0 on an empty corpus —
      a fail-open found in Session A and not yet fixed.)*

**Record the result of each, including the ones that pass.** A control verified
by watching it refuse is a fact. A control verified by reading its configuration
is a claim, and this build-out is largely a catalogue of the difference.
