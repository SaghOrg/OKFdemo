---
type: meeting-note
title: First variance findings
description: Readout of initial variance reconciliation work; three new discrepancies
  identified; February reload decision deferred to next architecture review.
tags:
- variance
- reconciliation
- fact-table
- odI-mapping
sources:
- resource: /_sources/meetings/2026-03-24_first_variance_findings.vtt
  id: T-03
  title: First variance findings
  last_modified: '2026-03-24'
generated:
  by: process:claude-haiku/meetings
  at: 2026-08-23 11:15:03+00:00
---


## Summary

Ishaan Bhatt presented the first complete reconciliation of FY26 Q1 warehouse figures against Finance trial balance. Three previously undetected variances emerged, plus confirmation of the February 14 duplicate already flagged. The FY26 Q1 gap of 4.20 Cr was traced to a missing DELETE_FLAG filter in the invoice line fact mapping, loading cancelled lines as revenue. A second issue was found in the date key derivation: invoices raised after 18:30 IST on month-end were being recorded in the next month due to source system UTC timestamps. A third, suspected cause—database link latency causing row re-extraction—was proposed as the root of the scheme discount gap but requires testing. The February duplicate sitting in the warehouse for three weeks (2.9 Cr) was confirmed as a consequence of manual re-run with no merge logic. Shalini Iyer raised the operational impact of carrying manual adjustments in spreadsheets and required clarity on the February re-run path; this decision was deferred pending the filter fix deployment.

## Decisions referenced

- [Decision on February reload deferral](/decisions/20260324-var008-february-reload-deferred.md) — whether to truncate and reload February or carry the duplicate until the mapping is fixed; decision taken to park the choice until the filter fix is committed.

## Action items

**AI-12 | Complete trial balance tie-out for April and May FY26 Q1 | Ishaan Bhatt | 27-Mar**  
Ishaan had completed June only; tied line-by-line for all three months required before the gap can be signed off. Shalini to be asked for the quarter; Finance has already signed the pack with the 4.20 Cr gap open.

**AI-13 | Write up the DELETE_FLAG and DATE_KEY fix as one mapping change | Karthik Subramanian | 31-Mar**  
Both changes travel in the same interface (`MAP_FACT_INVOICE_LINE`); combined note needed before regression testing. Karthik to explain the NVL predicate required to preserve old rows where DELETE_FLAG is null (see summary).

**AI-14 | Confirm regression test plan for the combined mapping change | Farida Contractor | 31-Mar (after AI-13)**  
Farida requested that the mapping be properly regenerated in the scenario, not hot-fixed, given a prior incident where regeneration was skipped and the old version continued to run. She confirmed one deployment and one regression is preferable to two separate changes.

**AI-15 | Pull database performance report for link latency hypothesis test | Karthik Subramanian | by 31-Mar**  
One "bad" night (heavy invoice volume, run long) and one "clean" night to be analysed for SQL\*Net wait time on the `ORION_PRD` database link. If link latency is large on bad nights and small on clean nights, and duplicate rows follow the same pattern, the hypothesis holds. If duplicates appear on a night where the link was fine, the theory dies. Karthik to request report from Aniruddh Deshpande (Oracle DBA).

**AI-16 | Send SKU case quantity discrepancy details | Vikram Sethi | 24-Mar (today)**  
Vikram raised that "Sovereign 1kg" and "Ta Rang 1kg" case quantities in the report differ from his file by a non-trivial amount. Screenshot and SKU codes to be sent to Ananya; Ishaan to investigate.

**AI-17 | Determine owner for secondary sales coverage issue | Ananya Krishnan | this week**  
Vikram raised that the DMS feed covers only 74% of distributors and lags by ~5 days, making weekly secondary off-take reporting to Rajeev Menon unreliable. Coverage is a separate problem from the primary sales variances; owner and next steps TBD.

**AI-18 | Log three new variance items to tracker | Sneha Pillai | 24-Mar**  
Three new items: (1) FY26 Q1 overstated 4.20 Cr; (2) Month-end date shift ~90 lakh full year; (3) Scheme discount gap 1.7 Cr, suspected cause—database link latency (marked SUSPECTED in tracker). February duplicate (`SESS_884012`, 2.9 Cr) already logged; link these three as related findings. Secondary coverage issue noted but not yet an action item.

## Open questions

**February re-run decision, parked until 14-Apr.** Three options laid out but not decided:
1. Carry the manual adjustment in Finance's spreadsheet until the mapping is rebuilt (requires no production risk, carries forever otherwise).
2. Delete the duplicate batch ID only (leaves some bad rows in place, lighter risk).
3. Truncate and reload the entire February range (cleanest, highest operational risk—re-read across the slow link, requires backfill, DBA oversight).

Shalini strongly preferred option 3; Farida strongly preferred option 1, citing the risk of truncate-reload running long and the need to delete 30 million rows on a production table. Karthik added that any reload today would re-import the cancelled lines still present in the mapping (DELETE_FLAG filter not yet in place), so option 3 is premature. **Decision deferred to 14-Apr architecture review** (T-04) with the condition that it be recorded in writing who deferred it.

**Secondary sales DMS feed coverage.** 74% of distributors receiving data; Nashik and Baddi [Note: ASR transcribed as "Buddy" for the plant name] despatches consistently two days late. Vikram asked how he is supposed to give weekly secondary off-take to Rajeev Menon under these constraints. Shalini clarified that her board pack uses *primary* invoiced sales, not secondary off-take, so they are separate conversations. This was parked as raised, not yet an action.

**SKU case quantity discrepancy.** Vikram's file shows different case quantities for Sovereign and Ta Rang products than the report displays. Cause unknown; investigation requested.

## Disagreements and holds

Farida and Shalini disagreed on February re-run safety and timing. Farida held that truncate-reload is too risky on a heavy data volume crossing a slow link; Shalini held that the 2.9 Cr duplicate sitting in the warehouse for three weeks is operationally untenable. Karthik pointed out that any reload before the filter fix is in place would re-import the very problem being solved. Ananya parked the decision to allow sequencing to be decided properly.

Karthik was careful to state he was "moderately confident, not confident" in the database link theory; he requested this qualifier survive into the notes and tracker to prevent later assertions that the team had concluded the cause was the link.

Vikram repeatedly raised that his numbers (secondary off-take, SKU quantities) do not match reports or Finance figures and asked for clarity on which the distributors should believe. Karthik and Shalini clarified that primary and secondary sales are two separate events, two different grains (BCPL to distributor vs. distributor to retailer), and that the distributors do not see Finance's trial balance or the warehouse numbers—they see claims from a different system entirely.

## Notes

- Recording was started late; the first few minutes of the meeting were not captured.
- Vikram joined from the airport and experienced intermittent connectivity (dropped once, rejoin at 35:43).
- ASR transcription note: The platform transcribed "Aniruddh Deshpande" as "Annie" in one instance; "Baddi" (a BCPL plant) appears to have been transcribed as "Buddy" in the raw dump; database link was transcribed as "be link" and required clarification.
- Shalini Iyer left the call at 42:00 (had another meeting at 16:45).
- Karthik Subramanian specified that the filter predicate must use `NVL(DELETE_FLAG, 'N') = 'N'` (treating blanks as live rows), not simply `DELETE_FLAG = 'N'`, otherwise historical data where the column is null will silently disappear without error.
- Farida Contractor emphasized: "Green does not mean correct", referring to Control-M batch completion status not guaranteeing data correctness.
- Shalini Iyer required that all figures going into Thursday's presentation deck match the tracker exactly, following an earlier incident where two versions floated.

### Variance summary for tracker

**VAR-001 (FY26 Q1 revenue overstated):** 4.20 Cr  
Cancelled invoice lines (DELETE_FLAG = 'Y') are loading into the fact as revenue because `MAP_FACT_INVOICE_LINE` has no filter. Since 2021. Fix: apply `NVL(DELETE_FLAG, 'N') = 'N'` predicate. Ties to Finance trial balance line-by-line once filter is applied (June verified, April and May due 27-Mar).

**VAR-002 (Month-end date misplacement):** ~90 lakh full year (approx 0.90 Cr)  
Invoices raised after 18:30 IST on the last day of a month are recorded in the next month because `DATE_KEY` is derived from `INVOICE_HEADER.CREATED_TS` (application server writes in UTC, which is IST -5:30). Fix: change `DATE_KEY` to use `INVOICE_DT` (proper date in IST). Deploys together with VAR-001 fix.

**VAR-003 (Scheme discount overstated):** 1.7 Cr FY26 (suspected cause, hypothesis not yet proven)  
Warehouse scheme discount figure is consistently 1.7 Cr *higher* than Finance accrual (trade promotion accrual), every month in same direction (never lower). Sample inspection shows duplicate fact rows—exact duplicates with same line ID, amount, different load date. Rows concentrated on heavy nights. **Suspected cause:** Database link (`ORION_PRD`) latency on heavy nights causes the extract window to overlap such that rows from a slow-running extract fall within the next night's window as well, and the `IKM Oracle Control Append` mapping reinserts them (no merge logic). Confidence: moderate. Test plan: pull DB performance report for link wait time on one bad night and one clean night; if link is a large share of elapsed on bad nights and small on clean nights, and duplicates follow pattern, hypothesis holds.

**VAR-008 (February duplicate):** 2.9 Cr (known mechanism, decision deferred)  
On Saturday 14-Feb-2026, the load failed and was manually re-run (session `SESS_884012`). The IKM Control Append re-inserted the entire night's data. Sat in the warehouse for three weeks before Meghna's reconciliation caught it. Same root mechanism as VAR-003 but different trigger (manual re-run vs. link latency). Whether to truncate-reload February or carry the adjustment is deferred to 14-Apr.
## Referenced by

- [Knowledge Base Index](/index.md)

