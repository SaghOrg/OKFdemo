---
type: warehouse-table
title: DIM_TAX_RATE
description: Effective-dated tax rate lookup dimension. Remediation for VAR-006 (retroactive tax rate application). Joined by HSN_CODE and invoice date. Replaced TAX_RATE_MASTER on 26-Aug-2026 (CHG0021339).
resource: BCPL_EDW.DIM_TAX_RATE
tags:
  - dimension
  - tax
  - gst
  - effective-dated
  - variance-remediation
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

DIM_TAX_RATE is the remediation for **VAR-006**, which exposed a retroactive tax rate change bug in the original TAX_RATE_MASTER table. This dimension holds GST rates with effective dating, enabling facts to look up the tax rate that was in force **on the invoice date**, not just the current rate.

Grain: **one row per HSN_CODE per effective-dated rate version.**

Population: 214 rows (all active rates and their history).

Live since: **26-Aug-2026** under change request **CHG0021339**.

## Key columns

**TAX_RATE_KEY** (NUMBER(8), NOT NULL, Primary Key)
- Surrogate key, meaningless, allocated from sequence.
- UNKNOWN member at TAX_RATE_KEY = -1 for unmatched facts.

**HSN_CODE** (VARCHAR2(10))
- Harmonized System of Nomenclature (tax code).
- Held as a string to preserve leading zeros. Example: '0902' for tea.
- Natural key (combined with effective dates).
- Joins to [/concepts/tables/bcpl-edw-dim-product.md](DIM_PRODUCT).HSN_CODE.

## Tax rate

**GST_RATE_PCT** (NUMBER(5,2))
- The Goods and Services Tax rate as a percentage. Examples: 5.00, 12.00, 18.00.
- A single HSN_CODE may have multiple rows with different GST_RATE_PCT, each effective-dated.

## Effective dating

**EFF_START_DT** (DATE)
- Date the rate became effective.
- Inclusive: invoices on or after this date use this rate.

**EFF_END_DT** (DATE)
- Date the rate ended.
- Exclusive: invoices on or after this date use a later rate. NULL means the rate is current.

**CURRENT_FLG** (CHAR(1))
- 'Y' for the active (current) rate, 'N' for historical rates.

## Audit columns

**LOAD_DT** (DATE)
- Date the row was loaded into the warehouse.

## Constraints and indexes

- **Primary Key**: TAX_RATE_KEY (NOT NULL)

## Relationships

DIM_TAX_RATE appears on:
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](FACT_INVOICE_LINE) (and potentially other facts that carry tax amounts).

Join pattern: `FACT.HSN_CODE = DIM_TAX_RATE.HSN_CODE AND FACT.DATE_KEY BETWEEN DIM_TAX_RATE.EFF_START_DT AND COALESCE(DIM_TAX_RATE.EFF_END_DT, 31-Dec-2099)`

## Variance linkage

### VAR-006 — Retroactive tax rate changes

**Status**: Closed on 26-Aug-2026 under CHG0021339  
**Severity**: High  
**Root cause**: The original table, TAX_RATE_MASTER, was a truncate-and-reload snapshot with no effective dating. When a tax rate changed in the source (e.g., Chandanaa HSN 3401 from 18% to 12% on 01-Oct-2025), the load overwrote the old rate. Invoices from Apr-Sep 2025 that referenced that rate were then recalculated with the October rate, overstating or understating tax and revenue.

**Example**: Chandanaa HSN 3401 was at 18% GST from April to September 2025. On 01-Oct-2025 it changed to 12%. The old TAX_RATE_MASTER was truncated and reloaded with only the 12% rate. When the warehouse recalculated an Apr-2025 invoice, it applied 12%, not 18%, retroactively restating revenue.

**Impact**: Calculated at 0.40 Cr.

**Source**: The source system, FIN_PROD.TAX_RATE_MASTER in ORION, carries EFF_FROM_DT and EFF_TO_DT (the history is available). The warehouse simply did not preserve it.

**Fix**: Deployed 26-Aug-2026. DIM_TAX_RATE supersedes TAX_RATE_MASTER with effective dating. Fact loads now join on (HSN_CODE, invoice_date) to pick the correct rate for that date.

See [/concepts/variances/var-006-tax-rate-retroactive.md](/concepts/variances/var-006-tax-rate-retroactive.md).

## Predecessor table: TAX_RATE_MASTER

The old table, BCPL_EDW.TAX_RATE_MASTER, still exists in the schema but is no longer used by current mappings. From DDL:

```
CREATE TABLE BCPL_EDW.TAX_RATE_MASTER
(
  HSN_CODE            VARCHAR2(10),
  GST_RATE_PCT        NUMBER(5,2),
  LOAD_DT             DATE
  -- no EFF_START_DT. no EFF_END_DT. no CURRENT_FLG. That is the bug.
);
```

**Not deleted**: Do not remove TAX_RATE_MASTER from the schema. It exists in case historical queries or scripts reference it. New mappings use DIM_TAX_RATE exclusively.

## Known issues from prose

From DOC-01 (Ani Deshpande, section 14 on FIN_PROD): "TAX_RATE_MASTER on this side is holding HSN_CODE, GST_RATE_PCT and, importantly, EFF_FROM_DT and EFF_TO_DT. so the rate history is available in the source, it is effective dated here."

From DOC-05 (section 5.7, originally): "This is the one I have parked. It sits inside BCPL_EDW with HSN_CODE, GST_RATE_PCT and LOAD_DT on it, and no surrogate key, so it is not a dimension in any sense I recognise. I have not drawn it into the star and I have not modelled it in this note, because I do not think it belongs where it is and I am not confident enough yet to say what it ought to be instead... TBC - Karthik to confirm whether the tax rate lookup belongs in the model at all, or whether it stays as it is and we work around it."

This uncertainty was resolved by the VAR-006 closure: DIM_TAX_RATE is now part of the conformed model.

## Data quality considerations

- **Completeness**: All active HSN codes and their rate histories are loaded.
- **Non-overlapping effective dates**: Rows for the same HSN_CODE do not overlap in time. An HSN_CODE has exactly one effective rate on any given date.
- **Granularity**: HSN_CODE level. A single product (SKU) may join through multiple HSN rows if the HSN changed over time (rare but possible).

## Load strategy

Loaded nightly as part of the standard warehouse load (LP_DAILY_SALES), typically finishing by 02:05 IST. Tax rate changes in FIN_PROD are picked up on the next nightly load.


## Related variances

- **[VAR-006 — GST rate change mishandled](/concepts/variances/var-006-tax-rate-retroactive.md)**: DIM_TAX_RATE is the direct remediation for this variance, described in full above under Variance linkage.

## Related concepts

- [TAX_RATE_MASTER](/concepts/tables/bcpl-edw-tax-rate-master.md)

## Referenced by

- [Data Architecture](/context/data-architecture.md)
