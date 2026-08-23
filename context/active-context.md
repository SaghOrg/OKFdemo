---
type: context
title: Active Context
description: What is happening right now on Project Drishti, as of the latest dated artifact in the read corpus — current focus, imminent dates, and what is blocked.
tags:
  - active-context
  - uat
  - go-live
  - var-003
  - var-005
  - dashboard-scope
  - current-status
stale_after: "2026-11-13"
generated:
  by: process:claude-sonnet/context
  at: 2026-08-23T11:30:00Z
sources:
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
  - resource: /_sources/email/EM-092_ani_scheme_recalc_late.eml
    id: EM-092
    title: "RE: RE: FW: VAR-003 - what is writing to SCHEME_DISC_AMT"
    author: Aniruddh Deshpande
    last_modified: "2026-10-08"
  - resource: /_sources/chat/CH-01_teams_data_workstream.txt
    id: CH-01
    title: Teams channel export — Data workstream
    author: Sneha Pillai
    last_modified: "2026-09-29"
  - resource: /_sources/chat/CH-02_whatsapp_uat_group.txt
    id: CH-02
    title: WhatsApp UAT group export
    author: Priya Nair
    last_modified: "2026-10-30"
---

# Active context

**As of the latest dated content in the read corpus: 30-Oct-2026** (the tail of `CH-02`, the WhatsApp
UAT group — see the note on that artifact below). The last formal steering committee is `T-08`,
22-Sep-2026; several emails and both chat exports run later than that and are the most current record
of where things actually stand.

## Current focus

**UAT, and it is going well.** UAT ran 12-Oct to 06-Nov-2026, 14 scripts (`UAT-01`-`UAT-14`), 9
testers. As of 30-Oct-2026 (`CH-02`): 12 of 14 scripts fully closed, the remaining 2 closed **with
comment** (Vikram Sethi's stockist-figure discrepancies on `UAT-08`, a known issue, not a new defect),
nothing open that blocks sign-off. Ananya Krishnan, 30-Oct: "this was a much cleaner three weeks than
I expected." Sign-off is still due 06-Nov-2026 and Sneha Pillai is tidying the defect log over the
final weekend.

**Go-live is 12-Nov-2026** (Thursday) — see `/log.md` for the two changes that got it there.
Cutover weekend 07-08-Nov-2026, historical reload window 09-11-Nov-2026, hypercare to 11-Dec-2026.
Nothing in the read corpus after `T-08` (22-Sep) suggests this date is at risk; the UAT chatter through
30-Oct is entirely operational (cosmetic defects, load-status pings, tie-break bugs), not date risk.

**Dashboard scope is 9** — see `/log.md`. Reports are named `DRISHTI - <name>` in workspace
`BCPL-DRISHTI-PRD` on dataset `DRISHTI_SALES`. UAT-02 through UAT-14 exercise all nine.

**VAR-003 (scheme discount double-count, INR 1.70 Cr, open)** — root cause is settled (source-side,
`FIN_PROD.PKG_MONTH_END`, see `/concepts/variances/var-003-scheme-discount-double-count.md`) but the
**close date is not committed**. At `T-08` (22-Sep) Karthik Subramanian explicitly declined to give the
steering committee a date, stating he and Aniruddh Deshpande had not yet agreed a position — see
`/decisions/20260922-var003-close-date-not-committed.md`. Two weeks later, `EM-092` (08-Oct-2026) shows
Karthik asking, in writing, for one settled sentence on where the problem sits, because he had given
slightly different answers to the same question twice in one week. Ani's reply (08-Oct) reconfirms the
root cause — source-side, not ETL, not Farida's load — and adds a new detail: `FIN_PROD` holds a direct
`UPDATE` grant on `OMS_PROD.INVOICE_LINE`, given in 2014, never reviewed since. This does not change the
root cause or move the close date; it is BCPL putting the existing answer in writing, at Karthik's
request, so it stops being re-litigated. The written target release, `R2026.09` (30-Sep-2026), had
already passed by the time of `EM-092` with no artifact in the read corpus confirming it was hit.
Ishaan Bhatt measured the key-based-merge remediation on the UAT box on 24-Sep (`CH-01`): "more than the
append, obviously, but it is not frightening" — write-up pending, no completion recorded.

**VAR-005 (credit notes absent, INR 3.11 Cr, open since April)** — Marijke van der Berg set a hard
external deadline at `T-08`: resolved before Klarissen's year-end close, i.e. by 31-Dec-2026, not after.
Action items from that session (`AI-58` Shalini Iyer/Ananya Krishnan to revert to group finance with a
recommendation and a named owner, before the next steerco; `AI-59` Ananya to send the FY26 variance walk
by month, in EUR at the 92.40 budget rate, to Wei Lin Tan, due 02-Oct-2026) have no confirmation of
completion anywhere in the read corpus.

## Imminent dates

| Date | Event |
|---|---|
| 06-Nov-2026 | UAT sign-off due |
| 07–08-Nov-2026 | Cutover weekend |
| 09–11-Nov-2026 | Historical reload window |
| **12-Nov-2026** | **Business go-live** |
| 11-Dec-2026 | Hypercare ends |
| 31-Dec-2026 | Marijke van der Berg's deadline for VAR-005 resolution (Klarissen year-end) |
| ~Feb-2027 | OBIEE decommission target, 90 days after go-live |

## Blocked / unresolved as of the end of the read corpus

- **VAR-003 close date.** Karthik Subramanian and Aniruddh Deshpande have not agreed a position;
  no date has been recommitted since `R2026.09` (30-Sep-2026) passed unconfirmed.
- **VAR-005 owner.** No named owner as of `T-08`; `AI-58` was still open when the read corpus ends.
- **Stockist-level drill-down on every dashboard page** — see
  `/decisions/20260805-dashboard-stockist-drilldown-unresolved.md`. Vikram Sethi wants it; Ritwik Ghosh
  objects on secondary-sales data-quality grounds (74% coverage). No owner assigned as of `T-07`
  (05-Aug-2026), not revisited in any later artifact read.
- **Secondary Sales Coverage (D02)**, dropped from the nine, leaves Vikram Sethi's "how do I see
  off-take going forward" question open. Ananya Krishnan undertook to call him the next morning
  (`T-08`); no follow-up recorded in the read corpus.
- **Tracker rounding inconsistency** (VAR-005 shown as 3.10 Cr in the summary sheet, 3.11 Cr in the
  detail sheet) — `AI-61`, owned by Ananya Krishnan, due 25-Sep-2026. No confirmation of the fix found.
- Ananya Krishnan on plan float, `T-08`: "not much. I am not going to pretend otherwise." No later
  artifact revisits this directly, though the UAT chatter through 30-Oct shows no sign of slippage.

## A note on sourcing this file

`CH-02` (the WhatsApp UAT group export) is catalogued in `_sources/MANIFEST.csv` as covering
09-Oct-2026 to 16-Oct-2026, but the artifact's own content runs to 30-Oct-2026. This file cites `CH-02`
against its actual latest content (30-Oct-2026), per the instruction to prefer the most recent
statement of a fact — the manifest's date range appears to be stale relative to the file it describes.
This is flagged, not silently corrected; the manifest itself is under `/_sources/` and was not edited.
