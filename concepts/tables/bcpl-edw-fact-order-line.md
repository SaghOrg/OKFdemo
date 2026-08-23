---
type: warehouse-table
title: FACT_ORDER_LINE
description: Fact table recording one row per order line, capturing order quantities
  and served quantities for fill-rate analysis.
resource: BCPL_EDW.FACT_ORDER_LINE
tags:
- order
- fill-rate
- served-quantity
- fact
- FACT_ORDER_LINE
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23 10:37:25+00:00
sources:
- resource: /_sources/technical/schema_edw.sql
  id: TECH-SQL-EDW
  last_modified: '2026-08-23'
- resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
  id: DOC-01
  title: ORION OLTP schema notes
  author: Aniruddh Deshpande
  last_modified: '2026-03-03'
- resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
  id: DOC-05
  title: EDW target model notes
  last_modified: '2026-05-15'
---


## Purpose

FACT_ORDER_LINE records the order side of the order-to-cash cycle, capturing what was ordered and what was served. It feeds fill-rate and order fulfilment analysis (dashboard D06). Crucially, it does not join to FACT_INVOICE_LINE; the two facts sit beside each other sharing dimensions but must never be merged.

## Grain

**One row per order line.** ORDER_ID and ORDER_LINE_ID are carried as degenerate dimensions, identical to the pattern on FACT_INVOICE_LINE.

## Dimension Keys

- **DATE_KEY**: links to DIM_DATE; derived from ORDER_DT.
- **CUSTOMER_KEY**: links to DIM_CUSTOMER.
- **PRODUCT_KEY**: links to DIM_PRODUCT.
- **GEO_KEY**: links to DIM_GEOGRAPHY.

## Measure Columns

- **ORDER_QTY_CS**: Quantity ordered, in cases.
- **SERVED_QTY_CS**: Quantity served (invoiced), in cases. Fill rate is calculated as SERVED_QTY_CS / ORDER_QTY_CS.

## Control Columns

- **LOAD_DT**: Date the row was loaded into the warehouse.
- **BATCH_ID**: References ETL_BATCH_CONTROL; links to the load plan run.

## Constraints

- **Primary key**: ORDER_LINE_KEY.
- No other unique constraints or indexes specified in the DDL.

## Business Logic Notes

When a partial despatch occurs, the order line is not split. Instead, a separate invoice line is created against the same order line, and the remaining balance quantity remains on the order line. This means an order line may correspond to multiple invoice lines over time. Reconciliation between orders and invoices must account for this partial fulfilment pattern.

As DOC-01 notes: "when a partial despatch happens the order line is not split, the invoice line gets created against the same order line and the balance quantity is..." (sentence incomplete in source).

## Relationships

- Joins to DIM_DATE, DIM_CUSTOMER, DIM_PRODUCT, DIM_GEOGRAPHY on their respective _KEY fields.
- **Does not join to FACT_INVOICE_LINE.** These are separate facts sharing dimensions. DOC-05 emphasizes: "FACT_INVOICE_LINE is the big one and basically everything hangs off it. FACT_ORDER_LINE and FACT_SECONDARY_SALES sit beside it and share dimensions with it. They do not join to it and they should never be made to."
- Feeds dashboard D06 (Order Fulfilment and Fill Rate).

## Data Quality and Known Gaps

No data quality issues are explicitly documented for this table in the source materials. However, the partial despatch pattern noted above is a consideration for analysts: an order line with SERVED_QTY_CS less than ORDER_QTY_CS should not be treated as an "unfulfilled" order until the order line is closed. The logic for determining order completion lives in OMS_PROD.ORDER_HEADER.ORDER_STATUS, not in the fact table itself.
## Referenced by

- [Order Header (OMS_PROD.ORDER_HEADER)](/concepts/tables/oms-prod-order-header.md)
- [Order Line (OMS_PROD.ORDER_LINE)](/concepts/tables/oms-prod-order-line.md)
- [Data Architecture](/context/data-architecture.md)

