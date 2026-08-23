---
type: oltp-table
title: Order Line (OMS_PROD.ORDER_LINE)
description: Order line detail, one row per SKU per order, recording quantities in the ordering unit of measure.
resource: OMS_PROD.ORDER_LINE
tags:
  - order management
  - oltp
  - oms_prod
  - order-line
  - fill-rate
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

ORDER_LINE holds the line-level detail for each order: the SKU, quantities in the order, and audit columns. The order side feeds the fill rate reporting, which compares ordered quantities against invoiced quantities. If fill rate reporting looks anomalous, the first place to investigate is this table, not the invoice.

## Grain

One row per SKU per order. Primary key is ORDER_LINE_ID (NUMBER(12)).

## Key Columns

| Column | Type | Meaning | Notes |
|---|---|---|---|
| ORDER_LINE_ID | NUMBER(12) | Surrogate key | PK |
| ORDER_ID | NUMBER(12) | Reference to order header | FK to ORDER_HEADER; FK is enabled and enforced |
| LINE_NO | NUMBER(4) | Line sequence within order | Sequential line number |
| SKU_ID | NUMBER(10) | Reference to SKU | Foreign key to SKU_MASTER (not shown in constraints but enforced by application) |
| QTY_CS | NUMBER(12,3) | Quantity in cases | In ordering UOM; not normalized to base UOM |
| QTY_EA | NUMBER(12,3) | Quantity in eaches | In ordering UOM; not normalized to base UOM |
| CREATED_BY | VARCHAR2(30) | User ID of creator | Application audit |
| CREATED_DT | DATE | Creation date | In IST |
| LAST_UPD_BY | VARCHAR2(30) | Last updater user ID | Application audit |
| LAST_UPD_DT | DATE | Last update date | In IST. Indexed for incremental extracts. |
| ACTIVE_FLG | CHAR(1) | Active flag | Soft delete flag; NULL or 'Y' or 'N' |
| DELETE_FLAG | CHAR(1) | Deletion flag | Soft delete flag; NULL or 'Y' or 'N'. NULL means pre-2019. |

## Constraints

- **Primary key:** ORDER_LINE_ID
- **Foreign key to ORDER_HEADER:** FK_ORDLINE_ORDHDR (enabled, enforced)

## Indexes

- `IX_ORDLINE_ORD` on ORDER_ID (for join to header)
- `IX_ORDLINE_LUD` on LAST_UPD_DT (for incremental extract)

## Data Quality and Operational Notes

### Quantity Units

Both QTY_CS (cases) and QTY_EA (eaches) are populated on every line. **Neither is normalized to a base unit of measure.** The quantities are in the ordering UOM as placed by the customer. Conversion between cases and eaches (or to a canonical base UOM) happens **downstream** in the warehouse mapping, which is where repeated arguments occur about the conversion rate.

When populating the warehouse fact [/concepts/tables/bcpl-edw-fact-order-line.md](/concepts/tables/bcpl-edw-fact-order-line.md), the measures ORDER_QTY_CS and SERVED_QTY_CS must specify which UOM they use.

### Partial Despatches

When a partial despatch occurs, the order line is **not split**. If an order line is for 100 cases and 50 are invoiced now and 50 later, the order line remains as 100. Two separate invoice lines are created, each referencing this same order line with their respective quantities. This means:

- ORDER_LINE.QTY_CS = 100
- Two invoice lines each with their own QTY_CS (50 + 50)
- Sum of invoice quantities may equal or be less than order quantity

This affects fill rate logic: the warehouse must aggregate invoice quantities by order line and compare to the order quantity, accounting for partial despatches.

### No Soft Delete on Pre-2019 Data

Like all transaction tables in ORION, order lines created before April 2019 have NULL in the DELETE_FLAG column (the column was added with the GST rework in R11.4 on 30-Mar-2019, with DEFAULT 'N' applying only to new rows). Existing pre-2019 rows were not back-filled.

When filtering for active (non-deleted) lines, use: `NVL(DELETE_FLAG,'N') = 'N'`

## Relationships

- **Parent:** [/concepts/tables/oms-prod-order-header.md](/concepts/tables/oms-prod-order-header.md) (via ORDER_ID)
- **Related warehouse fact:** [/concepts/tables/bcpl-edw-fact-order-line.md](/concepts/tables/bcpl-edw-fact-order-line.md)
