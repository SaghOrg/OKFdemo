# Project Bharadwaj — engagement knowledge base

A distilled, cross-linked knowledge base for a consulting engagement: Northlane
Analytics' OLTP→warehouse programme for Bharadwaj Consumer Products Ltd. It
holds what the engagement knows — table definitions, tracked variances, decision
records, meeting notes — in a form an agent can retrieve from and add to.

**Everything in it is synthetic. No real entity is depicted.** It also contains
deliberately planted credentials and PII, as fixtures for testing the checks
described below. They are fake by construction and live only under `/_sources/`
and `/_canon/`.

## First, once per clone

```
git config core.hooksPath .githooks
```

Run this before you write anything. The hooks are tracked in `.githooks/`, but
git will not use them until you point it at them, and `core.hooksPath` is
per-clone local config that the repository cannot set for you. **A fresh clone
has no protection until you run that line, and nothing will tell you it is
missing.**

You get two things for it: a pre-commit hook that refuses a commit containing
anything credential-shaped, and a pre-push hook that refuses a push whose
content fails any of the checks below.

## Running the checks

All of them are standard library only. No virtualenv, no `pip install`, nothing
to set up — that constraint exists so this runs on a locked-down machine.

```
python3 tools/validate.py            # frontmatter against schemas/concept.schema.json
python3 tools/check_sources.py       # every cited source exists under /_sources/
python3 tools/check_links.py         # every in-bundle markdown link resolves
python3 tools/check_supersession.py  # supersession links and status agree
python3 tools/check_secrets.py --all # no credential-shaped strings
python3 tools/check_hooks.py         # the hooks are present and executable
```

Each exits `0` when it ran and passed, `1` when it ran and found a problem, and
`2` when it could not run. **Exit 0 never means "could not check."**

## Running the tests

```
python3 tests/test_validate.py       # add -v for case-by-case output
```

These test the checks themselves. A few deliberately assert behaviour we do not
want — gaps and known false positives — so that closing one turns a test red and
forces a decision rather than passing silently. They are named `*KnownGaps` and
`*KnownFalsePositives`.

## Where things live

| Path | What |
|---|---|
| `AGENTS.md` | **The protocol.** How to read, answer and write. Start here. |
| `/concepts/` | Tables, variances, metrics, dashboards — one per file |
| `/decisions/` | Decision records, MADR format, `YYYYMMDD-slug.md` |
| `/meetings/`, `/context/` | Notes, and the orientation set |
| `/index.md`, `/log.md` | Catalogue, and the record of what changed when |
| `/tools/`, `/tests/`, `/schemas/` | The checks, their tests, the schema |
| `/_learnings/` | How this corpus was built. History, not instruction. |

`AGENTS.md` is written for agents and is the authority on how to work here.
`CLAUDE.md`, `.cursor/rules/kb.mdc` and `.github/copilot-instructions.md` all
just redirect to it. This file is the human-facing entry point and carries no
rules of its own.

## `/_sources/` and `/_canon/` are read-only

`/_sources/` holds the raw artifacts the knowledge base was distilled from —
transcripts, decks, emails. `/_canon/` holds build inputs. **Never edit either.**
Nothing checks this: no script compares them against a baseline, so a
modification is silent and permanent. They are the record of what was actually
said, and editing one rewrites history rather than correcting it.

They are also not search targets. Every record carries its provenance in its
`sources` frontmatter; cite from there rather than reading the archive.

## Contributing

Branch, open a pull request, and let someone else approve it — GitHub will not
let you approve your own. **Whoever approves it is the one who merges it.**
`AGENTS.md` explains why that matters more than it looks.
