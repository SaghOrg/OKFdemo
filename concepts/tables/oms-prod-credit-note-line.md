---
type: oltp-table
title: Credit Note Line
description: Detail line items for credit notes, mapping SKUs and amounts to parent credit note headers.
resource: OMS_PROD.CREDIT_NOTE_LINE
tags:
  - credit note
  - CN
  - credit note lines
  - line items
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP Schema Notes
    author: Aniruddh Deshpande
    last_modified: "2026-03-08"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:07Z
---

## Purpose

Holds the detail line items for each credit note, mapping affected SKUs, quantities, amounts, and reason codes. One or more line items per credit note, allowing credits to span multiple products and rationales.

## Grain and Volume

One row per line item on a credit note. FY26 total: 31,204 lines across approximately 9,318 credit notes (averaging 3.3 lines per credit note). All rows are written live from ADF screens and depot operations.

## Key Columns

**CN_LINE_ID** (Primary Key, NUMBER(12))
Unique surrogate identifier for each credit note line. Not used in business queries; line identity is typically tracked through CN_ID plus sequence.

**CN_ID** (NUMBER(12), Foreign Key)
References the parent CREDIT_NOTE row. Enforced foreign key constraint FK_CNLINE_CN. All line items for a credit note share the same CN_ID; queries filtering by credit note must join on this column.

**SKU_ID** (NUMBER(10))
References SKU_MASTER. The product affected by the credit. Nullable in DDL, allowing for header-level credits not tied to specific SKUs (e.g., flat adjustments).

**QTY** (NUMBER(12,3))
Quantity credited, in the unit of measure (UOM) from SKU_MASTER. Precision to three decimal places allows fractional units where relevant. Typically positive (representing amount claimed back).

**AMT** (NUMBER(16,2))
Credit amount in INR for this line item. Sum of all AMT values in a credit note matches CREDIT_NOTE.TOTAL_AMT. Precision to two decimals (standard for all currency in ORION).

**REASON_CD** (VARCHAR2(10))
Code explaining why this SKU is being credited. Examples: 'DAMAGE', 'RETURN', 'SHORT_QTY', 'QUALITY'. Used by Finance to classify credits and post to the correct GL account or sub-ledger. No check constraint; list of valid codes is maintained outside the schema.

## Audit and Lifecycle Columns

- **CREATED_BY, CREATED_DT**: Row insertion metadata. CREATED_DT is a DATE in IST (unlike CREDIT_NOTE.CREATED_TS which is UTC).
- **LAST_UPD_BY, LAST_UPD_DT**: Last modification tracking. LAST_UPD_DT is a DATE in IST.
- **ACTIVE_FLG**: Business availability flag ('Y' or 'N'). Reversed or voided lines are marked 'N'.
- **DELETE_FLAG**: Logical deletion ('Y', 'N', or NULL). Excludes superseded or cancelled lines from reporting.

## Constraints

- **PK_CREDIT_NOTE_LINE**: PRIMARY KEY on CN_LINE_ID
- **FK_CNLINE_CN**: FOREIGN KEY on CN_ID referencing CREDIT_NOTE (constraint is enabled; referential integrity is enforced)

## Relationship to Finance

Each line item rolls up to CREDIT_NOTE.TOTAL_AMT and ultimately to GL via the month-end close package. The REASON_CD is the primary key for sub-ledger posting; Finance will allocate each line to account 411200 (credit note account) and may further sub-divide by reason code for analytics.

## Related to Warehouse Exclusion

As noted in oms-prod-credit-note.md, there is no FACT_CREDIT_NOTE in BCPL_EDW. Credit note lines are not replicated to the warehouse fact table and are therefore not included in revenue figures reported through Power BI. Finance reconciles the gap outside the warehouse using a manual net-down in Excel (VAR-005).

## Related Tables

- /concepts/tables/oms-prod-credit-note.md (parent header; one-to-many relationship)
- /concepts/tables/oms-prod-sku-master.md (SKU_ID links to product master)

## Related variances

- **[VAR-005 — Credit notes absent from warehouse](/concepts/variances/var-005-credit-notes-absent.md)**: this table's lines are never replicated to BCPL_EDW; there is no FACT_CREDIT_NOTE, so revenue-affecting credit notes are netted by hand in Excel outside the warehouse.
