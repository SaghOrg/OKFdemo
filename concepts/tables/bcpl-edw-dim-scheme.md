---
type: warehouse-table
title: DIM_SCHEME
description: Trade promotion schemes dimension (QPS, monthly, slab, TPR). Only 5 rows. SCD1. Validity windows are set retrospectively causing lookup misses. Natural key is SCHEME_ID from ORION SCHEME_MASTER.
resource: BCPL_EDW.DIM_SCHEME
tags:
  - dimension
  - scd1
  - scheme
  - promotion
  - trade-promotion
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:36:54Z
sources:
  - resource: /_sources/schema_canon.sql
    id: SCHEMA
    last_modified: "2026-08-23"
  - resource: /_build/corpus_text/docs/DOC-05_edw_target_model_notes.docx.txt
    id: DOC-05
    title: BCPL_EDW target model - working notes
    author: Ishaan Bhatt
    last_modified: "2026-04-08"
  - resource: /_build/corpus_text/docs/DOC-01_orion_oltp_schema_notes.docx.txt
    id: DOC-01
    title: ORION - schema notes (OLTP side)
    author: Aniruddh Deshpande
    last_modified: "2026-03-09"
---

## Purpose and grain

DIM_SCHEME holds the master promotional scheme data from ORION. It is **SCD1** (no effective dating). Every row represents one distinct promotion offer.

Grain: **one row per scheme.**

Population: 5 active rows in production (as of the canon). This is the smallest dimension in BCPL_EDW.

## Known live schemes (as of canon)

| SCHEME_ID | SCHEME_CODE | SCHEME_NAME | SCHEME_TYPE |
|-----------|-------------|-------------|-------------|
| 5501 | QPS-Q1-SUV | Quarterly promotion Suvarn Q1 | QPS |
| 5514 | MTH-CHD-OCT | Monthly scheme Chandanaa October | MONTHLY |
| 5522 | SLB-TRG-FEST | Slab Tarang Festival | SLAB |
| 5533 | TPR-NMB-SOUTH | Trade promo recharge Nimbua South | TPR |
| 5540 | QPS-KSG-H2 | Quarterly Kesari Gold H2 | QPS |

## Key columns

**SCHEME_KEY** (NUMBER(8), NOT NULL, Primary Key)
- Surrogate key, meaningless, allocated from sequence.
- UNKNOWN member at SCHEME_KEY = -1 for unmatched facts.

**SCHEME_ID** (NUMBER(8))
- Natural key, equals `OMS_PROD.SCHEME_MASTER.SCHEME_ID`.

**SCHEME_CODE** (VARCHAR2(30))
- Business code, human-readable. Examples: QPS-Q1-SUV, TPR-NMB-SOUTH.

**SCHEME_NAME** (VARCHAR2(120))
- Full descriptive name.

## Scheme classification

**SCHEME_TYPE** (VARCHAR2(10))
- Four scheme types, check-constrained in ORION:
  - **QPS**: Quarterly promotion scheme
  - **MONTHLY**: Monthly scheme
  - **SLAB**: Volume-based slab promotion
  - **TPR**: Trade promotion recharge

## Validity dates

**START_DT** (DATE)
- Date the scheme became active for invoice application.

**END_DT** (DATE)
- Date the scheme expired.
- **Critical caveat** (from DOC-01): END_DT is set RETROSPECTIVELY. That is, the business closes a scheme at month end by setting END_DT to a date that is already in the past, after invoices have been raised inside that window. This is not a defect; it is standard practice.

## Lookup implications

**From DOC-05**: "Scheme lookups are the ones that fail most often in the fact load, because the source validity window gets closed retrospectively."

When the fact load does a scheme lookup by invoice date, a miss is a normal case, not an error. An invoice line invoiced inside the original valid window may fail to find a scheme because END_DT has since been moved before the invoice date. Design the mapping to treat this as a valid state and join to SCHEME_KEY = -1 (UNKNOWN).

## Audit columns

**LOAD_DT** (DATE)
- Date the row was loaded into the warehouse.

## Constraints and indexes

- **Primary Key**: SCHEME_KEY (NOT NULL)
- No unique constraint on SCHEME_ID, but all rows in ORION are unique by design.

## Relationships

DIM_SCHEME appears on:
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](FACT_INVOICE_LINE) only (specific to invoice-level promotions).

**Not** conformed to other facts. FACT_ORDER_LINE and FACT_SECONDARY_SALES do not have scheme keys.

## Data quality considerations

- **Small population risk**: 5 rows means one incorrect row is 20% of the dimension. Changes are visible.
- **Retrospective validity**: The standard practice of moving END_DT after invoices are raised means scheme lookup is inherently non-deterministic when queried after the fact. Document this in reconciliations.
- **No rate history**: DISC_PCT, SLAB_QTY_FROM, SLAB_QTY_TO (present in ORION) are held as attributes on this SCD1 table. They are overwritten if changed, and history is not kept.

## Known issues from prose

From DOC-01 (Ani Deshpande, section 12 on schemes): 
"SCHEME_MASTER is a small table. five live rows and that is the entire scheme universe at the moment... the validity windows get closed retrospectively. that is, somebody sets VALID_TO_DT to a date which is already in the past, after invoices have been raised inside that window. that is not a defect, the commercial team is told to do it that way at month end when a scheme is withdrawn, but the effect is that a lookup done by invoice date can fail to find a scheme which was very much applied at the time. keep that in mind when you build the scheme lookup, and treat a miss as a normal case not as an error."

From DOC-05: "Five rows. SCHEME_ID, SCHEME_CODE, SCHEME_NAME, SCHEME_TYPE, START_DT and END_DT. It is the smallest dimension in the warehouse and I would put money on it causing the most trouble per row of anything in the model, because the start and end dates in the source are not as stable as you would hope. Putting that on record here so that when it does cause trouble nobody is surprised."

## ORION source detail

From DOC-01: SCHEME_MASTER in OMS_PROD carries:
- SCHEME_ID (PK)
- SCHEME_CODE (business code)
- SCHEME_NAME
- SCHEME_TYPE (check-constrained to QPS, MONTHLY, SLAB, TPR)
- DISC_PCT (NUMBER(6,3))
- SLAB_QTY_FROM, SLAB_QTY_TO (meaningful only for SLAB type)
- VALID_FROM_DT, VALID_TO_DT (the retrospectively-adjusted window)

The warehouse imports the entire row into this dimension. No transformation beyond rounding or date handling.

