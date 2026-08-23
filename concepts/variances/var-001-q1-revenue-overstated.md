---
type: variance
title: "VAR-001 — FY26 Q1 revenue overstated"
description: MAP_FACT_INVOICE_LINE carried no DELETE_FLAG filter at all, so cancelled and logically-deleted invoice lines were loaded into FACT_INVOICE_LINE and counted as live revenue, overstating FY26 Q1 (Apr-Jun 2025) by INR 4.20 Cr.
resource: BCPL_EDW.MAP_FACT_INVOICE_LINE
tags:
  - variance
  - VAR-001
  - delete-flag
  - revenue-overstatement
  - FY26-Q1
  - invoice-line
  - trial-balance
owner: Farida Contractor
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

The warehouse was reporting FY26 Q1 (Apr-Jun 2025) net revenue of INR 438.60 Cr straight off
`FACT_INVOICE_LINE`. Shalini Iyer's trial balance came in INR 4.20 Cr lower and she would not sign
the board pack against the warehouse figure — a gap she had been chasing "since the eleventh of Feb"
per kickoff, and which surfaced formally at the first variance findings session on 24-Mar-2026 (T-03).

## Root cause, as derived from the sources

`MAP_FACT_INVOICE_LINE`, the ODI mapping that loads `OMS_PROD.INVOICE_LINE` into
`BCPL_EDW.FACT_INVOICE_LINE`, applied **no filter on `DELETE_FLAG` at all**. Ishaan Bhatt found this
by pulling the mapping XML: "in the mapping for the fact there is no delete flag filter at all... all
of them, there is no filter" (T-03). Every invoice line loaded, including ones a user had since
cancelled in ORION (`DELETE_FLAG = 'Y'`).

The obvious one-line fix — `DELETE_FLAG = 'N'` — is wrong, and this is the part of the story that
actually explains why it sat unnoticed since the interface was built in 2021. Per DOC-01 (Aniruddh
Deshpande): `DELETE_FLAG` did not exist before the GST rework, release R11.4, deployed 30-Mar-2019.
It was added with `DEFAULT 'N'`, but the default only applies to rows inserted after the column
exists — the pre-existing population was never back-filled. So the column is three-valued: `'Y'`
(cancelled), `'N'` (live), and `NULL` (created before Apr-2019, real historic sales). A plain
`DELETE_FLAG = 'N'` predicate passes every test written against recent data, because everything
recent is `'N'` — and it silently drops the entire pre-2019 population, roughly 9.2 million rows
(Ishaan's count in T-04: "nine point two million... out of about six point one core in invoice
line", roughly 14-15% of the table). The correct predicate, agreed in T-03 and confirmed at design
sign-off (T-05), is `NVL(DELETE_FLAG,'N') = 'N'`.

DOC-01 frames the mechanism plainly: "the predicate has to be `NVL(DELETE_FLAG,'N') = 'N'`. if
anybody writes `DELETE_FLAG = 'N'` it will pass every test they run... and it will silently throw
away the entire pre-2019 population."

## Impact

- **INR 4.20 Cr** (exact: INR 4,21,63,910) of cancelled/logically-deleted lines counted as revenue,
  concentrated in FY26 Q1 (Apr-Jun 2025), the quarter Shalini's board pack covered.
- Restated FY26 Q1 net revenue after the fix: **INR 434.40 Cr** (down from the pre-fix INR 438.60 Cr
  reported in the warehouse) — T-08: "the restated q one number is four three four point four zero
  core."

## Diagnostic history

| Date | Artifact | What happened |
|---|---|---|
| 24-Mar-2026 | T-03 | Ishaan Bhatt identifies the missing filter from the mapping XML; the three-valued-flag catch is explained live by Aniruddh Deshpande on the call so the fix isn't mis-written as a plain `= 'N'`. |
| 14-Apr-2026 | T-04 | Same finding reconfirmed at the architecture review; the `NVL` predicate and the ~9.2 million null-flag row count are restated for the design record. |
| 06-May-2026 | T-05 | Fix formally signed off: `NVL(DELETE_FLAG,'N')='N'` in the mapping, change `CHG0021184`, targeted for the June release window. |
| 12-Jun-2026 | XL-01 / T-08 | Fix deployed. Shalini ties out to the trial balance for Apr-Jun; item closed. |

No false trail on this one — the cause was found and confirmed in a single session (T-03) and never
revised. The only thing that took discussion was **which** fix to apply, not what was wrong.

## Status

**Closed** (12-Jun-2026), change reference `CHG0021184`.

## Owner

**Farida Contractor** — consistent across every source that names an owner (T-03, DK-03, XL-01, T-08).
No ownership conflict on this item.

## Remediation

Mapping predicate changed to `NVL(DELETE_FLAG,'N')='N'`, deployed under `CHG0021184` in the June 2026
release, alongside the VAR-002 fix (both changes were scoped to the same mapping and released together
per Farida Contractor's request in T-03: "if both changes are in the same interface then it is one
deployment and one regression").

## Comparison against the canon register

`variance_register_canon.csv` states the same mechanism, the same exact impact figure
(INR 4,21,63,910), the same owner, and the same open/close dates. My reading of T-03, T-04, T-05,
DOC-01, DK-03 and XL-01 agrees with the canon register on every point for this item — no
discrepancy found.

## Related concepts

- [/concepts/tables/oms-prod-invoice-line.md](/concepts/tables/oms-prod-invoice-line.md) — source table, `DELETE_FLAG` column
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) — target fact, `SRC_DELETE_FLAG` column
- [/concepts/variances/var-002-date-key-timezone.md](/concepts/variances/var-002-date-key-timezone.md) — deployed in the same change window, same mapping
- [/concepts/variances/var-008-feb-duplicate-load.md](/concepts/variances/var-008-feb-duplicate-load.md) — different mechanism, same "green batch does not mean correct data" family of finding

## Referenced by

- [Progress](/context/progress.md)

## Related decisions

- [Open question — whether to re-run February's load (VAR-008)](/decisions/20260324-var008-february-reload-deferred.md)
- [VAR-008 resolved: Finance restates February internally; batch-id guard rides with R2026.07](/decisions/20260402-var008-february-restatement-and-batch-guard.md)
