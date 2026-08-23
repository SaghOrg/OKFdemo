---
type: warehouse-table
title: ETL_ERROR_LOG
description: Log of rejected rows from ODI load plans, capturing constraint violations and other ETL failures.
resource: BCPL_EDW.ETL_ERROR_LOG
tags:
  - ETL
  - error-log
  - rejected-rows
  - control-table
  - ETL_ERROR_LOG
  - data-quality
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:25Z
sources:
  - resource: /_canon/schema_canon.sql
    id: TECH-SQL-EDW
    last_modified: "2026-08-23"
  - resource: /_build/corpus_text/docs/DOC-05_edw_target_model_notes.docx.txt
    id: DOC-05
    title: "EDW target model notes"
    last_modified: "2026-05-15"
---

## Purpose

ETL_ERROR_LOG captures rows that fail to load due to constraint violations or ETL errors. Rejected rows are copied from ODI's E$ (error) work tables to this log by a post-step in the load plan. It is used for monitoring load quality, but its absence does not mean the load was correct.

## Grain

One row per rejected record, capturing the rejection event.

## Columns

- **ERROR_ID**: Unique surrogate key for this rejection record. NUMBER(12).

- **BATCH_ID**: Links to ETL_BATCH_CONTROL.BATCH_ID, identifying which load run produced this error. NUMBER(10).

- **OBJECT_NM**: Name of the object (fact or dimension table) into which the row was being loaded when it was rejected. VARCHAR2(60). Examples: 'FACT_INVOICE_LINE', 'DIM_CUSTOMER'.

- **ERROR_TS**: Timestamp when the error occurred. TIMESTAMP(6).

- **ERROR_TEXT**: The error message from the database (e.g., constraint name, ORA- code, or custom error text). VARCHAR2(4000).

## Constraints

- **Primary key**: ERROR_ID.
- **Index**: `IX_EEL_BATCH` on BATCH_ID for queries finding all errors in a given load run.

## Critical Caveat: What It Does NOT Capture

**An empty error log does not mean the load was correct.** DOC-05 emphasizes:

> One caveat for anybody who wants to use it as a health check, and I would like this one repeated to the business at some point: an empty error log means nothing was rejected. It means precisely that and nothing beyond it. It is not evidence that a load was correct.

**Specifically, it does NOT capture:**

- **Late-arriving dimension issues (VAR-007)**: A fact row whose dimension lookup resolves to the -1 UNKNOWN member is a perfectly valid row. It violates no constraint, is never rejected, never logged, never counted. Example: a SKU invoiced before MAP_DIM_PRODUCT has seen it routes to PRODUCT_KEY = -1 and passes all checks.

- **Silent data loss from mid-plan failures (VAR-008, pre-fix)**: Before R2026.07, if a plan failed mid-execution, EXTRACT_HIGH_TS was already advanced, so subsequent rows were skipped. This caused no error log entry; the rows simply vanished.

- **Duplicate key logic failures (VAR-004)**: A row that joins to two dimension rows instead of one (due to late-arriving dimension or SCD2 logic error) is not rejected; it becomes a fact row with ambiguous lineage.

The error log is therefore useful only as a list of *known* failures. It should not be used as the sole basis for asserting load correctness.

## Relationships

- Links to ETL_BATCH_CONTROL via BATCH_ID.
- One row per rejected source record, not one row per batch.

## Operational Notes

If OBJECT_NM, ERROR_TS and ERROR_TEXT are reviewed alongside ETL_BATCH_CONTROL and the ODI session logs, they help diagnose which mapping failed and why. However, combining error log review with row-count variance analysis is necessary for complete load validation.


## Related variances

- **[VAR-007 — Late-arriving SKUs to UNKNOWN member](/concepts/variances/var-007-late-arriving-sku-unknown-member.md)**: a row substituting PRODUCT_KEY = -1 is never rejected and never logged here — this is precisely why the issue was invisible to load-audit monitoring.
- **[VAR-008 — Feb duplicate load](/concepts/variances/var-008-feb-duplicate-load.md)**: a duplicated row from a manual resubmit is a clean insert, not a constraint violation, so it never appears in this log either.
- **[VAR-004 — Duplicate facts on distributor reassignment](/concepts/variances/var-004-scd2-territory-reassignment.md)**: a fact joining to two current DIM_CUSTOMER rows is not rejected; it becomes a fact row with ambiguous lineage rather than an error-log entry.
