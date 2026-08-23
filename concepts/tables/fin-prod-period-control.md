---
type: oltp-table
title: PERIOD_CONTROL
description: Fiscal period status tracking table that marks whether each month is open for transaction entry, in the closing process, or closed.
resource: FIN_PROD.PERIOD_CONTROL
tags:
  - period
  - month-end
  - close
  - fiscal-calendar
  - status
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    last_modified: "2026-03-03"
  - resource: /_canon/schema_canon.sql
    id: SCHEMA
    last_modified: "2026-02-11"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:17Z
---

## Purpose

PERIOD_CONTROL is the single source of truth for fiscal period status in ORION. Each row represents one calendar month (YYYYMM format) and records whether transactions are still being entered, the close process is underway, or the period is locked down.

The table is actively queried by the PKG_MONTH_END package: when `PKG_MONTH_END.P_ADJUST_REVENUE` is called without an explicit period parameter, it resolves the current open period from this table (per DOC-01).

## Grain

One row per fiscal month. PERIOD_YYYYMM is the natural business key and the primary key.

## Columns

| Column | Type | Nullable | Notes |
|---|---|---|---|
| **PERIOD_YYYYMM** | VARCHAR2(6) | NOT NULL | Natural key. Format YYYYMM, e.g., "202603" for March 2026. Business key for the fiscal period. |
| STATUS | VARCHAR2(10) | YES | Enumerated status: OPEN, CLOSING, or CLOSED. Enforced by CHECK constraint. |
| CLOSED_TS | TIMESTAMP(6) | YES | When the period was closed. Set by month-end closing process. |
| CLOSED_BY | VARCHAR2(30) | YES | User ID of the person who closed the period. |
| CREATED_BY | VARCHAR2(30) | YES | User ID of the row creator. |
| CREATED_DT | DATE | YES | Date the row was created. |
| LAST_UPD_BY | VARCHAR2(30) | YES | User ID of the last update. |
| LAST_UPD_DT | DATE | YES | Date of the last update. |
| ACTIVE_FLG | CHAR(1) | YES | Logical flag, values typically Y or N. Standard audit column. |
| DELETE_FLAG | CHAR(1) | YES | Soft delete flag, values typically Y or N. |

## Keys and Constraints

- **Primary Key:** PERIOD_YYYYMM (single column)
- **Check Constraint:** `CK_PERIOD_STATUS` — STATUS must be in ('OPEN', 'CLOSING', 'CLOSED')
- No foreign keys defined in the schema
- No unique constraints other than PK

## Relationships

- Referenced by `/concepts/tables/fin-prod-scheme-accrual.md` (SCHEME_ACCRUAL.PERIOD_YYYYMM)
- Used by stored procedure PKG_MONTH_END.P_ADJUST_REVENUE (unmodeled stored procedure in FIN_PROD)

## Data Quality and Known Issues

None explicitly noted in DOC-01 or DOC-05.

The table acts as a gating mechanism for month-end closing; if a period's STATUS is not OPEN, downstream applications should block new transaction entry. The timestamp and user tracking columns support audit trails during close.

## Implementation Notes

PERIOD_YYYYMM format follows YYYYMM (six-digit string), aligned with BCPL's April-to-March fiscal year. See `/context/` glossary for fiscal calendar details.
