---
type: oltp-table
title: Scheme Master (OMS_PROD.SCHEME_MASTER)
description: Master table of promotional schemes applied to invoice lines, holding discount calculations, slab definitions, and validity windows.
resource: OMS_PROD.SCHEME_MASTER
tags:
  - schemes
  - promotions
  - oltp
  - oms_prod
  - discount
  - trade-promotion
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:15Z
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP Schema Notes
    last_modified: "2026-08-22"
  - resource: /_canon/schema_canon.sql
    id: schema-canon
    title: ORION Schema DDL
    last_modified: "2026-08-22"
---

## Purpose

SCHEME_MASTER holds the universe of promotional schemes (also called trade promotions or TPR by Vikram, scheme discounts by Shalini, or "secondary schemes" in the warehouse ETL). The table defines the discount structure, slab bands, validity windows, and scheme type for each active promotion.

This is a **small table**: five live rows as of the engagement period (FY26-FY27):
- 5501 QPS-Q1-SUV
- 5514 MTH-CHD-OCT
- 5522 SLB-TRG-FEST
- 5533 TPR-NMB-SOUTH
- 5540 QPS-KSG-H2

## Grain

One row per scheme. Primary key is SCHEME_ID (NUMBER(8)).

## Key Columns

| Column | Type | Meaning | Notes |
|---|---|---|---|
| SCHEME_ID | NUMBER(8) | Surrogate key | PK |
| SCHEME_CODE | VARCHAR2(30) | Business code | Mnemonic identifier (e.g. 'QPS-Q1-SUV') |
| SCHEME_NAME | VARCHAR2(120) | Display name | Full descriptive name of the scheme |
| SCHEME_TYPE | VARCHAR2(10) | Type of calculation | QPS, MONTHLY, SLAB, or TPR (check constrained) |
| DISC_PCT | NUMBER(6,3) | Discount percentage | For non-slab schemes, the discount % applied. Can be null for slab schemes. |
| SLAB_QTY_FROM | NUMBER(12,3) | Slab lower bound | For SLAB type only; quantity threshold from which discount applies |
| SLAB_QTY_TO | NUMBER(12,3) | Slab upper bound | For SLAB type only; quantity threshold up to which discount applies |
| VALID_FROM_DT | DATE | Validity start | Date from which scheme is active |
| VALID_TO_DT | DATE | Validity end | Date after which scheme is inactive. **See data quality notes.** |
| CREATED_BY | VARCHAR2(30) | User ID of creator | Application audit |
| CREATED_DT | DATE | Creation date | In IST |
| LAST_UPD_BY | VARCHAR2(30) | Last updater user ID | Application audit |
| LAST_UPD_DT | DATE | Last update date | In IST. Indexed for lookups. |
| ACTIVE_FLG | CHAR(1) | Active flag | Soft delete flag; NULL or 'Y' or 'N' |
| DELETE_FLAG | CHAR(1) | Deletion flag | Soft delete flag; NULL or 'Y' or 'N' |

## Constraints

- **Primary key:** SCHEME_ID
- **Check constraint:** `CK_SCHEME_TYPE` — SCHEME_TYPE IN ('QPS','MONTHLY','SLAB','TPR')

## Indexes

- `IX_SCHEME_VALID` on (VALID_FROM_DT, VALID_TO_DT) — used for scheme lookups by date

## Data Quality and Operational Notes

### Scheme Types

Four types of schemes are defined in the check constraint:

- **QPS** — Quantity Point Scheme (probably; the name is not formally defined in the corpus)
- **MONTHLY** — Monthly promotion
- **SLAB** — Quantity slab scheme; uses SLAB_QTY_FROM and SLAB_QTY_TO to define the slab bands
- **TPR** — Trade Promotion Rebate

For SLAB type schemes, SLAB_QTY_FROM and SLAB_QTY_TO define the quantity band. For other types, these columns are typically null.

DISC_PCT contains the discount percentage and applies to most scheme types. For slab-based schemes, the discount percentage may be null if the slab itself is the primary lookup key.

### Retrospective Validity Window Closure

**This is a critical operational characteristic:** Validity windows get closed **retrospectively**. That is, the commercial team:

1. Sets VALID_TO_DT to a date that is **already in the past** at the time the update is made
2. Does this at month-end when a scheme is being withdrawn
3. This occurs **after invoices have already been raised within that validity window**

Example: Scheme 5514 MTH-CHD-OCT is valid from 01-Oct through 31-Oct. Invoices are raised on 15-Oct. On 02-Nov, the commercial team closes the scheme by setting VALID_TO_DT to 31-Oct (already past).

**Consequence for warehouse:** A lookup done by invoice date against VALID_FROM_DT and VALID_TO_DT may **fail to find a scheme which was very much in effect at the time the invoice was raised**. For example:
- Invoice raised on 15-Oct with SCHEME_ID = 5514
- At ETL time, a join from invoice to SCHEME_MASTER using invoice date between VALID_FROM_DT and VALID_TO_DT may not find the row if the date range has already been closed

This is not a defect; it is how the business operates. The correct behavior is to:
- **Treat a scheme lookup miss as a normal case, not an error**
- Prefer the SCHEME_ID on the invoice line itself (see `SCHEME_ID` in [/concepts/tables/oms-prod-invoice-line.md](/concepts/tables/oms-prod-invoice-line.md))
- Use the SCHEME_MASTER only for enrichment (scheme name, type, calculation details)

See also [VAR-007](/concepts/variances/var-007-late-arriving-sku-unknown-member.md) for related late-arriving dimension issues.

### Applied Scheme Recording

There is **no separate table** recording which scheme was applied to each invoice line. The schema is:
- `INVOICE_LINE.SCHEME_ID` — the ID of the scheme applied (if any)
- `INVOICE_LINE.SCHEME_DISC_AMT` — the discount amount resulting from that scheme

One line, one scheme. If multiple schemes could apply to a single line, the commercial team decides offline (typically in a spreadsheet) which one wins, and only the winning scheme reaches the database. The decision and deliberation process is not recorded.

On the finance side, `FIN_PROD.SCHEME_ACCRUAL` provides an accrual view of scheme discounts:
- Grain: CUST_ID, SCHEME_ID, PERIOD_YYYYMM
- Does NOT tie line-by-line to invoice lines
- Should not be expected to reconcile at line level with invoice SCHEME_DISC_AMT

## Relationships

- **Referenced by:** [/concepts/tables/oms-prod-invoice-line.md](/concepts/tables/oms-prod-invoice-line.md) via SCHEME_ID
- **Accrual counterpart:** FIN_PROD.SCHEME_ACCRUAL (not in OMS_PROD; exists in FIN_PROD, period-grain accrual)
- **Warehouse dimension:** [/concepts/tables/bcpl-edw-dim-scheme.md](/concepts/tables/bcpl-edw-dim-scheme.md)

## Vocabulary

Referred to variously as:
- **Scheme** or **scheme discount** (Ani, Karthik, Neha, Ananya, Sneha)
- **Secondary scheme** (Farida, warehouse ETL)
- **Trade Promotion Accrual** or **TPR** (Shalini, Finance)
- **TPR** or **secondary scheme** (Vikram, Sales)
- **Promo accrual** (Marijke, Wei Lin, Group Finance)

All refer to the same entity: promotional discounts applied at the line level on invoices, sourced from SCHEME_MASTER and INVOICE_LINE.

## Related variances

- **[VAR-007 — Late-arriving SKUs to UNKNOWN member](/concepts/variances/var-007-late-arriving-sku-unknown-member.md)**: referenced above under Relationships.
- **[VAR-003 — Scheme discount double-count](/concepts/variances/var-003-scheme-discount-double-count.md)**: SCHEME_MASTER slab definitions are what FIN_PROD.PKG_MONTH_END.P_RECALC_SCHEME_DISCOUNT reads when it recomputes entitlement; the defect is in how that recomputation is written back to OMS_PROD.INVOICE_LINE, not in this table.
