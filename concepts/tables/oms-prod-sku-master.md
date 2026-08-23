---
type: oltp-table
title: SKU Master
description: Product master data covering codes, descriptions, pack sizes, units of measure, pricing, and tax classification for all items BCPL manufactures or distributes.
resource: OMS_PROD.SKU_MASTER
tags:
  - SKU
  - product
  - item master
  - pack size
  - UOM
  - MRP
  - HSN code
  - brand
  - category
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP Schema Notes
    author: Aniruddh Deshpande
    last_modified: "2026-03-08"
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: EDW Target Model Notes
    last_modified: "2026-05-20"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:07Z
---

## Purpose

Holds the product master data for all SKUs (Stock Keeping Units) that BCPL manufactures, distributes, or sells. Covers product codes, descriptions, packaging formats, units of measure, maximum retail price (MRP), tax classification (HSN code), brand and category. Used in order entry, invoicing, inventory, and pricing operations.

## Grain and Volume

One row per unique SKU (product variant). Rows are added as new products are introduced and marked inactive when SKUs are discontinued but never deleted (history is retained). ACTIVE_FLG = 'Y' on 862 rows as of the engagement period; total population is larger due to discontinued SKUs.

## Key Columns

**SKU_ID** (Primary Key, NUMBER(10))
Unique surrogate identifier for each SKU. Not used in business operations; operators and reports identify SKUs by SKU_CODE.

**SKU_CODE** (VARCHAR2(30), Unique)
Business-facing product code. Uniquely identifies each SKU. Enforced by unique index UX_SKU_CODE. Used in all customer-facing documents, order entry, and warehouse operations.

**SKU_DESC** (VARCHAR2(200))
Long-form product description, 200 characters maximum. Used in legacy OBIEE reports and customer-facing documents. May contain operator notes such as '(NEW PACK)' added by the brand or commercial team. **Contains editorial notes; not a system-generated field.**

**BRAND_CD** (VARCHAR2(10))
Brand code classifying the product under one of the portfolio brands. Valid values (from DDL comments): SUV, NMB, KSG, CHD, TRG, RKS. Used for brand-level rollups in reporting and operational segmentation.

**CATEGORY_CD** (VARCHAR2(10))
Product category code (e.g., HOME_CARE, PERSONAL_CARE, DAIRY, etc.). **Nullable; 37 rows have NULL in this column and have for years.** No enforcement to fill the gap; category is optional in the operational data model and the gaps are treated as "unknown category" in reporting.

## Product Format and Packaging

**PACK_SIZE** (VARCHAR2(20))
Free-form text field describing the package quantity and unit. Examples: '500 g', '4x100 g', '1 L', '10 kg'. **Do not attempt to parse this field into a number.** It is unstructured and varies by product type, and attempts to extract numeric pack size have a high failure rate. If numeric pack size is needed in reporting, it must be maintained as a separate derived column or in a supplementary table.

**UOM** (VARCHAR2(5))
Unit of Measure for the base selling unit. Captures four values: **EA (each), CS (case), KG (kilogram), LT (litre).** Note that the DDL comment lists only 'KG | LT | EA', but DOC-01 explicitly mentions 'CS' (case) as a valid UOM, indicating the DDL comment is incomplete.

**MRP** (NUMBER(12,2))
Maximum Retail Price in INR. Used in pricing logic and margin calculations. Precision to two decimals (standard for all currency).

## Tax Classification

**HSN_CODE** (VARCHAR2(10))
Harmonised System of Nomenclature code for GST and excise duty determination. Held as a VARCHAR2 string (not a number) to preserve leading zeros; e.g., tea is '0902'. Links to FIN_PROD.TAX_RATE_MASTER to determine applicable GST rate at invoice time. The effective date of HST_CODE and its tax rate is not tracked in OMS_PROD; see VAR-006 for the tax rate misdating issue.

## Lifecycle and Audit

- **CREATED_BY, CREATED_DT**: Row creation metadata. Both DATE types in IST.
- **LAST_UPD_BY, LAST_UPD_DT**: Last modification tracking. INDEX IX_SKU_LUD on LAST_UPD_DT for change tracking.
- **ACTIVE_FLG**: Business availability flag ('Y' or 'N'). A discontinued SKU is marked 'N' (not deleted) and history remains queryable. 862 rows are marked 'Y' (active); others are inactive variants or discontinued SKUs. **Do not confuse ACTIVE_FLG ('Y'/'N', business availability) with DELETE_FLAG ('Y'/'N'/'NULL', logical deletion).**
- **DELETE_FLAG**: Logical deletion marker ('Y', 'N', or NULL on rows created before 30-Mar-2019). Used to exclude logically deleted or superseded rows from transactional queries.

## Indexes

- **PK_SKU_MASTER**: PRIMARY KEY on SKU_ID
- **UX_SKU_CODE**: UNIQUE index on SKU_CODE (business key)
- **IX_SKU_LUD**: Index on LAST_UPD_DT for change tracking
- **IX_SKU_BRAND**: Composite index on (BRAND_CD, CATEGORY_CD) for brand and category rollups

## Data Quality Notes

1. **CATEGORY_CD nulls**: 37 SKUs have NULL category and have not been updated. This is a minor gap and is not flagged as a data quality variance; it is treated as "unknown category" in warehouse reporting.

2. **UOM discrepancy**: The DDL comment lists UOM values as 'KG | LT | EA' but DOC-01 explicitly states 'EA, CS, KG or LT', indicating CS (case) is in production. The DDL comment is incomplete and should be treated as illustrative, not exhaustive.

3. **ACTIVE_FLG vs. DELETE_FLAG**: The distinction between these two flags causes repeated confusion in reviews and is documented in DOC-01. ACTIVE_FLG ('Y'/'N') controls business availability (discontinued SKUs stay marked 'N' but are not deleted). DELETE_FLAG ('Y'/'N'/NULL) is logical deletion (for administrative purges or corrections). Both must be checked in filters; most reporting uses `ACTIVE_FLG='Y'` AND `NVL(DELETE_FLAG,'N')='N'`.

## Warehouse Mapping

In BCPL_EDW, SKU_MASTER is the source for the DIM_PRODUCT dimension with grain one row per SKU. The warehouse adds BRAND_NAME and CATEGORY_NAME as text translations. Natural key is SKU_ID; surrogate key is PRODUCT_KEY. The effective dating of category changes (if any) is not tracked in the warehouse; DIM_PRODUCT is a Type 1 (overwrite) dimension, not SCD2.

## Related variances

- **[VAR-007 — Late-arriving SKUs to UNKNOWN member](/concepts/variances/var-007-late-arriving-sku-unknown-member.md)**: A SKU invoiced before it appears in SKU_MASTER routes to PRODUCT_KEY = -1 (UNKNOWN) and does not resync when the SKU finally arrives. Affects 2.0% of invoiced volume, averaging 8,140 lines a month.
- **[VAR-006 — GST rate change mishandled](/concepts/variances/var-006-tax-rate-retroactive.md)**: SKU_MASTER's HSN_CODE is the join key into the (formerly non-effective-dated) tax rate tables; the misdating defect lived in the tax rate tables, not here, but this is where the join originates.

## Related Tables

- /concepts/tables/oms-prod-invoice-line.md (SKU_ID links line items to products)
- /concepts/tables/oms-prod-order-line.md (SKU_ID links order lines to products)
- /concepts/tables/oms-prod-credit-note-line.md (SKU_ID links credit note lines to products)
- /concepts/tables/oms-prod-scheme-master.md (schemes apply to SKUs via SCHEME_ID on invoices)
