---
type: decision
title: "Go-live dashboard scope reinstated to 9 (D04, D11 return)"
description: D04 (Scheme Effectiveness) and D11 (Credit and Receivables Exposure) are added back into go-live scope, funded from a Phase 2 budget line Klarissen Group released in August, following the credit note escalation (VAR-005) and the scheme discount work (VAR-003). Confirmed to the steering committee as nine dashboards live on 12-Nov-2026, at go-live, not by end of hypercare.
tags:
  - decision
  - dashboard-scope
  - reporting-scope
  - go-live
  - D04
  - D11
  - scheme-effectiveness
  - credit-and-receivables-exposure
  - phase-2
  - klarissen
status: accepted
generated:
  by: process:claude-sonnet/decisions
  at: 2026-08-23T11:03:46Z
sources:
  - resource: /_sources/decks/DK-05_dashboard_wireframes.pptx
    id: DK-05
    title: Power BI wireframe pack - seven committed pages, two candidates for sponsor decision
    author: Ritwik Ghosh
    last_modified: "2026-08-05"
  - resource: /_sources/meetings/2026-08-05_dashboard_scope_workshop.txt
    id: T-07
    title: Dashboard scope workshop
    author: Ananya Krishnan
    last_modified: "2026-08-05"
  - resource: /_sources/decks/DK-06_steerco_sep2026.pptx
    id: DK-06
    title: Steering Committee, 22 September 2026
    author: Ananya Krishnan
    last_modified: "2026-09-22"
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
updated: "2026-09-22"
---

# Go-live dashboard scope reinstated to 9 (D04, D11 return)

**Deciders:** The funding/scope decision itself sits with Klarissen Group ("the sponsor decides" —
`DK-05`); Marijke van der Berg is named as the requester on behalf of Group ("we asked," `T-08`).
**Confirmed to:** Rajeev Menon (chair), Shalini Iyer, Vikram Sethi, Karthik Subramanian, Ananya
Krishnan, Sneha Pillai, Marijke van der Berg (`T-08`).

## Context and problem statement

After the cut from 12 to 7 (see
[/decisions/20260330-dashboard-scope-cut-12-to-7.md](/decisions/20260330-dashboard-scope-cut-12-to-7.md)),
D04 (Scheme Effectiveness) and D11 (Credit and Receivables Exposure) were two of the five dashboards
deferred to Phase 2. Both kept coming up in conversation during the dashboard build workshop
(`T-07`, 05-Aug-2026) — Vikram Sethi raised the inability to measure whether a trade scheme actually
worked, and the credit note position (`VAR-005`) had by then been escalated to Group level by Marijke
van der Berg (14-Jul-2026, `EM-061`). `DK-05`, circulated the same day as `T-07`, carries both as
**"CANDIDATE — not funded"**: sketched layouts, explicitly not to be designed in detail until a sponsor
decision was made — "these two are not funded... this pack shows them as candidates, that is as far as
it goes" (`DK-05` speaker notes). `T-07` closed without a number: "seven committed, two candidates,
going up for a decision" (Ananya Krishnan).

No artifact in the read corpus documents the moment Group released the Phase 2 budget line in August;
the first confirmation available is the steering committee pack itself.

## Decision drivers

- Klarissen Group's own stated needs: "we asked for Scheme Effectiveness because we cannot see the
  promo accrual anywhere at all, and Credit and Receivables for the obvious reason" (Marijke van der
  Berg, `T-08`), tying D04 to the `VAR-003` scheme discount finding and D11 to the `VAR-005` credit
  note escalation.
- Funding source: both dashboards are funded from "the Phase 2 budget line Group released in August,"
  explicitly not from Shalini Iyer's own budget ("so it is not coming out of my budget" / "it is not
  coming out of your budget, good, I like that answer" — Vikram Sethi and Ananya Krishnan, `T-08`).
- Delivery risk: both sit on the existing `DRISHTI_SALES` data model, so this is build effort only, not
  new plumbing, and Ritwik Ghosh already had wireframes for both from August — confirmed by Karthik
  Subramanian not to move the 12-Nov go-live date (`DK-06`, `T-08`).

## Considered options

By the time this reached the steering committee it was presented as a confirmed scope figure, not a
live choice among options — the deliberation (fund vs. do not fund) happened at Group level, off the
record available in this corpus.

## Decision outcome

Chosen: **Nine dashboards live at go-live, 12-Nov-2026** — the original seven plus D04 and D11
reinstated. Confirmed explicitly as an at-go-live figure, not an end-of-hypercare figure: "ananya, is
nine at go-live, or nine by the end of hypercare?" / "at go-live, on the twelfth" (Vikram Sethi and
Ananya Krishnan, `T-08`). Secondary Sales Coverage (D02) is **not** part of the nine — Vikram Sethi's
separate, unresolved ask; see
[/decisions/20260805-dashboard-stockist-drilldown-unresolved.md](/decisions/20260805-dashboard-stockist-drilldown-unresolved.md).

Because Klarissen Group funded both dashboards specifically in response to two open variances
(`VAR-003`, `VAR-005`) that Group itself had escalated, and because the reinstatement does not put the
12-Nov date at risk.

### Consequences

- Good: D04 and D11 build on the existing model — Ritwik Ghosh is "not starting cold," having
  wireframes from August.
- Good: Does not move the 12-Nov go-live date — confirmed on the record by Karthik Subramanian.
- Bad: Additional load on Ritwik Ghosh's team inside the same build window as the rest of the
  programme — as of `DK-06`'s own speaker notes, the dashboard build was privately about two reports
  behind plan at the time of the 22-Sep pack, "smoothed over" to a green status row because D04/D11 do
  not move the date, only the workload; the honest verbal answer, if pressed, was amber.
- Neutral: D02 (Secondary Sales Coverage), D08, and D10 — the other three dashboards deferred in the
  12→7 cut — are **not** reinstated by this decision and remain in Phase 2.
- Neutral: All nine, including the two reinstated, are covered in the UAT script set — "all nine, yes,
  including the two new ones" (Ananya Krishnan, `T-08`).

## Evidence

| Claim | Source |
|---|---|
| D04 and D11 carried as unfunded candidates, sponsor decision pending, after the dashboard workshop | `/_sources/decks/DK-05_dashboard_wireframes.pptx` |
| T-07 closes at "seven committed, two candidates," no number reached | `/_sources/meetings/2026-08-05_dashboard_scope_workshop.txt` (T-07) |
| Nine dashboards confirmed live 12-Nov-2026, at go-live not end of hypercare; D04/D11 named as reinstated, funded from the Phase 2 budget line released in August; secondary sales coverage not included | `/_sources/decks/DK-06_steerco_sep2026.pptx`; `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |
| Marijke van der Berg's stated reasons for D04 and D11 | `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |
| D04/D11 build does not move the 12-Nov date, sits on the existing model | `/_sources/decks/DK-06_steerco_sep2026.pptx`; `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |

## Follow-ups

- [ ] None outstanding specific to this scope decision as of 22-Sep-2026; dashboard build workstream
      tracked as amber internally despite a green report to committee (`DK-06` speaker notes) — watch
      for slippage next cycle.

## Related concepts

- [/decisions/20260330-dashboard-scope-cut-12-to-7.md](/decisions/20260330-dashboard-scope-cut-12-to-7.md) — the cut this decision partially reverses
- [/decisions/20260805-dashboard-stockist-drilldown-unresolved.md](/decisions/20260805-dashboard-stockist-drilldown-unresolved.md)
- [/concepts/variances/var-003-scheme-discount-double-count.md](/concepts/variances/var-003-scheme-discount-double-count.md) — motivation for D04
- [/concepts/variances/var-005-credit-notes-absent.md](/concepts/variances/var-005-credit-notes-absent.md) — motivation for D11
- [/concepts/tables/fin-prod-ar-open-item.md](/concepts/tables/fin-prod-ar-open-item.md) — D11 is built on receivables ageing from this extract
