---
type: oltp-table
title: OMS_PROD.CUSTOMER_TERRITORY_HIST
description: Territory assignment history for customers. Tracks effective-dated territory transitions with known overlapping periods and no primary key constraint.
resource: OMS_PROD.CUSTOMER_TERRITORY_HIST
tags:
  - customer-territory
  - territory-history
  - dimension-history
  - effective-dating
  - slowly-changing
  - data-quality-issue
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION - schema notes (OLTP side)
    author: Aniruddh Deshpande
    last_modified: "2026-03-09"
  - resource: /_sources/technical/schema_oltp.sql
    id: SCHEMA_CANON
    last_modified: "2026-08-23"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: VAR_REGISTER
    last_modified: "2026-08-23"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:14Z
---

## Purpose and grain

**Purpose:** Append-mostly history table tracking territory assignments for customers over time. Supports reporting queries that need to know which territory a customer belonged to on a given date, and audit trails of territory changes.

**Grain:** One row per customer territory assignment period. No row count specified in documentation, but the table is known to have overlapping rows (see section below).

## Key attributes

### Business columns

- **CUST_ID** (NUMBER(10), NOT NULL): Foreign key to OMS_PROD.CUSTOMER. Identifies the customer.
- **TERRITORY_CD** (VARCHAR2(12), NOT NULL): The territory code assigned to this customer during the period (e.g., `TER-W-014`). Links to TERRITORY_MASTER.
- **EFF_FROM_DT** (DATE, NOT NULL): Effective start date. The date on which this territory assignment began.
- **EFF_TO_DT** (DATE, nullable): Effective end date. Nullable; NULL means the assignment is still in force. When a new territory assignment is created for a customer, the previous row's EFF_TO_DT should be set to the day before the new EFF_FROM_DT, but this is not enforced.

### Audit columns

Standard ORION audit columns:
- CREATED_BY, CREATED_DT: Row creation metadata.
- LAST_UPD_BY, LAST_UPD_DT: Last modification metadata.
- ACTIVE_FLG (CHAR(1), Y/N): Audit flag.
- DELETE_FLAG (CHAR(1), Y/N): Logical deletion flag.

## Known structural issues

### No primary key

The table has **no primary key constraint and no unique constraint on (CUST_ID, EFF_FROM_DT)**. This is deliberate but problematic:

- Multiple rows for the same customer can have overlapping effective date ranges.
- 61 customers have at least one period during which they are assigned to two territories simultaneously.
- Queries joining this table to other tables must decide how to handle overlaps; the database does not prevent or resolve them.
- No mechanism exists to automatically prevent new overlaps from being created.

This design allows the table to be flexible but imposes complexity on consuming layers. The SCD2 implementation in the warehouse (`DIM_CUSTOMER`) must handle these overlaps explicitly; see VAR-004.

### Edited in place

The table is **append-mostly, not append-only**. When a user or administrator notices a territory assignment error, the row is edited in place rather than a new correcting row being inserted. This means:

- LAST_UPD_DT can move on old rows, even years after they were created.
- Incremental extracts keyed on LAST_UPD_DT will re-extract historical periods if corrections are made.
- The timestamp-based change detection cannot distinguish between a new assignment and a correction to an old assignment.

## Relationships with variance records

**VAR-004** documents a variance caused by overlapping territory assignments. Worked example: customer DIST-W-0241 (Mahalaxmi Distributors) was reassigned on 17-Apr-2026 from territory `TER-W-014` to `TER-W-011`. At that transition, both the old and new rows in CUSTOMER_TERRITORY_HIST had overlapping effective date ranges. When the SCD2 dimension in the warehouse processed this, both dimension rows carried `CURRENT_FLG='Y'`, causing invoice facts to join to two dimension rows. This resulted in 61 customers being affected, with 18 having two current rows.

## Indexes

- **Non-unique index** `IX_CTH_CUST` on (CUST_ID, EFF_FROM_DT) supports lookups by customer and effective date.

## Relationships

- Links to `/concepts/tables/oms-prod-customer.md` via CUST_ID.
- Links to `/concepts/tables/oms-prod-territory-master.md` via TERRITORY_CD.
- Links to `/concepts/variances/var-004-scd2-territory-reassignment.md` for the SCD2 overlap issue.

## Data quality implications for the warehouse

When building the warehouse dimension `DIM_CUSTOMER` with SCD2 effective dating, this table presents special handling requirements:

1. **Overlap resolution:** Determine a rule for which row is "current" when overlaps exist (e.g., the row with the latest EFF_FROM_DT).
2. **Gap handling:** Ensure that every day a customer exists, there is an unbroken chain of effective-dated territory rows (or that gaps are expected and documented).
3. **Reprocessing:** If a historical row is corrected (EFF_TO_DT is updated), re-extract all dependent dimensions and facts that reference that customer for the affected date range.

Ani's note (DOC-01) emphasizes that **anybody joining this table to anything must decide for themselves what to do when two rows are open for the same party at the same time.**

## Related variances

- **[VAR-004 — Duplicate facts on distributor reassignment](/concepts/variances/var-004-scd2-territory-reassignment.md)**: the source-side territory history this table carries; the SCD2 defect itself lives in the warehouse's DIM_CUSTOMER, not here, but the worked example (DIST-W-0241) originates from a change recorded in this table.

## Referenced by

- [Data Architecture](/context/data-architecture.md)
