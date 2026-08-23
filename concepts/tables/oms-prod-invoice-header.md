---
type: oltp-table
title: OMS_PROD.INVOICE_HEADER
description: Master invoice record for all document types (invoices, SCN, SMP). One row per invoice issued.
resource: OMS_PROD.INVOICE_HEADER
tags:
  - invoice
  - header
  - master
  - transaction
  - otp
  - created_ts
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP Schema Notes
    author: Aniruddh Deshpande
    last_modified: "2026-03-01"
  - resource: /_sources/technical/schema_oltp.sql
    id: SCHEMA
    title: ORION / BCPL_EDW DDL extract
    last_modified: "2026-03-15"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:03Z
---

## Purpose and grain

`INVOICE_HEADER` contains the master record for every invoice, credit note, and service memorandum issued by BCPL. One row per document. The table records the header totals and key routing information (customer, depot); line items are in `INVOICE_LINE`.

## Key columns and meaning

| Column | Type | Meaning | Notes |
|--------|------|---------|-------|
| **INVOICE_ID** | NUMBER(12) | Surrogate PK | System-generated sequence number |
| **INVOICE_NO** | VARCHAR2(20) | Business key | Document number visible to the customer; uniquely indexed |
| **INVOICE_DT** | DATE | Business date | IST. This is the date a user would see on the invoice. **Do not use `CREATED_TS` for business reporting.** |
| CUST_ID | NUMBER(10) | Customer reference | Foreign key to `CUSTOMER` master |
| DEPOT_CD | VARCHAR2(12) | Issuing depot | Reference to depot master |
| DOC_TYPE | VARCHAR2(4) | Document type code | Constrained: `INV` (invoice), `STN` (credit note), `SMP` (service memo) |
| TOTAL_GROSS_AMT | NUMBER(16,2) | Header gross amount | INR, pre-discount |
| TOTAL_NET_AMT | NUMBER(16,2) | Header net amount | INR, post-discount and tax |
| INVOICE_STATUS | VARCHAR2(20) | Processing status | Codes not enumerated in DDL |
| CREATED_TS | TIMESTAMP(6) | Application write timestamp | **Written by the app server in UTC, not IST.** This is not a business date and should not be used for reporting. See VAR-002. No index exists on this column; that omission was part of why the mapping's reliance on it went undetected. |
| ORDER_ID | NUMBER(12) | Associated order | FK to `ORDER_HEADER`, nullable |
| ACTIVE_FLG | CHAR(1) | Active flag | Semantics not documented |
| DELETE_FLAG | CHAR(1) | Soft-delete flag | Values: `Y` (deleted), `N` (active), NULL (pre-30-Mar-2019). Added in release R11.4 on 30-Mar-2019 and **not back-filled**, so NULL represents a mix of genuinely-deleted rows and rows created before the column existed. |

## Keys and constraints

| Constraint | Type | Columns | Notes |
|------------|------|---------|-------|
| PK_INVOICE_HEADER | Primary key | INVOICE_ID | Surrogate |
| UX_INVHDR_NO | Unique index | INVOICE_NO | Business key; uniquely indexed |
| CK_INVHDR_DOCTYPE | Check | DOC_TYPE | Enforces ('INV', 'STN', 'SMP') |
| CK_INVHDR_DEL | Check | DELETE_FLAG | Enforces ('Y', 'N') but does not enforce NULL |
| IX_INVHDR_DT | Index | INVOICE_DT | Business date index |
| IX_INVHDR_CUST | Index | CUST_ID, INVOICE_DT | Composite for customer + period queries |
| IX_INVHDR_LUD | Index | LAST_UPD_DT | Update audit tracking |

## Relationships

- **Foreign key to** `/concepts/tables/oms-prod-customer.md` via CUST_ID
- **Foreign key to** `/concepts/tables/oms-prod-order-header.md` via ORDER_ID (optional)
- **Reverse foreign key from** `/concepts/tables/oms-prod-invoice-line.md` via INVOICE_ID (mandatory, enforced)
- **Reverse foreign key from** `/concepts/tables/oms-prod-credit-note.md` via ... (related concept to be confirmed)

## Known data-quality issues

### VAR-002: CREATED_TS in UTC, not IST

The `CREATED_TS` column is written by the application server in UTC. Invoices raised after 18:30 IST on the last day of a month are timestamped the next calendar day, causing them to route to the wrong month in the warehouse fact table when `DATE_KEY` was derived from `CREATED_TS`. This was fixed in `CHG0021207` on 03-Jun-2026; the mapping now uses `INVOICE_DT` instead. Quote: "if you need a date for anything commercial, take INVOICE_DT. CREATED_TS is when the row got written on the app server clock and it is not local time" (DOC-01).

### DELETE_FLAG back-fill gap

`DELETE_FLAG` was added in release R11.4 on 30-Mar-2019 and was **not back-filled**. Rows created before that date carry NULL. A filter `NVL(DELETE_FLAG, 'N') = 'N'` will include pre-2019 deleted rows but exclude them if the flag is explicitly set.

### FIN_PROD UPDATE grant

FIN_PROD holds a direct UPDATE grant on `OMS_PROD.INVOICE_LINE` (not the header, but documented here as a security note). This grant was given in 2014 during scheme calculation work and has never been reviewed since. Ani notes "if you are ever sitting and wondering who all is able to change an invoice line in this database, the honest answer includes anything running as FIN_PROD" (DOC-01).

## Audit columns

| Column | Semantics |
|--------|-----------|
| CREATED_BY | User or process that inserted the row |
| CREATED_TS | UTC timestamp of insertion |
| LAST_UPD_BY | User or process that last modified the row |
| LAST_UPD_DT | IST date of last modification |

## Row count

No profiling figure is provided in the sources for the header table. The related `INVOICE_LINE` table contains 61,847,220 rows as of the 31-May-2026 profiling run, spanning data from 01-Apr-2016 onwards (earlier data is in `INVOICE_LINE_ARCHIVE`).

## Incremental extract

Mappings use `LAST_UPD_DT` as the CDC (change-data-capture) predicate for the nightly load.

## Discrepancy

The prose description in DOC-01 refers to the business key as **"INVOICE_NUM"**, but the schema DDL defines it as **"INVOICE_NO"**.

**DDL statement (schema_canon.sql):**
```
INVOICE_NO VARCHAR2(20) NOT NULL,
...
CREATE UNIQUE INDEX OMS_PROD.UX_INVHDR_NO ON OMS_PROD.INVOICE_HEADER (INVOICE_NO) TABLESPACE OMS_IDX;
```

**Prose statement (DOC-01):**
> "INVOICE_ID is the PK. INVOICE_NUM is the document number and it is unique, index UX_INVHDR_NO."

The index name `UX_INVHDR_NO` could reasonably abbreviate either name. The DDL is authoritative; the column is named `INVOICE_NO`, not `INVOICE_NUM`. Ani's description aligns functionally (unique business key) but uses a different column name.

## Related variances

- **[VAR-002 — Month-end boundary drift](/concepts/variances/var-002-date-key-timezone.md)**: CREATED_TS (UTC) vs INVOICE_DT (IST), described above under Known data-quality issues.

## Referenced by

- [Data Architecture](/context/data-architecture.md)

## Related decisions

- [ADR-005 — DATE_KEY on FACT_INVOICE_LINE derived from INVOICE_DT, not CREATED_TS](/decisions/20260506-var002-date-key-fix.md)
