---
type: oltp-table
title: OMS_PROD.TERRITORY_MASTER
description: Territory master data defining sales territories, region assignments,
  and territory ownership by employee ID.
resource: OMS_PROD.TERRITORY_MASTER
tags:
- territory
- region
- sales-ops
- geography
- TER-*
- TERRITORY_CD
- REGION_CD
- employee
sources:
- resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
  id: DOC-01
  title: ORION - schema notes (OLTP side)
  author: Aniruddh Deshpande
  last_modified: '2026-03-09'
- resource: /_sources/technical/schema_oltp.sql
  id: SCHEMA_CANON
  last_modified: '2026-08-23'
generated:
  by: process:claude-haiku/tables
  at: "2026-08-23T10:37:14Z"
---


## Purpose and grain

**Purpose:** Master dimension for sales territories. Defines each sales territory, its geographic region, and the employee who owns (manages) it. Used as a reference dimension for territory lookups from CUSTOMER and CUSTOMER_TERRITORY_HIST, and as a hierarchy root for sales reporting by territory and region.

**Grain:** One row per territory. **118 rows** as of the last documentation date.

## Key attributes

### Territory identity

- **TERRITORY_CD** (VARCHAR2(12), NOT NULL, PK): Unique territory code. Format examples: `TER-W-014`, `TER-N-007`, `TER-S-021`, `TER-E-105`. The two-letter region code is embedded in the code itself for readability.
- **TERRITORY_NAME** (VARCHAR2(80)): Human-readable territory name (e.g., "Western Division - Gujarat", "Northern Division - Punjab").

### Geographic and ownership

- **REGION_CD** (VARCHAR2(6)): The region to which the territory belongs. **Exactly four regions exist and have always existed**: `NORTH`, `WEST`, `SOUTH`, `EAST`. No fifth region has ever been created, regardless of what sales presentation materials may show.
- **EMP_ID** (VARCHAR2(20)): The territory owner / manager, stored as an employee code (e.g., `BCPL-EMP-04412`). **The ORION system deliberately stores only the employee ID, not the employee name.** This design decision was made early and is considered good by the data team; it avoids name updates and keeps the dimension clean. Do not undo this pattern in the warehouse.

### Audit columns

Standard ORION audit columns:
- CREATED_BY, CREATED_DT: Row creation metadata.
- LAST_UPD_BY, LAST_UPD_DT: Last modification metadata.
- ACTIVE_FLG (CHAR(1), Y/N): Audit flag indicating whether the territory is active in the system.
- DELETE_FLAG (CHAR(1), Y/N): Logical deletion flag.

## Constraints and indexes

- **Primary key:** `PK_TERRITORY_MASTER` on TERRITORY_CD.
- **No unique indexes** other than the PK.
- **No foreign key** to any employee or HR table. EMP_ID is a reference to the BCPL employee ID namespace but is not enforced as a constraint. Employee names, roles, and hierarchies must be looked up in an external HR system if needed.

## Hierarchical structure

Territories roll up to regions, not to depots. These are two separate hierarchies:

- **Territory → Region:** Each territory (118 rows) maps to exactly one of the four regions (NORTH, WEST, SOUTH, EAST).
- **Depot hierarchy:** Depots (22 rows, defined in DEPOT_MASTER) are organized by city and state, not by territory. A territory does not roll up into a depot, and a depot does not roll up into a territory.

When business questions ask for "sales by state," be clear about which hierarchy is being queried: "state the goods were delivered to" (depot side) or "state the territory owner is based in" (territory side).

## Relationships

- Links to `/concepts/tables/oms-prod-customer.md` via TERRITORY_CD (customer's current territory).
- Links to `/concepts/tables/oms-prod-customer-territory-hist.md` via TERRITORY_CD (customer's territory history).
- Links to `/concepts/tables/oms-prod-depot-master.md` (implicit: both are geographic dimensions but follow separate hierarchies).
- Links to warehouse concept `/concepts/tables/bcpl-edw-dim-territory.md` (when created) for the conformed warehouse territory dimension.

## Design philosophy

Per Ani's note in DOC-01 (section 11):

> "We deliberately do not keep rep names in these tables, only the employee code. That was decided long back and it is a good decision. Please do not undo it in the warehouse."

Downstream systems (the warehouse, reports, BI) should respect this principle:
- Store EMP_ID in warehouse dimensions without dereferencing it to employee names.
- If employee names are needed in a report, join to the HR employee master separately, late in the process.
- This keeps the data warehouse independent of HR master data changes and prevents name updates from cascading through the fact tables.

## Four regions, always

The four region codes are hard-coded in checks and business logic throughout ORION and in reporting. Do not invent a fifth region, do not soft-delete a region, and do not rename them.
## Referenced by

- [Data Architecture](/context/data-architecture.md)

