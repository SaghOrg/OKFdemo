---
type: oltp-table
title: SCHEME_ACCRUAL
description: Period-end accrual of scheme discounts (trade promotions) at the customer-scheme-period
  grain, written by the month-end close procedure.
resource: FIN_PROD.SCHEME_ACCRUAL
tags:
- scheme-discount
- trade-promotion
- accrual
- month-end
- customer
- financial
sources:
- resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
  id: DOC-01
  last_modified: '2026-03-03'
- resource: /_canon/schema_canon.sql
  id: SCHEMA
  last_modified: '2026-02-11'
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23 10:37:17+00:00
---


## Purpose

SCHEME_ACCRUAL holds the accrued value of scheme discounts (known in finance as "trade promotion accruals" or "secondary schemes" in operational language) at the customer-scheme-period level. It is the accountant's view of scheme liability: one row per customer per scheme per period, with the total accrual amount that should be reserved.

The table is written by `PKG_MONTH_END.P_RECALC_SCHEME_DISCOUNT` during the month-end close process and is used to support accrual-based accounting. It is distinct from the transaction-level scheme amounts that appear on individual invoices.

DOC-01 notes explicitly: "it does not tie line by line to the invoice line, it is at party and period grain, so do not expect the two to reconcile at line level, they were never meant to."

## Grain

One row per (customer, scheme, period) combination. ACCRUAL_ID is a surrogate key; the natural business key is (CUST_ID, SCHEME_ID, PERIOD_YYYYMM).

## Columns

| Column | Type | Nullable | Notes |
|---|---|---|---|
| **ACCRUAL_ID** | NUMBER(12) | NOT NULL | Surrogate primary key. Allocated from a sequence. No business meaning. |
| CUST_ID | NUMBER(10) | YES | Customer identifier. References OMS_PROD.CUSTOMER_MASTER (not a declared FK in this schema). |
| SCHEME_ID | NUMBER(8) | YES | Scheme master identifier. References OMS_PROD.SCHEME_MASTER (not a declared FK). |
| PERIOD_YYYYMM | VARCHAR2(6) | YES | Fiscal period key. Format YYYYMM. Indexed separately for query performance. Soft foreign key to FIN_PROD.PERIOD_CONTROL. |
| ACCRUAL_AMT | NUMBER(16,2) | YES | Accrued amount in local currency (INR). Precision 16 digits, 2 decimals. The core fact value. |
| POSTED_FLG | CHAR(1) | YES | Posting flag, typically Y or N. Indicates whether the accrual has been posted to the GL. |
| CREATED_BY | VARCHAR2(30) | YES | User ID of the row creator. |
| CREATED_TS | TIMESTAMP(6) | YES | **CREATED_TS, not CREATED_DT.** Timestamp in UTC. DOC-01 emphasizes this: "the created column is not CREATED_DT, it is CREATED_TS, TIMESTAMP(6), and the application server writes it in UTC." For business dating, use the PERIOD_YYYYMM instead. |
| LAST_UPD_BY | VARCHAR2(30) | YES | User ID of the last update. |
| LAST_UPD_DT | DATE | YES | Date of the last update (note: DATE, not TIMESTAMP). |
| ACTIVE_FLG | CHAR(1) | YES | Logical flag, values typically Y or N. |
| DELETE_FLAG | CHAR(1) | YES | Soft delete flag, values typically Y or N. |

## Keys and Constraints

- **Primary Key:** ACCRUAL_ID (surrogate)
- **Index:** `IX_ACCRUAL_PERIOD` on (PERIOD_YYYYMM) for period-based queries
- **Implicit relationship:** PERIOD_YYYYMM to FIN_PROD.PERIOD_CONTROL (no FK constraint defined)
- No explicit foreign keys to OMS_PROD (CUST_ID, SCHEME_ID)

## Timestamp Caveat

CREATED_TS is recorded in UTC, not IST. This differs from other OLTP tables where the business date is in IST. For any business date interpretation, use PERIOD_YYYYMM.

## Relationships

- `/concepts/tables/fin-prod-period-control.md` — soft relationship on PERIOD_YYYYMM
- OMS_PROD.CUSTOMER_MASTER — via CUST_ID (not a declared FK)
- OMS_PROD.SCHEME_MASTER — via SCHEME_ID (not a declared FK)

## Data Quality and Known Issues

**DOC-01 uncertainty:** Ani Deshpande notes: "I think but check with Farida whether the extract is picking up the accrual table at all, i have a feeling it is not and i may be wrong about that." This suggests the warehouse extract may not be consuming SCHEME_ACCRUAL systematically. This merits verification with the ODI mapping layer.

**No line-by-line reconciliation:** The accrual amount is at customer-scheme-period grain and will not reconcile to the sum of individual invoice-level scheme amounts. The two are logically independent views intended for different business purposes.

## Implementation Notes

The table is populated only during the month-end close, not in real-time. It is a standard accrual reserve table for financial reporting. The posting flag allows for a two-step process: calculate accrual, then post to GL.
## Referenced by

- [VAR-003 — Scheme discount double-count](/concepts/variances/var-003-scheme-discount-double-count.md)
- [Data Architecture](/context/data-architecture.md)

