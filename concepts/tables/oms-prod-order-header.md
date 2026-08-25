---
type: oltp-table
title: Order Header (OMS_PROD.ORDER_HEADER)
description: Source order header records holding the master data for each order placed with BCPL.
resource: OMS_PROD.ORDER_HEADER
tags:
  - order management
  - oltp
  - oms_prod
  - order
generated:
  by: process:claude-haiku/tables
  at: "2026-08-23T10:37:15Z"
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP Schema Notes
    last_modified: "2026-08-22"
  - resource: /_sources/technical/schema_oltp.sql
    id: schema-canon
    title: ORION Schema DDL
    last_modified: "2026-08-22"
---

## Purpose

ORDER_HEADER is the master table for order-to-cash transactions in ORION. It records each order placed by a customer with the depot, order date, and current status. The order side feeds the fill rate reporting and reconciliation of committed vs. invoiced volumes.

## Grain

One row per order. Primary key is ORDER_ID (NUMBER(12)).

## Key Columns

| Column | Type | Meaning | Notes |
|---|---|---|---|
| ORDER_ID | NUMBER(12) | Surrogate key | PK |
| ORDER_NO | VARCHAR2(20) | Business order number | The number as seen by the customer |
| ORDER_DT | DATE | Date order was placed | In IST; used for fiscal period assignment |
| CUST_ID | NUMBER(10) | Reference to customer | FK to CUSTOMER table; see discrepancy section |
| DEPOT_CD | VARCHAR2(12) | Receiving depot code | Delivery point, e.g. DEP-MUM-01 |
| ORDER_STATUS | VARCHAR2(20) | Current order status | Overwritten in place; no history |
| CREATED_BY | VARCHAR2(30) | User ID of creator | Application audit |
| CREATED_TS | TIMESTAMP(6) | Creation timestamp | **WARNING: Written in UTC**, not IST. See data quality notes. |
| LAST_UPD_BY | VARCHAR2(30) | Last updater user ID | Application audit |
| LAST_UPD_DT | DATE | Last update date | In IST. Indexed for incremental extract. |
| ACTIVE_FLG | CHAR(1) | Active flag | Soft delete flag; NULL or 'Y' or 'N' |
| DELETE_FLAG | CHAR(1) | Deletion flag | Soft delete flag; NULL or 'Y' or 'N'. NULL means pre-2019. |

## Constraints

- **Primary key:** ORDER_ID
- **Foreign key to ORDER_LINE:** enabled (the reverse FK from ORDER_LINE.ORDER_ID is enabled and enforced)
- **Foreign key to CUSTOMER:** **DISABLED** since 2020 during master data cleanup and never re-enabled. See discrepancy section.

## Indexes

- `IX_ORDHDR_DT` on ORDER_DT
- `IX_ORDHDR_LUD` on LAST_UPD_DT (used for incremental extract predicate)

## Data Quality and Operational Notes

### Order Status History

ORDER_STATUS is overwritten in place. There is **no status history table** anywhere in ORION. If a query asks "when did this order move from status X to status Y?", the database cannot answer it. The application log may have it, but logs are rolled over. See [VAR-003](/concepts/variances/var-003-scheme-discount-double-count.md) for implications for reconciliation.

### Partial Despatches

When a partial despatch occurs, the order line is **not split**. Instead, a separate invoice line is created against the same order line, with the balance quantity remaining on the order. This affects reconciliation of order quantities against invoice quantities.

### CREATED_TS Timezone Issue

The CREATED_TS column is TIMESTAMP(6) and is written by the application server in **UTC time, not IST**. This is a structural issue that has been in place since the system was built in 2009 and cannot be easily changed (nine years of data in UTC). The business date for order is ORDER_DT (which is DATE, not TIMESTAMP).

All other date columns (ORDER_DT, LAST_UPD_DT) are in IST.

## Relationships

- **Parent:** CUSTOMER (via CUST_ID, but FK is disabled)
- **Child:** [/concepts/tables/oms-prod-order-line.md](/concepts/tables/oms-prod-order-line.md) (via ORDER_ID)
- **Related warehouse fact:** [/concepts/tables/bcpl-edw-fact-order-line.md](/concepts/tables/bcpl-edw-fact-order-line.md)

## Discrepancy

**FK to CUSTOMER is disabled, but the source suggests orphan rows exist.**

DOC-01 states: "the foreign key from ORDER_HEADER to CUSTOMER was disabled in 2020 during the master data cleanup and never enabled back. i still have the enable script. it will fail today because there are orphan rows in there from the cleanup itself, which is a nice circle."

The DDL shows the FK as commented out with the note: "The FK to CUSTOMER was disabled in 2020 during the master data cleanup and never re-enabled".

This means CUST_ID values in ORDER_HEADER may not have a matching CUSTOMER record. The warehouse mapping must account for this: if it is joining on CUST_ID and dropping non-matches, that is already handling it quietly. **Recommendation:** Verify in the mapping whether orphaned orders are being dropped or routed to a placeholder customer key.

## Related variances

- **[VAR-003 — Scheme discount double-count](/concepts/variances/var-003-scheme-discount-double-count.md)**: referenced above for the general point that ORION order/invoice status changes are not history-tracked, which is part of why reconciliation problems like VAR-003 are hard to trace after the fact.

## Referenced by

- [Data Architecture](/context/data-architecture.md)
