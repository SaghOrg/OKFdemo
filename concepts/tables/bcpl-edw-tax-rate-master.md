---
type: warehouse-table
title: TAX_RATE_MASTER
description: Snapshot table of GST rates by HSN code, truncate-and-reload with no effective dating (see VAR-006 and DIM_TAX_RATE for remediation).
resource: BCPL_EDW.TAX_RATE_MASTER
tags:
  - tax
  - GST
  - rate-master
  - snapshot
  - TAX_RATE_MASTER
  - VAR-006
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:25Z
sources:
  - resource: /_sources/technical/schema_edw.sql
    id: TECH-SQL-EDW
    last_modified: "2026-08-23"
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: "EDW target model notes"
    last_modified: "2026-05-15"
---

## Purpose

TAX_RATE_MASTER holds the current GST rate for each HSN (Harmonized System of Nomenclature) code used in invoicing. It is a lookup table used to map TAX_AMT on invoices, though the lookup is not happening at invoice time—instead, FACT_INVOICE_LINE carries pre-calculated TAX_AMT from OMS_PROD.

## Grain

One row per HSN code, representing the current rate.

## Columns

- **HSN_CODE**: Harmonized System of Nomenclature code. VARCHAR2(10). Primary key (though not explicitly declared in DDL).

- **GST_RATE_PCT**: GST rate as a percentage. NUMBER(5,2). Example: 18.00 for 18% GST.

- **LOAD_DT**: Date the row was loaded. DATE. In a truncate-and-reload table, this is the refresh date of the entire table, not a row-level timestamp.

## Constraints and Design

- No surrogate key.
- No effective dating columns (no EFF_START_DT, EFF_END_DT, or CURRENT_FLG).
- No unique constraint declared on HSN_CODE in the DDL.
- Truncate-and-reload refresh: on each load, the entire table is cleared and reloaded with the current rates from FIN_PROD.

## Critical Issue: VAR-006 (CLOSED via CHG0021339, 26-Aug-2026)

**The lack of effective dating is a defect**, and it caused VAR-006.

On 01-Oct-2025, the tax rate for Chandanaa HSN 3401 changed from 18% to 12%. Since TAX_RATE_MASTER is truncate-and-reload, the new rate (12%) was applied retroactively to all historical invoices with that HSN—including April-September 2025 invoices that should have used 18%.

**Result**: Invoices from Apr-Sep 2025 were recalculated on historical reload with the wrong rate, overstating cost and understating taxable revenue.

**Fix**: A new table **DIM_TAX_RATE** was created with effective dating (CHG0021339, deployed 26-Aug-2026). DIM_TAX_RATE has:
- TAX_RATE_KEY (surrogate)
- HSN_CODE
- GST_RATE_PCT
- EFF_START_DT
- EFF_END_DT
- CURRENT_FLG

DIM_TAX_RATE is the correct lookup going forward. TAX_RATE_MASTER remains in the schema but should not be used for new development. See [/concepts/tables/bcpl-edw-dim-tax-rate.md](/concepts/tables/bcpl-edw-dim-tax-rate.md) (if it exists).

## Relationship to FIN_PROD.TAX_RATE_MASTER

**BCPL_EDW.TAX_RATE_MASTER is not the same as FIN_PROD.TAX_RATE_MASTER.**

FIN_PROD.TAX_RATE_MASTER (the source system) has effective dating:
- EFF_FROM_DT, EFF_TO_DT, ACTIVE_FLG, DELETE_FLAG
- Designed for historical lookups

BCPL_EDW.TAX_RATE_MASTER (the warehouse copy) is a degenerate snapshot:
- No effective dating, no flags
- Truncate-and-reload loses history
- This is the design mistake that caused VAR-006

## Discrepancy

**DDL states**: TAX_RATE_MASTER has HSN_CODE, GST_RATE_PCT, LOAD_DT only. Accompanied by the comment: `-- no EFF_START_DT. no EFF_END_DT. no CURRENT_FLG. That is the bug.`

**Prose (DOC-05, section 5.7) states**:

> This is the one I have parked. It sits inside BCPL_EDW with HSN_CODE, GST_RATE_PCT and LOAD_DT on it, and no surrogate key, so it is not a dimension in any sense I recognise. I have not drawn it into the star and I have not modelled it in this note, because I do not think it belongs where it is and I am not confident enough yet to say what it ought to be instead. It is a lookup that somebody put in the warehouse because the warehouse was convenient.
>
> TBC - Karthik to confirm whether the tax rate lookup belongs in the model at all, or whether it stays as it is and we work around it.

**Resolution**: The prose from DOC-05 (dated 2026-05-15) reflects the pre-fix state. By 26-Aug-2026, CHG0021339 deployed DIM_TAX_RATE as the proper remedy. TAX_RATE_MASTER remains in the schema for backward compatibility but is deprecated for new work.

## Usage Guidance

**Do not use TAX_RATE_MASTER for new reports or analysis.** If you need to look up the rate that applied to an invoice on a specific date, use DIM_TAX_RATE and join on EFF_START_DT and EFF_END_DT. If you are working with data prior to 26-Aug-2026 (the CHG0021339 deployment date), the VAR-006 restatement note should be consulted to understand which rates are correct.


## Related variances

- **[VAR-006 — GST rate change mishandled](/concepts/variances/var-006-tax-rate-retroactive.md)**: this table is the defective object at the center of the variance, described in full above.

## Referenced by

- [Data Architecture](/context/data-architecture.md)
