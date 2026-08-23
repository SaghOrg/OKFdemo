---
type: variance
title: "VAR-002 — Month-end boundary drift"
description: DATE_KEY on FACT_INVOICE_LINE was derived from INVOICE_HEADER.CREATED_TS, which the application server writes in UTC, so invoices raised after roughly 18:30 IST on the last day of a month were keyed into the following month.
resource: BCPL_EDW.MAP_FACT_INVOICE_LINE
tags:
  - variance
  - VAR-002
  - date-key
  - timezone
  - UTC
  - IST
  - month-end
  - boundary-drift
owner: Karthik Subramanian
generated:
  by: process:claude-sonnet/variances
  at: 2026-08-23T10:45:28Z
sources:
  - resource: /_sources/meetings/2026-03-24_first_variance_findings.txt
    id: T-03
    title: First variance findings
    author: Ananya Krishnan
    last_modified: "2026-03-24"
  - resource: /_sources/meetings/2026-04-14_architecture_review.txt
    id: T-04
    title: Architecture review
    author: Karthik Subramanian
    last_modified: "2026-04-14"
  - resource: /_sources/meetings/2026-05-06_design_signoff.txt
    id: T-05
    title: Design sign-off
    author: Karthik Subramanian
    last_modified: "2026-05-06"
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP schema notes
    author: Aniruddh Deshpande
    last_modified: "2026-03-09"
  - resource: /_sources/decks/DK-03_variance_rootcause_v2.pptx
    id: DK-03
    title: Variance root cause - working readout, v2
    author: Karthik Subramanian
    last_modified: "2026-05-05"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
---

## Observed

A small but persistent number of invoices were landing in the wrong fiscal month in the warehouse —
raised on the last day of a month but reported against the first days of the next. First raised in
T-03 (24-Mar-2026) as the second item Ishaan Bhatt walked through, immediately after VAR-001.

## Root cause, as derived from the sources

The `DATE_KEY` used to place a fact row into a calendar/fiscal period was **not** derived from
`INVOICE_DT` (the correct, business-meaningful, IST date on `OMS_PROD.INVOICE_HEADER`). It was
derived from `INVOICE_HEADER.CREATED_TS`, the row-creation timestamp — and that timestamp is written
by the application server **in UTC**. From T-03: "the created time stamp is written by the
application server in u t c... so it is not india time it is five and a half hours behind."

The consequence, spelled out by Karthik Subramanian in the same session: "any invoice that is raised
after half past six in the evening on the last day of a month gets a created timestamp that already
belongs to the next day and therefore to the next month." Farida Contractor confirmed the operational
pattern that makes this land consistently: "the thirtieth and thirty first of every month the depots
bill till late especially the last day" — so the affected invoices are concentrated exactly where a
month-end boundary problem would be most damaging: late invoicing on the last day of the period.

Aniruddh Deshpande noted at the architecture review (T-04) that this is not a novel failure mode for
this landscape: "we did this in two thousand seventeen also, there was one report, the depot despatch
report, same issue was there, month end quantity was going to next month... in the report layer they
knew, but in the e d w nobody knew or nobody bothered." The UTC-vs-IST date key problem had already
been solved once, in a different report, and the knowledge did not travel to the warehouse build.

## Impact

**INR 90 lakh** (exact: INR 89,74,200) across FY26. Sized in T-03 ("for the full year i am getting
about ninety lakh") and unchanged through to close.

## Diagnostic history

| Date | Artifact | What happened |
|---|---|---|
| 24-Mar-2026 | T-03 | Root cause and full-year impact (~90L) established in one pass. Logged as a separate tracker item from VAR-001 on Ananya Krishnan's instruction ("separate, they are different causes"), even though the fix rides in the same mapping change. |
| 14-Apr-2026 | T-04 | Ani Deshpande adds the 2017 precedent (depot despatch report) as corroborating context; no change to the finding. |
| 06-May-2026 | T-05 | Fix signed off as ADR-005: derive `DATE_KEY` from `INVOICE_DT` instead of `CREATED_TS`. Change `CHG0021207`, same June release window as VAR-001 ("both together"). |
| 12-Jun-2026 | XL-01 / T-08 | Deployed; item closed. |

One documented near-miss worth recording: **DK-03 v1** (circulated 30-Apr-2026) stated this impact as
"INR 9 L" instead of "INR 90 L" — a typo, caught by Sneha Pillai the same afternoon and corrected in
v2 (the version read for this file). DK-03's own slide-1 speaker notes flag this explicitly: "v1 went
out 30-Apr and had the wrong figure on the VAR-002 slide (typo, said 9 L instead of 90 L)... this
version is corrected there." Not a root-cause false trail like VAR-003, but a factual value that was
briefly wrong in circulation and is worth knowing about if anyone is holding onto an old copy of DK-03.

## Status

**Closed** (12-Jun-2026), change reference `CHG0021207`, design decision `ADR-005`.

## Owner

**Karthik Subramanian** — consistent across every source (T-03, DK-03, XL-01, T-08). No ownership
conflict.

## Remediation

`DATE_KEY` derivation changed from `INVOICE_HEADER.CREATED_TS` to `INVOICE_HEADER.INVOICE_DT` in
`MAP_FACT_INVOICE_LINE`, recorded as `ADR-005`, deployed under `CHG0021207` in the same release as
`CHG0021184` (VAR-001). Shalini Iyer was told the fix would move monthly numbers at the boundary "for
a small number of invoices" and asked for an invoice-by-invoice walk of the affected records (T-05).

## Comparison against the canon register

`variance_register_canon.csv` states the same mechanism, the same exact impact figure
(INR 89,74,200), the same owner, and the same open/close dates. Agreement is complete for this item.
The one thing the canon register does not carry, which the sources do, is the DK-03 v1/v2 typo — a
minor but real fact about how the number was briefly misstated in circulation, included above for
completeness.

## Related concepts

- [/concepts/tables/oms-prod-invoice-header.md](/concepts/tables/oms-prod-invoice-header.md) — source of `INVOICE_DT` (correct) and `CREATED_TS` (wrong, UTC)
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) — target fact, `DATE_KEY` column
- [/concepts/tables/bcpl-edw-dim-date.md](/concepts/tables/bcpl-edw-dim-date.md) — the date dimension the corrected key joins to
- [/concepts/variances/var-001-q1-revenue-overstated.md](/concepts/variances/var-001-q1-revenue-overstated.md) — deployed in the same change window, same mapping
- [OMS_PROD.INVOICE_LINE](/concepts/tables/oms-prod-invoice-line.md)

## Referenced by

- [Progress](/context/progress.md)

## Related decisions

- [ADR-005 — DATE_KEY on FACT_INVOICE_LINE derived from INVOICE_DT, not CREATED_TS](/decisions/20260506-var002-date-key-fix.md)
