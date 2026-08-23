---
type: variance
title: "VAR-007 — Late-arriving SKUs to UNKNOWN member"
description: MAP_FACT_INVOICE_LINE has no late-arriving dimension handling. A SKU invoiced before MAP_DIM_PRODUCT has seen it routes to PRODUCT_KEY = -1 (UNKNOWN) and is never re-pointed once the dimension row arrives. Averages 8,140 lines a month, peaked at 11,902 in Jan-2026, 2.0% of invoiced volume.
resource: BCPL_EDW.DIM_PRODUCT
tags:
  - variance
  - VAR-007
  - late-arriving-dimension
  - UNKNOWN-member
  - product-key
  - DQ-R-04
  - dim-product
  - reporting-layer
owner: Ritwik Ghosh
generated:
  by: process:claude-sonnet/variances
  at: 2026-08-23T10:45:28Z
sources:
  - resource: /_sources/meetings/2026-06-18_dq_readout.txt
    id: T-06
    title: Data quality readout
    author: Neha Gokhale
    last_modified: "2026-06-18"
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
  - resource: /_sources/email/EM-081_late_arriving_skus_unknown_member.eml
    id: EM-081
    title: "VAR-007 - SKUs landing on the UNKNOWN member (-1) and what it does to the product pages"
    author: Ritwik Ghosh
    last_modified: "2026-09-02"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
  - resource: /_sources/technical/schema_edw.sql
    id: TECH-SQL-EDW
    title: BCPL_EDW DDL
    author: Ishaan Bhatt
    last_modified: "2026-04-07"
---

## Observed

A steady share of invoiced volume was landing on the reserved `PRODUCT_KEY = -1` ("UNKNOWN") row of
`DIM_PRODUCT` and staying there. Surfaced through the 31-May-2026 data quality profiling run and
formalised at the 18-Jun-2026 DQ readout.

## Root cause, as derived from the sources

`MAP_FACT_INVOICE_LINE` has **no late-arriving dimension handling at all**. Ishaan Bhatt's mechanism
summary, written for Ritwik Ghosh's benefit (quoted inside EM-081, 31-Aug-2026): "`MAP_FACT_INVOICE_LINE`
looks the SKU up in the dim. if the SKU is not there yet, and often it is not, because an invoice can
be raised the same day the SKU is created, the mapping substitutes `PRODUCT_KEY = -1` and carries on.
The row is not rejected. Nothing is written to `ETL_ERROR_LOG`. So the load audit for that night looks
completely clean and there is nothing to alert on."

The part that makes this a lasting problem rather than a one-night lag: "the part that actually hurts
is the second half. once `MAP_DIM_PRODUCT` picks the SKU up on a later night, the fact row is never
re-pointed. it stays on -1 for good. so this is not a one day lag that heals itself, those rows are
permanently unclassified unless somebody goes back and repairs them" (Ishaan Bhatt, EM-081). A later
correction in the same thread narrows the population slightly: it is not only brand-new SKUs — "it is
not only new skus. anything the lookup cannot resolve takes the same path. new SKUs are just the big
bucket."

Neha Gokhale's framing at T-06 makes clear this is an absence, not a defect in existing logic: "there
is no late arriving handling in the fact mapping at all, it is not that it is broken, it was never
built."

**Distinct from a separate, similar-looking issue**: 37 SKUs in `SKU_MASTER` carry a null
`CATEGORY_CD` — this is a *different* failure with the same symptom on a report (a product attribute
showing blank), and Neha Gokhale is explicit the two should not be conflated: "that is separate, that
is on the master itself, those thirty-seven have a row in the dim, they just have nothing in the
category... different failure, same symptom on a report, which is why people conflate them" (T-06).

## Impact

Deliberately expressed as a **volume percentage, not a rupee figure**: "no and I am deliberately not
putting one, it is a volume percentage, and if I convert it to money somebody will add it to a total
that it does not belong in" (Ananya Krishnan, T-06).

- **2.0% of invoiced volume**
- **8,140 lines/month average**
- **11,902 lines in Jan-2026 (peak)** — "that was the festive replenishment I think" (T-06)
- Fails `DQ-R-04` (completeness: every invoiced SKU resolves to a known `DIM_PRODUCT` member),
  threshold 99.5%, actual **98.0%**

All four figures are as of the 31-May-2026 profiling run. Meghna Rao's own caveat on them, carried
into EM-081: "nothing has changed in the mapping since, so I would expect them to still hold, but
please quote the run date with them wherever you use them." A sample check she ran (500 of the -1
lines) found the SKU code resolves in the master today — confirming these are genuinely late
arrivals, not junk or malformed codes.

## Diagnostic history

| Date | Artifact | What happened |
|---|---|---|
| 31-May-2026 | DQ profiling run | `DQ-R-04` fails at 98.0% against 99.5%; -1 volume quantified. |
| 18-Jun-2026 | T-06 | Formally raised as VAR-007, assigned to the reporting workstream with Ritwik Ghosh as owner ("it lands in the reporting layer more than anywhere else so I will put ritwik as the owner"). No fix planned this release, per the tracker comment logged the same day. |
| 31-Aug to 02-Sep-2026 | EM-081 | The mechanism gets written down properly for the first time (Ishaan Bhatt, in reply to Ritwik Ghosh, explicitly so Ritwik can "put it in your notes properly and stop quoting me from chat" — i.e. the mechanism had previously only existed as informal chat explanation). A downstream reporting design problem is raised in the same thread: on the Product Mix dashboard page, slicing by Category makes UNKNOWN rows drop out of the visual entirely, so the same date range shows two different totals on two different pages depending on whether a product-attribute slicer is applied. Priya Nair frames this as worse than a layout problem — a trust problem: users will conclude the report is broken rather than understand it as 2% of lines pending classification, especially because the old OBIEE reports silently dropped these lines rather than surfacing them at all. |
| 22-Sep-2026 | T-08 | Restated to the steering committee as the fourth open item, with no rupee value — "no rupee number no. it is expressed as a share of invoiced volume." Rajeev Menon notes it will not go in the board pack as a result, though it stays in the register. |

No false-trail history — the mechanism was correctly identified on first diagnosis.

## Status

**Open** at the end of the read corpus. Per Ishaan Bhatt's EM-081 reply: "nothing has gone in for this
one. no mapping change, no fix. it is open." As of EM-081 (02-Sep-2026), Ritwik Ghosh is still waiting
on Karthik Subramanian for a straight answer on whether late-arriving dimension handling is inside the
remediation build before UAT, so that the interim reporting workaround (showing UNKNOWN as a visible,
selectable slicer member) can be built once rather than built and then discarded mid-UAT. No source in
this read set records that answer being given.

## Owner

**Ritwik Ghosh** — consistent across T-06, EM-081, and XL-01. No ownership conflict. Worth noting: the
DQ readout explicitly frames this as belonging to the **reporting workstream**, not the ETL/data
workstream, because the underlying mapping fix (if it happens at all) is not funded this release —
the practical decision in front of the team, as EM-081 frames it, is a reporting-layer workaround
rather than a source fix.

## Remediation

Not built. Three options were on the table as of EM-081 (02-Sep-2026), attributed to Ritwik Ghosh, with
no funded decision recorded in any source read for this file:

1. Show UNKNOWN as a real, selectable member in report slicers (honest, but exposes the gap directly to users).
2. Leave it out of slicers and add a footnote (cleaner page, but the people who need the caveat are the ones least likely to read a footnote).
3. Fix it upstream so fact rows are re-pointed once the dimension catches up, removing the reporting problem at its source — Ritwik's stated preference, but explicitly "not mine to decide."

## Comparison against the canon register

`variance_register_canon.csv` states the same mechanism, the same figures (8,140 average / 11,902
peak / 2.0% / `DQ-R-04` at 98.0% vs 99.5%), and the same owner. Full agreement. The canon register's
one-line summary does not carry the downstream reporting-design consequence (the two-totals-on-two-pages
trust problem) that EM-081 documents in detail — included above because it is the most concrete
evidence in the corpus of this variance's user-facing cost, distinct from its data-quality cost.

## Related concepts

- [/concepts/tables/bcpl-edw-dim-product.md](/concepts/tables/bcpl-edw-dim-product.md) — the dimension carrying the `PRODUCT_KEY = -1` UNKNOWN member
- [/concepts/tables/oms-prod-sku-master.md](/concepts/tables/oms-prod-sku-master.md) — source table; the 37 null-`CATEGORY_CD` rows are a related but distinct issue
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) — the fact carrying the unresolved `PRODUCT_KEY`
- [/concepts/tables/bcpl-edw-etl-error-log.md](/concepts/tables/bcpl-edw-etl-error-log.md) — confirms nothing is logged when a row substitutes the UNKNOWN member; this is precisely why the issue is invisible to load-audit monitoring
- [Scheme Master (OMS_PROD.SCHEME_MASTER)](/concepts/tables/oms-prod-scheme-master.md)

## Referenced by

- [Progress](/context/progress.md)
- [Data quality readout](/meetings/2026-06-18_dq_readout.md)

## Related decisions

- [Go-live date moves from 15-Sep to 30-Oct-2026](/decisions/20260819-golive-date-slip-to-30oct.md)
