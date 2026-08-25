---
type: warehouse-table
title: DIM_PRODUCT
description: SKU (stock-keeping unit) dimension with SCD2 history tracking MRP and pack changes. Includes UNKNOWN member for late-arriving products (VAR-007). Natural key is SKU_ID from ORION SKU_MASTER.
resource: BCPL_EDW.DIM_PRODUCT
tags:
  - dimension
  - scd2
  - conformed-dimension
  - product
  - sku
generated:
  by: process:claude-haiku/tables
  at: "2026-08-23T10:36:54Z"
sources:
  - resource: /_sources/technical/schema_edw.sql
    id: SCHEMA
    last_modified: "2026-08-23"
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: BCPL_EDW target model - working notes
    author: Ishaan Bhatt
    last_modified: "2026-04-08"
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION - schema notes (OLTP side)
    author: Aniruddh Deshpande
    last_modified: "2026-03-09"
---

## Purpose and grain

DIM_PRODUCT holds the master item (SKU) data from ORION. It is **slowly changing dimension type 2 (SCD2)** as of 06-May-2026. Every row represents a distinct version of a product, with effective dating capturing attribute changes.

Grain: **one row per SKU attribute version, effective-dated.**

Current population: 1,246 rows (all time). Of these, 862 are ACTIVE_FLG='Y' and are sellable today.

## Key columns

**PRODUCT_KEY** (NUMBER(10), NOT NULL, Primary Key)
- Surrogate key, meaningless, allocated from sequence.
- UNKNOWN member at PRODUCT_KEY = -1 for unmatched facts.

**SKU_ID** (NUMBER(10))
- Natural key, equals `OMS_PROD.SKU_MASTER.SKU_ID`.

**SKU_CODE** (VARCHAR2(30))
- Business code for the product.

**SKU_DESC** (VARCHAR2(200))
- Long description, printed on legacy OBIEE reports. Contains edits like '(NEW PACK)' made by the brand team. Not normalized; do not parse.

## Product classification

**BRAND_CODE** (VARCHAR2(10)), **BRAND_NAME** (VARCHAR2(60))
- Brand codes are restricted to six values only, no exceptions:
  - SUV (Suvarn)
  - NMB (Nimbua)
  - KSG (Kesari Gold)
  - CHD (Chandanaa)
  - TRG (Tarang)
  - RKS (Rakshak)
- If a seventh brand code appears in an extract, the extract—not ORION—has an error.

**CATEGORY_CODE** (VARCHAR2(10)), **CATEGORY_NAME** (VARCHAR2(60))
- CATEGORY_CODE is nullable; 37 rows have NULL since the 2016 ORION migration.
- This null population has never been remediated because the ORION application front end does not use the column.
- Expect DQ profiling runs to flag this repeatedly. It is not an error; it is a standing data quality caveat.

## Product specification

**PACK_SIZE** (VARCHAR2(20))
- Free-text field. Examples: '500 g', '4x100 g'. Do not attempt to parse it as a numeric value.

**UOM** (VARCHAR2(5))
- Unit of measure, restricted to: EA (eaches), CS (cases), KG, LT (litres).
- Values are check-constrained in ORION.

**MRP_AMT** (NUMBER(12,2))
- Maximum retail price. **MRP revisions are the primary driver of SCD2 churn on this dimension.** More MRP changes than any other attribute.

**HSN_CODE** (VARCHAR2(10))
- Harmonized System of Nomenclature (tax code). Held as a string to preserve leading zeros. Example: '0902' for tea.
- HSN_CODE is the join key for tax rate lookup to [/concepts/tables/bcpl-edw-dim-tax-rate.md](DIM_TAX_RATE).
- Any changes to the tax model must flow through this dimension, not around it.

## Product status

**ACTIVE_FLG** (CHAR(1))
- 'Y' = currently sellable, 'N' = discontinued but historical data is valid.
- A discontinued SKU (ACTIVE_FLG='N') is NOT deleted; its history remains.

## Effective dating and history

**EFF_START_DT** (DATE)
- Date this version of the SKU became effective.

**EFF_END_DT** (DATE)
- Date this version ended (NULL for the current row).

**CURRENT_FLG** (CHAR(1))
- 'Y' for the active version, 'N' for historical versions.

## Audit columns

**LOAD_DT** (DATE)
- Date the row was loaded into the warehouse.

## Constraints and indexes

- **Primary Key**: PRODUCT_KEY (NOT NULL)
- **Index**: `IX_DIMPROD_NK` on (SKU_ID, CURRENT_FLG) for efficient current-row lookups.

## Relationships

DIM_PRODUCT is a **conformed dimension** shared by:
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](FACT_INVOICE_LINE)
- [/concepts/tables/bcpl-edw-fact-order-line.md](FACT_ORDER_LINE)
- [/concepts/tables/bcpl-edw-fact-secondary-sales.md](FACT_SECONDARY_SALES)

All facts join on PRODUCT_KEY. HSN_CODE on this table is the natural key for joining to tax rates.

## Variance linkage

### VAR-007 — Late-arriving dimensions

**Status**: Open  
**Severity**: Medium  
**Root cause**: When a SKU is invoiced before MAP_DIM_PRODUCT has been loaded with that SKU, the fact row has no matching PRODUCT_KEY. The mapping routes such rows to PRODUCT_KEY = -1 (UNKNOWN) as a fallback.

**Impact**: 2.0% of invoiced volume. Average 8,140 lines per month, peak 11,902 in Jan-2026. These rows are unbillable to customers and unmeasurable to finance.

**Example**: A new pack size is sold before the SKU master is updated.

**Fix**: Open. Requires late-arriving dimension handling logic in the mapping—deferring delivery until source has the dimension, or building a catch-up merge.

See [/concepts/variances/var-007-late-arriving-sku-unknown-member.md](/concepts/variances/var-007-late-arriving-sku-unknown-member.md).

### Indirect linkage: VAR-006 — Tax rate changes

TAX_RATE_MASTER (the old tax table without effective dating) was replaced by [/concepts/tables/bcpl-edw-dim-tax-rate.md](DIM_TAX_RATE) on 26-Aug-2026 under CHG0021339. Tax lookups now flow through DIM_PRODUCT.HSN_CODE. See [/concepts/variances/var-006-tax-rate-retroactive.md](/concepts/variances/var-006-tax-rate-retroactive.md).

## Data quality considerations

- **Null CATEGORY_CODE**: 37 rows affected. Standing issue, not an error.
- **Pack size is text**: Cannot be parsed as a number. Free-text field.
- **Brand codes constrained**: Only six allowed values. Extract validation should check for others.
- **Active flag semantics**: ACTIVE_FLG='N' means discontinued, not deleted. Historical data is valid.

## Load strategy

From DOC-05: "MRP revisions drive most of the version churn. Nothing else on it moves anywhere near as often."

SCD2 updates are measured and budgeted against the nightly load window. Any changes to the dimension definition require performance validation on DEV before deployment to PROD.

## Known issues from prose

From DOC-01 (Ani Deshpande): 
- SKU_MASTER has 1,246 rows total, 862 with ACTIVE_FLG='Y' (sellable).
- Brand codes are hardcoded check-constrained to six values.
- CATEGORY_CD null on 37 rows since 2016 migration, unfixed because the front end does not use it.
- PACK_SIZE is free text; no parsing.
- HSN_CODE held as VARCHAR2(10) to preserve leading zeros (e.g., '0902' for tea).

From DOC-05: "HSN_CODE living here matters more than it looks, because the tax rate lookup keys off HSN, so anything we end up doing about tax has to come back through this dim and not around the side of it."

## SCD2 change history

Proposed SCD1 on 14-Apr-2026 (ADR-003) but superseded to remain SCD2 to preserve history for product costing and trend analysis. SCD2 was confirmed on 06-May-2026.


## Related variances

- **[VAR-007 — Late-arriving SKUs to UNKNOWN member](/concepts/variances/var-007-late-arriving-sku-unknown-member.md)**: the PRODUCT_KEY = -1 UNKNOWN-member issue, described in full above under Variance linkage.
- **[VAR-006 — GST rate change mishandled](/concepts/variances/var-006-tax-rate-retroactive.md)**: indirect — DIM_PRODUCT.HSN_CODE is the join key into the tax rate tables DIM_TAX_RATE replaced after this variance.

## Referenced by

- [Data Architecture](/context/data-architecture.md)

## Related decisions

- [DIM_PRODUCT proposed as SCD1 (overwrite, no history)](/decisions/20260414-dim-product-scd1-proposed.md)
- [ADR-003 — DIM_PRODUCT keeps history (SCD2), reversing the April position](/decisions/20260506-dim-product-scd2.md)
