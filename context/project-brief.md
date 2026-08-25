---
type: context
title: Project Brief
description: What Project Drishti is, who is involved, and what success looks like
  — the starting point for the BCPL OLTP-to-warehouse engagement.
tags:
- project-brief
- drishti
- bcpl
- northlane-analytics
- klarissen
- scope
- cast
- workstreams
generated:
  by: process:claude-sonnet/context
  at: "2026-08-23T11:30:00Z"
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
- resource: /_sources/meetings/2026-09-22_steering_committee.txt
  id: T-08
  title: Steering committee
  author: Rajeev Menon
  last_modified: '2026-09-22'
---


# Project brief

## What this is

**Project Drishti** — the internal name used throughout mail subject lines and distribution lists
(`drishti-core@`, `drishti-steerco@`) — is Northlane Analytics' engagement to rebuild Bharadwaj
Consumer Products Ltd's (BCPL) sales and distributor reporting. This knowledge base itself is
catalogued under the name **Project Bharadwaj**; both names refer to the same engagement, so grep
either. BCPL is an FMCG manufacturer headquartered in Mumbai, 62% owned by **Klarissen Group N.V.**
(Amsterdam), which sponsors the programme at group level and reads the numbers directly (`T-01`, `DK-01`).

SOW signed **28-Jan-2026**. Kickoff **Wed 11-Feb-2026**, 15:00-16:00 IST, Nashik board room, Andheri
East office, with Marijke van der Berg (Klarissen Group CFO) dialling in for the first 20 minutes
only (`DK-01`, `T-01`).

## The problem (`T-01`, `DK-01` slide 8)

Shalini Iyer (Head of Finance Systems, BCPL) observed in January 2026 that FY26 Q1 (Apr-Jun 2025)
revenue in the warehouse did not match the closed, audited books reported to group — and once
revisited, several other periods showed the same kind of unexplained gap, with no pattern by month,
region or category. Finance was spending four to five days every month rebuilding reconciliation by
hand in Excel. Rajeev Menon (CIO) routinely had to choose between three different numbers for the
same period — one from Finance, one from Sales Ops, one from the warehouse — because there was no
single governed definition of "the number." Primary and secondary sales and scheme figures were
quoted loosely and interchangeably across teams, and nobody could say with confidence how much of
reported revenue would survive a line-by-line audit. See `/context/glossary.md` for how "primary
sales," "secondary sales," "distributor/stockist/channel partner," and "scheme discount/trade
promotion accrual/TPR" map across the people who use each term.

## Scope

**Source:** ORION, a custom Oracle order-to-cash OLTP built for BCPL in 2009 (Oracle Database 19c;
schemas `OMS_PROD` and `FIN_PROD`).
**Target:** `BCPL_EDW`, a star schema on a separate Oracle 19c instance.
**ETL:** Oracle Data Integrator (ODI) 12c, nightly batch via Control-M.
**BI:** OBIEE 11g (legacy, 41 catalogue reports, ~12 actually used) being retired in favour of Power BI.

See `/context/data-architecture.md` for the pipeline in detail and links to every table concept.

**Workstreams** (`DK-01` slide 11):

| Workstream | Focus | Lead |
|---|---|---|
| WS1 — Data & Variance Root Cause | Inventory every source of a sales number, profile the tables, trace a period end to end | Karthik Subramanian |
| WS2 — Data Quality | Baseline and improve completeness/validity/consistency/uniqueness/timeliness | Neha Gokhale |
| WS3 — Dashboard Design & Build | Design and build Power BI, retiring OBIEE reports | Ritwik Ghosh |
| WS4 — Change, UAT & Cutover | UAT, training, cutover planning | Ananya Krishnan |
| WS5 — Programme Governance | Steering, RAID, status reporting | Ananya Krishnan |

Eight tracked variances, `VAR-001` to `VAR-008` — see `/concepts/variances/`.

## Who is involved

**BCPL:** Rajeev Menon (CIO, executive sponsor, chairs steerco), Shalini Iyer (Head of Finance
Systems, primary business sponsor), Aniruddh "Ani" Deshpande (Senior Oracle DBA, 14 years, the only
person present when ORION was built), Farida Contractor (ODI/ETL Lead, owns the nightly load), Vikram
Sethi (National Sales Operations Manager), Priya Nair (BI Analyst), Meghna Rao (Data Quality Analyst,
joins from May 2026).

**Klarissen Group N.V. (62% parent):** Marijke van der Berg (Group CFO, board sponsor), Wei Lin Tan
(Group FP&A Manager, builds the consolidated group pack).

**Northlane Analytics (the consultancy):** Ananya Krishnan (Engagement Lead), Karthik Subramanian
(Data Architect — "everything else waits on" this workstream, per `DK-01` speaker notes), Ishaan Bhatt
(Analytics Engineer), Neha Gokhale (Data Quality Lead), Ritwik Ghosh (BI Developer), Sneha Pillai
(Business Analyst and note-taker). Six named consultants at SOW signature plus two offshore developers
joining for the build phase.

Full cast profiles, writing styles, and vocabulary quirks (who says "stockist" vs. "distributor" vs.
"channel partner," etc.) are in `/context/glossary.md`, not repeated here.

**Governance** (`DK-01` slide 13): steering committee monthly; core working session weekly (Tuesdays
16:00 IST); Friday status email; workshops as required. "One issue, one owner, one due date."

## What success looks like

- A single, trusted, reconciled source of primary and secondary sales and distributor reporting,
  replacing OBIEE and the shadow Excel trackers.
- Documented lineage from ORION through ODI into `BCPL_EDW`.
- The tracked variances closed or, where still open, explained with an owner and a root cause (see
  `/log.md` and `/concepts/variances/`).
- Power BI live at go-live with the dashboards in the final agreed scope — see `/log.md` for how that
  count moved (12 → 7 → 9) and `/context/active-context.md` for where it stands now.
- OBIEE decommissioned 90 days after go-live.
- Hypercare completed cleanly.

**Go-live itself moved twice over the course of the engagement — see `/log.md`, which is the
authoritative record of that change and of every other fact that changed mid-engagement.** Do not
treat 15-Sep-2026 (the date this brief's own source deck, `DK-01`, was written against) as current.
## Referenced by

- [Knowledge Base Index](/index.md)

