---
type: decision
title: "Open question — stockist-level drill-down on every dashboard page"
description: Vikram Sethi asked for every dashboard, not just Primary Sales Performance and Distributor Scorecard, to drill to individual stockist level with both primary (billing) and secondary (off-take) figures side by side. Ritwik Ghosh objects that secondary sales coverage is only 74% and unreliable enough that showing it beside billing invites people to subtract two numbers that should not be compared. The dashboard scope workshop ends with the question unresolved and no owner assigned.
tags:
  - decision
  - open-question
  - dashboard-build
  - stockist
  - distributor
  - secondary-sales
  - off-take
  - drill-down
  - data-quality
status: draft
generated:
  by: process:claude-sonnet/decisions
  at: "2026-08-23T11:03:46Z"
sources:
  - resource: /_sources/meetings/2026-08-05_dashboard_scope_workshop.txt
    id: T-07
    title: Dashboard scope workshop
    author: Ananya Krishnan
    last_modified: "2026-08-05"
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
updated: "2026-09-22"
---

# Open question — stockist-level drill-down on every dashboard page

**Status: unresolved as of the end of the read corpus (22-Sep-2026). No decision has been made and
none should be inferred from this record.**

**Positions held by:** Vikram Sethi (Sales Ops) vs. Ritwik Ghosh (dashboard build), with Ananya
Krishnan managing time and Shalini Iyer declining to arbitrate the design question. No named owner was
assigned to the open point at the end of `T-07`.

## Context and problem statement

At the dashboard scope workshop (`T-07`, 05-Aug-2026), after Ritwik Ghosh walked through the top-of-
page design for D01 (Primary Sales Performance) showing a table capped around twenty rows, Vikram
Sethi raised his standing ask directly: "I have three hundred forty stockists, if you show me top
fifty I am blind on the rest." He escalated it to a scope-wide position: "if I cannot see Trilok
Traders separately then the dashboard is for someone else, not for me... every dashboard, every one of
them, must go down to stockist level," and specified it further: "primary and secondary both, side by
side — that is what I have been asking since February."

Two separate asks are bundled in this one position, which Ritwik Ghosh named explicitly: (1) drill-down
to distributor level, which already exists on D01 and D03; and (2) showing off-take (secondary sales)
alongside billing (primary sales) on every page, which does not exist anywhere today.

## The disagreement, stated in both parties' own terms

**Vikram Sethi's position:** Sales Operations works at the stockist level, not an aggregate. Export to
Excel is not an acceptable substitute — "then give me an export button and I will do it in Excel" was
offered and explicitly rejected as a real fix, because "the North sheet is because the report does not
give me what I want," and ad hoc spreadsheets are exactly how the organisation ends up with four
different versions of the same number. He does not accept that data quality is a reason to withhold
the number: "then fix the feed" / "we are making the perfect the enemy of something usable." His ask,
restated at the end of the session without change: "stockist level on every dashboard, primary and
secondary side by side. That is it, and it is not changing."

**Ritwik Ghosh's position:** The secondary sales feed covers roughly 74% of distributors — the rest do
not upload, or upload partially — so putting off-take beside billing on the same visual invites people
to subtract one from the other and treat a coverage gap as a real discrepancy: "the gap is not real, it
is a coverage gap," but "an unusable number is worse than no number." He is willing to build a
distributor-level drill-through (already exists on two pages) but not to put an unreliable secondary
figure on every revenue-carrying page. A separate coverage page was also ruled out of the seven
committed dashboards ("a separate page is not in the seven").

**What both sides agree on:** the underlying secondary-sales data quality gap is real (74% coverage,
five days late) and is not something dashboard design can fix. Neither party disputes the coverage
figure itself.

## Attempted narrowing, not a resolution

Ananya Krishnan tried to move the conversation to an action rather than a decision: "can we do this —
Ritwik takes an action to show what a distributor-level drill-through looks like" (accepted, logged as
an action on Ritwik Ghosh). This closes only the drill-through half of Vikram Sethi's ask, not the
primary/secondary side-by-side half, which both parties acknowledge remains open. When Shalini Iyer was
asked to arbitrate, she declined to make it a layout call: "I do not know — that is for Ritwik and
Karthik to work out, it is not really a layout problem though."

## How the session actually ends

No number, no owner: "so we have the seven committed, and two candidates going up for a decision... and
then there is the open point on distributor-level drill-down — I have not put an owner on that one"
(minute-taker, `T-07`). Ananya Krishnan's closing line: "okay, so to close — seven committed, two
candidates going up for a decision, and the drill-down question stays open." Ritwik Ghosh, half in
jest, notes he has already started building without waiting for the resolution: "I have already
started building, na."

## Status as of the end of the read corpus

Still open at the 22-Sep-2026 steering committee (`T-08`). Vikram Sethi raised a closely related point
there — whether Secondary Sales Coverage (D02) is inside the confirmed nine dashboards — and was told
directly it is not: "no, Vikram, secondary coverage is not in the nine." When he pressed further ("the
stockists are asking me every month"), Rajeev Menon moved the conversation offline rather than resolve
it in the room: "Vikram. Offline." Ananya Krishnan committed to a personal call the next morning. No
artifact in the read corpus records that call taking place or its outcome.

## Evidence

| Claim | Source |
|---|---|
| Vikram Sethi's ask: stockist-level drill-down, primary and secondary side by side, on every page | `/_sources/meetings/2026-08-05_dashboard_scope_workshop.txt` (T-07) |
| Ritwik Ghosh's objection: secondary coverage ~74%, five days late; unreliable number is worse than no number | `/_sources/meetings/2026-08-05_dashboard_scope_workshop.txt` (T-07) |
| Shalini Iyer declines to arbitrate; distributor drill-through action given to Ritwik Ghosh as a partial narrowing | `/_sources/meetings/2026-08-05_dashboard_scope_workshop.txt` (T-07) |
| Session closes with the drill-down question explicitly left open and no owner assigned | `/_sources/meetings/2026-08-05_dashboard_scope_workshop.txt` (T-07) |
| Secondary Sales Coverage confirmed not in the nine go-live dashboards; question moved offline at the steering committee, no recorded outcome | `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |

## Follow-ups

- [ ] Assign an owner to the stockist-level, primary/secondary drill-down question — unassigned as of
      `T-07` and still unresolved as of `T-08`.
- [ ] Ritwik Ghosh to demonstrate a distributor-level drill-through (partial narrowing only; does not
      resolve the primary/secondary side-by-side ask).
- [ ] Ananya Krishnan's offline call with Vikram Sethi, committed at `T-08` — outcome not present in
      the read corpus.

## Related concepts

- [/decisions/20260330-dashboard-scope-cut-12-to-7.md](/decisions/20260330-dashboard-scope-cut-12-to-7.md)
- [/decisions/20260922-dashboard-scope-reinstated-7-to-9.md](/decisions/20260922-dashboard-scope-reinstated-7-to-9.md)
- [/concepts/tables/bcpl-edw-fact-secondary-sales.md](/concepts/tables/bcpl-edw-fact-secondary-sales.md)
- [/concepts/tables/bcpl-edw-dim-customer.md](/concepts/tables/bcpl-edw-dim-customer.md) — the stockist/distributor/customer dimension this drill-down would resolve against

## Referenced by

- [Progress](/context/progress.md)
- [Dashboard scope workshop — T-07 — 05 Aug 2026](/meetings/2026-08-05_dashboard_scope_workshop.md)
