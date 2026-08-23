---
type: warehouse-table
title: DIM_SALESREP
description: Sales representative dimension with SCD2 history. Employee codes only, no names. 610 current rows. Refreshed ad hoc (not nightly). Feeds D10 Sales Rep Productivity report, dropped at go-live.
resource: BCPL_EDW.DIM_SALESREP
tags:
  - dimension
  - scd2
  - salesrep
  - employee
status: null
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

DIM_SALESREP holds the master sales representative data from ORION. It is **slowly changing dimension type 2 (SCD2)** with effective dating to track role and territory changes. Every row represents a distinct version of a sales rep.

Grain: **one row per sales rep version, effective-dated.**

Population: 610 current rows.

## Key columns

**SALESREP_KEY** (NUMBER(8), NOT NULL, Primary Key)
- Surrogate key, meaningless, allocated from sequence.
- UNKNOWN member at SALESREP_KEY = -1 for unmatched facts.

**EMP_ID** (VARCHAR2(20))
- Natural key, equals ORION employee code.
- Format: BCPL-EMP-04412 (example).
- **EMPLOYEE NAMES ARE NEVER PRINTED IN ARTIFACTS.** This column carries codes only.

## Attributes

**ROLE_CODE** (VARCHAR2(20))
- Sales role classification. Examples: Area Manager, Territory Manager, Salesman.
- Changes over time (tracked by SCD2).

**TERRITORY_CODE** (VARCHAR2(12))
- Sales territory assignment. Examples: TER-W-014, TER-N-032.
- A sales rep belongs to one territory.
- Territory changes trigger SCD2 version creation.

**MANAGER_EMP_ID** (VARCHAR2(20))
- Employee code of the direct manager.
- Format: BCPL-EMP-xxxxx.
- Also a code, never a name.

## Effective dating and history

**EFF_START_DT** (DATE)
- Date this version of the sales rep became effective.

**EFF_END_DT** (DATE)
- Date this version ended (NULL for the current row).

**CURRENT_FLG** (CHAR(1))
- 'Y' for the active version, 'N' for historical versions.

## Audit columns

**LOAD_DT** (DATE)
- Date the row was loaded into the warehouse.

## Constraints and indexes

- **Primary Key**: SALESREP_KEY (NOT NULL)

## Relationships

DIM_SALESREP appears on:
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](FACT_INVOICE_LINE) only (sales rep responsible for the sale).

**Not** conformed to other facts. FACT_ORDER_LINE and FACT_SECONDARY_SALES do not have sales rep keys.

**Not shared**: FACT_SECONDARY_SALES (secondary sales are distributor-to-retailer; BCPL sales reps are not involved).

## Load schedule

**Critical difference from other dimensions**: DIM_SALESREP is **refreshed ad hoc**, not nightly.

From DOC-05: "It is also not loaded on the nightly load. It gets refreshed when somebody asks for it, which means it can be stale, which matters to anyone building something that assumes it is current. Worth knowing up front."

This means:
- Sales rep data may be 1–7 days old in PROD at any given time.
- Any report or dashboard using this dimension must carry a "as of [date]" caveat.
- Build with the assumption that CURRENT_FLG='Y' rows are not guaranteed to reflect today's organization.

## Reporting impact

From schema DDL: DIM_SALESREP feeds **D10 Sales Rep Productivity** dashboard, which is **dropped and not in scope at go-live** (9 committed dashboards). This dimension's load schedule and staleness are not a blocker for the go-live phase.

If D10 is reinstated post-go-live, the staleness caveat must be surfaced to users.

## Privacy and naming convention

**From DDL**: "REP NAMES ARE NEVER PRINTED IN ANY ARTIFACT. There is no name column here and there must not be one. Employee codes only, in BCPL-EMP-04412 form."

**From DOC-05**: "Note there is no name column on this dimension and there should not be one. Employee codes only, in the BCPL-EMP-04412 form. If a report needs to put a person's name on a screen then that is a conversation with the business first, and a change to the model second, in that order."

This is a deliberate design decision made long before this engagement. It is not a gap; it is a security and privacy constraint. Maintain it.

## Data quality considerations

- **Staleness by design**: Expect the dimension to be out of date.
- **Role and territory changes**: Territory reassignments trigger SCD2 versions. Do not assume CURRENT_FLG='Y' rows are unique on EMP_ID.
- **Manager chain**: MANAGER_EMP_ID is also a code. No resolution to manager names or roles is available in the warehouse.

## Known issues from prose

From DOC-01 (Ani Deshpande, section 11 on territory): "TERRITORY_MASTER, 118 rows. TERRITORY_CD in the form TER-W-014, TERRITORY_NAME, REGION_CD, and EMP_ID which is the territory owner in the form BCPL-EMP-04412. we deliberately do not keep rep names in these tables, only the employee code, that was decided long back and it is a good decision, pls do not undo it in the warehouse."

From DOC-05: "This one already carries EFF_START_DT, EFF_END_DT and CURRENT_FLG. Attributes are EMP_ID, ROLE_CODE, TERRITORY_CODE and MANAGER_EMP_ID. Note there is no name column on this dimension and there should not be one. Employee codes only, in the BCPL-EMP-04412 form."

