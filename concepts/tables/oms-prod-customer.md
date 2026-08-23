---
type: oltp-table
title: OMS_PROD.CUSTOMER
description: The party master table holding all customers, distributors, modern trade retailers and institutional buyers in the ORION order-to-cash system.
resource: OMS_PROD.CUSTOMER
tags:
  - customer
  - party
  - distributor
  - modern-trade
  - institutional
  - master-data
  - CUST_ID
  - CUST_CODE
sources:
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: ORION - schema notes (OLTP side)
    author: Aniruddh Deshpande
    last_modified: "2026-03-09"
  - resource: /_canon/schema_canon.sql
    id: SCHEMA_CANON
    last_modified: "2026-08-23"
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:14Z
---

## Purpose and grain

**Purpose:** Central customer registry for the ORION order-to-cash application. Holds all parties who are involved in the business: distributors, modern trade outlets, institutional buyers, and others. The table also serves as the hierarchy root for territory assignments and depot relationships.

**Grain:** One row per customer relationship. Approximately 2,140 rows as of March 2026, of which 340 are classified as DISTRIBUTOR; the remainder are MODERN_TRADE or INSTITUTIONAL. The count is subject to growth as new parties are added.

## Key attributes

### Keys and identity

- **CUST_ID** (NUMBER(10), NOT NULL, PK): Surrogate key, meaningless number assigned by the system. Never used in business communication.
- **CUST_CODE** (VARCHAR2(20), NOT NULL, unique): The business identifier, the only code that sales operations and external parties reference. Format examples: `DIST-W-0233` (Sahyog Enterprises, Bhiwandi), `DIST-N-0142` (Trilok Traders, Ghaziabad). No connection between the code pattern and the party's legal entity; one commercial party with two delivery addresses may be represented as two separate rows with different codes.

### Business classification

- **CUST_TYPE** (VARCHAR2(20), check constraint): One of `DISTRIBUTOR`, `MODERN_TRADE`, or `INSTITUTIONAL`. No other values exist.
- **STATUS_FLG** (CHAR(1)): Business availability flag, distinct from ACTIVE_FLG. Values: `A` (active, trading) or `I` (inactive, no longer trading). **Important:** This is NOT the ACTIVE_FLG from the standard audit columns. Confusion between the two flags appears repeatedly in operational code.

### Location and operations

- **TERRITORY_CD** (VARCHAR2(12)): Link to a territory code in TERRITORY_MASTER (e.g., `TER-W-014`). A customer is assigned to one territory at any given time; territory reassignments are tracked in CUSTOMER_TERRITORY_HIST.
- **DEPOT_CD** (VARCHAR2(12)): Primary delivery depot. May be overridden at the line level on orders and invoices. If a party requires two fixed delivery addresses, the standard practice (since the application's inception) is to create a second CUST_CODE with a different DEPOT_CD.
- **CREDIT_LIMIT** (NUMBER(14,2)): The customer's credit exposure limit in INR.

### Data quality notes

- **Name field:** CUST_NAME is 120 characters and retains trailing spaces and double spaces from a 2016 data migration. The field is not trimmed by the application.
- **KYC fields:** The ADF screens added several KYC-related columns later. Most are blank because they were never made mandatory. Only newer customers in the south and west regions have populated KYC data.

## Constraints and indexes

- **Primary key:** `PK_CUSTOMER` on CUST_ID.
- **Unique constraint:** `CK_CUSTOMER_TYPE` enforces CUST_TYPE ∈ {DISTRIBUTOR, MODERN_TRADE, INSTITUTIONAL}.
- **Delete flag constraint:** `CK_CUSTOMER_DEL` enforces DELETE_FLAG ∈ {Y, N}.
- **Unique index:** `UX_CUSTOMER_CODE` on CUST_CODE supports lookups by business code.
- **Last-updated index:** `IX_CUSTOMER_LUD` on LAST_UPD_DT. This index exists solely to support the nightly ODI incremental extract, which uses LAST_UPD_DT as the change-detection predicate.
- **Territory index:** `IX_CUSTOMER_TERR` on TERRITORY_CD.

## Known data quality issues

1. **Two active-like flags:** STATUS_FLG (business availability: A/I) and ACTIVE_FLG (audit flag: Y/N) both signal "active" status but mean different things. Sales operations and reporting sometimes filter on whichever flag gives them the expected answer. When building mappings or extracts, explicitly document which flag is being used.

2. **No foreign key from ORDER_HEADER:** The foreign key from ORDER_HEADER to CUSTOMER was disabled in 2020 during a master data cleanup and was never re-enabled. The cleanup itself left orphan rows that prevent the constraint from being added back. Whether the warehouse should care about these orphans is TBC.

3. **One party, multiple codes:** A single commercial entity can be represented by multiple CUST_CODE values if it has multiple delivery addresses. No column indicates the link. Legacy reports in OBIEE handle this inconsistently. Priya Nair (BI Analyst) knows which reports do and do not account for this pattern.

## Relationships

- Links to `/concepts/tables/oms-prod-customer-territory-hist.md` via CUST_ID for territory assignment history.
- Links to `/concepts/tables/oms-prod-territory-master.md` via TERRITORY_CD for the current territory assignment.
- Links to `/concepts/tables/oms-prod-depot-master.md` via DEPOT_CD for the primary depot.
- Links to `/concepts/tables/oms-prod-invoice-header.md` via CUST_ID for invoices issued to the customer.
- Links to `/concepts/tables/oms-prod-order-header.md` via CUST_ID for orders placed by the customer.
- Links to `/concepts/tables/oms-prod-credit-note.md` via CUST_ID for credit notes issued against the customer.

## Audit columns

Standard ORION audit columns:
- CREATED_BY, CREATED_DT: Row creation metadata.
- LAST_UPD_BY, LAST_UPD_DT: Last modification metadata. LAST_UPD_DT is used for incremental extracts.
- ACTIVE_FLG (CHAR(1), Y/N): Audit flag indicating whether the row is logically active in the system, distinct from STATUS_FLG.
- DELETE_FLAG (CHAR(1), Y/N): Logical deletion flag. Y means logically deleted; N means live.
