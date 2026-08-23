---
type: warehouse-table
title: DIM_CUSTOMER
description: Customer (distributor, modern trade, institutional) dimension with SCD2 history tracking effective date changes and territory reassignments. Subject to VAR-004.
resource: BCPL_EDW.DIM_CUSTOMER
tags:
  - dimension
  - scd2
  - conformed-dimension
  - party-master
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

DIM_CUSTOMER holds the master party data for all customers: distributors, modern trade, and institutional buyers. It is **slowly changing dimension type 2 (SCD2)** as of 06-May-2026. Every row represents a distinct version of a customer, with effective dating capturing when the customer's attributes changed.

Grain: **one row per customer attribute version, effective-dated.**

Current population: approximately 2,140 current rows, with projections of ~6,900 by Mar-2027. In ORION, these are rows in OMS_PROD.CUSTOMER with `CUST_TYPE` = 'DISTRIBUTOR', 'MODERN_TRADE', or 'INSTITUTIONAL'. Of the 2,140 current customers, 340 are DISTRIBUTOR type.

## Key columns

**CUSTOMER_KEY** (NUMBER(10), NOT NULL, Primary Key)
- Surrogate key, meaningless, allocated from sequence.
- UNKNOWN member at CUSTOMER_KEY = -1 for unmatched facts.

**CUSTOMER_ID** (NUMBER(10))
- Natural key, equals `OMS_PROD.CUSTOMER.CUST_ID`.
- Identifies the underlying business entity across all versions.

**CUSTOMER_CODE** (VARCHAR2(20))
- Business code, unique in ORION. Examples: DIST-W-0233 (Sahyog Enterprises), DIST-N-0142 (Trilok Traders).
- This is the code sales operations staff use when identifying customers; they use CODE, never ID.

## Attributes

**CUSTOMER_NAME** (VARCHAR2(120))
- Firm name. Contains trailing spaces and double spaces inherited from the 2016 ORION migration.

**CUSTOMER_TYPE** (VARCHAR2(20))
- Business entity type: 'DISTRIBUTOR', 'MODERN_TRADE', or 'INSTITUTIONAL'.
- In ORION this is `CUST_TYPE`, check-constrained to these three values only.

**TERRITORY_CODE** (VARCHAR2(12))
- Sales territory code from ORION, e.g., 'TER-W-014'.
- Territory is a sales hierarchy, distinct from geography/depot. A customer belongs to one territory but a territory may span multiple depots.

**REGION_CODE** (VARCHAR2(6))
- Four regions only: 'NORTH', 'WEST', 'SOUTH', 'EAST'. No fifth region exists.
- Carried from TERRITORY_MASTER.REGION_CODE via the territory.

**STATE_CODE** (VARCHAR2(6))
- GST state code, held as a string to preserve leading zeros. Example: '27' = Maharashtra, '29' = Karnataka, '07' = Delhi.

**DEPOT_CODE** (VARCHAR2(12))
- Primary depot for this customer, e.g., 'DEP-MUM-01', 'DEP-BLR-08'.
- Not the shipping address (ORION has no separate ship-to table). If a customer needs multiple delivery addresses, ORION opens a second CUST_CODE for them.

**CREDIT_LIMIT_AMT** (NUMBER(14,2))
- Current credit limit from ORION.
- **Warning**: this is a point-in-time current-state number on a dimension row. It is correct for today's view but wrong for historical queries. A trend built on this column will misrepresent the past. Document this caveat wherever this column is used.

## Effective dating and history

**EFF_START_DT** (DATE)
- Date this version of the customer became effective.

**EFF_END_DT** (DATE)
- Date this version of the customer ended (NULL for the current row).

**CURRENT_FLG** (CHAR(1))
- Flag indicating the current version: 'Y' for the active version, 'N' for historical versions.
- **Critical for VAR-004**: see Variance section below.

## Audit columns

**LOAD_DT** (DATE)
- Date the row was loaded into the warehouse.

**UPD_DT** (DATE)
- Date the row was last updated (changed).

## Constraints and indexes

- **Primary Key**: CUSTOMER_KEY (NOT NULL)
- **Index**: `IX_DIMCUST_NK` on (CUSTOMER_ID, CURRENT_FLG) for efficient current-row lookups.
- **Note**: No unique constraint on (CUSTOMER_ID, CURRENT_FLG='Y'). Such a constraint would have prevented VAR-004.

## Relationships

DIM_CUSTOMER is a **conformed dimension** shared by:
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](FACT_INVOICE_LINE)
- [/concepts/tables/bcpl-edw-fact-order-line.md](FACT_ORDER_LINE)
- [/concepts/tables/bcpl-edw-fact-secondary-sales.md](FACT_SECONDARY_SALES)

All facts join on CUSTOMER_KEY to this dimension.

## Vocabulary note

From DOC-05: naming consistency is an open action. The same business entity is called:
- **"customer"** in the warehouse (CUSTOMER_ID, CUSTOMER_CODE, CUSTOMER_NAME in DDL).
- **"party"** in ORION (party code, party master, party master).
- **"distributor"** by business users.

All three words refer to the same thing. The reporting layer (Power BI) must choose one term and hold it consistently. This is documented in DOC-05 as an open item.

## Variance linkage

### VAR-004 — Territory reassignment SCD2 bug

**Status**: Open  
**Severity**: High  
**Root cause**: On a customer territory reassignment, the SCD2 logic sets the closing row's EFF_END_DT to the same timestamp as the new row's EFF_START_DT but leaves CURRENT_FLG='Y' on BOTH rows. This causes a fact row joining on CUSTOMER_KEY to match two dimension rows, both marked current.

**Impact**: 61 customers have overlapping effective date ranges, of which 18 carry two current rows. This doubles revenue on affected customer lines.

**Worked example** (from canon): DIST-W-0241 (Mahalaxmi Distributors) was reassigned from territory TER-W-014 to TER-W-011 on 17-Apr-2026. Both rows carry CURRENT_FLG='Y' and overlap, so invoice lines for Mahalaxmi double-count.

**Detection**: Fails DQ-R-07 (conformed dimension uniqueness).

**Fix**: Open. Planned design change: add a unique constraint on (CUSTOMER_ID, CURRENT_FLG='Y') to the dimension, and amend the SCD2 close logic to set EFF_END_DT to the sysdate of the new row's start minus 1 second, so rows never overlap in time.

See [/concepts/variances/var-004.md](/concepts/variances/var-004.md).

## Data quality considerations

- **Overlapping effective dates** (VAR-004): 61 customers affected.
- **Natural key uniqueness**: The natural key (CUSTOMER_ID, CURRENT_FLG) is indexed but not constrained. Duplicates are possible.
- **Null handling**: CURRENT_FLG is a required column; all rows must have 'Y' or 'N'.
- **Stale territory data**: Territory can change in ORION and is reflected in this dimension, but the mapping is refreshed on the nightly load. Territory changes in ORION are captured when the dimension is next loaded.

## Load performance

From DOC-05 (Farida Contractor's concern): MAP_DIM_CUSTOMER currently runs 4 min 12 sec on the nightly load. On month-end nights the full load finishes 04:10-04:12 IST. The load window SLA is 05:30 IST. This dimension has caused SLA breach twice in FY26 Q4 (14-Feb and 02-Mar 2026). Any changes to the dimension or its mapping require measured performance validation before deployment.

## Known issues from prose

From DOC-01 (Ani Deshpande): ORION.CUSTOMER has a STATUS_FLG field ('A' = active, 'I' = inactive) which is a business column distinct from the audit ACTIVE_FLG. They often mean different things. The mapping must specify which flag is used to filter current customers.

From DOC-05: "CREDIT_LIMIT_AMT bothers me slightly. It is a current state number sitting on a dimension, which is perfectly fine if you are looking at a scorecard today and wrong the moment you look back at last year."

