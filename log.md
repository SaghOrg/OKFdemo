---
type: log
title: Change log
description: Append-only record of every fact in this knowledge base that had one
  value earlier in the engagement and a different, current value later — both values,
  both source artifacts, and the date it changed. The authoritative answer to "which
  number is current."
generated:
  by: process:claude-sonnet/context
  at: "2026-08-23T11:45:00Z"
sources:
- resource: /_sources/decks/DK-01_kickoff_v3_FINAL.pptx
  id: DK-01
  title: 'Kickoff: Data, Analytics & Reporting Transformation'
  author: Ananya Krishnan
  last_modified: '2026-02-11'
- resource: /_sources/meetings/2026-02-11_kickoff_scope.txt
  id: T-01
  title: Kickoff and scope
  author: Ananya Krishnan
  last_modified: '2026-02-11'
- resource: /_sources/meetings/2026-03-24_first_variance_findings.txt
  id: T-03
  title: First variance findings
  author: Ananya Krishnan
  last_modified: '2026-03-24'
- resource: /_sources/email/EM-023_dashboard_scope_cut.eml
  id: EM-023
  title: 'RE: RE: FW: Drishti - discovery close out pack and Friday actions'
  author: Shalini Iyer
  last_modified: '2026-03-30'
- resource: /_sources/meetings/2026-04-14_architecture_review.txt
  id: T-04
  title: Architecture review
  author: Karthik Subramanian
  last_modified: '2026-04-14'
- resource: /_sources/email/EM-041_farida_scd2_concern.eml
  id: EM-041
  title: 'RE: DIM_CUSTOMER dimension design - your comments'
  author: Farida Contractor
  last_modified: '2026-04-16'
- resource: /_sources/trackers/XL-03_scd2_load_impact.xlsx
  id: XL-03
  title: SCD2 load impact - assumptions, scenarios and conclusion
  author: Karthik Subramanian
  last_modified: '2026-04-22'
- resource: /_sources/email/EM-047_karthik_scd2_counter.eml
  id: EM-047
  title: 'RE: RE: FW: RE: SCD2 load window, measured on DEV'
  author: Karthik Subramanian
  last_modified: '2026-04-23'
- resource: /_sources/docs/DOC-03_stored_procedure_walkthrough.docx
  id: DOC-03
  title: PKG_MONTH_END and the batch close proc - walkthrough of the five routines
  author: Aniruddh Deshpande
  last_modified: '2026-04-28'
- resource: /_sources/meetings/2026-05-06_design_signoff.txt
  id: T-05
  title: Design sign-off
  author: Karthik Subramanian
  last_modified: '2026-05-06'
- resource: /_sources/docs/DOC-04_dimension_strategy.docx
  id: DOC-04
  title: BCPL_EDW Dimension Strategy (Appendix A, ADR-001 to ADR-005)
  author: Karthik Subramanian
  last_modified: '2026-05-11'
- resource: /_sources/decks/DK-03_variance_rootcause_v2.pptx
  id: DK-03
  title: Variance root cause - working readout, v2
  author: Karthik Subramanian
  last_modified: '2026-05-05'
- resource: /_sources/email/EM-055_var004_handover_ishaan.eml
  id: EM-055
  title: VAR-004 duplicate rows on DIM_CUSTOMER - handover to Ishaan
  author: Farida Contractor
  last_modified: '2026-07-09'
- resource: /_sources/email/EM-063_shalini_validated_credit_note_impact.eml
  id: EM-063
  title: 'RE: FW: India FY2026 - channel partner credit notes'
  author: Shalini Iyer
  last_modified: '2026-07-21'
- resource: /_sources/email/EM-068_golive_slip_30oct.eml
  id: EM-068
  title: 'RE: RE: FW: Drishti - revised go live date (was: wk28 status pack)'
  author: Ananya Krishnan
  last_modified: '2026-08-19'
- resource: /_sources/email/EM-072_feb_duplicate_load_chain.eml
  id: EM-072
  title: February reconciliation - LP_DAILY_SALES re-run 14-Feb (five-level forwarded
    chain)
  author: Farida Contractor
  last_modified: '2026-08-21'
- resource: /_sources/email/EM-089_uat_scheduling.eml
  id: EM-089
  title: 'RE: RE: UAT - dates, scripts, and who signs what'
  author: Sneha Pillai
  last_modified: '2026-09-28'
- resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
  id: XL-01
  title: Variance tracker v7
  author: Sneha Pillai
  last_modified: '2026-09-18'
- resource: /_sources/decks/DK-06_steerco_sep2026.pptx
  id: DK-06
  title: Steering Committee, 22 September 2026
  author: Ananya Krishnan
  last_modified: '2026-09-22'
- resource: /_sources/meetings/2026-09-22_steering_committee.txt
  id: T-08
  title: Steering committee
  author: Rajeev Menon
  last_modified: '2026-09-22'
---


# Change log

Every row below is a fact that had one value earlier in the engagement and a different, current value
later. Per the write protocol in `AGENTS.md`, a superseded fact is recorded here rather than silently
overwritten — both values, both sources, and the date it changed stay visible. **If you take one thing
from this file: check it before quoting any date, count, or figure from an earlier artifact.
Something in this KB that looks stale almost certainly is, and this file is where the current value
lives.**

Rows are grouped: the two multi-hop facts that the engagement changed its mind about twice (go-live
date, dashboard count) are first, because they are the ones most likely to trip up a reader working
from a single document. Each hop is its own row.

| Fact | Earlier value | Current value | Changed on | Earlier source | Current source |
|---|---|---|---|---|---|
| **Go-live date** (hop 1) | Tue **15-Sep-2026** | Fri **30-Oct-2026** | 2026-08-19 | `DK-01` (kickoff deck, 11-Feb-2026, "the only date that matters to Rajeev on this whole deck"); `T-01` (11-Feb-2026, same date agreed in the room) | `EM-068` (19-Aug-2026), Ananya Krishnan: "The plan date for go live is now Friday 30 October 2026. 15-Sep is gone, please stop quoting it, including in anything that goes to Klarissen." Driver: ORION `R12.2.9` patch weekend locks the source system 12-20 Sep, and `VAR-004`/`VAR-007` remediation would not be finished in time for a clean cutover. See `/decisions/20260819-golive-date-slip-to-30oct.md`. |
| **Go-live date** (hop 2) | Fri **30-Oct-2026** | Thu **12-Nov-2026** (final) | 2026-09-22 | `EM-068` (19-Aug-2026, as above) | `T-08` / `DK-06` (22-Sep-2026 steering committee). Driver: Klarissen Group close blackout, 26-Oct to 06-Nov CET, forbids a cutover inside that window. Cutover weekend 07-08-Nov, historical reload 09-11-Nov, hypercare to 11-Dec-2026. See `/decisions/20260922-golive-date-final-12nov.md`. |
| **Go-live dashboard count** (hop 1) | **12** dashboards, D01-D12 | **7** dashboards | 2026-03-30 | `DK-01` (kickoff deck, slide 9, 11-Feb-2026, "12 dashboards in scope for go-live... per the SOW") | `EM-023` (30-Mar-2026), Shalini Iyer: "We are not doing twelve. It is seven." D02, D04, D08, D10, D11 move to Phase 2. Driven by a Group capex freeze on the BI licence uplift and UAT tester availability, not by a change in business need. See `/decisions/20260330-dashboard-scope-cut-12-to-7.md`. |
| **Go-live dashboard count** (hop 2) | **7** dashboards | **9** dashboards (D04, D11 reinstated) | 2026-09-22 | `EM-023` (30-Mar-2026, as above); `DK-05` (07-Aug-2026) and `T-07` (05-Aug-2026) show the intermediate state, "seven committed plus two candidates," and do **not** themselves arrive at nine | `T-08` / `DK-06` (22-Sep-2026). D04 (Scheme Effectiveness) and D11 (Credit and Receivables Exposure) return, funded from a Phase 2 budget line Klarissen Group released in August. See `/decisions/20260922-dashboard-scope-reinstated-7-to-9.md`. |
| **VAR-003 root cause — belief** (hop 1) | **Suspected: latency on the `ORION_PRD` database link**, causing rows to be re-extracted into overlapping nightly windows. Logged in the tracker explicitly as "suspected," Karthik Subramanian "moderately confident, not confident." | **Database-link hypothesis eliminated. Root cause not identified.** AWR evidence: 4.1 min total dblink wait across the whole load (1.2% of elapsed), no correlation between link speed and duplicate incidence, duplicates exact rather than torn. | 2026-04-14 | `T-03` (24-Mar-2026, first variance findings — the hypothesis raised and logged) | `T-04` (14-Apr-2026, architecture review — Karthik Subramanian retracts his own hypothesis on the record: "it was the most visible broken thing in the chain so it got the blame, which is exactly how you get the wrong answer.") |
| **VAR-003 root cause — belief** (hop 2) | **Root cause not identified** (open, unattributed) | **Source-side**: `FIN_PROD.PKG_MONTH_END.P_RECALC_SCHEME_DISCOUNT`, an additive `UPDATE` with no idempotency guard, run nightly via `DBMS_SCHEDULER` inside ORION (outside Control-M), colliding with the incremental extract window | 2026-04-28 (documented); formally accepted 2026-05-06 | `T-04` (14-Apr-2026, as above) | `DOC-03` (28-Apr-2026, Aniruddh Deshpande's stored-procedure walkthrough — the only artifact in the read corpus that states the mechanism in full); formally accepted as settled at `T-05` (06-May-2026, "it is settled" — Aniruddh Deshpande). Reconfirmed in writing, at Karthik Subramanian's explicit request, by `EM-092` (08-Oct-2026). See `/concepts/variances/var-003-scheme-discount-double-count.md` for the full diagnostic history, and `/decisions/20260922-var003-close-date-not-committed.md` for why the *close date*, unlike the root cause, is still not settled. |
| **`DIM_PRODUCT` SCD strategy** | **SCD1** (overwrite, no history) — "product is much simpler... I am proposing SCD1 for DIM_PRODUCT, overwrite" (Karthik Subramanian). Agreed in the room with no objection. | **SCD2** (keeps history) — tracks `PACK_SIZE`, `MRP_AMT`, `BRAND_CODE`, `CATEGORY_CD`, `UOM`. Reverses the April position. | 2026-05-06 | `T-04` (14-Apr-2026, architecture review). See `/decisions/20260414-dim-product-scd1-proposed.md` (`status: superseded`). | `T-05` (06-May-2026, design sign-off) and `DOC-04` (11-May-2026, `ADR-003`). Driver: the Product Mix and Contribution dashboard (D09) needs the `MRP`/pack size **in force at the time of a historic invoice**, not today's value. See `/decisions/20260506-dim-product-scd2.md`. |
| UAT window | **10-Aug-2026 to 28-Aug-2026** (as planned) | **12-Oct-2026 to 06-Nov-2026** (as finally scheduled) | 2026-09-28 (confirmed in writing; the window had already moved implicitly with the 30-Oct go-live plan from 19-Aug, but `EM-068` explicitly declined to commit a UAT window that day: "I am not putting a UAT window in writing today... I would rather give you a date I can hold than a date that looks tidy in a plan.") | `DK-01` (kickoff deck, slide 4, 11-Feb-2026) | `EM-089` (28-Sep-2026), Sneha Pillai: "I did not want to put dates in writing until the enviroment position was confirmed, and it was confirmed on Friday evening, so here we are." |
| Owner of VAR-004 (Duplicate facts on distributor reassignment) | Farida Contractor | Ishaan Bhatt | 2026-07-09 | `XL-01` (18-Sep-2026 save, Register tab, Owner column — still stale, shows "F. Contractor," never updated); `DK-03` (05-May-2026, shown as unassigned, "DW team (TBC)," predates the handover) | `EM-055` (09-Jul-2026, the handover mail — "Reason is bandwidth on my side and nothing else"); confirmed without qualification at `T-08` (22-Sep-2026) |
| FY26 impact of VAR-005 (Credit notes absent from warehouse) | INR 2.40 Cr (working estimate, Apr 2025–Dec 2025 only, excluded `OFF_INV_ADJ` type) | INR 3.11 Cr / INR 3,11,20,000 (validated, full FY26, 1,206 documents, `RATE_DIFF` + `OFF_INV_ADJ`) | 2026-07-21 | `DK-03` (05-May-2026) | `EM-063` (21-Jul-2026, Shalini Iyer, validated against the FY26 trial balance — and the only artifact that explains *why* the earlier figure undercounted); `XL-01` carries the validated figure in the `VAR-005_detail` sheet, but its own Summary sheet still rounds to 3.10 Cr as of 18-Sep-2026 — an internal inconsistency confirmed still unresolved at the 22-Sep-2026 steering committee, `T-08` |
| VAR-002 impact figure as printed in `DK-03` | INR 9 L (typo, v1, circulated 30-Apr-2026) | INR 90 L (corrected, v2, circulated 05-May-2026) | 2026-05-05 (approx., "same afternoon" per the deck's own account) | `DK-03` slide 1 speaker notes | `DK-03` slide 1 speaker notes, same artifact — the deck records its own typo and correction directly; no other artifact in the read corpus repeats the wrong figure |
| VAR-008 batch-id guard: closed vs. deployed | Recorded as closed with "batch id guard added, tested ok" (reads as though already live) | Guard actually deployed to production later, with release `R2026.07` | Reconciliation closed 2026-04-02; guard deployed 2026-07-08 | `XL-01` change log, 02-Apr-2026 entry | `EM-072` (21-Aug-2026), Farida Contractor's own account distinguishing the 02-Apr reconciliation closure from the 08-Jul-2026 `R2026.07` guard deployment |
| `MAP_DIM_CUSTOMER` SCD2 load-window cost | "12 to 15 minutes" (Farida Contractor's stated estimate — explicitly flagged as unmeasured: "I have not measured it and I am not pretending I have") | **+7 min 28 sec** measured (4 min 12 sec baseline → 11 min 40 sec with SCD2), on DEV, 21-Apr-2026 | 2026-04-23 | `EM-041` (16-Apr-2026, Farida Contractor's objection to `DIM_CUSTOMER` SCD2 on load-window grounds) | `EM-047` and `XL-03` (23-Apr-2026, Karthik Subramanian's measured counter — worst month-end night lands at 04:20 IST, 70 minutes inside the 05:30 SLA). Objection resolved by measurement rather than argument; feeds `ADR-002`, see `/decisions/20260506-dim-customer-scd2.md`. |

## Notes

- **The two multi-hop facts (go-live date, dashboard count) are the ones most likely to be quoted
  wrong**, because `DK-01` — the kickoff deck — is the most-circulated, most-memorable artifact in the
  corpus and it is wrong about both by the end of the engagement. Anyone answering "when do we go
  live" or "how many dashboards" from `DK-01` alone gets the *first* value, not the current one, and
  should be redirected here.
- **VAR-003's root cause is the one place a "belief that changed" is not the same thing as "the
  variance closed."** The root cause moved twice (DBLINK hypothesis → ruled out → source-side
  procedure) and has been settled since 06-May-2026. The variance itself is still **open** — no close
  date is committed (see `/decisions/20260922-var003-close-date-not-committed.md`) — and `EM-092`
  (08-Oct-2026) shows the settled root cause being restated in writing, not re-investigated. Do not
  read that restatement as new information changing the mechanism; it changes nothing except putting
  an already-settled answer on the record.
- The VAR-004 ownership change is the case the original transform-stage instructions specifically
  called out: "where the tracker's owner disagrees with a later email, the email wins."
- None of these entries change any variance's final, currently-accepted root cause **except** the
  VAR-003 row above, which traces the belief itself changing (twice) before it settled. Every other row
  is an ownership record, a quantified-impact figure, a scope figure, or a schedule date that was
  corrected, reversed, or clarified later in the engagement.
- This file is deliberately a flat table, not a narrative. For the full diagnostic history behind any
  single row — especially VAR-003's false trail — follow the linked concept and decision files.
## Referenced by

- [Knowledge Base Index](/index.md)

