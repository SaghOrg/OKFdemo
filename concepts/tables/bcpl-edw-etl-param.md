---
type: warehouse-table
title: ETL_PARAM
description: Parameter store for ETL configuration, holding key-value pairs that control load behavior.
resource: BCPL_EDW.ETL_PARAM
tags:
  - ETL
  - parameters
  - configuration
  - control-table
  - ETL_PARAM
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

ETL_PARAM is a name-value parameter store used by load plans to read configuration at runtime. It is not a fact or dimension; it is pure control metadata.

## Grain

One row per parameter name.

## Columns

- **PARAM_NAME**: The name of the parameter. VARCHAR2(60) NOT NULL, primary key. Examples: 'FIN_PERIOD_OPEN', and others (not fully documented).

- **PARAM_VALUE**: The value of the parameter. VARCHAR2(200). Can be NULL for deactivation.

- **UPD_TS**: When the parameter was last updated. TIMESTAMP(6).

- **UPD_BY**: Who updated it (user name or system process). VARCHAR2(30).

## Constraints

- **Primary key**: PARAM_NAME.
- No other constraints or indexes specified.

## Known Parameters

### FIN_PERIOD_OPEN

The row `PARAM_NAME = 'FIN_PERIOD_OPEN'` holds a YYYYMM string indicating which financial period is open for data posting.

**CRITICAL**: The mechanism by which this row is set and what it controls is an exclusive fact to DOC-02 and is NOT to be stated or explained in any other artifact. DOC-02 makes clear that somebody has to set this parameter by hand, and that manual step is a known process gap. Other artifacts may mention that ETL_PARAM exists and may acknowledge that this row is present, but they may not explain its purpose or the fact that manual intervention is required.

## Data Quality and Known Gaps

DOC-05 notes: "There are a handful of rows in it. I have not gone through what each one actually drives and it is out of scope for this note, but somebody should, because a parameter table with no documentation against it is a parameter table that is going to surprise us at some point."

**No comprehensive documentation exists** mapping each PARAM_NAME to what it controls, what its valid values are, and how it is set. This is a documentation debt. The parameter table is in production, but its design intent and full inventory of parameters should be documented separately.

## Relationships

- Used by ODI load plans at runtime to read configuration.
- Updated manually or by administrative procedures, not by the load plans themselves.

