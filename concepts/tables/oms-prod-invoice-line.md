---
type: oltp-table
title: OMS_PROD.INVOICE_LINE
description: Line-item detail for all invoices, credit notes, and service memos. Contains quantities, pricing, and scheme discounts.
resource: OMS_PROD.INVOICE_LINE
tags:
  - invoice
  - line
  - detail
  - transaction
  - quantities
  - discount
  - scheme
  - oltp
  - var-001
  - var-003
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
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: EDW Target Model Notes
    last_modified: "2026-05-10"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:03Z
---

## Purpose and grain

`INVOICE_LINE` contains the line-item detail for every invoice, credit note, and service memorandum issued by BCPL. One row per SKU per document. Quantities are recorded in two units of measure (cases and eaches). The table carries pricing, all discount and tax components, and the applied scheme.

Grain: **one row per SKU per invoice**.

## Row count and scope

**61,847,220 rows** as of the 31-May-2026 profiling run. Contains data from 01-Apr-2016 onwards. Earlier line items are in `INVOICE_LINE_ARCHIVE`. Average of 21,400 new rows per nightly load (range 6,200 on Sundays to 48,900 on month-end nights).

## Key columns and meaning

| Column | Type | Meaning | Notes |
|--------|------|---------|-------|
| **INVOICE_LINE_ID** | NUMBER(12) | Surrogate PK | System-generated, never reused |
| **INVOICE_ID** | NUMBER(12) | Document reference | FK to `INVOICE_HEADER.INVOICE_ID`; **this FK is enabled** (rare, most FKs in ORION are disabled) |
| **SKU_ID** | NUMBER(10) | Product reference | FK to `SKU_MASTER` |
| **LINE_NO** | NUMBER(4) | Sequence within invoice | Sequential per invoice, 1, 2, 3, … |
| **QTY_CS** | NUMBER(12,3) | Quantity ordered | Cases (not normalised to base UOM) |
| **QTY_EA** | NUMBER(12,3) | Quantity ordered | Individual eaches (not normalised to base UOM). **Note:** The warehouse receives these in two separate columns and must manage UOM conversion downstream, which is "a recurring source of arguments" (DOC-05). |
| **UNIT_PRICE** | NUMBER(12,2) | Base unit price | INR per unit (UOM not specified in DDL) |
| **GROSS_AMT** | NUMBER(16,2) | Line gross amount | INR before discount and tax |
| **SCHEME_DISC_AMT** | NUMBER(16,2) | Scheme discount amount | INR. **Rewritten additively by month-end processes.** See VAR-003. The applied scheme code is in SCHEME_ID; no historical audit of scheme calculations is recorded. |
| **CASH_DISC_AMT** | NUMBER(16,2) | Cash discount | INR early-payment or other term discount |
| **TAX_AMT** | NUMBER(16,2) | Tax amount | INR GST or other tax applied |
| **NET_AMT** | NUMBER(16,2) | Net amount | INR after all discounts and tax |
| **SCHEME_ID** | NUMBER(8) | Applied scheme | FK to `SCHEME_MASTER` (or NULL). **One line, one scheme.** If multiple schemes could apply, the business decides offline in a spreadsheet, and only the winner is recorded here. The decision process is not audited anywhere in ORION. |
| **CREATED_TS** | TIMESTAMP(6) | Application write timestamp | Written by app server in UTC (see VAR-002 on `INVOICE_HEADER`) |
| **LAST_UPD_DT** | DATE | Last update date | IST. The nightly ODI load uses this column as the CDC predicate for incremental extraction. |
| **ACTIVE_FLG** | CHAR(1) | Active flag | Semantics not documented |
| **DELETE_FLAG** | CHAR(1) | Soft-delete flag | Values: `Y` (deleted), `N` (active), NULL (pre-30-Mar-2019). Added in release R11.4 on 30-Mar-2019 and **not back-filled**. A mapping with no DELETE_FLAG filter will double-count cancelled lines as revenue (VAR-001). |

## Keys and constraints

| Constraint | Type | Columns | Notes |
|------------|------|---------|-------|
| PK_INVOICE_LINE | Primary key | INVOICE_LINE_ID | Surrogate |
| FK_INVLINE_INVHDR | Foreign key | INVOICE_ID → INVOICE_HEADER.INVOICE_ID | **This FK is enabled** (enforced). Cascading delete is not set. |
| CK_INVLINE_DEL | Check | DELETE_FLAG | Enforces ('Y', 'N') but does not enforce NULL |
| IX_INVLINE_INV | Index | INVOICE_ID | Join efficiency |
| IX_INVLINE_SKU | Index | SKU_ID | SKU lookups and join efficiency |
| IX_INVLINE_LUD | Index | LAST_UPD_DT | CDC predicate index for the nightly load |

## Relationships

- **Foreign key to** `/concepts/tables/oms-prod-invoice-header.md` via INVOICE_ID (mandatory, enforced)
- **Foreign key to** `/concepts/tables/oms-prod-sku-master.md` via SKU_ID
- **Foreign key to** `/concepts/tables/oms-prod-scheme-master.md` via SCHEME_ID (optional, nullable)
- **Reverse foreign key from** `BCPL_EDW.FACT_INVOICE_LINE` (warehouse fact table)

## Known data-quality issues

### VAR-001: DELETE_FLAG not filtered

The mapping `MAP_FACT_INVOICE_LINE` originally had no filter on `DELETE_FLAG`, so cancelled invoices and individual cancelled line items were counted as revenue in FY26 Q1. This caused the FY26 Q1 revenue to be overstated. The fix was deployed in `CHG0021184` on 03-Jun-2026; the mapping now filters `NVL(DELETE_FLAG, 'N') = 'N'`.

The column itself is unavailable for rows created before 30-Mar-2019 (NULL means "created before the column existed OR explicitly deleted"), and this is by design (see `/concepts/variances/var-001.md`).

### VAR-003: SCHEME_DISC_AMT rewritten additively by month-end processes

The `SCHEME_DISC_AMT` column is rewritten during the month-end close by FIN_PROD procedures. The rewrites are **additive** — they modify existing values rather than replacing them. This means:
1. The scheme discount amount on a line may not equal the discount applied at transaction time.
2. There is no audit trail of the calculation.
3. A fact extract taken mid-close and one taken post-close may show different values.

No reconciliation between the calculated discount and the actual cash effect is recorded in ORION. Finance nets credit notes in Excel outside the warehouse (VAR-005). Quote from Ani: "the SCHEME DISCOUNT amount you see on a line is the outcome of a decision that is not recorded anywhere in ORION" (DOC-01).

This variance remains open; see `/concepts/variances/var-003.md` for status.

### DELETE_FLAG back-fill gap

As noted on `INVOICE_HEADER`, the `DELETE_FLAG` column was added in R11.4 on 30-Mar-2019 and was not back-filled. Rows created before that date carry NULL. The filter `NVL(DELETE_FLAG, 'N') = 'N'` will treat pre-2019 rows as active, which may or may not be correct depending on whether they were logically deleted at the time.

### FIN_PROD UPDATE grant on this table

FIN_PROD holds a direct UPDATE grant on `INVOICE_LINE` (separate from its grant on the header table). This grant was given in 2014 during scheme calculation work and has never been reviewed since. Ani notes: "if you are ever sitting and wondering who all is able to change an invoice line in this database, the honest answer includes anything running as FIN_PROD, and i have never sat down and checked what is actually using that grant" (DOC-01).

### UOM conversion not normalised

Quantities are received in two columns: `QTY_CS` (cases) and `QTY_EA` (eaches). These are **not normalised to a base unit of measure**. UOM conversion happens downstream in the warehouse, and the lack of normalisation is "a recurring source of arguments" (DOC-05).

### Scheme application not audited

There is no table recording the scheme calculation logic or the decision process when multiple schemes could apply. The applied scheme code (`SCHEME_ID`) and discount amount (`SCHEME_DISC_AMT`) are captured on the line, but the reasoning is not. Per Ani: "if two schemes could apply, the business decides which one, offline, in a spreadsheet, and only the winner reaches the database" (DOC-01).

## Audit columns

| Column | Semantics |
|--------|-----------|
| CREATED_BY | User or process that inserted the row |
| CREATED_TS | UTC timestamp of insertion |
| LAST_UPD_BY | User or process that last modified the row |
| LAST_UPD_DT | IST date of last modification |

## Warehouse mapping

The warehouse mapping `MAP_FACT_INVOICE_LINE` loads this table nightly via the incremental extract on `LAST_UPD_DT`. The surrogate `INVOICE_LINE_KEY` is created in `FACT_INVOICE_LINE`; `INVOICE_ID` and `INVOICE_LINE_ID` are carried as degenerate dimensions (non-key identifiers). See `/concepts/tables/oms-prod-invoice-line.md` for the warehouse grain and key structure.
