---
type: meeting-note
title: Steering committee — 22 September 2026
description: Go-live date repriced to 12 November 2026 due to Klarissen group close
  blackout; variance position reviewed; reporting scope confirmed at nine dashboards.
tags:
- steering-committee
- go-live-date
- variance
- reporting-scope
- credit-notes
- uat
sources:
- resource: /_sources/meetings/2026-09-22_steering_committee.vtt
  id: T-08
  last_modified: '2026-09-22'
generated:
  by: process:claude-haiku/meetings
  at: 2026-08-23 11:14:54+00:00
---


## Summary

The steering committee convened to address the project plan and go-live readiness. The primary topic was the go-live date, which has been repriced to Thursday 12 November 2026 from the previously committed 30 October 2026. The driver is Klarissen's group close blackout window (26 October to 6 November CET), during which no operating company can cut over. The team proposed a cutover weekend of 7–8 November, historical data reload 9–11 November, and business go-live 12 November, with hypercare running through 11 December. The cost is unchanged; the move fits inside Northlane Analytics' capped-fee envelope.

The steering committee also reviewed the cumulative variance position (INR 13.85 Cr total, of which INR 8.40 Cr is closed and INR 5.45 Cr is open), with particular focus on two open variances—VAR-003 (scheme discount double count) and VAR-005 (credit notes)—where ownership and remediation timelines remain unresolved. Reporting scope was confirmed at nine dashboards live on the twelfth, comprising the seven committed dashboards plus D04 (Scheme Effectiveness) and D11 (Credit and Receivables Exposure), which Klarissen requested and funded from their Phase 2 budget.

UAT is scheduled for October 2026 with confirmed slots, nine named testers, and fourteen scripts, including coverage of all nine dashboards. UAT sign-off is due before the cutover weekend. Several open questions remain around resourcing, system availability, and data freeze mechanics.

## Decisions referenced

- [Go-live date moves from 30-Oct to 12-Nov-2026 (final)](/decisions/20260922-golive-date-final-12nov.md) — cutover weekend 7–8 November, historical reload 9–11 November, business go-live 12 November 2026, driven by the Klarissen group close blackout.
- [Go-live date moves from 15-Sep to 30-Oct-2026](/decisions/20260819-golive-date-slip-to-30oct.md) — the prior committed date, set six weeks earlier, that this meeting superseded a second time.
- [Go-live dashboard scope reinstated to 9 (D04, D11 return)](/decisions/20260922-dashboard-scope-reinstated-7-to-9.md) — confirms nine dashboards live at go-live: the seven committed plus D04 and D11.
- [Open question — VAR-003 close date not committed at the steering committee](/decisions/20260922-var003-close-date-not-committed.md) — records Karthik's refusal to commit a close date in this session.

## Action items

| Item | Owner | What | Due |
|---|---|---|---|
| AI-56 | Ananya Krishnan | Recirculate the plan with cutover weekend and go-live date marked up | 24 September |
| AI-57 | Sneha Pillai | Circulate UAT slots and tester allocation | 28 September |
| AI-58 | Shalini Iyer, Ananya Krishnan | Revert to group finance (Marijke, Wei Lin) with recommendation and named owner for VAR-005 resolution | Before next steerco |
| AI-59 | Ananya Krishnan | Send FY26 variance walk by month, in EUR at 92.40 budget rate, to Wei Lin | 2 October |
| AI-60 | Rajeev Menon | Confirm the variance register position is reflected in the audit file | 9 October |
| AI-61 | Ananya Krishnan | Correct rounding inconsistency between the summary sheet and detail sheet of the variance tracker | 25 September |
| AI-62 | Ananya Krishnan | Send freeze note (master data, ORION availability, sourcing mechanics) to Vikram Sethi | Not dated |

## Open questions

**VAR-003 — Scheme discount double count (1.70 Cr, open)**

Karthik stated the position has not changed since the last steering committee and offered no close date. Root cause is confirmed as source-side: a finance procedure inside ORION rewrites the scheme discount amount; this is not an ETL mapping issue. Karthik would not commit to a close date, stating "I would rather come back with a date that holds." He and Aniruddh Deshpande (the source-side owner) have not yet agreed a position. Shalini owns the variance but is not taking a decision to fix it on the finance side today. The variance sits at 1.70 Cr (per Shalini's board pack).

**VAR-005 — Credit notes (3.11 Cr, open since April)**

Maritians van der Berg made a firm statement: "this must be resolved before our year end, not after it" (i.e. by 31 December). The variance comprises 1,206 credit note documents totaling 3.11 Cr, which is a "channel partner" number that does not yet exist in the warehouse. Finance carries it via manual monthly adjustment, which Marijke characterized as recurring overhead. 

Shalini confirmed the 3.11 Cr is FY26 only and validated against the trial balance (July 2026). She will not have the FY27 number until end of October—after Klarissen's year-end preparation has already begun. Wei Lin requested the variance bridge by month in EUR at the 92.40 budget rate for the group pack.

When Ananya said she had no plan to present that she would stand behind, Marijke pushed back: "I do not want options. I want a date and an owner." Rajeev noted that the owner question cannot be answered inside this meeting. The variance remains open, and the December year-end deadline is a hard constraint from the Klarissen side.

Shalini flagged that the credit note claims raised by distributors ("stockist" claims, in Vikram's vocabulary) are a separate category and not part of this quantification—which Marijke confirmed she understood.

**Secondary Sales Coverage (D02) — Dropped from scope**

Vikram asked whether Secondary Sales Coverage (D02) is inside the nine dashboards. Ananya confirmed it is not. Vikram then asked how he will see "off-take" numbers going forward; Ananya said "the same way you see it today, for now." Rajeev cut the discussion offline, stating the monthly distributor claims are a different conversation. Ananya undertook to call Vikram the next morning to discuss, but this remains unresolved in the steering committee record.

**UAT timeline and float**

When Rajeev asked how much float remains in the plan, Ananya replied: "not much. I am not going to pretend otherwise." This is concerning given the UAT must complete before the cutover weekend of 7–8 November. Shalini pressed on whether all nine dashboards (including the two newly reinstated ones—D04 and D11) will be in the UAT scripts; Ananya confirmed yes, with Ritwik and Priya writing those scripts now.

**Finance resourcing in November**

Shalini flagged that her team will be in the middle of the October close during the reload week (9–11 November), creating a resourcing conflict. The reload does not restate anything (same source rows going back in), so there is no financial impact, but Finance resources are needed for the Wednesday consistency checks. Shalini said it is "a resourcing thing, I will manage it" but has not yet agreed the November staffing plan. She also requested clarification on ORION availability during the cutover weekend, which Ananya undertook to address in the freeze note.

**Distributor territory remapping — ASR confusion**

Vikram asked about "the buddy despatches" and later "Buddy and Nashville." The transcript captured this from the ASR, but context suggests he meant "Baddi despatches" (a locality, not a person name) and "Baddi and Nashik" (a reference to plant locations, per the project geography). This is a transcript garbling and should be read with caution.

**Group reporting implications**

Marijke noted that the twelfth of November falls inside Klarissen's November reporting month, so any reload-related movement in the India numbers will be visible to group finance. Both Karthik and Ananya stated the reload is a reload only (no value moves), but the fact was registered: "if the India numbers move in November because of this, group finance sees it." Rajeev clarified this is "a Klarissen calendar item, not an India item."

---

**Note on inconsistency**: Sneha captured an arithmetic discrepancy: the three open variances (1.70 + 0.65 + 3.11 = 5.46 Cr) sum to 5.46 Cr but the summary states 5.45 Cr. Ananya explained the summary sheet rounds VAR-005 to 3.10 Cr while the detail sheet carries 3.11 Cr, accounting for the one-lac difference. This inconsistency within a single workbook was flagged as a concern by Shalini, as Marijke's team reads both sheets. Ananya took AI-61 to fix it.

**Note on ASR**: The transcript contains several platform ASR renderings: "core" for crore, "lac" for lakh, "SED 2" for SCD2 (slowly changing dimension type 2), "Annie" for Ani (Aniruddh Deshpande). These are platform errors in the `.vtt` file and should not be taken as authoritative spelling.
## Referenced by

- [Knowledge Base Index](/index.md)

