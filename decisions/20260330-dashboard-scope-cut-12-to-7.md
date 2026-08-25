---
type: decision
title: "Go-live dashboard scope cut from 12 to 7"
description: Shalini Iyer cuts the go-live dashboard list from the 12 scoped at kickoff to 7, moving D02, D04, D08, D10 and D11 to Phase 2. Driven by a Group capex freeze on the BI licence uplift and by UAT tester availability in Sales Operations, not by a change in what the business wants.
tags:
  - decision
  - dashboard-scope
  - reporting-scope
  - go-live
  - power-bi
  - phase-2
  - capex-freeze
  - uat
status: proposed
generated:
  by: process:claude-sonnet/decisions
  at: "2026-08-23T11:03:46Z"
sources:
  - resource: /_sources/decks/DK-01_kickoff_v3_FINAL.pptx
    id: DK-01
    title: "Kickoff: Data, Analytics & Reporting Transformation"
    author: Ananya Krishnan
    last_modified: "2026-02-11"
  - resource: /_sources/email/EM-023_dashboard_scope_cut.eml
    id: EM-023
    title: "RE: RE: FW: Drishti - discovery close out pack and Friday actions"
    author: Shalini Iyer
    last_modified: "2026-03-30"
updated: "2026-03-30"
---

# Go-live dashboard scope cut from 12 to 7

**Deciders:** Shalini Iyer (Head of Finance Systems, BCPL — the decision is hers to make and is stated
as such). **Informed:** Rajeev Menon (flagged directly, in case Group raised it with him first), Priya
Nair, Ananya Krishnan.

## Context and problem statement

`DK-01`, the kickoff deck (11-Feb-2026), scoped **12 dashboards** (D01–D12) for go-live "per the SOW."
On 30-Mar-2026, Shalini Iyer wrote to cut that list to **7**, closing the loop on a scope confirmation
Ananya Krishnan had asked for since the discovery close-out (27-Mar-2026): "the reporting scope
confirmation... without [it] Ritwik is sizing a build against a list that is not fixed."

## Decision drivers

- **Group capex freeze.** "I have the FY27 position back from Group now and I have to cut the go-live
  list... Group has frozen the capex line that the BI licence uplift was sitting in. Without that
  uplift we can fund seven dashboards for go-live and we cannot fund twelve. That is the whole of it
  and it is not a negotiation I can win from here" (Shalini Iyer, `EM-023`).
- **UAT tester capacity.** "Even if the money were there I do not have the user time to take twelve
  dashboards through UAT. The people who would test are the same people who close the month for me,
  and Sales Ops are short-handed as it is. Seven is what we can put in front of users properly rather
  than badly" (`EM-023`).

## Considered options

The mail records a decision already made rather than options weighed in the open — Shalini Iyer states
the constraint (capex line frozen) as fixed and not negotiable from her position. The only choice
exercised on the record is *which seven stay in*.

## Decision outcome

Chosen: **Seven dashboards stay in scope for go-live; five move to Phase 2.**

Stays in for go-live:
- D01 Primary Sales Performance
- D03 Distributor Scorecard
- D05 Stock and Despatch
- D06 Order Fulfilment and Fill Rate
- D07 Revenue Reconciliation
- D09 Product Mix and Contribution
- D12 Executive Summary

Moves to Phase 2:
- D02 Secondary Sales Coverage
- D04 Scheme Effectiveness
- D08 GST and Tax Summary
- D10 Sales Rep Productivity
- D11 Credit and Receivables Exposure

Because the funding was not available for the licence uplift the full twelve required, and the
business could not properly UAT twelve dashboards with the testers actually available.

### Consequences

- Good: Seven dashboards get a build the business can properly test rather than "badly."
- Bad: Five capabilities are deferred, including GST/Tax Summary, Sales Rep Productivity, Secondary
  Sales Coverage, Scheme Effectiveness and Credit/Receivables Exposure — the last two of which were
  later reinstated; see
  [/decisions/20260922-dashboard-scope-reinstated-7-to-9.md](/decisions/20260922-dashboard-scope-reinstated-7-to-9.md).
- Neutral: Shalini Iyer was explicit that the five are deferred, not cancelled — "please do not go back
  and tell the team that the five are cancelled, they are Phase 2. I will make the case for them again
  at the FY27 review" — and that nothing already running in OBIEE for those five topics should be
  switched off in the interim.
- Neutral: Ritwik Ghosh was directed not to start building against the deferred five.

## Evidence

| Claim | Source |
|---|---|
| 12 dashboards scoped for go-live per the SOW | `/_sources/decks/DK-01_kickoff_v3_FINAL.pptx` |
| Cut to 7; capex freeze on the BI licence uplift; UAT tester capacity in Sales Ops | `/_sources/email/EM-023_dashboard_scope_cut.eml` |
| The 7 that stay in and the 5 that move to Phase 2, with instruction not to describe the 5 as cancelled | `/_sources/email/EM-023_dashboard_scope_cut.eml` |

## Follow-ups

- [ ] Ananya Krishnan to deliver the revised build plan against the seven, by 03-Apr-2026 (`EM-023`).
- [ ] Priya Nair to ensure none of the five deferred reports are switched off in OBIEE (`EM-023`).
- [ ] Shalini Iyer to make the case for the deferred five again at the FY27 review (`EM-023`).

## Related concepts

- [/decisions/20260922-dashboard-scope-reinstated-7-to-9.md](/decisions/20260922-dashboard-scope-reinstated-7-to-9.md) — D04 and D11 reinstated from this deferred set
- [/decisions/20260805-dashboard-stockist-drilldown-unresolved.md](/decisions/20260805-dashboard-stockist-drilldown-unresolved.md) — the dashboard-build workshop that followed this scope cut

## Referenced by

- [Dashboard scope workshop — T-07 — 05 Aug 2026](/meetings/2026-08-05_dashboard_scope_workshop.md)
