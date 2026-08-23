---
type: oltp-table
title: Depot Master
description: Master data for BCPL's 22 distribution centers (depots) organized by region and state.
resource: OMS_PROD.DEPOT_MASTER
tags:
  - depot
  - distribution center
  - warehouse
  - geography
  - region
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION OLTP Schema Notes
    author: Aniruddh Deshpande
    last_modified: "2026-03-08"
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: EDW Target Model Notes
    last_modified: "2026-05-20"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:07Z
---

## Purpose

Reference table defining BCPL's physical distribution network. Stores metadata for 22 operating depots (distribution centers) across four geographic regions. Used by order management, invoicing, and inventory operations to route shipments and track regional performance.

## Grain and Volume

One row per active distribution center. Exactly 22 rows, stable and rarely changing. Regional breakdown: NORTH (6 depots), WEST (6), SOUTH (5), EAST (5). This four-region structure is canonical and deliberate; there is no fifth region despite occasional references in business presentations.

## Key Columns

**DEPOT_CD** (Primary Key, VARCHAR2(12))
Unique business code for each depot. Format pattern: `DEP-<CITY>-<NN>`, e.g., `DEP-MUM-01` (Bhiwandi), `DEP-BLR-08` (Bengaluru), `DEP-KOL-11` (Kolkata). The city abbreviation and sequence number provide geographic and operational context.

**DEPOT_NAME** (VARCHAR2(80))
Full business name of the depot location. Used in reports and correspondence (e.g., "Bhiwandi Distribution Center", "Bengaluru Hub").

**CITY** (VARCHAR2(60))
City where the depot is located. Text field to accommodate various city name lengths and spellings.

**STATE_CD** (VARCHAR2(6))
Two-character GST state code held as a VARCHAR2 string (not a number), e.g., '27' for Maharashtra, '29' for Karnataka, '07' for Delhi. Stored as string to preserve leading zeros (historically, a failed attempt to make this a NUMBER caused schema issues in 2017 and was abandoned). The state code ties depots to GST rate determination via FIN_PROD.TAX_RATE_MASTER.

**REGION_CD** (VARCHAR2(6))
One of four values: NORTH, WEST, SOUTH, EAST. Defines the sales region to which the depot belongs and is used for regional rollups in reporting. Not a hierarchy; depots roll up cleanly by region but do not further roll up into sub-zones or districts.

## Audit and Lifecycle Columns

- **CREATED_BY, CREATED_DT**: Row creation metadata. Both DATE types in IST.
- **LAST_UPD_BY, LAST_UPD_DT**: Last modification timestamp. LAST_UPD_DT is a DATE in IST.
- **ACTIVE_FLG**: Business availability flag ('Y' or 'N'). Closed or consolidated depots are marked 'N' but are not deleted (history is retained).
- **DELETE_FLAG**: Logical deletion ('Y', 'N', or NULL on very old rows). Used to exclude decommissioned depots from transactional processing.

## Constraints

- **PK_DEPOT_MASTER**: PRIMARY KEY on DEPOT_CD

## Relationship to Territory and Geography

Depot and territory are two **separate and independent hierarchies** in ORION. A territory does not roll up into a depot and vice versa. They are "cut differently for different reasons":
- Depots are physical inventory hubs organized by geographic region (for supply chain).
- Territories are sales management units organized around sales rep assignments and customer coverage.

When a business question asks for "sales by state", it must be clarified whether the reporting dimension is:
- The state where the goods were dispatched from (depot state), or
- The state where the customer is located (customer territory state).

Both are valid; different reports may use different dimensions. See /concepts/tables/oms-prod-territory-master.md for the territory hierarchy.

## Warehouse Target

In BCPL_EDW, DEPOT_MASTER is the source for the DIM_DEPOT dimension. The warehouse adds STATE_NAME and REGION_NAME as text translations for display. The warehouse grain is one row per depot (22 rows, matching the source). Depot is a small, stable, boring dimension, which is what you want from reference data.

## Related Tables

- /concepts/tables/oms-prod-invoice-header.md (DEPOT_CD links invoices to shipping origin)
- /concepts/tables/oms-prod-order-header.md (DEPOT_CD links orders to fulfillment depot)
- /concepts/tables/oms-prod-territory-master.md (separate geography hierarchy for sales management)
- /concepts/tables/oms-prod-customer.md (CUSTOMER.DEPOT_CD links customers to their home depot)

## Referenced by

- [Data Architecture](/context/data-architecture.md)
