---
type: meeting-note
title: T-01 — Kickoff and scope
description: Project Drishti kickoff, establishing scope, workstream structure, discovery approach, and initial commitments from BCPL and Klarissen leadership.
tags: [kickoff, scope, discovery, variance, warehouse, go-live, phase-planning]
sources:
  - resource: /_sources/meetings/2026-02-11_kickoff_scope.vtt
    id: T-01
    last_modified: "2026-02-11"
generated:
  by: process:claude-haiku/meetings
  at: 2026-08-23T11:14:55Z
---

## Summary

Project Drishti kickoff on 11 February 2026, 15:00-16:00 IST in the Nashik board room (Andheri East office, 4th floor), with Marijke van der Berg joining from Amsterdam (10:30-10:50 CET, 20 minutes). The meeting established the programme's mandate, workstream structure, and discovery approach.

**The core problem:** Shalini Iyer observed in January that FY26 Q1 (Apr-Jun 2025) numbers in the warehouse do not match the closed, audited books reported to group. Not a rounding or timing difference; when revisited, multiple other periods also show unexplained variances. No pattern by month, region, or category. Additionally, Finance spends four to five days every month rebuilding reconciliation by hand in Excel. Rajeev Menon, as CIO, finds himself choosing between three conflicting versions of the same number from Finance, Sales Ops, and the warehouse.

**Rajeev's expectations** (stated once, non-negotiable):
1. Board pack number and warehouse number must be the same
2. Without ten people doing manual work every month
3. Dashboards that people actually open (existing OBIEE catalogue has 41 reports, most unused)
4. Not a two-year programme; "do not boil the ocean"

**Marijke's position:** India is the second-largest operating company by revenue but the only one where the monthly number requires rebuilding before it can go into the group pack. She wants visibility of the walk from gross to net by month, and trustworthiness of the reported number. Currency: 92.40 EUR/INR budget rate, not spot. FY26 close is six weeks away (31 March); do not disturb it.

**Phase structure and go-live date:** Agreed 15 September 2026 for system go-live. Four phases: discovery and variance root-cause (now to early May), remediation and warehouse rebuild, Power BI build and testing, cutover and hypercare (to 11 December). Shalini flagged concern that testing falls in the close window, but Rajeev asked her to plan to the September date; date may move but let us plan for it.

**Discovery approach:** Karthik will not return in three weeks with "data quality is poor"; he will trace specific numbers through the system. Four workstreams: (1) inventory of all places a sales number comes from (source system, warehouse, reports, spreadsheets), (2) written definitions for every reported measure, (3) profiling on actual tables (row counts, nulls, duplicates), requiring read access to staging, warehouse, and ORION, (4) one end-to-end reconciliation per month/region, tracing invoices from source through staging to warehouse to report, accounting for every rupee of difference. First reconciliation takes three weeks; subsequent ones faster. Access to be chased with Aniruddh (Ani) Deshpande, the Oracle DBA, who was not present.

## Decisions referenced

- /decisions/20260211-do-not-touch-production.md — Commitment that nothing goes into production between now and close of FY26 (31 March 2026)
- /decisions/20260211-go-live-september-15.md — System go-live target of 15 September 2026 (noted as potentially moveable but plan baseline)
- /decisions/20260211-budget-rate-92-40.md — EUR/INR conversion rate for group reporting to be 92.40 (not spot rate)

## Action items

| Owner | What | By |
|---|---|---|
| Sneha Pillai | Circulate correct version of kickoff pack and plan (slide 4 changed from Friday version) | 11-Feb (today) |
| Shalini Iyer | Share FY26 Q1 working paper and trial balance extract | 16-Feb (Monday) |
| Karthik Subramanian | Send list of ORION tables needed for profiling | (start of next week) |
| Farida Contractor | Arrange read access to staging schema and `BCPL_EDW` warehouse | (following submission of table list) |
| Farida Contractor | Chase read access to ORION with Aniruddh Deshpande (he requires specific table list, not blanket access) | (following submission of table list) |
| Farida Contractor | Share job inventory (ODI interfaces / mappings) for sales chain, circa 20 interfaces in scope | 23-Feb |
| Priya Nair | Pull OBIEE usage tracking: who ran which of the 41 catalogue reports | 25-Feb |
| Vikram Sethi | Send the sales operations sheet that his regional coordinators maintain (with TPR and secondary scheme adjustments) | 12-Feb (day after) |
| Sneha Pillai | Set up recurring weekly working sessions (Tuesdays, 16:00 IST, starts next Tuesday 18-Feb) and steering committee invites for full year | This week (11-17 Feb) |
| Karthik Subramanian | Fifteen-minute discussion with Aniruddh Deshpande on ORION architecture | ASAP |

## Open questions

**Reconciliation magnitude (Shalini unresolved):** Shalini declined to state a number on the recorded call after a previous number appeared in a slide attributed to her. She confirmed it is "not a rounding difference" and "not a timing difference that I can explain in one line", but will only quantify after she has checked it properly. Ranges mentioned: either lakhs or crores (but not which).

**Scope of gross-to-net walk (Karthik clarified with Marijke):** Marijke wanted visibility of the walk from gross to net. Karthik asked whether by month or by channel partner; Marijke clarified by month first, with ability to drill into one month further. (Resolved in the call.)

**Dashboard count and reporting scope:** Rajeev asked how many dashboards he is getting. Ananya deferred to "slide four" (reporting scope slide) and committed to having it ready. Rajeev flagged this is one of two things he will be asked by the board, along with the date.

**OBIEE usage reality (Priya identified):** There are 41 reports in the catalogue but most are unused. Priya noted she will pull usage tracking to identify which are actually used, because asking people always yields "everybody says they need everything".

**Prompt / slicer behaviour in Power BI (Priya and Ritwik aligned but not finalized):** In OBIEE, one dashboard prompt at the top cascades across all analyses. In Power BI, a slicer sits on the page and can be synced across pages if wanted. Ritwik noted he would not sync everything as it gets confusing. Deferred to workshops.

**"Buddy" products value mismatch (Vikram's observation, noted for investigation):** Vikram observed that "Buddy" brand personal care items are always coming with value mismatches (quantity matches, value does not), whereas "Sovereign" and "Tarang" items are mostly fine. Karthik noted this as a very specific observation. Transcript note: "Buddy" may be an ASR error; source unknown. "Nashik" (a plant location referenced by Vikram) was transcribed as "Nashville", likely an ASR error.

**Data model documentation (Karthik noted, no commitment sought):** No recent data model exists for ORION; the source system was built in 2009 by Sahyadri Softech. Farida maintains documentation for the warehouse. Karthik agreed to build understanding of the source as discovery proceeds.

**Secondary sales mixing in primary (Karthik clarified, Vikram accepted):** Vikram's spreadsheet contains both primary sales (invoiced to distributors / "stockist"-level) and secondary sales (off-take; distributor selling to retailer). Karthik explained the difference (Bharadwaj to distributor = revenue; distributor to retailer = not revenue) and committed to writing down definitions for every measure so they are visible to all. Shalini had raised this mixing for two years. Vikram agreed: "the two things get mixed up, I accept."

**Primary vs. secondary definition (Vikram confirmed):** Vikram's regional coordinators manually add TPR (trade promotion rebate, loosely; also "secondary scheme") and secondary scheme amounts from scheme circulars and depot staff directly. These things do not come properly in the extract. Karthik asked for written definitions and Shalini confirmed she can help.

**Go-live date tightness in close window (Shalini flagged, Rajeev accepted risk):** Shalini asked whether 15 September is firm because if so, testing falls in the middle of the close cycle. Ananya said the plan is built around it and is tight but holds. Rajeev said "Shalini if it moves it moves, but let us plan for the fifteenth." Shalini asked for this to be noted.
