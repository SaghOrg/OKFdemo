---
type: decision
title: "<ADR-NNN — short imperative phrase, or a descriptive line for an open question>"
description: <One or two sentences. What was decided, who signed it off, and what is still open.>
tags:
  - decision
  - <ADR-NNN>
  - <VAR-NNN, table name, or any other word someone would grep for>
# draft while the question is open, accepted once it is decided, superseded
# once a later record replaces this one.
status: draft
# When this record replaces another, add `supersedes: /decisions/YYYYMMDD-slug.md`
# here, and on that record set `superseded_by` back to this one together with
# `status: superseded`. Never delete the record being replaced. Omit both keys
# when neither applies — a key with a blank value is not valid.
#
# Replace the two lines below. They describe this template, not your record.
generated:
  by: process:claude-opus/templates
  at: "2026-08-25T00:00:00Z"
# One entry per artifact this record was derived from. `resource` is the only
# required field; add `id`, `title`, `author` and `last_modified` where you
# know them. Cite these files, never edit them.
#
# A decision taken verbally and never minuted still cites the context around
# it — the prior discussion, the analysis, the mail thread that led up to it.
# Mark the decision line itself as unsourced in the body instead. Never name an
# artifact that did not produce this decision.
sources:
  - resource: /_sources/<folder>/<artifact>
# The day this record last changed. Update it on every edit.
updated: "2026-08-25"
---

# <title>

**Date:** <DD-Mmm-YYYY — the day the decision was taken, which is not necessarily the day it was written down>
**Deciders:** <whoever actually signed off, and nothing about anyone else>
**Consulted:** none recorded
**Informed:** none recorded

## Context and problem statement

What forced a decision. State the situation as it was understood *at the time*,
including anything believed then that later turned out to be wrong — the history
of a wrong belief is valuable here.

## Decision drivers

- <driver>
- <driver>

## Considered options

1. <option>
2. <option>

## Decision outcome

Chosen: **<option>**.

Because <justification>.

### Consequences

- Good: <consequence>
- Bad: <consequence>
- Neutral: <consequence>

## Evidence

Every claim below names the source file it came from. Where the decision itself
was taken verbally and never minuted, say so on its own line here rather than
attributing it to a meeting, mail or deck that did not produce it.

| Claim | Source |
|---|---|
| <claim> | `/_sources/...` |

## Related concepts

- [/concepts/...](/concepts/...)

## Referenced by

- [<record that links here>](/...)

## Follow-ups

- [ ] <action, owner, date>
