---
type: meeting-note
title: Dashboard scope workshop — T-07 — 05 Aug 2026
description: Scoping the seven committed dashboards for go-live and handling three
  competing requirements around distributor-level visibility, secondary sales data
  quality, and group-level reporting.
tags:
- dashboards
- d01
- d03
- d05
- d06
- d07
- d09
- d12
- candidates
- secondary sales
- distributor drill-down
- vocabulary
sources:
- resource: /_sources/meetings/2026-08-05_dashboard_scope_workshop.vtt
  last_modified: '2026-08-05'
generated:
  by: process:claude-haiku/meetings
  at: "2026-08-23T11:15:00Z"
---


## Summary

The team held a 90-minute workshop in the Nashik board room to lock in dashboard scope and design direction for the seven committed dashboards and two candidates. Ritwik Ghosh walked through each dashboard's audience, layout rules, and data sources. Wei Lin Tan (joining remotely from Singapore) listed group-level requirements for executive reporting. The meeting exposed three structural tensions that remain unresolved:

1. Vikram Sethi (Sales Ops) has requested "stockist"-level (distributor-level) drill-down with both primary billing and secondary off-take data on every page since February, saying his team works at distributor grain and cannot use aggregated views. Ritwik countered that mixing two grains on one page — one revenue-auditable (primary), one not (secondary) — would invite misuse ("people will subtract one from the other and ask why there's a gap"). Shalini reinforced that secondary data cannot sit on pages she signs off as finance without audit reconciliation.

2. Secondary sales coverage is 74% of distributors, 5 days behind, and runs from an unreliable SFA upload. Ritwik and Meghna argued this data quality makes it unsafe to show alongside primary sales. Vikram countered that 74% is "something, not zero" and suggested secondary as a separate page or a trend-only visualization.

3. Vocabulary drift across the client, consultancy, and Klarissen is slowing design: "distributor", "stockist", "channel partner" for the same thing; "primary sales" / "secondary sales" / "sell-in" / "sell-out" for overlapping but distinct measures; "net revenue" defined differently by Finance and BI.

The team surfaced two dashboard candidates (D04 Scheme Effectiveness, D11 Credit and Receivables Exposure) that are not funded but keep appearing in conversation. These will go to the sponsor (Rajeev, with Klarissen group) as candidates for a later decision.

## Decisions referenced

- [/decisions/20260330-dashboard-scope-cut-12-to-7.md](/decisions/20260330-dashboard-scope-cut-12-to-7.md) — the prior scope decision (seven committed, five deferred to Phase 2) this workshop designed against; the two candidates raised here (D04, D11) are drawn from its deferred five.
- *Unresolved:* [/decisions/20260805-dashboard-stockist-drilldown-unresolved.md](/decisions/20260805-dashboard-stockist-drilldown-unresolved.md) — records the stockist-level drill-down and primary/secondary side-by-side disagreement this workshop left open with no owner assigned.

## Action items

| Item | Description | Owner(s) | Date |
|------|-------------|---------|------|
| AI-46 | Create one-page definitions sheet covering: net revenue (Finance definition), primary sales (invoice to distributor), secondary sales (distributor to retailer), fill rate (order fulfilment %). Signed off by Shalini, Vikram, and Priya. | Shalini (lead, with Ritwik); Priya input | TBC |
| AI-47 | Pull list of existing OBIEE agent subscribers from catalogue — these are people who only consume via email, not dashboard. Show who is on which agent. | Priya | Friday 12-Aug |
| AI-48 | Add group-level terminology to definitions sheet: sell-in (primary), sell-out (secondary), channel partner (distributor). Clarify which are revenue and which are not. | Sneha (with Ananya) | TBC |
| AI-49 | Every dashboard page must carry a "data as of" card showing the refresh timestamp and lag (e.g. "as of 05-Aug 06:15 IST, 5 days behind for secondary"). | Ritwik | In build |
| AI-50 | Confirm whether "plant" dimension is derived in the warehouse layer or exists as a master. Check with Ishaan if needed; affects DIM_PRODUCT design. | Ritwik | TBC |
| AI-51 | Send monthly count of rows with PRODUCT_KEY = -1 ("unknown product") to Ritwik. Quote is ~8,140 lines/month average, peak 11,902 in Jan-2026. | Meghna | With this week's data |
| AI-52 | Define and submit list of users who receive "all region" access (no RLS role restriction). This list will be provided to Power BI team and is separate from the 128 named users on the dashboard. | Shalini | End of week 12-Aug |
| AI-53 | Split the 74% secondary sales coverage statistic by region (North, West, South, East) so the team can understand where the feed is strongest. | Meghna | This week |
| AI-54 | Circulate wireframe pack showing layouts for the seven committed dashboards and two candidates (marked "not funded"). Current blockers: wifi, screen share unavailable; Ritwik will email as attachment. | Ritwik | Friday 09-Aug |
| AI-55 | Review the existing Distributor Scorecard report and check how "fill rate" is calculated there. Report back with the formula so it can be mapped to the new DIM_ORDER model. | Priya | TBC |

**Open point (no owner, no date yet):** Distributor-level "stockist" drill-down on all pages, showing primary and secondary side-by-side. Vikram raised this repeatedly and has been asking since February. Current positions: Vikram (required, or Sales will build their own sheet); Ritwik (breaks dashboard grain, secondary data too fragile); Shalini (cannot mix unauditable off-take with primary revenue on one page). Ananya to pick this up separately with Karthik and Vikram.

## Open questions

**Distributor drill-down grain.** Vikram says "every dashboard, every one of them, must go down to stockist level… if I cannot see Trilok Traders separately then the dashboard is for someone else, not for me." Ritwik's counter: "340 distributors, 860 active SKUs, by month — that is not something a person reads… if you filter to one distributor one brand I can show every line, but I cannot put all of it on one page and call it a dashboard." Shalini: "I am not against off-take being somewhere, I am against it being on the same page as a number I have to sign." The three positions did not converge.

**Secondary sales data quality.** Meghna reported 74% distributor coverage and ~5 days lag (last 5 days of month missing on day 1 of next month). Vikram said this contradicts what his field team reports; Meghna replied "I am only reporting what is in the feed." Priya noted the old OBIEE report used to carry a note "secondary is indicative" in the footer. Ritwik worried that showing secondary next to primary creates "two truths on one page", and the gap "is not real, it is a coverage gap." Shalini agreed: "I cannot have a page where two numbers sit next to each other and only one of them ties to anything." Whether secondary should appear as a separate report, a trend-only page, per-region filtering, or not at all remains open.

**"Plant" dimension.** Priya asked whether Plant (a distribution hub) sits in the existing dimension or is derived from distributor/territory master. Ritwik and Ishaan to investigate; affects whether it can be a slicer on D01 Primary Sales Performance and D05 Stock and Despatch.

**Refresh frequency.** Current scheduled refreshes are 06:00 and 14:00 IST. Vikram noted the secondary file sometimes arrives during the day and asked for more refreshes on month-end nights. Ritwik replied "the source only changes once a night anyway" (referring to the warehouse). Left as an open item to be decided before UAT.

**Outstanding column on D03 Distributor Scorecard.** Priya flagged that the existing report's "outstanding" value comes from the receivables side (AR_OPEN_ITEM), not the sales fact table. This is data D11 (Credit and Receivables Exposure) will need. Ritwik to check if this is in the current model or will need to be built separately.

## Vocabulary notes

The meeting spent notable time on vocabulary drift — evidence of the root-cause problem Ananya flagged: "half the confusion on this project is two people using the same word for two things."

**Distributor terms:**
- Vikram says "stockist" (always).
- Finance, Northlane, and the BI team say "distributor".
- Klarissen says "channel partner".
- Linked to: /context/glossary.md (requires update with these three terms).

**Sales terms:**
- Primary sales: BCPL invoicing the distributor. Sits in `FACT_INVOICE_LINE`. Revenue. This is "sell-in" in group language.
- Secondary sales: Distributor selling onward to retailer. Comes from SFA upload. Not revenue. This is "sell-out" in group language. Also called "off-take" by Sales Ops.
- Old OBIEE reports labeled secondary as "indicative" to warn of gaps.
- Wei Lin requested that the definitions sheet carry both India and group terminology so the monthly group pack can be self-serve from Power BI instead of a two-day manual Excel job in Shalini's team.

**Dashboard terminology:**
- Priya (OBIEE): "report", "dashboard page", "analysis", "prompt", "agent" (scheduled delivery).
- Ritwik (Power BI): "report" (the file), "page" (inside the file), "slicer", "measure", "tile".
- Snag: Ritwik calls a scrollable view a "page"; Priya expects a "prompt" to apply to all analyses below it. Power BI slicers apply page-by-page and can be synced cross-page, but not automatically. Ritwik's rule: "one visual, one message" — not a blueprint everyone shares yet.

Ananya requested the definitions sheet be captured and noted "capturing that as an action" — this became AI-48.

## ASR and transcript notes

- The transcript's automated speech recognition transcribed "crore" as "core" and "lakh" as "lac" in several places; the team clearly said "crore".
- "Stockist" is correctly transcribed; not a misheard term.
- The platform misattributed one line to `<v Unknown Speaker>` (line ~745, on RLS roles); context suggests it was Ritwik.
- The Nashik board room (4th floor) wifi dropout is evident in the transcript around line 855–875 (Vikram losing signal in a tunnel while driving).
- Screen-share attempts failed for ~20 minutes (wifi blocking); the team worked around it by Ritwik describing wireframes verbally and committing to email them Friday.

## Meeting logistics

- **Room**: Andheri East office, Nashik board room, 4th floor.
- **Attendees**: Ritwik Ghosh (BI Developer, Northlane), Priya Nair (BI Analyst, BCPL), Vikram Sethi (Sales Ops, BCPL, late; joined 00:11:35 via phone from car), Shalini Iyer (Finance Systems, BCPL, on phone + laptop), Meghna Rao (Data Quality, BCPL, audio only), Ananya Krishnan (Engagement Lead, Northlane), Sneha Pillai (Business Analyst/note-taker, Northlane), Wei Lin Tan (Group FP&A, Klarissen, 12:30 SGT / 10:00 IST, left at 11:00 IST).
- **Apologies**: None recorded.
- **Time**: 90 minutes, 10:00–11:30 IST (well-used).
- **Pre-read**: Sneha sent a two-page pre-read Monday; Priya had not opened it, Shalini read in the car. Ritwik clarified the pack would come Friday (separate).
- **Notes**: Sneha circulated via notes and tracker update immediately after.
## Referenced by

- [Knowledge Base Index](/index.md)

