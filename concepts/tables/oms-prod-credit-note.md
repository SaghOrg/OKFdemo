---
type: oltp-table
title: Credit Note
description: Header table for credit notes issued against invoices, covering damage claims, returns, rate adjustments, off-invoice adjustments, and scheme-related credits.
resource: OMS_PROD.CREDIT_NOTE
tags:
  - credit note
  - CN
  - returns
  - damage
  - rate adjustment
  - scheme credit
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP Schema Notes
    author: Aniruddh Deshpande
    last_modified: "2026-03-08"
generated:
  by: process:claude-haiku/tables
  at: "2026-08-23T10:37:07Z"
---

## Purpose

Tracks credit notes issued by BCPL across five distinct business reasons: product damage claims, customer returns, rate differences, off-invoice adjustments, and scheme-related credits. Credit notes reduce revenue and are the primary mechanism for correcting invoice-related transactions.

## Grain and Volume

One row per credit note issued. FY26 volume: approximately 9,318 credit note documents spanning 31,204 line items. Documents are written daily from ADF screens and depot operations.

## Key Columns

**CN_ID** (Primary Key, NUMBER(12))
Unique surrogate identifier for each credit note. Not used in business reporting; operations identify credit notes by CN_NO.

**CN_NO** (VARCHAR2(20))
Business-facing credit note number. Unique identifier used in all correspondence and financial reports.

**CN_DT** (DATE)
Date of credit note issuance in IST. Business date for all reporting purposes. Indexed for period-based queries (IX_CN_DT).

**CUST_ID** (NUMBER(10))
Reference to customer in CUSTOMER table. Composite index IX_CN_CUST on (CUST_ID, CN_DT) for distributor-level lookups.

**CN_TYPE** (VARCHAR2(15))
Constrained to five values via CHECK constraint:
- DAMAGE: product damage or defect claims
- RETURN: full or partial customer returns
- RATE_DIFF: adjustment for rate differences or pricing corrections
- OFF_INV_ADJ: off-invoice adjustments and allowances
- SCHEME: credit notes issued as part of scheme promotions

The type governs downstream GL posting in FIN_PROD.

**CN_STATUS** (VARCHAR2(20))
Lifecycle status of the credit note (e.g., DRAFT, APPROVED, POSTED, REVERSED). Used to filter live vs. historical credits.

**TOTAL_AMT** (NUMBER(16,2))
Total credit note amount in INR. Sum of all line-item amounts (AMT in CREDIT_NOTE_LINE). Posted to GL account 411200 (credit note account) via Finance's month-end close package.

**REF_INVOICE_ID** (NUMBER(12))
Optional foreign key to INVOICE_HEADER. Nullable because not all credit notes refer to a single invoice; some apply to standing adjustments or scheme settlements. Where populated, typically references the original invoice being credited.

## Constraints and Indexes

- **PK_CREDIT_NOTE**: PRIMARY KEY on CN_ID
- **CK_CN_TYPE**: CHECK constraint enforcing the five CN_TYPE values
- **IX_CN_DT**: Index on CN_DT for date-range scans
- **IX_CN_CUST**: Composite index on (CUST_ID, CN_DT) for distributor and period lookups
- **IX_CN_LUD**: Index on LAST_UPD_DT for tracking updates

## Audit and Lifecycle Columns

- **CREATED_BY, CREATED_TS**: Row insertion metadata. CREATED_TS is a TIMESTAMP(6) written by the application server in UTC, not IST (see VAR-002 for the date-handling implications).
- **LAST_UPD_BY, LAST_UPD_DT**: Last row modification. LAST_UPD_DT is a DATE in IST.
- **ACTIVE_FLG**: Business availability flag ('Y' or 'N'). A discontinued credit note or reversal is marked 'N' but not deleted.
- **DELETE_FLAG**: Logical deletion ('Y', 'N', or NULL on rows created before 30-Mar-2019). Used to exclude reversed or superseded credits from reporting.

## Relationship to Finance

Credit notes flow to FIN_PROD via the month-end close package (PKG_MONTH_END), which rolls up by GL account. The Finance team (Shalini's team) quotes three account codes:
- 410100: Net Sales Domestic (revenue)
- 410900: Scheme Discount Contra
- 411200: Credit Note Account (offset to revenue)

Credit note amounts are explicitly excluded from warehouse reporting via FACT_INVOICE_LINE and are reconciled manually in Excel (Finance shadows the EDW numbers outside the warehouse).

## Known Issues

**VAR-005: No Fact Table for Credit Notes**

There is no FACT_CREDIT_NOTE in BCPL_EDW. Credit notes were not loaded into the warehouse during the initial 2021 build and have not been added since. Finance nets credit notes by hand each month in Excel, deducting them from gross invoice revenue. This is the primary data quality gap on the revenue line and is tracked as an open variance. The EDW revenue figures are therefore gross of all credits and corrections.

## Related Tables

- /concepts/tables/oms-prod-invoice-header.md (credit notes reference invoices via REF_INVOICE_ID)
- /concepts/tables/oms-prod-credit-note-line.md (detail lines; CN_ID is foreign key)
- /concepts/tables/oms-prod-customer.md (CUST_ID links to customer master)

## Related variances

- **[VAR-005 — Credit notes absent from warehouse](/concepts/variances/var-005-credit-notes-absent.md)**: this table is the ORION-side source that was never replicated into BCPL_EDW, described above under Known Issues.

## Referenced by

- [Data Architecture](/context/data-architecture.md)

## Related decisions

- **[ADR-007 — Credit note netting threshold set at INR 25,000 per document](/decisions/20260826-var005-credit-note-netting-threshold.md)** — Finance's manual net-down applies a materiality threshold of INR 25,000 at this table's grain (the credit note document/header), not at line grain. Confirmed verbally by Shalini Iyer, captured 26-Aug-2026.
