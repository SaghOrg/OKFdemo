---
type: oltp-table
title: AR_OPEN_ITEM (FIN_PROD)
description: Receivables ageing at invoice level, the sole source of ageing data for D11 Credit and Receivables Exposure dashboard.
resource: FIN_PROD.AR_OPEN_ITEM
tags:
  - accounts receivable
  - ageing
  - receivables
  - credit exposure
  - D11
  - OLTP
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:09Z
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    author: Aniruddh Deshpande
    last_modified: 2026-03-08
---

## Purpose

Records open receivables items by invoice and customer, with ageing buckets calculated by due date. This is the only table in ORION that holds ageing information. Used exclusively to feed D11 (Credit and Receivables Exposure) dashboard; D11 does NOT draw credit notes from any source.

## Grain

One row per outstanding invoice line item from a customer.

## Key Columns

- **AR_ITEM_ID** (NUMBER(12), PK): Unique identifier for the open item record
- **CUST_ID** (NUMBER(10)): Customer identifier, links to CUSTOMER in OMS_PROD
- **INVOICE_ID** (NUMBER(12)): Invoice reference, links to INVOICE_HEADER in OMS_PROD
- **DUE_DT** (DATE): Payment due date; determines AGEING_BUCKET assignment
- **OPEN_AMT** (NUMBER(16,2)): Outstanding amount in INR, two decimal places
- **AGEING_BUCKET** (VARCHAR2(20)): One of `0-30`, `31-60`, `61-90`, or `90+`, calculated based on days past due date

## Keys and Constraints

- Primary Key: AR_ITEM_ID
- Indexed on (CUST_ID, DUE_DT) for customer and date-based queries
- Standard OLTP audit columns: CREATED_BY, CREATED_DT, LAST_UPD_BY, LAST_UPD_DT
- Delete flag: DELETE_FLAG (CHAR(1)), must always be filtered as `NVL(DELETE_FLAG,'N') = 'N'`
- Activity flag: ACTIVE_FLG (CHAR(1))

## Relationships

- Links to CUSTOMER (OMS_PROD) via CUST_ID
- Links to INVOICE_HEADER (OMS_PROD) via INVOICE_ID
- Source for [/concepts/dashboards/d11-credit-receivables-exposure.md] dashboard

## Notes

- This is the only ageing source; ageing is never calculated in reports from raw invoice data
- As per DOC-01: "AR_OPEN_ITEM is the receivables ageing, invoice level, and it is the only place ageing exists."
- D11 dashboard will have credit exposure data, but NOT credit note detail; D11 has no credit note source
