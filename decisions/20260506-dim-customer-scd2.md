---
type: decision
title: "ADR-002 — DIM_CUSTOMER keeps history (SCD2)"
description: DIM_CUSTOMER is built as an SCD2 dimension, effective-dated on TERRITORY_CODE, REGION_CODE, STATE_CODE, DEPOT_CODE and CUSTOMER_TYPE, so a territory reassignment does not restate sales already reported for a closed period. Proposed at the architecture review, objected to on load-window grounds, the objection resolved by measurement, and formally approved by the business sponsor at design sign-off.
tags:
  - decision
  - ADR-002
  - dim-customer
  - scd2
  - scd1
  - effective-dating
  - territory-reassignment
  - load-window
  - conformed-dimension
status: accepted
generated:
  by: process:claude-sonnet/decisions
  at: 2026-08-23T11:03:46Z
sources:
  - resource: /_sources/meetings/2026-04-14_architecture_review.txt
    id: T-04
    title: Architecture review
    author: Karthik Subramanian
    last_modified: "2026-04-14"
  - resource: /_sources/email/EM-041_farida_scd2_concern.eml
    id: EM-041
    title: "RE: DIM_CUSTOMER dimension design - your comments"
    author: Farida Contractor
    last_modified: "2026-04-16"
  - resource: /_sources/email/EM-047_karthik_scd2_counter.eml
    id: EM-047
    title: "RE: RE: FW: RE: SCD2 load window, measured on DEV"
    author: Karthik Subramanian
    last_modified: "2026-04-23"
  - resource: /_sources/trackers/XL-03_scd2_load_impact.xlsx
    id: XL-03
    title: SCD2 load impact - assumptions, scenarios and conclusion
    author: Karthik Subramanian
    last_modified: "2026-04-23"
  - resource: /_sources/meetings/2026-05-06_design_signoff.txt
    id: T-05
    title: Design sign-off
    author: Karthik Subramanian
    last_modified: "2026-05-06"
  - resource: /_sources/docs/DOC-04_dimension_strategy.docx
    id: DOC-04
    title: BCPL_EDW Dimension Strategy (Appendix A, ADR-001 to ADR-005)
    author: Karthik Subramanian
    last_modified: "2026-05-11"
updated: "2026-05-11"
---

# ADR-002 — DIM_CUSTOMER keeps history (SCD2)

**Deciders:** Shalini Iyer (business sponsor, formal approver), Karthik Subramanian, Ananya Krishnan,
Farida Contractor, Aniruddh Deshpande, Ishaan Bhatt, Sneha Pillai. Rajeev Menon joined T-05 partway
through (15:52) and deferred to Shalini's approval without a separate technical view.

**Consulted:** Farida Contractor raised the load-window objection in writing (`EM-041`) ahead of the
design session rather than in the room, at Karthik Subramanian's own request (`EM-047` quotes his
15-Apr mail asking for her view before he wrote the design up formally).

## Context and problem statement

`DIM_CUSTOMER` was originally built as SCD1 — one row per customer, overwritten in place when an
attribute changes. Distributor territory, region and depot assignments change during the year, and
when they do, SCD1 immediately restates every historic invoice line for that distributor against the
new territory: "if a distributor moves territory in April and we overwrite, then all of last year's
sales for that distributor get reported against the new territory, which is not what happened"
(Karthik Subramanian, `T-04`). Shalini Iyer named the consequence in business terms at `T-05`: "if I
close a quarter and sign a pack and then somebody in sales ops does a territory realignment in April
and my April numbers for a closed quarter change, then I have signed something that is no longer
true — that is not a reporting preference, that is an audit problem." Territory realignment is not an
edge case: it happens three or four times a year and moves fifty to sixty distributors at once when
it does (Aniruddh Deshpande, `T-04`).

The candidate fix — SCD2, effective-dated with `EFF_START_DT`, `EFF_END_DT` and `CURRENT_FLG` — was
raised at the architecture review (`T-04`, 14-Apr-2026) and left explicitly open at the end of that
session: "today was scoping the decisions, not taking them, except product... customer is open and I
want Farida's number and my number in the same place before we talk about it again" (Karthik
Subramanian / Farida Contractor, `T-04`).

## Decision drivers

- Sales already reported for a closed period must not move when a distributor is reassigned —
  Finance's core requirement, stated independently by both Shalini Iyer and Sales Operations in
  materially the same words (`DOC-04` §5.1).
- The nightly load window is not elastic. Farida Contractor, who owns the load, objected in writing
  (`EM-041`, 16-Apr-2026) before the design was written up formally:
  - `MAP_DIM_CUSTOMER` ran a stable 4 min 12 sec average over the prior 30 runs.
  - Her estimate for the SCD2 cost was **12 to 15 minutes** on a month-end night — explicitly labelled
    an estimate, not a measurement.
  - `LP_DAILY_SALES` (the nightly plan `MAP_DIM_CUSTOMER` sits inside) finishes around 02:05 IST on an
    ordinary night but 04:10–04:12 IST on the worst month-end nights in the sample, against a 05:30
    IST availability SLA — the SLA had already been breached twice that quarter (14-Feb, 02-Mar).
  - Her counter-proposal: keep `DIM_CUSTOMER` as SCD1 and write changed rows to a separate history
    table instead, so the nightly cost sits on a small insert rather than a compare-and-update across
    the whole dimension. She asked to be shown *why* this was wrong rather than told that it was
    (`EM-041`, point 6).
  - Her explicit condition: "measure it on DEV, show me the number and the method, and I will look at
    it again the same day" (`EM-041`, point 7).

## Considered options

1. **Keep SCD1** on `DIM_CUSTOMER`. Rejected: restates closed-period reporting on every reassignment,
   which both Finance and Sales Operations stated they could not accept.
2. **SCD1 with a separate history table** (Farida Contractor's counter-proposal, `EM-041` point 6):
   keep the dimension current and small, write changed rows to a history table with effective dates,
   and let downstream consumers join to that table for historic attribution. Karthik Subramanian
   acknowledged this as "a fair question" and "a modelling question rather than a load question" in
   `EM-047` (23-Apr-2026) and deferred a written answer to the design session; the design session
   itself resolved Farida's objection through the measured cost of full SCD2 rather than by working
   through this alternative's own trade-offs on the record, and no artifact in the read set shows it
   being formally ruled out — it is not carried forward as an open item either.
3. **SCD2 on `DIM_CUSTOMER`**, tracking `TERRITORY_CODE`, `REGION_CODE`, `STATE_CODE`, `DEPOT_CODE`
   and `CUSTOMER_TYPE`. Facts resolve `CUSTOMER_KEY` by natural key plus invoice date falling inside
   `EFF_START_DT`–`EFF_END_DT`, not by `CURRENT_FLG='Y'` (`DOC-04` §5.4). Chosen.

## Decision outcome

Chosen: **Option 3 — SCD2 on `DIM_CUSTOMER`**, approved by Shalini Iyer as business sponsor at design
sign-off (`T-05`, 06-May-2026): "so, Shalini, formally as the business sponsor, are you approving SCD2
on DIM_CUSTOMER" / "yes, yes, I am approving it" (Ananya Krishnan / Shalini Iyer).

Because the business requirement (closed periods must not restate) was uncontested, and the one real
objection — load-window cost — was closed by measurement rather than argument. Karthik Subramanian
measured the actual delta on DEV (21-Apr-2026) instead of answering Farida Contractor's estimate with
a counter-estimate: **+7 min 28 sec** (4 min 12 sec → 11 min 40 sec), lower than her 12–15 minute
estimate. Modelled against the worst month-end night in a 76-night sample rather than the average, the
plan finish moves from 04:12 IST to **04:20 IST** against the 05:30 IST SLA — **70 minutes of
head-room** (`XL-03`, circulated `EM-047`, 23-Apr-2026). Farida Contractor accepted the measured number
on the record at `T-05`: "I accepted the measurement, yes. I am not going to argue with a measured
number, that is not my style" — while stating plainly that she was not blocking, not endorsing: "no,
no, I am not blocking it, I am saying it is a risk and it stays on the risk list."

### Consequences

- Good: A territory reassignment no longer restates historic reporting. The April invoice for a
  reassigned distributor keeps pointing at the April version of that customer (`T-05`).
- Good: Side benefits surfaced in discussion — a de-listed-then-relisted product-style visibility
  applies analogously to customer status changes, and `MAP_STG_CUSTOMER_TERRITORY_HIST` is retained in
  the extract as an input even though it cannot be used as the system of record (it has no primary key
  and contains overlapping, back-dated rows) — "we can use it as an input... but we cannot use it as
  the truth" (Karthik Subramanian, `T-05`).
- Bad: The nightly load gets measurably slower — accepted risk, not a free change. Farida Contractor's
  risk-register position stands: "then we are having this conversation again" if the real (post-build)
  number comes back worse than the DEV model (`T-05`). A re-measurement on rebuilt DEV, then UAT, is
  an explicit follow-up rather than a closed question.
- Bad: Existing `DIM_CUSTOMER` rows carry no version history — the dimension was SCD1 until this
  decision. `DOC-04` §5.5 records this as a real gap and recommends against inventing history: new
  rows open a single version dated from the start of loaded fact history (Option A), with
  back-populating from the unreliable `CUSTOMER_TERRITORY_HIST` source table (Option B) held as a
  separate, Finance-owned decision, not taken here.
- Neutral: The fact-to-dimension lookup changes from a current-row lookup to a date-ranged lookup —
  "the single change with the most risk in it" per `DOC-04` §11, and the closing-rule invariant (no
  two versions of the same customer with overlapping effective dates) becomes a hard, tested rule
  after the near-identical failure mode surfaced independently as `VAR-004`.

## Evidence

| Claim | Source |
|---|---|
| SCD1 restates closed periods on reassignment; territory changes 3-4x/year, 50-60 distributors at a time | `/_sources/meetings/2026-04-14_architecture_review.txt` (T-04) |
| Farida Contractor's written objection: current runtime 4 min 12 sec, estimate 12-15 min added, SLA breaches 14-Feb and 02-Mar, counter-proposal of a separate history table | `/_sources/email/EM-041_farida_scd2_concern.eml` |
| Measured delta +7 min 28 sec (4:12 → 11:40) on DEV 21-Apr-2026; worst-case finish 04:20 IST vs 05:30 SLA, 70 min head-room | `/_sources/trackers/XL-03_scd2_load_impact.xlsx`, circulated in `/_sources/email/EM-047_karthik_scd2_counter.eml` |
| Farida Contractor accepts the measured number but keeps it on the risk register, not blocking | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Shalini Iyer's formal approval as business sponsor | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Tracked attributes: TERRITORY_CODE, REGION_CODE, STATE_CODE, DEPOT_CODE, CUSTOMER_TYPE; fact resolves on natural key + invoice date, not CURRENT_FLG | `/_sources/docs/DOC-04_dimension_strategy.docx` §5.3-5.4, Appendix A ADR-002 |

## Follow-ups

- [ ] Re-measure the full load plan (not just the interface) on rebuilt DEV once both `DIM_CUSTOMER`
      and `DIM_PRODUCT` are converted, then again on UAT when available — owner Ishaan Bhatt (DEV) /
      Farida Contractor (full-plan timing), by 22-May-2026 and 29-May-2026 respectively (`T-05`
      action items AI-31, AI-32).
- [ ] Decide whether to back-populate `DIM_CUSTOMER` history from `OMS_PROD.CUSTOMER_TERRITORY_HIST`
      (Option B, `DOC-04` §5.5/§10.2) — explicitly a Finance decision, not yet taken.
- [ ] Add a function-based unique index enforcing exactly one `CURRENT_FLG='Y'` row per `CUSTOMER_ID`
      (`DOC-04` §7.6/§10.1) — open item, not yet raised as a change at the time of writing.

## Related concepts

- [/concepts/tables/bcpl-edw-dim-customer.md](/concepts/tables/bcpl-edw-dim-customer.md)
- [/concepts/variances/var-004-scd2-territory-reassignment.md](/concepts/variances/var-004-scd2-territory-reassignment.md) — the closing-rule invariant this decision required is exactly the rule `VAR-004` broke in the build
- [/decisions/20260506-dim-product-scd2.md](/decisions/20260506-dim-product-scd2.md) — the companion SCD2 decision taken the same day, ADR-003

## Referenced by

- [Progress](/context/progress.md)
- [Design sign-off](/meetings/2026-05-06_design_signoff.md)
- [Architecture review](/meetings/2026-04-14_architecture_review.md)
