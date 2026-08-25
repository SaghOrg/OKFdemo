---
type: warehouse-table
title: ETL_BATCH_CONTROL
description: Control table recording metadata for each load plan run, including status, row counts, and high-water mark for incremental loads.
resource: BCPL_EDW.ETL_BATCH_CONTROL
tags:
  - ETL
  - batch-control
  - load-metadata
  - control-table
  - ETL_BATCH_CONTROL
generated:
  by: process:claude-haiku/tables
  at: "2026-08-23T10:37:25Z"
sources:
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: TECH-SQL-EDW
    last_modified: "2026-08-23"
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: "EDW target model notes"
    last_modified: "2026-05-15"
---

## Purpose

ETL_BATCH_CONTROL is the operational control table for the nightly load. It records one row per load plan run, capturing start/end times, status, row counts, and the high-water mark for incremental extraction. Every fact row is stamped with BATCH_ID to enable traceability back to the load run that produced it.

## Grain

One row per execution of a load plan (e.g., LP_DAILY_SALES).

## Columns

- **BATCH_ID**: Surrogate key for this run. NUMBER(10). Fact tables (FACT_INVOICE_LINE, FACT_ORDER_LINE, FACT_SECONDARY_SALES) carry BATCH_ID to link back to their load run. DOC-05: "BATCH_ID being stamped onto the fact rows is, as I said further up, the single most useful thing in the entire control layer. Whoever put it there in 2021 did us a favour. Keep it."

- **LOAD_PLAN_NAME**: Name of the ODI load plan, e.g., 'LP_DAILY_SALES'. VARCHAR2(60).

- **BUSINESS_DATE**: The business date for which the load ran. This is the date the load is *for*, not the date it *ran*. DATE.

- **START_TS**: When the load plan started, recorded at the plan's first step. TIMESTAMP(6).

- **END_TS**: When the load plan completed (reached its final step). TIMESTAMP(6). Note: does NOT imply correctness, only that the plan reached its closing step.

- **STATUS**: VARCHAR2(15). One of 'RUNNING', 'DONE', or 'FAILED'.
  - 'RUNNING': Plan started but has not yet completed.
  - 'DONE': Plan reached its closing step. Does NOT mean the data is correct.
  - 'FAILED': Plan stopped before reaching its closing step.

- **ROWS_INSERTED**: Count of rows successfully inserted into the target tables. NUMBER(12).

- **ROWS_REJECTED**: Count of rows rejected during load (constraint violations, etc.). NUMBER(12).

- **EXTRACT_HIGH_TS**: High-water mark timestamp for incremental extraction. Used by subsequent runs to know which source rows to extract. TIMESTAMP(6).

  **Known issue**: EXTRACT_HIGH_TS is persisted only by the closing step of a successful plan (P_ETL_BATCH_CLOSE). Before the R2026.07 fix of 08-Jul-2026, it was advanced at the START of the plan, so a mid-plan failure moved the window past rows that were never loaded, causing silent data loss. That was half of VAR-008. DOC-05 notes: "I have not traced how or when it gets set and I am not going to guess in a document. [Farida to explain]"

- **RESTART_COUNT**: Number of times the plan was restarted/re-run for this business date. NUMBER(4).

## Constraints

- **Primary key**: BATCH_ID.
- **Index**: `IX_EBC_PLAN` on (LOAD_PLAN_NAME, BUSINESS_DATE) for queries finding the latest run for a given plan and business date.

## Data Quality and Known Issues

### Stale RUNNING Rows

The DDL comment states: "Stale RUNNING rows from plans that aborted before the closing step sit here for ever. Several exist. The ops dashboard shows jobs in flight for months."

Plans that terminate abnormally (e.g., network timeout, Out of Memory, manual kill) never reach P_ETL_BATCH_CLOSE and leave their row in RUNNING state. These rows accumulate and should not be treated as "jobs in flight" without confirmation via the Control-M execution log. Counting RUNNING rows is not a valid health check.

### VAR-008: Batch Duplication (CLOSED)

On 14-Feb-2026, LP_DAILY_SALES was manually re-run (session SESS_884012) after an initial failure. The second run used IKM Oracle Control Append, which appended all rows from the night again instead of skipping already-loaded data. The same BATCH_ID was allocated to both runs, allowing duplicates to slip in. Fixed in R2026.07 (08-Jul-2026) by adding a uniqueness guard on BATCH_ID per plan per business date. Impact: INR 2.90 Cr, closed.

## Relationships

- Referenced by BATCH_ID in FACT_INVOICE_LINE, FACT_ORDER_LINE, FACT_SECONDARY_SALES.
- Populated by the ODI load plans themselves, triggered by Control-M jobs starting at 01:00 IST every night.

## Operational Notes

The nightly load (LP_DAILY_SALES) typically completes within ~58 minutes (01:00 to 01:58 IST). Including post-load checks and the batch close step, the warehouse is ready by ~02:05 IST, leaving headroom against the 05:30 IST business SLA. Any significant change to the model (new columns, extra lookups, historical loads) must be measured on DEV first, and the cost (elapsed time delta) must be confirmed before deployment.


## Related variances

- **[VAR-008 — Feb duplicate load](/concepts/variances/var-008-feb-duplicate-load.md)**: the batch-duplication variance this table's BATCH_ID guard (added with R2026.07, deployed 08-Jul-2026) was built to prevent, described in full above.

## Referenced by

- [Data Architecture](/context/data-architecture.md)
