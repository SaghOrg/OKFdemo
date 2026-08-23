---
type: log
title: Change log
description: Append-only record of facts that changed during the engagement and were surfaced while authoring the /concepts/variances/ records — old value, new value, when it changed, and which sources establish each.
generated:
  by: process:claude-sonnet/variances
  at: 2026-08-23T10:45:28Z
sources:
  - resource: /_sources/email/EM-055_var004_handover_ishaan.eml
    id: EM-055
    title: "VAR-004 duplicate rows on DIM_CUSTOMER - handover to Ishaan"
    author: Farida Contractor
    last_modified: "2026-07-09"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
  - resource: /_sources/decks/DK-03_variance_rootcause_v2.pptx
    id: DK-03
    title: Variance root cause - working readout, v2
    author: Karthik Subramanian
    last_modified: "2026-05-05"
  - resource: /_sources/email/EM-063_shalini_validated_credit_note_impact.eml
    id: EM-063
    title: "RE: FW: India FY2026 - channel partner credit notes"
    author: Shalini Iyer
    last_modified: "2026-07-21"
  - resource: /_sources/email/EM-072_feb_duplicate_load_chain.eml
    id: EM-072
    title: "February reconciliation - LP_DAILY_SALES re-run 14-Feb (five-level forwarded chain)"
    author: Farida Contractor
    last_modified: "2026-08-21"
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
---

# Change log

Entries below were identified while authoring `/concepts/variances/`. Each row records a fact that
had one value earlier in the engagement and a different, current value later — per the write
protocol in `AGENTS.md`, the record is superseded rather than silently overwritten, and both values
stay visible here.

| Fact | Old value | New value | Changed on | Sources |
|---|---|---|---|---|
| Owner of VAR-004 (Duplicate facts on distributor reassignment) | Farida Contractor | Ishaan Bhatt | 2026-07-09 | `EM-055` (the change); `XL-01_variance_tracker_v7.xlsx` (18-Sep-2026 save, Register tab, Owner column — still stale, shows "F. Contractor"); `DK-03` (05-May-2026, shown as unassigned/"DW team (TBC)", predates the handover); `/concepts/variances/var-004-scd2-territory-reassignment.md` (`owner` field set to the current value per this log) |
| FY26 impact of VAR-005 (Credit notes absent from warehouse) | INR 2.40 Cr (working estimate, Apr 2025–Dec 2025 only, excluded `OFF_INV_ADJ` type) | INR 3.11 Cr / INR 3,11,20,000 (validated, full FY26, 1,206 documents, `RATE_DIFF` + `OFF_INV_ADJ`) | 2026-07-21 | `DK-03` (the old estimate, presented 05-May-2026); `EM-063` (the validation and, uniquely, the explanation of why the earlier figure undercounted); `XL-01` (carries the validated figure in the `VAR-005_detail` sheet; the Summary sheet still rounds it to 3.10 Cr as of 18-Sep-2026, an internal inconsistency confirmed still unresolved as of the 22-Sep-2026 steering committee, `T-08`) |
| VAR-002 impact figure as printed in `DK-03` | INR 9 L (typo, v1, circulated 30-Apr-2026) | INR 90 L (corrected, v2, circulated 05-May-2026) | 2026-05-05 (approx., "same afternoon" per the deck's own account) | `DK-03` slide 1 speaker notes, which record the typo and its correction directly; no other artifact in the read set repeats the wrong figure |
| VAR-008 batch-id guard: closed vs. deployed | Recorded as closed with "batch id guard added, tested ok" | Guard actually deployed to production later, with release `R2026.07` | Reconciliation closed 2026-04-02; guard deployed 2026-07-08 | `XL-01` change log (02/04/2026 entry, reads as though the guard was already live); `EM-072` (21-Aug-2026, Farida Contractor's own account distinguishing the 02-Apr reconciliation closure from the 08-Jul-2026 `R2026.07` guard deployment) |

## Notes

- The VAR-004 ownership change is the case the transform stage instructions specifically called out:
  "where the tracker's owner disagrees with a later email, the email wins." The other three rows were
  surfaced independently while reading the underlying sources for each variance and are included here
  because they are the same category of fact — a value that was true, then stopped being true, with
  both states still visible in the corpus.
- None of these entries change any variance's root cause. They are all either an ownership record or
  a quantified-impact / status figure that was corrected or clarified later in the engagement.
