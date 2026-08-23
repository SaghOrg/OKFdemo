---
type: warehouse-table
title: FACT_SECONDARY_SALES
description: Fact table of distributor-to-retailer sales (off-take) from the DMS feed,
  with structural incompleteness as a key caveat.
resource: BCPL_EDW.FACT_SECONDARY_SALES
tags:
- secondary-sales
- off-take
- distributor-sales
- DMS
- fact
- FACT_SECONDARY_SALES
- incomplete-feed
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23 10:37:25+00:00
sources:
- resource: /_sources/technical/schema_edw.sql
  id: TECH-SQL-EDW
  last_modified: '2026-08-23'
- resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
  id: DOC-05
  title: EDW target model notes
  last_modified: '2026-05-15'
---


## Purpose

FACT_SECONDARY_SALES captures distributor sell-through data—the sales of BCPL's products by distributors to retailers. This is off-take or "secondary sales," distinct from primary sales (BCPL billing the distributor). The feed comes from the DMS (Distributor Management System) upload and is structurally incomplete.

## Grain and Source

One row per distributor per SKU per day, as uploaded via the DMS feed. The load runs at 04:00 IST as part of LP_SECONDARY_UPLOAD. The feed frequently arrives empty (no file).

## Caveat: Structural Incompleteness

**This feed is not comprehensive.** DOC-05 states:

> The caveat that has to travel with this fact wherever it goes: the feed covers roughly 74% of distributors and it lags around five days. So it is structurally incomplete, and it is never going to tie back to the invoice fact, and it should not be put next to the invoice fact in a way that invites somebody to try. Also, and this one keeps coming back, primary sales and secondary sales are not the same measure. Primary is BCPL billing the distributor. Secondary is the distributor selling on to the retailer. Only the first of those is revenue.

**These properties are intentional trade-offs, not defects:**

- 74% distributor coverage (not 100%) reflects upload participation and scope.
- 5-day lag reflects DMS batch cycle times.
- Primary and secondary sales measure different things; they should never be joined on CUSTOMER_KEY or DATE_KEY to "reconcile."
- **Do not join this fact to FACT_INVOICE_LINE.** They sit beside each other but share no grain.

## Dimension Keys

- **DATE_KEY**: links to DIM_DATE.
- **CUSTOMER_KEY**: links to DIM_CUSTOMER (the distributor, not the end retailer).
- **PRODUCT_KEY**: links to DIM_PRODUCT.
- **GEO_KEY**: links to DIM_GEOGRAPHY.

## Measure Columns

- **QTY_CS**: Quantity sold by distributor, in cases.
- **VALUE_AMT**: Value of the sale.

## Control Columns

- **SRC_FILE_NM**: Name of the DMS upload file from which this row was loaded; aids traceability.
- **LOAD_DT**: Date the row was loaded into the warehouse.
- **BATCH_ID**: References ETL_BATCH_CONTROL.

## Constraints

- **Primary key**: SECONDARY_KEY.
- No other unique constraints or indexes specified.

## Relationships

- Joins to DIM_DATE, DIM_CUSTOMER, DIM_PRODUCT, DIM_GEOGRAPHY on their respective _KEY fields.
- **Does not join to FACT_INVOICE_LINE or FACT_ORDER_LINE.** All three facts share dimensions but are separate.
- Feeds dashboard D02 (Secondary Sales Coverage) — though D02 was dropped from the final nine-dashboard scope at go-live.

## Vocabulary

Vikram Sethi uses "secondary" and "secondary scheme" loosely for any promotional activity on the distributor side. Wei Lin Tan uses "sell-out" for secondary sales (in contrast to "sell-in" for primary sales). The formal definition here is: off-take data from the DMS feed.

## Usage Guidance

Any analysis comparing primary and secondary sales must be explicit about the incompleteness: "Primary sales (FACT_INVOICE_LINE) cover 100% of BCPL billing; secondary sales (FACT_SECONDARY_SALES) cover ~74% of distributors with a ~5-day lag." Analysts often encounter Vikram's numbers moving because his shadow workbook (BCPL_reco_Aug26_vikram_v3.xlsx) pulls from the DMS feed and is subject to the same latency.
## Referenced by

- [Data Architecture](/context/data-architecture.md)
- [Open question — stockist-level drill-down on every dashboard page](/decisions/20260805-dashboard-stockist-drilldown-unresolved.md)

