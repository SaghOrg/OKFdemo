---
type: oltp-table
title: OMS_PROD.INVOICE_LINE_ARCHIVE
description: Pre-01-Apr-2016 line-item archive. Closed, not extracted. Same shape as INVOICE_LINE minus DELETE_FLAG.
resource: OMS_PROD.INVOICE_LINE_ARCHIVE
tags:
  - invoice
  - archive
  - historical
  - inactive
  - oltp
  - pre-2016
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP Schema Notes
    author: Aniruddh Deshpande
    last_modified: "2026-03-01"
  - resource: /_canon/schema_canon.sql
    id: SCHEMA
    title: ORION schema DDL (canonical)
    last_modified: "2026-03-15"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:03Z
---

## Purpose and scope

`INVOICE_LINE_ARCHIVE` contains line-item detail for all invoices, credit notes, and service memos issued **before 01-Apr-2016**. The table was **closed on 01-Apr-2016** and is no longer receiving new rows. It is not extracted into the warehouse and has not been opened by anyone since 2016.

The table was retained because somebody said at the time that audit might ask for it. Audit has never asked.

## Grain and row count

Grain: **one row per SKU per invoice**. No current row count is provided in the sources; all counts refer to the active `INVOICE_LINE` table (61.8M rows as of 31-May-2026).

## Schema: same as INVOICE_LINE minus one column

`INVOICE_LINE_ARCHIVE` has the same structure as `INVOICE_LINE` **except that it lacks the `DELETE_FLAG` column entirely**. This is deliberate: the soft-delete programme (which added `DELETE_FLAG` to active tables) did not exist when the archive was closed off in 2016.

| Column | Type | Meaning | Difference from INVOICE_LINE |
|--------|------|---------|------|
| INVOICE_LINE_ID | NUMBER(12) | Surrogate PK | Same |
| INVOICE_ID | NUMBER(12) | Document reference | Same |
| LINE_NO | NUMBER(4) | Sequence within invoice | Same |
| SKU_ID | NUMBER(10) | Product reference | Same |
| QTY_CS | NUMBER(12,3) | Quantity in cases | Same |
| QTY_EA | NUMBER(12,3) | Quantity in eaches | Same |
| UNIT_PRICE | NUMBER(12,2) | Base unit price | Same |
| GROSS_AMT | NUMBER(16,2) | Line gross amount | Same |
| SCHEME_DISC_AMT | NUMBER(16,2) | Scheme discount amount | Same |
| CASH_DISC_AMT | NUMBER(16,2) | Cash discount | Same |
| TAX_AMT | NUMBER(16,2) | Tax amount | Same |
| NET_AMT | NUMBER(16,2) | Net amount | Same |
| SCHEME_ID | NUMBER(8) | Applied scheme | Same |
| CREATED_BY | VARCHAR2(30) | Creator audit column | Same |
| CREATED_TS | TIMESTAMP(6) | Creation timestamp (UTC) | Same |
| LAST_UPD_BY | VARCHAR2(30) | Last updater audit column | Same |
| LAST_UPD_DT | DATE | Last update date | Same |
| ACTIVE_FLG | CHAR(1) | Active flag | Same |
| **DELETE_FLAG** | — | **Absent** | **Not present. Never existed.** |

The archive carries **five of the six** audit columns, omitting only `LAST_UPD_BY` intentionally. This is correct by design; do not add a sixth column to make the structure "symmetrical" (DOC-01).

## Keys and constraints

No primary key, foreign key, or check constraints are defined on this table. It has no indexes.

## Relationships

- **No active relationships** in the ORION application. The table is read-only archive data.
- `INVOICE_HEADER` has no pointers to archive records; all active `INVOICE_ID` references in `INVOICE_HEADER` point to rows in the active `INVOICE_LINE` table only.

## Why DELETE_FLAG is absent

The soft-delete programme (which added `DELETE_FLAG` to transactional tables in R11.4, 30-Mar-2019) came three years **after** this archive was closed. At the time the column was added, the archive table was no longer in scope for changes.

The column was not retrofitted to the archive for two reasons:
1. Logical separation: the archive represents a fixed historical state with no ongoing deletions.
2. The table is not extracted; adding a column that serves only for CDC filtering would be pointless.

Ani explicitly documents: "do not let anybody add the sixth [column] to make it symmetrical. it is not extracted" (DOC-01). This is a deliberate structural inconsistency and should be preserved as-is.

## Extraction and use

- **Not extracted.** The nightly ODI load does not touch this table.
- **Not accessed by warehouse mappings.** All `FACT_INVOICE_LINE` data comes from the active `INVOICE_LINE` table (filtered to 01-Apr-2016 onwards).
- **Read-only for audit and support.** Historical queries that need pre-2016 data would query this table directly from ORION, not from the warehouse.

## Data-quality notes

- No profiling, quality rules, or maintenance applied since 2016.
- No documented issues or known data quality defects.
- Subject to the same CREATED_TS UTC offset noted on `INVOICE_HEADER` and `INVOICE_LINE`, but immaterial since the table is not actively used.

## Audit columns

| Column | Semantics |
|--------|-----------|
| CREATED_BY | User or process that inserted the row |
| CREATED_TS | UTC timestamp of insertion |
| LAST_UPD_BY | User or process that last modified the row; **omitted by design** |
| LAST_UPD_DT | IST date of last modification |
| ACTIVE_FLG | Active flag; semantics not documented |

## Relationship to active INVOICE_LINE table

See `/concepts/tables/oms-prod-invoice-line.md` for details on the active transactional table. The archive represents a fixed-state backup with no ongoing changes.
