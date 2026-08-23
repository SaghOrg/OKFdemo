---
type: warehouse-table
title: SEC_USER_REGION
description: Security mapping table for Power BI row-level security, linking user
  UPNs to regions they are authorized to see.
resource: BCPL_EDW.SEC_USER_REGION
tags:
- security
- row-level-security
- RLS
- Power-BI
- SEC_USER_REGION
- access-control
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23 10:37:25+00:00
sources:
- resource: /_canon/schema_canon.sql
  id: TECH-SQL-EDW
  last_modified: '2026-08-23'
- resource: /_build/corpus_text/docs/DOC-05_edw_target_model_notes.docx.txt
  id: DOC-05
  title: EDW target model notes
  last_modified: '2026-05-15'
---


## Purpose

SEC_USER_REGION is the access control table for Power BI row-level security. It maps individual users (by User Principal Name) to the geographic regions they are authorized to view. The Power BI dataset uses this table at query time to filter data, ensuring Sales Ops users and other viewers see only data for their assigned regions.

## Grain

One row per user-region pair. A user with access to multiple regions appears on multiple rows.

## Columns

- **USER_UPN**: User Principal Name (email address). VARCHAR2(120) NOT NULL. Part of composite primary key.

- **REGION_CODE**: The region code the user is authorized for. VARCHAR2(6) NOT NULL. Part of composite primary key. Links to DIM_GEOGRAPHY.REGION_CODE.

- **LOAD_DT**: Date the row was loaded/updated. DATE.

## Constraints

- **Composite primary key**: (USER_UPN, REGION_CODE).
- No other indexes specified.

## Operational Context

### User Population

At go-live, 128 named users were configured in SEC_USER_REGION, of which 41 are Sales Ops. The remaining ~87 users include Finance, management, and other stakeholders with varying access scopes.

### Maintenance Cycle

DOC-05 emphasizes: "It is not part of the star, it carries no business data, and it should not be maintained on the same cycle as the sales load, because the people who approve access are not the people who run the load and the two things fail for completely different reasons."

**This means:**
- SEC_USER_REGION is updated by identity management or business process, not by the nightly ETL load.
- Access changes (promotions, region reassignments, terminations) follow a separate process.
- Do not tie SEC_USER_REGION refresh to the main warehouse load or to BCPL_EDW_DAILY folder jobs in Control-M.
- If access approval and access provisioning are owned by different teams (e.g., HR approves, IT provisions), synchronization failures will not block the warehouse load.

### Row-Level Security in Power BI

The dataset `DRISHTI_SALES` in Power BI workspace `BCPL-DRISHTI-PRD` uses an RLS rule that joins to SEC_USER_REGION on the current user's UPN and filters by REGION_CODE. The rule applies to fact and dimension rows that carry REGION_CODE or GEO_KEY linking to DIM_GEOGRAPHY.REGION_CODE.

As a result:
- A Sales Ops user assigned to 'WR' (Western Region) sees only invoice lines, order lines, and secondary sales for that region.
- A user not in SEC_USER_REGION sees no rows (or sees only public/aggregate measures, depending on the Power BI role design).
- A user assigned to multiple regions sees data across all assigned regions.

## Relationships

- USER_UPN should match the authenticated user identity in the Power BI tenant (typically Azure AD or on-premises AD).
- REGION_CODE links to DIM_GEOGRAPHY.REGION_CODE.
- No joins to fact tables; used only for filtering at query time.

## Data Quality and Known Gaps

No discrepancies between DDL and prose are documented. However, auditing of who has access to which regions should be part of ongoing GRC (Governance, Risk, Compliance) procedures.
## Referenced by

- [Data Architecture](/context/data-architecture.md)

