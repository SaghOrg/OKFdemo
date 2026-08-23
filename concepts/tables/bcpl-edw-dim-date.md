---
type: warehouse-table
title: DIM_DATE
description: Calendar and fiscal calendar dimension covering 01-Apr-2015 to 31-Mar-2031, with IST timezone anchoring all warehouse dates.
resource: BCPL_EDW.DIM_DATE
tags:
  - dimension
  - calendar
  - fiscal
  - conformed-dimension
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:36:54Z
sources:
  - resource: /_sources/technical/schema_edw.sql
    id: SCHEMA
    last_modified: "2026-08-23"
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: BCPL_EDW target model - working notes
    author: Ishaan Bhatt
    last_modified: "2026-04-08"
---

## Purpose and grain

DIM_DATE provides the calendar structure for all warehouse facts. Every row represents a single calendar day. The dimension covers 01-Apr-2015 to 31-Mar-2031, providing runway so the warehouse operates without redesign pressure through FY31.

**All warehouse dates are IST end-to-end. This is a non-negotiable rule.** Every mapping spec must name the exact source column that DATE_KEY is derived from. If a fact needs multiple dates—an order date and a despatch date, for example—the fact carries multiple date keys with both roles named explicitly.

## Key columns

**DATE_KEY** (NUMBER(8), NOT NULL, Primary Key)
- Format: YYYYMMDD  
- The surrogate key, readable without joining to other tables. Example: 20260422 for 22-Apr-2026.
- UNKNOWN row is the exception: DATE_KEY = -1, which breaks the key format deliberately and consistently with every other dimension.

**FULL_DATE** (DATE)
- The actual date value.

## Calendar structure

**DAY_NAME**, **DAY_OF_MONTH** (NUMBER(2)), **WEEK_OF_YEAR** (NUMBER(2))
- Day names are populated (e.g., 'Monday', 'Tuesday').
- Week of year and day of month support reporting roll-ups.

**MONTH_NUM** (NUMBER(2)), **MONTH_NAME** (VARCHAR2(10)), **CAL_QTR** (NUMBER(1)), **CAL_YEAR** (NUMBER(4))
- Calendar month and quarter (calendar year quarters, not fiscal).

## Fiscal structure

This section is load-bearing and appears in every finance reconciliation.

**FISCAL_MONTH_NUM** (NUMBER(2))
- Ranges 1 to 12, with April = 1 (the start of BCPL's fiscal year).
- Used as the canonical fiscal period reference.

**FISCAL_QTR** (VARCHAR2(8))
- Format: 'FY26-Q1', 'FY26-Q2', etc.
- Always spelt out, no exceptions: FY26-Q1, FY26-Q2, FY26-Q3, FY26-Q4.
- See the BCPL_EDW_canon/BRIEF.md for the fiscal calendar: FY26 = 01-Apr-2025 to 31-Mar-2026. The fiscal year is named for the calendar year in which it **ends**.

**FISCAL_YEAR** (VARCHAR2(4))
- Format: 'FY26', 'FY27', etc.
- Named for the ending calendar year.

**FULL_DATE** 
- Commented in DDL: "FY label named for the ending year. FY26 = 01-Apr-2025 to 31-Mar-2026."

## Flags and metadata

**IS_MONTH_END_FLG** (CHAR(1))
- Flag indicating the last day of a calendar month. Used in reporting and for month-end load volume estimation.

**IS_WORKING_DAY_FLG** (CHAR(1))
- Flag for business day identification (excluding weekends and holidays).

**LOAD_DT** (DATE)
- Audit column: the date the row was loaded into the warehouse.

## Relationships and conformation

DIM_DATE is a **conformed dimension**—it appears on all three facts: FACT_INVOICE_LINE, FACT_ORDER_LINE, and FACT_SECONDARY_SALES. Every fact uses DATE_KEY to join to this dimension. The same DATE_KEY value always represents the same calendar day across all facts.

- Link to [/concepts/tables/bcpl-edw-fact-invoice-line.md](FACT_INVOICE_LINE)
- Link to [/concepts/tables/bcpl-edw-fact-order-line.md](FACT_ORDER_LINE)  
- Link to [/concepts/tables/bcpl-edw-fact-secondary-sales.md](FACT_SECONDARY_SALES)

## Constraints

- **Primary Key**: DATE_KEY (NOT NULL)

## Data quality considerations

The dimension is stable and comprehensive. No known quality issues. All dates in the dimension are in IST; the warehouse accepts no other timezone for date columns.

## Variance linkage

No variances are rooted in DIM_DATE itself. However:
- **VAR-002** (Date key derivation) involves this dimension indirectly: the mapping for FACT_INVOICE_LINE was corrected to derive DATE_KEY from `INVOICE_DT` (a DATE in IST) rather than from `CREATED_TS` (a TIMESTAMP in UTC). This ensures invoices appear on the commercial date, not the application server write time.

See [/concepts/variances/var-002-date-key-timezone.md](/concepts/variances/var-002-date-key-timezone.md) for detail.

## Known design notes

From DOC-05: "5844 rows, covering 01-Apr-2015 to 31-Mar-2031, so we have runway and nobody has to think about it again for a while. DATE_KEY is a NUMBER(8) in YYYYMMDD form, which I like, because you can read a key off a fact row without joining anything to it."

The UNKNOWN row at DATE_KEY = -1 is intentional: it allows facts with unmapped dates to carry a known surrogate rather than NULL, supporting downstream reporting logic.

## Related variances

- **[VAR-002 — Month-end boundary drift](/concepts/variances/var-002-date-key-timezone.md)**: not a defect in DIM_DATE itself, but the reason FACT_INVOICE_LINE.DATE_KEY was corrected to derive from INVOICE_DT rather than the UTC-written CREATED_TS.

## Referenced by

- [Data Architecture](/context/data-architecture.md)

## Related decisions

- [ADR-005 — DATE_KEY on FACT_INVOICE_LINE derived from INVOICE_DT, not CREATED_TS](/decisions/20260506-var002-date-key-fix.md)
