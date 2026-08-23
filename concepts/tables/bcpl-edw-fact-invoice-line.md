---
type: warehouse-table
title: FACT_INVOICE_LINE
description: Primary fact table recording one row per invoice line from OMS_PROD, with grain at the line level and links to all core dimensions.
resource: BCPL_EDW.FACT_INVOICE_LINE
tags:
  - invoice
  - sales
  - primary-sales
  - revenue
  - fact
  - FACT_INVOICE_LINE
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23T10:37:25Z
sources:
  - resource: /_sources/technical/schema_edw.sql
    id: TECH-SQL-EDW
    last_modified: "2026-08-23"
  - resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
    id: DOC-01
    title: "ORION OLTP schema notes"
    author: Aniruddh Deshpande
    last_modified: "2026-03-03"
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: "EDW target model notes"
    last_modified: "2026-05-15"
---

## Purpose

FACT_INVOICE_LINE is the primary fact table of the warehouse, capturing every line of every invoice raised by BCPL to its distributors. It feeds all revenue reporting and most dashboards, and serves as the hub to which other facts are compared.

## Grain

**One row per invoice line as it exists in OMS_PROD.INVOICE_LINE.** Not one row per invoice, not one row per invoice per SKU. Grain is atomic: every distinct line_no within every distinct invoice becomes one row.

The surrogate key is INVOICE_LINE_KEY. Source identifiers INVOICE_ID and INVOICE_LINE_ID are carried as degenerate dimensions—business identifiers that live on the fact row with no separate dimension table. As DOC-05 notes: "There is no reason to build a DIM_INVOICE and I will push back hard if anybody proposes one."

## Dimension Keys

- **DATE_KEY**: links to DIM_DATE; derived from INVOICE_DT (the business date), not CREATED_TS (which is in UTC). See [VAR-002](/concepts/variances/var-002-date-key-timezone.md).
- **CUSTOMER_KEY**: links to DIM_CUSTOMER.
- **PRODUCT_KEY**: links to DIM_PRODUCT.
- **GEO_KEY**: links to DIM_GEOGRAPHY.
- **SALESREP_KEY**: links to DIM_SALESREP.
- **SCHEME_KEY**: links to DIM_SCHEME; identifies which scheme (if any) was applied to this line.

## Measure Columns

- **QTY_CS**, **QTY_EA**: Case and each quantities. Source INVOICE_LINE carries both; cases and eaches are the business unit distinction.
- **GROSS_AMT**: Gross amount before any discount or tax.
- **SCHEME_DISC_AMT**: Scheme discount amount. Carries a known issue: see Discrepancy section below.
- **CASH_DISC_AMT**: Cash discount amount.
- **TAX_AMT**: Tax amount (GST).
- **NET_AMT**: Net amount after discounts and tax.

## Control Columns

- **SRC_DELETE_FLAG**: Soft-delete flag carried through from OMS_PROD.INVOICE_LINE. Values 'Y', 'N', or NULL. Originally not filtered during extract, which caused VAR-001 (cancelled lines counted as revenue). Since CHG0021184 (03-Jun-2026), filtered as `NVL(SRC_DELETE_FLAG,'N')='N'` in the mapping. Still carries the flag for audit trail.
- **LOAD_DT**: Date the row was loaded into the warehouse.
- **BATCH_ID**: References ETL_BATCH_CONTROL; every row is stamped with the load plan run it arrived in. DOC-05 calls this "the single most useful thing in the entire control layer."
- **ODI_SESS_NO**: ODI session number for traceability.

## Constraints and Indexes

- **Primary key**: INVOICE_LINE_KEY.
- **Missing constraint**: There is NO unique constraint on (INVOICE_ID, INVOICE_LINE_ID). This absence is load-bearing: a unique key would have raised ORA-00001 on the first duplicate insert in 2021, preventing the silent duplicates that caused VAR-008. The constraint gap is intentional for failure visibility.
- **Indexes**:
  - `IX_FIL_DATE` on DATE_KEY (LOCAL tablespace EDW_IDX)
  - `IX_FIL_CUST` on (CUSTOMER_KEY, DATE_KEY) (LOCAL tablespace EDW_IDX)
  - `IX_FIL_PROD` on PRODUCT_KEY (LOCAL tablespace EDW_IDX)

LOCAL indexes indicate the table is partitioned (almost certainly on DATE_KEY per DOC-05, though Ani had not yet confirmed the partition scheme at the time of writing).

## Data Quality Issues

### VAR-001: DELETE_FLAG Not Filtered (CLOSED)

Until CHG0021184 on 03-Jun-2026, the extract mapping MAP_FACT_INVOICE_LINE carried no filter on SRC_DELETE_FLAG. Cancelled invoice lines (DELETE_FLAG = 'Y') were loaded as if they were live sales, overstating FY26 Q1 revenue. Root cause: the mapping clause was never written. Fixed by adding `NVL(SRC_DELETE_FLAG,'N')='N'` to the WHERE clause. Impact: INR 4.20 Cr, closed.

### VAR-003: SCHEME_DISC_AMT Double-Counted (OPEN)

SCHEME_DISC_AMT on the fact row carries the amount of scheme discount that was applied on that invoice line. However, the business's understanding of scheme discount (the accrual basis in FIN_PROD.SCHEME_ACCRUAL) is a separate table at customer-scheme-period grain that does not reconcile line-by-line to FACT_INVOICE_LINE. DOC-01 notes: "SCHEME DISCOUNT amount you see on a line is the outcome of a decision that is not recorded anywhere in ORION."

The issue is structural: the warehouse is carrying both the line-level transactional amount and Finance is maintaining an accrual amount outside the warehouse (in Excel). This double-counts scheme discount in reconciliations. Open. See [ADR-004](/decisions/adr-004-scheme-discount-handling.md).

### VAR-008: Batch Duplication (CLOSED)

On Sat 14-Feb-2026, LP_DAILY_SALES was re-run manually after a first failure (session SESS_884012). The IKM Oracle Control Append appended the entire night's data again instead of skipping it, duplicating 2.9 Cr of sales. The duplicate sat in February figures for three weeks before discovery. Root cause: BATCH_ID was not used to guard against duplicate batch inserts. Fixed in R2026.07 (deployed 08-Jul-2026) by adding batch-id uniqueness check. Impact: INR 2.90 Cr, closed.

### DQ-R-12: SRC_DELETE_FLAG Nullness

Data quality rule DQ-R-12 measures null rate on SRC_DELETE_FLAG. Historical archive rows and a legacy data load carry NULL (the flag did not exist until 2016). Rows with DELETE_FLAG = NULL should be treated as 'N' (live) but the profiling rule flags nulls as failures. This is a rule definition issue, not a data issue.

## Relationships

- Joins to DIM_DATE on DATE_KEY.
- Joins to DIM_CUSTOMER on CUSTOMER_KEY.
- Joins to DIM_PRODUCT on PRODUCT_KEY.
- Joins to DIM_GEOGRAPHY on GEO_KEY.
- Joins to DIM_SALESREP on SALESREP_KEY.
- Joins to DIM_SCHEME on SCHEME_KEY (can be -1 for UNKNOWN/no scheme).
- Feeds dashboards D01 (Primary Sales Performance), D03 (Distributor Scorecard), D05 (Stock and Despatch), D07 (Revenue Reconciliation), D09 (Product Mix and Contribution), D12 (Executive Summary).

## Discrepancy

### Partition Scheme Unconfirmed

**DDL states**: Indexes are created LOCAL, which requires the table to be partitioned. The partition clause is not visible in the schema_canon.sql provided.

**Prose (DOC-05) states**: "It is almost certainly DATE_KEY. I would rather have it confirmed than assume it and then design a load around the assumption. [Ani to confirm]"

The DDL comment following the index creation is: `-- *** THERE IS NO UNIQUE CONSTRAINT ON INVOICE_LINE_ID. THAT IS THE POINT. ***`

**Resolution**: Neither source explicitly states the partition key. The warehouse is in production; the partition scheme must be documented separately or confirmed with Ani Deshpande.


## Related variances

- **[VAR-001 — FY26 Q1 revenue overstated](/concepts/variances/var-001-q1-revenue-overstated.md)**: SRC_DELETE_FLAG not filtered, described above under Data Quality Issues.
- **[VAR-002 — Month-end boundary drift](/concepts/variances/var-002-date-key-timezone.md)**: DATE_KEY derivation, described above under Dimension Keys.
- **[VAR-003 — Scheme discount double-count](/concepts/variances/var-003-scheme-discount-double-count.md)**: SCHEME_DISC_AMT double-counted, described above under Data Quality Issues.
- **[VAR-004 — Duplicate facts on distributor reassignment](/concepts/variances/var-004-scd2-territory-reassignment.md)**: a fact row here joins to two DIM_CUSTOMER rows when the SCD2 bug fires, doubling the affected customer's revenue.
- **[VAR-007 — Late-arriving SKUs to UNKNOWN member](/concepts/variances/var-007-late-arriving-sku-unknown-member.md)**: PRODUCT_KEY resolves to -1 on this fact when the SKU dimension hasn't caught up yet.
- **[VAR-008 — Feb duplicate load](/concepts/variances/var-008-feb-duplicate-load.md)**: batch duplication, described above under Data Quality Issues.
- [VAR-005 — Credit notes absent from warehouse](/concepts/variances/var-005-credit-notes-absent.md)

## Referenced by

- [Data Architecture](/context/data-architecture.md)

## Related decisions

- [ADR-005 — DATE_KEY on FACT_INVOICE_LINE derived from INVOICE_DT, not CREATED_TS](/decisions/20260506-var002-date-key-fix.md)
- [ADR-004 — VAR-003 remediation: rebuild MAP_FACT_INVOICE_LINE as a key-based merge](/decisions/20260506-var003-remediation-key-based-merge.md)
