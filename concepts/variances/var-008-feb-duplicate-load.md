---
type: variance
title: "VAR-008 — Feb duplicate load"
description: LP_DAILY_SALES failed on the night of Saturday 14-Feb-2026 and was resubmitted manually as session SESS_884012. IKM Oracle Control Append has no update branch, so the entire night's invoice lines were appended a second time. INR 2.9 Cr of duplicated sales sat in the February figures for three weeks.
resource: BCPL_EDW.LP_DAILY_SALES
tags:
  - variance
  - VAR-008
  - duplicate-load
  - LP_DAILY_SALES
  - IKM-control-append
  - manual-resubmit
  - batch-id
  - SESS_884012
owner: Farida Contractor
generated:
  by: process:claude-sonnet/variances
  at: "2026-08-23T10:45:28Z"
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
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
  - resource: /_sources/email/EM-072_feb_duplicate_load_chain.eml
    id: EM-072
    title: "February reconciliation - LP_DAILY_SALES re-run 14-Feb (five-level forwarded chain)"
    author: Farida Contractor
    last_modified: "2026-08-21"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
---

## Observed

North region billing figures for February 2026 did not match Vikram Sethi's own extract, first
flagged by him on 06-Mar-2026 ("north stockist billing in teh report is coming much higher than my
sheet"). Priya Nair independently confirmed the report layer was reproducing the same figure as the
warehouse and traced it to a screenshot comparison: a 20-Feb-2026 screenshot of the Distributor
Scorecard showed a lower February primary figure than the same report showed on re-run, with nothing
changed in the analysis in between — pointing at data that had grown, not a report defect.

## Root cause, as derived from the sources

`LP_DAILY_SALES` (the nightly load plan) failed on the night of **Saturday 14-Feb-2026**. Farida
Contractor resubmitted it manually the same night; the resubmission is recorded as **session
`SESS_884012`**. Because the fact interface loads via `IKM Oracle Control Append` — **insert-only,
with no update branch and no key declared on the fact's natural key** — the resubmission did not skip
or replace anything already loaded. It re-read the same incremental window and appended the entire
night's invoice lines a second time. Per Ishaan Bhatt (quoted in EM-072, 27-Mar-2026 mail forwarded
in the chain): "IKM Oracle Control Append has no update branch and there is no update key declared on
the fact mapping. so whatever the predicate hands it gets inserted. it has no way of recognising a row
it has already seen."

Confirmation that the duplicates are a clean re-run rather than something more complicated: "the
february dupes are exact dupes. same `INVOICE_LINE_ID` appearing twice in the fact, same amounts,
same everything. not partial rows and not a rounding thing... every second copy carries the load date
of the re-run, so they all arrived together in one session rather than dribbling in over the month.
that is what makes me confident it is the resubmit and not something else" (Ishaan Bhatt, EM-072).

This is explicitly the **same underlying weakness in the load** that made VAR-003's duplication
possible (insert-only append, no merge, no natural-key constraint on the fact) — but a **different
trigger**. VAR-003 is triggered by a source-side procedure quietly moving `LAST_UPD_DT` on rows the
warehouse has already extracted; VAR-008 is triggered by a manual resubmission of a failed plan. T-03
records the team explicitly choosing to log them as separate tracker items despite the shared
mechanism: "same family, different trigger, and I would keep them as separate items in the tracker"
(Aniruddh Deshpande, paraphrased in the transcript as Speaker 4).

Why it sat undetected for three weeks: 14-Feb-2026 was a Saturday, "a small night by volume,"
so the duplication did not stand out on a daily view and only surfaced once someone totalled the
month (Ishaan Bhatt, EM-072). Farida Contractor's own account of the gap in process control is candid
rather than defensive: "there is no mail from February saying the run had failed. it failed, I
resubmitted it, the plan completed, and that was the end of it as far as anybody knew until Vikram's
mail on the 6th. that gap is not a process I can point at, it is simply that a resubmit was normal and
nobody logged it" (EM-072).

## Impact

**INR 2.90 Cr** (exact: INR 2,94,10,000) of duplicated sales, sitting inside the February figures for
roughly three weeks before being caught and tied out (Ishaan Bhatt's count, confirmed against Farida
Contractor's working — EM-072, T-03).

## Diagnostic history

| Date | Artifact | What happened |
|---|---|---|
| 06-Mar-2026 | EM-072 (earliest mail in chain) | Vikram Sethi flags a North billing mismatch; Priya Nair confirms the report layer is not the cause and asks Farida Contractor to check the batch around 14th-15th Feb. |
| 11-Mar-2026 | EM-072 | Farida Contractor confirms via Control-M history: `LP_DAILY_SALES` failed 14-Feb-2026, was manually resubmitted the same night as `SESS_884012`, and this was the only manual resubmit in February. She deliberately asks for the duplicate to be counted "from outside my team... so nobody can say we marked our own homework." |
| 24-Mar-2026 | T-03 | Raised on the same call as VAR-001/002/003, as an already-known item ("the february one is already in the log from before"). Confirmed as INR 2.9 Cr, sat in the number for three weeks "till meghna's reconciliation picked it up." A live debate on how to handle the already-duplicated February data (leave it with a manual Finance adjustment vs. delete the duplicate batch vs. truncate-and-reload February) is explicitly parked rather than resolved that day, pending the architecture review three weeks later — Shalini Iyer asks that the deferral be recorded in writing as a deferral, not an agreement. |
| 27-Mar-2026 | EM-072 (quoted) | Ishaan Bhatt confirms the duplicate total (INR 2.9 Cr) and the exact-duplicate signature described above. |
| 02-Apr-2026 | XL-01 log / EM-072 (quoted, Ananya Krishnan's close-out mail) | Reconciliation item closed: February restated internally by Finance so the month reconciles. A batch-id guard is agreed as the structural fix, explicitly **not** as a one-off patch but riding with the `R2026.07` release. |
| 08-Jul-2026 | EM-072 (Farida Contractor, 21-Aug-2026 summary, referring back to this date) | The batch-id guard actually **deploys** with `R2026.07`. This is a real, worth-noting gap from the 02-Apr closure date: the tracker's terse log entry ("`02/04/2026 | VAR-008 closed. batch id guard added, tested ok`") reads as though the guard was already live at closure, but the guard was only *agreed* on 02-Apr and did not go into production until over three months later. What closed on 02-Apr was the specific February reconciliation (Finance's restatement), not the structural fix that prevents a recurrence. |
| 21-Aug-2026 | EM-072 | Farida Contractor forwards the full chain to Neha Gokhale for the evidence folder, restating the summary above and explicitly separating "closed" (02-Apr) from "guard deployed" (08-Jul) in the same mail. |
| 22-Sep-2026 | T-08 | Confirmed closed to the steering committee, grouped with VAR-001, VAR-002, and VAR-006 in the INR 8.40 Cr closed total. |

No root-cause false trail — the mechanism was correctly and quickly identified (11-Mar-2026) and never
revised. The only genuine tension in the record is the closure-date vs. guard-deployment-date gap
described above.

## Status

**Closed** (02-Apr-2026 for the reconciliation; the structural guard did not deploy until 08-Jul-2026
with `R2026.07`). Tested against two subsequent month-ends with no repeat, confirmed by Farida
Contractor in the June sync (XL-01 comment).

## Owner

**Farida Contractor** — consistent across T-03, EM-072, and XL-01. No ownership conflict.

## Remediation

A batch-id guard added to the load plan so a deliberate resubmit of an already-loaded batch is
rejected rather than appended again. Agreed 02-Apr-2026, deployed with release `R2026.07` on
08-Jul-2026 (see the closure-date nuance above). The interim manual control, in place between the
incident and the guard's actual deployment, was procedural rather than technical: nobody resubmits
`LP_DAILY_SALES` without telling Farida Contractor first, and if a resubmit is unavoidable, the
prior batch's rows are deleted by `BATCH_ID` before the plan goes back in (`DOC-02`, referenced for
context on the interim control; not a primary source for this file's factual claims).

## Comparison against the canon register

`variance_register_canon.csv` states the same mechanism (manual resubmit, `SESS_884012`, control
append with no merge), the same impact (INR 2,94,10,000), the same owner, and the same opened/closed
dates (06-Mar-2026 / 02-Apr-2026). Agreement on every fact stated in the canon register. What the
canon register's single "Batch-id guard added in `R2026.07`" line does not surface, and my reading of
`EM-072` does, is that the guard's actual production deployment (08-Jul-2026) trails the item's
recorded close date (02-Apr-2026) by over three months — the closure recorded on the tracker reflects
the financial reconciliation being resolved, not the structural fix being live. This is worth
flagging precisely because the tracker's own log wording ("batch id guard added, tested ok" on
02-Apr) could be read as claiming the guard was already in production at that point, which the later
correspondence contradicts.

## Related concepts

- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) — the fact table that received the duplicated night's data
- [/concepts/tables/bcpl-edw-etl-batch-control.md](/concepts/tables/bcpl-edw-etl-batch-control.md) — batch tracking table; the guard targets `BATCH_ID` on this table's population
- [/concepts/variances/var-003-scheme-discount-double-count.md](/concepts/variances/var-003-scheme-discount-double-count.md) — shares the same underlying load weakness (control-append, no merge, no natural-key constraint) but a different trigger
- [ETL_ERROR_LOG](/concepts/tables/bcpl-edw-etl-error-log.md)

## Related variances

- [VAR-001 — FY26 Q1 revenue overstated](/concepts/variances/var-001-q1-revenue-overstated.md)

## Referenced by

- [Progress](/context/progress.md)

## Related decisions

- [Open question — whether to re-run February's load (VAR-008)](/decisions/20260324-var008-february-reload-deferred.md)
- [VAR-008 resolved: Finance restates February internally; batch-id guard rides with R2026.07](/decisions/20260402-var008-february-restatement-and-batch-guard.md)
- [ADR-004 — VAR-003 remediation: rebuild MAP_FACT_INVOICE_LINE as a key-based merge](/decisions/20260506-var003-remediation-key-based-merge.md)
