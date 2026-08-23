---
type: warehouse-table
title: DIM_GEOGRAPHY
description: Physical geography dimension covering depots, cities, states, and regions.
  SCD1 (no history). Natural key is DEPOT_CODE from ORION DEPOT_MASTER. 22 rows plus
  UNKNOWN.
resource: BCPL_EDW.DIM_GEOGRAPHY
tags:
- dimension
- scd1
- conformed-dimension
- geography
- depot
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23 10:36:54+00:00
sources:
- resource: /_sources/technical/schema_edw.sql
  id: SCHEMA
  last_modified: '2026-08-23'
- resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
  id: DOC-05
  title: BCPL_EDW target model - working notes
  author: Ishaan Bhatt
  last_modified: '2026-04-08'
- resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
  id: DOC-01
  title: ORION - schema notes (OLTP side)
  author: Aniruddh Deshpande
  last_modified: '2026-03-09'
---


## Purpose and grain

DIM_GEOGRAPHY represents the physical locations (depots) from which BCPL distributes goods. It is **SCD1** (no effective dating), meaning attributes are overwritten in place and no history is kept.

Grain: **one row per depot (physical warehouse location).**

Population: 22 rows representing all active BCPL depots, plus UNKNOWN at GEO_KEY = -1.

## Key columns

**GEO_KEY** (NUMBER(6), NOT NULL, Primary Key)
- Surrogate key, meaningless, allocated from sequence.
- UNKNOWN member at GEO_KEY = -1 for unmatched facts.

**DEPOT_CODE** (VARCHAR2(12))
- Natural key, equals `OMS_PROD.DEPOT_MASTER.DEPOT_CD`.
- Format examples: DEP-MUM-01 (Bhiwandi), DEP-BLR-08 (Bengaluru), DEP-KOL-11 (Kolkata).
- Unique; one row per physical depot.

**DEPOT_NAME** (VARCHAR2(80))
- Human-readable depot name. Example: "Bhiwandi" for DEP-MUM-01.

## Geographic hierarchy

**CITY** (VARCHAR2(60))
- City where the depot is located.

**STATE_CODE** (VARCHAR2(6)), **STATE_NAME** (VARCHAR2(60))
- GST state code (held as string to preserve leading zeros, e.g., '27' = Maharashtra) and full state name.

**REGION_CODE** (VARCHAR2(6)), **REGION_NAME** (VARCHAR2(30))
- Sales region assignment. 
- **Four regions only**: NORTH, WEST, SOUTH, EAST.
- No fifth region exists in BCPL's organizational structure, regardless of sales presentations.
- Derived from `OMS_PROD.DEPOT_MASTER.REGION_CD`.

## Audit columns

**LOAD_DT** (DATE)
- Date the row was loaded into the warehouse.

## Constraints and indexes

- **Primary Key**: GEO_KEY (NOT NULL)
- No unique constraint on DEPOT_CODE (natural key), but all rows in ORION are unique by design.

## Relationships

DIM_GEOGRAPHY is a **conformed dimension** shared by:
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](FACT_INVOICE_LINE)
- [/concepts/tables/bcpl-edw-fact-order-line.md](FACT_ORDER_LINE)
- [/concepts/tables/bcpl-edw-fact-secondary-sales.md](FACT_SECONDARY_SALES)

All facts join on GEO_KEY. This represents the destination location (where the depot shipped the goods), not the customer's sales territory.

## Design notes

**Depot vs. Territory distinction** (from DOC-05):
- Territory is a sales organization unit; depot is a physical warehouse location.
- They are two separate hierarchies cut for different purposes.
- A territory does NOT roll up into a depot, and a depot does NOT roll up into a territory.
- When business users ask for "sales by state," explicitly clarify: do they mean the state where goods were shipped (geography) or the state where the sales rep's territory is based? Ask first, build second.

**Stability**: DIM_GEOGRAPHY is small (22 rows), stable, and boring—which is exactly what you want from a geography dimension. Rarely changes.

## Data quality considerations

- **Completeness**: All 22 physical depots are represented; coverage is 100%.
- **Consistency**: REGION_CODE values are restricted to four values and are consistent across all rows.
- **Natural key**: DEPOT_CODE is the stable unique identifier. SCD1 treats it as immutable.

## Known issues from prose

From DOC-01 (Ani Deshpande, section 11 on depot and territory): "DEPOT_MASTER, 22 rows. DEPOT_CD looks like DEP-MUM-01 (Bhiwandi), DEP-BLR-08 (Bengaluru), DEP-KOL-11 (Kolkata) and so on. CITY, STATE_CD which is the two character GST state code held as a string ('27' Maharashtra, '29' Karnataka, '07' Delhi), and REGION_CD which is one of NORTH, WEST, SOUTH, EAST. four regions. there is no fifth region and there never has been, whatever the sales presentations show."

From DOC-05: "22 rows. The grain is the depot. DEPOT_CODE is the natural key and it carries DEPOT_NAME, CITY, STATE_CODE, STATE_NAME, REGION_CODE and REGION_NAME. Small, stable, boring, which is what you want from a geography dimension."
## Referenced by

- [Data Architecture](/context/data-architecture.md)

