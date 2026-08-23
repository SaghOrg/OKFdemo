---
type: oltp-table
title: TAX_RATE_MASTER
description: Effective-dated GST tax rates by HSN code, supporting the tracking of tax rate changes over time in ORION.
resource: FIN_PROD.TAX_RATE_MASTER
tags:
  - tax
  - gst
  - hsn
  - effective-dating
  - rate-master
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    last_modified: "2026-03-03"
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    last_modified: "2026-05-15"
  - resource: /_canon/schema_canon.sql
    id: SCHEMA
    last_modified: "2026-02-11"
  - resource: /_canon/variance_register_canon.csv
    id: VARIANCE_REGISTER
    last_modified: "2026-09-22"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:17Z
---

## Purpose

TAX_RATE_MASTER is the reference table for GST tax rates keyed by HSN (Harmonized System of Nomenclature) code. Unlike a simple snapshot, this table is **effective-dated**: each row carries EFF_FROM_DT (effective from) and EFF_TO_DT (effective to), allowing the rate history to be preserved. When an HSN's tax rate changes, a new row is inserted with the new rate and the appropriate effective dates.

Example (from schema comment): Chandanaa product, HSN 3401, was taxed at 18% until 30-Sep-2025 and at 12% from 01-Oct-2025 onwards. Two rows capture this:
- HSN_CODE=3401, GST_RATE_PCT=18.00, EFF_FROM_DT=01-Apr-2025, EFF_TO_DT=30-Sep-2025
- HSN_CODE=3401, GST_RATE_PCT=12.00, EFF_FROM_DT=01-Oct-2025, EFF_TO_DT=NULL

## Grain

One row per (HSN_CODE, effective date range). Multiple rows may exist for the same HSN with non-overlapping effective periods. Rows are not uniquely keyed by HSN alone.

## Columns

| Column | Type | Nullable | Notes |
|---|---|---|---|
| **HSN_CODE** | VARCHAR2(10) | NOT NULL | Harmonized System of Nomenclature code. Part of the logical key but **NOT** a primary key on its own. |
| **GST_RATE_PCT** | NUMBER(5,2) | NOT NULL | GST tax rate as a percentage, e.g., 18.00 for 18%, 12.00 for 12%. Precision 5 digits, 2 decimals. |
| **EFF_FROM_DT** | DATE | NOT NULL | Effective from date (inclusive). Part of the logical key. When this rate begins to apply. |
| EFF_TO_DT | DATE | YES | Effective to date (inclusive). When this rate stops applying. NULL indicates the rate is current (open-ended). |
| CREATED_BY | VARCHAR2(30) | YES | User ID of the row creator. |
| CREATED_DT | DATE | YES | Date the row was created. |
| LAST_UPD_BY | VARCHAR2(30) | YES | User ID of the last update. |
| LAST_UPD_DT | DATE | YES | Date of the last update. |
| ACTIVE_FLG | CHAR(1) | YES | Logical flag, values typically Y or N. |
| DELETE_FLAG | CHAR(1) | YES | Soft delete flag, values typically Y or N. |

## Keys and Constraints

- **Primary Key:** **NOT DEFINED** in the DDL. This is a structural anomaly. Logically, the unique key should be (HSN_CODE, EFF_FROM_DT) to prevent duplicate rate entries for the same HSN on the same effective date. No PRIMARY KEY constraint is declared.
- **Index:** `IX_TAXRATE_HSN` on (HSN_CODE, EFF_FROM_DT) supports lookup queries: "What is the current rate for HSN X?" or "What was the rate for HSN X on date Y?"
- No foreign keys defined

## Discrepancy: Missing Primary Key

The DDL does not declare a PRIMARY KEY constraint, despite the clear logical structure suggesting (HSN_CODE, EFF_FROM_DT) should be unique. The index `IX_TAXRATE_HSN` supports efficient queries but does not enforce uniqueness. This creates a risk of duplicate effective-dated rows for the same HSN and start date, though application-level logic may prevent it.

## Effective-Dating Design

The source table (FIN_PROD) is **effective-dated**. DOC-01 states: "TAX_RATE_MASTER on this side is holding HSN_CODE, GST_RATE_PCT and, importantly, EFF_FROM_DT and EFF_TO_DT. so the rate history is available in the source, it is effective dated here."

This design allows the source system to retain the full history of tax rate changes. To query the rate that applied on a given business date, a query would select the row where HSN_CODE matches, EFF_FROM_DT <= business_date, and (EFF_TO_DT >= business_date OR EFF_TO_DT IS NULL).

## Variance Context — VAR-006

VAR-006 ("GST rate change mishandled") documents a critical asymmetry: the **warehouse copy** (`BCPL_EDW.TAX_RATE_MASTER`) was a truncate-and-reload snapshot with no effective dating, while the **source** (this table, FIN_PROD.TAX_RATE_MASTER) retains full history. As a result, when the Chandanaa HSN 3401 rate changed from 18% to 12% on 01-Oct-2025, the warehouse version applied the new rate retrospectively to historical invoices from Apr-Sep-2025.

The fix (`CHG0021339`, deployed 26-Aug-2026) replaced the warehouse snapshot with a proper `DIM_TAX_RATE` dimension carrying effective dating. See `/concepts/variances/var-006-tax-rate-retroactive.md` for full detail.

## Relationships

- Implicit: Used to look up the applicable GST rate when posting invoice transactions (in OMS_PROD)
- Warehouse: Related to `/concepts/tables/bcpl-edw-dim-tax-rate.md` (the corrected dimension, post-VAR-006)
- Reference: HSN codes come from OMS_PROD.SKU_MASTER (unmodeled table)

## Data Quality and Known Issues

**DOC-05 concern:** Karthik's notes on the warehouse model mention: "This is the one I have parked. It sits inside BCPL_EDW with HSN_CODE, GST_RATE_PCT and LOAD_DT on it, and no surrogate key, so it is not a dimension in any sense I recognise… TBC - Karthik to confirm whether the tax rate lookup belongs in the model at all." This reflects uncertainty about the warehouse role of this table, which was resolved by the VAR-006 remediation.

The source table itself is well-structured for its purpose (effective-dated rate history), but the missing PRIMARY KEY constraint is an implementation gap worth fixing.

## Implementation Notes

To find the applicable tax rate for an HSN on a given invoice date:
```sql
SELECT GST_RATE_PCT
FROM FIN_PROD.TAX_RATE_MASTER
WHERE HSN_CODE = ?
  AND EFF_FROM_DT <= invoice_date
  AND (EFF_TO_DT >= invoice_date OR EFF_TO_DT IS NULL)
```

On a date with multiple overlapping rates (an error condition), the query would return multiple rows. Application logic should prevent overlaps at insert time.

## Related variances

- **[VAR-006 — GST rate change mishandled](/concepts/variances/var-006-tax-rate-retroactive.md)**: this table is the correctly effective-dated ORION source; the defect was entirely in the warehouse copy (BCPL_EDW.TAX_RATE_MASTER) failing to carry that effective dating across.
