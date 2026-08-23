REM ============================================================================
REM  schema_canon.sql
REM  BCPL  |  Project Bharadwaj  |  AUTHORITATIVE DDL BASELINE
REM  Target: Oracle Database 19c Enterprise Edition (19.18.0.0.0)
REM  gen-seed: 20260822
REM ----------------------------------------------------------------------------
REM  CANON-INTERNAL. Phase A output. NOT an artifact. NOT part of _sources/.
REM  Do not copy this file into _sources/. Write schema_oltp.sql and
REM  schema_edw.sql yourself, using these names, with generated-DDL noise.
REM ============================================================================

REM  ##########################################################################
REM  ##  PRECEDENCE  -  RECONCILED AT THE PHASE A EXIT GATE, 22-Aug-2026    ##
REM  ##########################################################################
REM
REM  CANON.md in this directory is the master fact sheet and it is BINDING.
REM  THIS FILE NOW IMPLEMENTS CANON.md SECTION 9 EXACTLY. There are no open
REM  name collisions between the two any more.
REM
REM  An earlier revision of this file carried a different object registry
REM  (CUSTOMER_MASTER, ITEM_MASTER, ORD_HEADER/ORD_LINE, DISTRIBUTOR_MASTER,
REM  FIN_PROD.INVOICE_HEADER/INVOICE_LINE, CREDIT_NOTE_HEADER, WH_LOAD_AUDIT,
REM  WH_ERROR_LOG, DIM_DISTRIBUTOR, FACT_SALES_ORDER, FACT_RETURNS,
REM  AGG_MONTHLY_SALES and others). Every one of those names is now DEAD.
REM  They are listed in CANON.md section 20.2 as the closed-universe exclusion
REM  list. None of them appears in this file any more and none of them may
REM  appear in any artifact in _sources/.
REM
REM  This file and procs_canon.sql are consistent with each other and with
REM  CANON.md section 9. procs_canon.sql carries the same tables in a leaner
REM  form plus the PKG_MONTH_END package shape; this file carries the full
REM  convention commentary, constraints, indexes, seeds and plumbing.
REM
REM  OBJECT COUNTS, FROZEN
REM      OMS_PROD                      13 tables
REM      FIN_PROD                       7 tables
REM      OLTP TOTAL                    20 tables
REM      BCPL_EDW model tables         12 tables  (8 dimension/reference,
REM                                                3 fact, 1 security)
REM      BCPL_EDW ETL control tables    3 tables
REM      BCPL_EDW TOTAL                15 tables
REM      STG_ORION landing tables      13 tables  (disposable, listed only)
REM  There is NO BCPL_EDW.FACT_CREDIT_NOTE. See section 3.
REM  ##########################################################################

REM ----------------------------------------------------------------------------
REM  FISCAL YEAR CONVENTION  (applies everywhere: OLTP, EDW, reporting)
REM      FY26 = 01-Apr-2025 through 31-Mar-2026.
REM      Fiscal period 1 = April, period 12 = March.
REM      Fiscal quarters: Q1 Apr-Jun, Q2 Jul-Sep, Q3 Oct-Dec, Q4 Jan-Mar.
REM      "FY" label always names the year the fiscal year ENDS in.
REM      So an invoice dated 12-Feb-2026 is FY26 P11 Q4. Yes people get this
REM      wrong constantly, especially in decks. It is FY26.
REM      Identical to CANON.md section 2. Do not restate it differently.
REM ----------------------------------------------------------------------------
REM  ENVIRONMENTS / SCHEMAS
REM      OMS_PROD   order to cash. Schema inside the OLTP application known
REM                 everywhere as ORION. Host orion-db-prd-01.bcpl.local.
REM                 INVOICING LIVES HERE, not in FIN_PROD.
REM      FIN_PROD   GL, AR, tax rates, accruals, period control, month end.
REM                 Same ORION instance as OMS_PROD, separate schema.
REM      OMS_RO     read only account used by the extracts.
REM      ODI_STG_RD the ODI reader account.
REM      BCPL_EDW   enterprise warehouse. Separate instance,
REM                 host edw-db-prd-01.bcpl.local. Single instance.
REM      STG_ORION  ODI staging / work schema. Sits INSIDE the EDW instance,
REM                 not inside ORION. Holds STG_* landing tables plus the ODI
REM                 generated C$ / I$ / E$ objects. Disposable.
REM ============================================================================

SET DEFINE OFF
WHENEVER SQLERROR CONTINUE

PROMPT ====== SECTION 0: CONVENTIONS ======

/* ----------------------------------------------------------------------------
   AUDIT COLUMN CONVENTION  (OLTP ONLY: OMS_PROD + FIN_PROD)
   ----------------------------------------------------------------------------
   RECONCILED SPELLING. CANON.md section 20.3 governs and this is it. An
   earlier revision of this file used CREATED_DATE / LAST_UPDATED_DATE /
   LAST_UPDATED_BY / ACTIVE_FLAG. Those spellings are DEAD. Do not use them
   anywhere, in any artifact, in any comment, in any mapping document.

   Every table in OMS_PROD and FIN_PROD carries the same six columns, in the
   same order, at the END of the column list:

       CREATED_BY       VARCHAR2(30)
       CREATED_DT       DATE            -- see the exception below
       LAST_UPD_BY      VARCHAR2(30)
       LAST_UPD_DT      DATE
       ACTIVE_FLG       CHAR(1)         'Y' / 'N'
       DELETE_FLAG      CHAR(1)         'Y' / 'N' / NULL

   THE ONE EXCEPTION, AND IT IS LOAD BEARING.
   On the transaction tables the created column is a TIMESTAMP written by the
   application server IN UTC, and it is called CREATED_TS, not CREATED_DT:

       OMS_PROD.INVOICE_HEADER        CREATED_TS  TIMESTAMP(6)
       OMS_PROD.INVOICE_LINE          CREATED_TS  TIMESTAMP(6)
       OMS_PROD.INVOICE_LINE_ARCHIVE  CREATED_TS  TIMESTAMP(6)
       OMS_PROD.ORDER_HEADER          CREATED_TS  TIMESTAMP(6)
       OMS_PROD.CREDIT_NOTE           CREATED_TS  TIMESTAMP(6)
       FIN_PROD.SCHEME_ACCRUAL        CREATED_TS  TIMESTAMP(6)

   INVOICE_HEADER.CREATED_TS being UTC while INVOICE_DT is a DATE in IST is
   the entire mechanism of VAR-002. Renaming it or making it a DATE destroys
   the variance. CANON.md section 9.1 mandates this and wins.

   The second exception: OMS_PROD.INVOICE_LINE_ARCHIVE is "the same shape
   minus DELETE_FLAG" (CANON.md section 9.1). It carries five of the six.
   The column never existed on it because the table was closed off in 2016,
   three years before the soft delete programme.

   CREATED_BY / LAST_UPD_BY hold either an application user id or a batch
   service account. The service accounts you will actually see in prod data
   are 'ODI_LOAD', 'BATCH_OMS', 'SVC_FINBATCH', 'DMS_IFACE', 'SFA_IFACE' and
   the old 'APPS' (pre-2018 migrated rows). CANON.md section 20.4 blesses
   these for use in sample data and schema commentary.

   LAST_UPD_DT is the ONLY change-capture mechanism available to the
   warehouse. There is no GoldenGate, no CDC, no journalising. Everything
   incremental is a timestamp comparison. Keep that in mind when reading the
   ODI notes, it explains most of what goes wrong. It is also the column the
   incremental extract predicate keys off:
       STG_INVOICE_LINE.LAST_UPD_DT >= TRUNC(SYSDATE) - 1
   If an artifact calls it LAST_UPDATED_DATE the VAR-003 evidence chain stops
   making sense.

   ACTIVE_FLG vs DELETE_FLAG: not the same thing and people mix them up.
   ACTIVE_FLG = business availability (a discontinued SKU is ACTIVE_FLG 'N'
   but is absolutely not deleted). DELETE_FLAG = logical deletion.
   Note that OMS_PROD.CUSTOMER additionally carries a business column
   STATUS_FLG ('A' active / 'I' inactive) which is NOT one of the six and is
   NOT a synonym for ACTIVE_FLG. CANON.md section 9.1 lists it; keep it.

   *** DELETE_FLAG WAS INTRODUCED IN 2019. ***
   Before that, cancellations and bad rows were physically deleted from the
   OLTP tables. The 2019 change (soft delete programme, went in with the GST
   rework) added DELETE_FLAG to the OLTP tables with a DEFAULT of 'N', and
   switched the purge routines to UPDATE ... SET DELETE_FLAG='Y' instead of
   DELETE. Consequence: any query or mapping written before 2019, or written
   after 2019 by somebody working from a pre-2019 example, will read logically
   deleted rows as if they were live and over-report.

   AND THE OTHER HALF OF THE TRAP: a DEFAULT only applies to rows inserted
   after the column exists. The existing rows were never back-filled, so every
   row that predates the change carries NULL, not 'N'. The column is therefore
   three valued: 'Y', 'N', and NULL.

   Frozen distribution on OMS_PROD.INVOICE_LINE at the 31-May-2026 profiling
   run (CANON.md section 9.1 and 18.4, do not recompute):
       'Y'   5,380,708   ( 8.7%)
       'N'  47,251,124   (76.4%)
       NULL  9,215,388   (14.9%)
       sum  61,847,220

   The correct predicate everywhere is

       NVL(DELETE_FLAG,'N') = 'N'

   and NOT  DELETE_FLAG = 'N', which passes every check anyone would run and
   silently discards the entire pre-2019 population, 9.2 million rows.

   The CHECK constraints below permit NULL, because in Oracle a CHECK on a
   NULL evaluates to UNKNOWN and the row passes. That is not an oversight, it
   is the only reason the 2019 change could be deployed without an outage.

   *** EXCLUSIVITY WARNING ***
   WHY the NULLs exist is fact F-DELFLAG in fact_ownership.csv and is
   EXCLUSIVE to DOC-01. Canon may state it, which is why it is stated here.
   No artifact in _sources/ may explain it unless fact_ownership.csv says that
   artifact owns it. Other artifacts may state that the correct predicate is
   NVL(DELETE_FLAG,'N') = 'N'. They may not explain why it has to be.
---------------------------------------------------------------------------- */

/* ----------------------------------------------------------------------------
   FLAG / CODE CONVENTIONS
     CHAR(1) flags are 'Y' or 'N'. Not 1/0. Not 'y'. There is a check
     constraint on most of them, but not all, see notes on individual tables.
     STATE_CD / STATE_CODE is the 2 character GST state code ('27'
     Maharashtra, '29' Karnataka, '07' Delhi, '33' Tamil Nadu, '19' West
     Bengal etc). Stored as VARCHAR2 because of the leading zeros. Somebody
     tried to make it NUMBER in 2017 and it went badly.
     HSN_CODE is 4/6/8 digits held as VARCHAR2(10).
     UOM values in use: 'EA','CS','KG','LT'. CANON.md section 3 fixes the
     UOM of every canonical SKU; do not invent others.
     REGION_CD values: 'NORTH','WEST','SOUTH','EAST'. Four regions, no more.
     DEPOT_CD form 'DEP-XXX-nn'. TERRITORY_CD form 'TER-W-014'.
     EMP_ID form 'BCPL-EMP-04412'. Rep names are never printed anywhere.
   ----------------------------------------------------------------------------
   MONEY / QUANTITY PRECISION
     Amounts        NUMBER(16,2)   INR
     Credit limits  NUMBER(14,2)
     Unit prices    NUMBER(12,2)
     Quantities     NUMBER(12,3)
     Percentages    NUMBER(6,3)    (GST rate is NUMBER(5,2))
---------------------------------------------------------------------------- */


PROMPT ====== SECTION 1: OMS_PROD (13 tables) ======

-- ---------------------------------------------------------------------------
-- 1.1  CUSTOMER
--      2,140 rows. 340 of them are CUST_TYPE 'DISTRIBUTOR'; those are the
--      distributors everybody argues about. STATUS_FLG is a business column
--      and is not one of the six audit columns.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.CUSTOMER
(
  CUST_ID          NUMBER(10)     NOT NULL,
  CUST_CODE        VARCHAR2(20)   NOT NULL,
  CUST_NAME        VARCHAR2(120)  NOT NULL,
  CUST_TYPE        VARCHAR2(20),          -- DISTRIBUTOR | MODERN_TRADE | INSTITUTIONAL
  TERRITORY_CD     VARCHAR2(12),
  DEPOT_CD         VARCHAR2(12),
  CREDIT_LIMIT     NUMBER(14,2),
  STATUS_FLG       CHAR(1),               -- business status. A active, I inactive
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_CUSTOMER PRIMARY KEY (CUST_ID),
  CONSTRAINT CK_CUSTOMER_TYPE CHECK (CUST_TYPE IN ('DISTRIBUTOR','MODERN_TRADE','INSTITUTIONAL')),
  CONSTRAINT CK_CUSTOMER_DEL  CHECK (DELETE_FLAG IN ('Y','N'))
);
CREATE UNIQUE INDEX OMS_PROD.UX_CUSTOMER_CODE ON OMS_PROD.CUSTOMER (CUST_CODE) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_CUSTOMER_LUD  ON OMS_PROD.CUSTOMER (LAST_UPD_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_CUSTOMER_TERR ON OMS_PROD.CUSTOMER (TERRITORY_CD) TABLESPACE OMS_IDX;
-- IX_CUSTOMER_LUD exists purely for the nightly ODI extract predicate.

-- ---------------------------------------------------------------------------
-- 1.2  CUSTOMER_TERRITORY_HIST
--      Source-side territory history. Append-mostly, edited in place when
--      somebody notices a mistake. EFF_TO_DT is nullable and means "still in
--      force". Overlapping rows exist and are not constrained against:
--      61 customers have at least one overlap. That is the source-side half
--      of the VAR-004 story; the SCD2 half is in BCPL_EDW.DIM_CUSTOMER.
--      Worked example: DIST-W-0241 Mahalaxmi Distributors, reassigned
--      17-Apr-2026 from TER-W-014 to TER-W-011.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.CUSTOMER_TERRITORY_HIST
(
  CUST_ID          NUMBER(10)     NOT NULL,
  TERRITORY_CD     VARCHAR2(12)   NOT NULL,
  EFF_FROM_DT      DATE           NOT NULL,
  EFF_TO_DT        DATE,                  -- nullable, and overlaps exist
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1)
);
CREATE INDEX OMS_PROD.IX_CTH_CUST ON OMS_PROD.CUSTOMER_TERRITORY_HIST (CUST_ID, EFF_FROM_DT) TABLESPACE OMS_IDX;
-- No PK, no unique constraint on (CUST_ID, EFF_FROM_DT), no overlap check.
-- Nobody has ever added one. This is why the overlaps are there.

-- ---------------------------------------------------------------------------
-- 1.3  SKU_MASTER
--      1,246 rows, 862 active, 37 with a null CATEGORY_CD.
--      Brand codes: SUV NMB KSG CHD TRG RKS. Nothing else exists.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.SKU_MASTER
(
  SKU_ID           NUMBER(10)     NOT NULL,
  SKU_CODE         VARCHAR2(30)   NOT NULL,
  SKU_DESC         VARCHAR2(200),
  BRAND_CD         VARCHAR2(10),          -- SUV NMB KSG CHD TRG RKS
  CATEGORY_CD      VARCHAR2(10),          -- null on 37 rows
  PACK_SIZE        VARCHAR2(20),
  UOM              VARCHAR2(5),           -- KG | LT | EA
  MRP              NUMBER(12,2),
  HSN_CODE         VARCHAR2(10),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),               -- 862 rows are 'Y'
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_SKU_MASTER PRIMARY KEY (SKU_ID)
);
CREATE UNIQUE INDEX OMS_PROD.UX_SKU_CODE  ON OMS_PROD.SKU_MASTER (SKU_CODE) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_SKU_LUD   ON OMS_PROD.SKU_MASTER (LAST_UPD_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_SKU_BRAND ON OMS_PROD.SKU_MASTER (BRAND_CD, CATEGORY_CD) TABLESPACE OMS_IDX;
-- No NOT NULL on CATEGORY_CD. 37 rows exploit that. Nobody will fix it.

-- ---------------------------------------------------------------------------
-- 1.4  INVOICE_HEADER
--      8,902,144 rows at the 31-May-2026 profiling run.
--      DOC_TYPE mix: INV 94.7%, STN 4.7%, SMP 0.6%.
--      *** INVOICE_DT is a DATE in IST. CREATED_TS is a TIMESTAMP written by
--          the application server IN UTC. That gap is VAR-002. ***
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.INVOICE_HEADER
(
  INVOICE_ID       NUMBER(12)     NOT NULL,
  INVOICE_NO       VARCHAR2(20)   NOT NULL,
  INVOICE_DT       DATE           NOT NULL,   -- DATE, in IST
  DOC_TYPE         VARCHAR2(4),               -- INV | STN | SMP
  CUST_ID          NUMBER(10),
  DEPOT_CD         VARCHAR2(12),
  ORDER_ID         NUMBER(12),
  INVOICE_STATUS   VARCHAR2(20),
  TOTAL_GROSS_AMT  NUMBER(16,2),
  TOTAL_NET_AMT    NUMBER(16,2),
  CREATED_BY       VARCHAR2(30),
  CREATED_TS       TIMESTAMP(6),              -- WRITTEN BY THE APP SERVER IN UTC. VAR-002.
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),                   -- Y | N | NULL (pre 30-Mar-2019)
  CONSTRAINT PK_INVOICE_HEADER PRIMARY KEY (INVOICE_ID),
  CONSTRAINT CK_INVHDR_DOCTYPE CHECK (DOC_TYPE IN ('INV','STN','SMP')),
  CONSTRAINT CK_INVHDR_DEL     CHECK (DELETE_FLAG IN ('Y','N'))
);
CREATE UNIQUE INDEX OMS_PROD.UX_INVHDR_NO ON OMS_PROD.INVOICE_HEADER (INVOICE_NO) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVHDR_DT   ON OMS_PROD.INVOICE_HEADER (INVOICE_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVHDR_CUST ON OMS_PROD.INVOICE_HEADER (CUST_ID, INVOICE_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVHDR_LUD  ON OMS_PROD.INVOICE_HEADER (LAST_UPD_DT) TABLESPACE OMS_IDX;
-- There is no index on CREATED_TS. Nothing operational ever needed one, which
-- is part of why nobody noticed the mapping was keying the date off it.

-- ---------------------------------------------------------------------------
-- 1.5  INVOICE_LINE
--      *** 61,847,220 rows at the 31-May-2026 profiling run, from
--          01-Apr-2016. Older lines are in INVOICE_LINE_ARCHIVE. ***
--      SCHEME_DISC_AMT is the column the month end package rewrites. See
--      procs_canon.md section 4 and CANON.md section 11. Do not reproduce the
--      timing anywhere: it is fact F-TIMING and belongs to DOC-03 alone.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.INVOICE_LINE
(
  INVOICE_LINE_ID  NUMBER(12)     NOT NULL,
  INVOICE_ID       NUMBER(12)     NOT NULL,
  LINE_NO          NUMBER(4),
  SKU_ID           NUMBER(10),
  QTY_CS           NUMBER(12,3),
  QTY_EA           NUMBER(12,3),
  UNIT_PRICE       NUMBER(12,2),
  GROSS_AMT        NUMBER(16,2),
  SCHEME_DISC_AMT  NUMBER(16,2),             -- rewritten additively. VAR-003.
  CASH_DISC_AMT    NUMBER(16,2),
  TAX_AMT          NUMBER(16,2),
  NET_AMT          NUMBER(16,2),
  SCHEME_ID        NUMBER(8),
  CREATED_BY       VARCHAR2(30),
  CREATED_TS       TIMESTAMP(6),
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,                     -- the incremental extract predicate keys off this
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),                  -- added R11.4, 30-Mar-2019, NOT back-filled
  CONSTRAINT PK_INVOICE_LINE PRIMARY KEY (INVOICE_LINE_ID),
  CONSTRAINT FK_INVLINE_INVHDR FOREIGN KEY (INVOICE_ID)
    REFERENCES OMS_PROD.INVOICE_HEADER (INVOICE_ID),
  CONSTRAINT CK_INVLINE_DEL CHECK (DELETE_FLAG IN ('Y','N'))
);
CREATE INDEX OMS_PROD.IX_INVLINE_INV ON OMS_PROD.INVOICE_LINE (INVOICE_ID) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVLINE_SKU ON OMS_PROD.INVOICE_LINE (SKU_ID) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVLINE_LUD ON OMS_PROD.INVOICE_LINE (LAST_UPD_DT) TABLESPACE OMS_IDX;
-- Historical. Keep this as a commented-out artefact in schema_oltp.sql,
-- exactly as generated DDL from a 2019 change would have left it:
-- ALTER TABLE OMS_PROD.INVOICE_LINE ADD (DELETE_FLAG CHAR(1) DEFAULT 'N');  -- R11.4  30-MAR-2019

-- ---------------------------------------------------------------------------
-- 1.6  INVOICE_LINE_ARCHIVE
--      Pre 01-Apr-2016. Same shape as INVOICE_LINE MINUS DELETE_FLAG: the
--      column never existed here because the table was closed off three years
--      before the soft delete programme. Not extracted. Nobody has looked at
--      it since 2016. Five of the six audit columns; that is deliberate.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.INVOICE_LINE_ARCHIVE
(
  INVOICE_LINE_ID  NUMBER(12),
  INVOICE_ID       NUMBER(12),
  LINE_NO          NUMBER(4),
  SKU_ID           NUMBER(10),
  QTY_CS           NUMBER(12,3),
  QTY_EA           NUMBER(12,3),
  UNIT_PRICE       NUMBER(12,2),
  GROSS_AMT        NUMBER(16,2),
  SCHEME_DISC_AMT  NUMBER(16,2),
  CASH_DISC_AMT    NUMBER(16,2),
  TAX_AMT          NUMBER(16,2),
  NET_AMT          NUMBER(16,2),
  SCHEME_ID        NUMBER(8),
  CREATED_BY       VARCHAR2(30),
  CREATED_TS       TIMESTAMP(6),
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1)
  -- no DELETE_FLAG. CANON.md section 9.1. Do not add one.
);

-- ---------------------------------------------------------------------------
-- 1.7  ORDER_HEADER
--      Feeds fill-rate reporting via BCPL_EDW.FACT_ORDER_LINE (dashboard D06).
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.ORDER_HEADER
(
  ORDER_ID         NUMBER(12)     NOT NULL,
  ORDER_NO         VARCHAR2(20),
  ORDER_DT         DATE,
  CUST_ID          NUMBER(10),
  DEPOT_CD         VARCHAR2(12),
  ORDER_STATUS     VARCHAR2(20),
  CREATED_BY       VARCHAR2(30),
  CREATED_TS       TIMESTAMP(6),
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_ORDER_HEADER PRIMARY KEY (ORDER_ID)
);
CREATE INDEX OMS_PROD.IX_ORDHDR_DT   ON OMS_PROD.ORDER_HEADER (ORDER_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_ORDHDR_LUD  ON OMS_PROD.ORDER_HEADER (LAST_UPD_DT) TABLESPACE OMS_IDX;
-- The FK to CUSTOMER was disabled in 2020 during the master data cleanup and
-- never re-enabled:
-- ALTER TABLE OMS_PROD.ORDER_HEADER ADD CONSTRAINT FK_ORDHDR_CUST FOREIGN KEY (CUST_ID) REFERENCES OMS_PROD.CUSTOMER (CUST_ID);

-- ---------------------------------------------------------------------------
-- 1.8  ORDER_LINE
--      One row per SKU per order. Quantities are in the ordering UOM, not
--      normalised to a base UOM. Conversion happens downstream, which is a
--      recurring source of arguments.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.ORDER_LINE
(
  ORDER_LINE_ID    NUMBER(12)     NOT NULL,
  ORDER_ID         NUMBER(12)     NOT NULL,
  LINE_NO          NUMBER(4),
  SKU_ID           NUMBER(10),
  QTY_CS           NUMBER(12,3),
  QTY_EA           NUMBER(12,3),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_ORDER_LINE PRIMARY KEY (ORDER_LINE_ID),
  CONSTRAINT FK_ORDLINE_ORDHDR FOREIGN KEY (ORDER_ID)
    REFERENCES OMS_PROD.ORDER_HEADER (ORDER_ID)
);
CREATE INDEX OMS_PROD.IX_ORDLINE_ORD ON OMS_PROD.ORDER_LINE (ORDER_ID) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_ORDLINE_LUD ON OMS_PROD.ORDER_LINE (LAST_UPD_DT) TABLESPACE OMS_IDX;

-- ---------------------------------------------------------------------------
-- 1.9  SCHEME_MASTER
--      FIVE rows, and that is the entire scheme universe for this corpus.
--      5501 QPS-Q1-SUV | 5514 MTH-CHD-OCT | 5522 SLB-TRG-FEST
--      5533 TPR-NMB-SOUTH | 5540 QPS-KSG-H2
--      SCHEME_TYPE drives which calculation branch the recalculation runs.
--      Validity windows get closed retrospectively, which is why scheme
--      lookups fail most often in the fact load. See VAR-007.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.SCHEME_MASTER
(
  SCHEME_ID        NUMBER(8)      NOT NULL,
  SCHEME_CODE      VARCHAR2(30),
  SCHEME_NAME      VARCHAR2(120),
  SCHEME_TYPE      VARCHAR2(10),          -- QPS | MONTHLY | SLAB | TPR
  DISC_PCT         NUMBER(6,3),
  SLAB_QTY_FROM    NUMBER(12,3),
  SLAB_QTY_TO      NUMBER(12,3),
  VALID_FROM_DT    DATE,
  VALID_TO_DT      DATE,
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_SCHEME_MASTER PRIMARY KEY (SCHEME_ID),
  CONSTRAINT CK_SCHEME_TYPE CHECK (SCHEME_TYPE IN ('QPS','MONTHLY','SLAB','TPR'))
);
CREATE INDEX OMS_PROD.IX_SCHEME_VALID ON OMS_PROD.SCHEME_MASTER (VALID_FROM_DT, VALID_TO_DT) TABLESPACE OMS_IDX;

-- ---------------------------------------------------------------------------
-- 1.10 CREDIT_NOTE
--      *** THIS EXISTS IN THE SOURCE. It is the warehouse that has no credit
--          note fact table, not ORION that has no credit notes. ***
--      FY26: 9,318 documents, INR 46.81 Cr total.
--      Revenue-affecting types RATE_DIFF and OFF_INV_ADJ: 1,206 documents,
--      INR 3,11,20,000. The rest settle against provisions or through the
--      scheme accrual route inside ORION.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.CREDIT_NOTE
(
  CN_ID            NUMBER(12)     NOT NULL,
  CN_NO            VARCHAR2(20),
  CN_DT            DATE,
  CUST_ID          NUMBER(10),
  CN_TYPE          VARCHAR2(15),          -- DAMAGE | RETURN | RATE_DIFF | OFF_INV_ADJ | SCHEME
  CN_STATUS        VARCHAR2(20),
  TOTAL_AMT        NUMBER(16,2),
  REF_INVOICE_ID   NUMBER(12),
  CREATED_BY       VARCHAR2(30),
  CREATED_TS       TIMESTAMP(6),
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_CREDIT_NOTE PRIMARY KEY (CN_ID),
  CONSTRAINT CK_CN_TYPE CHECK (CN_TYPE IN ('DAMAGE','RETURN','RATE_DIFF','OFF_INV_ADJ','SCHEME'))
);
CREATE INDEX OMS_PROD.IX_CN_DT   ON OMS_PROD.CREDIT_NOTE (CN_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_CN_CUST ON OMS_PROD.CREDIT_NOTE (CUST_ID, CN_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_CN_LUD  ON OMS_PROD.CREDIT_NOTE (LAST_UPD_DT) TABLESPACE OMS_IDX;

-- ---------------------------------------------------------------------------
-- 1.11 CREDIT_NOTE_LINE
--      31,204 rows FY26.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.CREDIT_NOTE_LINE
(
  CN_LINE_ID       NUMBER(12)     NOT NULL,
  CN_ID            NUMBER(12)     NOT NULL,
  SKU_ID           NUMBER(10),
  QTY              NUMBER(12,3),
  AMT              NUMBER(16,2),
  REASON_CD        VARCHAR2(10),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_CREDIT_NOTE_LINE PRIMARY KEY (CN_LINE_ID),
  CONSTRAINT FK_CNLINE_CN FOREIGN KEY (CN_ID)
    REFERENCES OMS_PROD.CREDIT_NOTE (CN_ID)
);

-- ---------------------------------------------------------------------------
-- 1.12 DEPOT_MASTER
--      22 rows. North 6, West 6, South 5, East 5.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.DEPOT_MASTER
(
  DEPOT_CD         VARCHAR2(12)   NOT NULL,
  DEPOT_NAME       VARCHAR2(80),
  CITY             VARCHAR2(60),
  STATE_CD         VARCHAR2(6),
  REGION_CD        VARCHAR2(6),           -- NORTH | WEST | SOUTH | EAST
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_DEPOT_MASTER PRIMARY KEY (DEPOT_CD)
);

-- ---------------------------------------------------------------------------
-- 1.13 TERRITORY_MASTER
--      118 rows. EMP_ID is the territory owner, in BCPL-EMP-nnnnn form.
--      Rep names are never printed in any artifact. Codes only.
-- ---------------------------------------------------------------------------
CREATE TABLE OMS_PROD.TERRITORY_MASTER
(
  TERRITORY_CD     VARCHAR2(12)   NOT NULL,
  TERRITORY_NAME   VARCHAR2(80),
  REGION_CD        VARCHAR2(6),
  EMP_ID           VARCHAR2(20),          -- BCPL-EMP-04412 style
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_TERRITORY_MASTER PRIMARY KEY (TERRITORY_CD)
);


PROMPT ====== SECTION 2: FIN_PROD (7 tables) ======

/* ----------------------------------------------------------------------------
   FIN_PROD is the finance schema in the SAME ORION instance as OMS_PROD.
   It holds the GL, receivables, tax rates, scheme accruals, the period
   control table and the PKG_MONTH_END package. It does NOT hold invoicing.
   Invoicing is in OMS_PROD. Anyone who puts INVOICE_HEADER or INVOICE_LINE
   in FIN_PROD is working from the superseded registry.

   Control-M schedules NOTHING inside FIN_PROD. The one thing in here that
   runs on a clock is a DBMS_SCHEDULER job and its timing is fact F-TIMING,
   exclusive to DOC-03.
---------------------------------------------------------------------------- */

-- ---------------------------------------------------------------------------
-- 2.1  TAX_RATE_MASTER
--      *** THE SOURCE TABLE IS EFFECTIVE DATED. The warehouse copy is not.
--          That asymmetry is the whole of VAR-006. ***
--      Chandanaa, HSN 3401: 18% to 30-Sep-2025, 12% from 01-Oct-2025.
-- ---------------------------------------------------------------------------
CREATE TABLE FIN_PROD.TAX_RATE_MASTER
(
  HSN_CODE         VARCHAR2(10)   NOT NULL,
  GST_RATE_PCT     NUMBER(5,2)    NOT NULL,
  EFF_FROM_DT      DATE           NOT NULL,
  EFF_TO_DT        DATE,
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1)
);
CREATE INDEX FIN_PROD.IX_TAXRATE_HSN ON FIN_PROD.TAX_RATE_MASTER (HSN_CODE, EFF_FROM_DT) TABLESPACE FIN_IDX;

-- ---------------------------------------------------------------------------
-- 2.2  SCHEME_ACCRUAL
--      Written by PKG_MONTH_END.P_RECALC_SCHEME_DISCOUNT. One row per
--      customer per scheme per period.
-- ---------------------------------------------------------------------------
CREATE TABLE FIN_PROD.SCHEME_ACCRUAL
(
  ACCRUAL_ID       NUMBER(12)     NOT NULL,
  CUST_ID          NUMBER(10),
  SCHEME_ID        NUMBER(8),
  PERIOD_YYYYMM    VARCHAR2(6),
  ACCRUAL_AMT      NUMBER(16,2),
  POSTED_FLG       CHAR(1),
  CREATED_BY       VARCHAR2(30),
  CREATED_TS       TIMESTAMP(6),
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_SCHEME_ACCRUAL PRIMARY KEY (ACCRUAL_ID)
);
CREATE INDEX FIN_PROD.IX_ACCRUAL_PERIOD ON FIN_PROD.SCHEME_ACCRUAL (PERIOD_YYYYMM) TABLESPACE FIN_IDX;

-- ---------------------------------------------------------------------------
-- 2.3  PERIOD_CONTROL
--      One row per fiscal period. PKG_MONTH_END.P_ADJUST_REVENUE resolves the
--      open period from here when p_period is null.
-- ---------------------------------------------------------------------------
CREATE TABLE FIN_PROD.PERIOD_CONTROL
(
  PERIOD_YYYYMM    VARCHAR2(6)    NOT NULL,
  STATUS           VARCHAR2(10),          -- OPEN | CLOSING | CLOSED
  CLOSED_TS        TIMESTAMP(6),
  CLOSED_BY        VARCHAR2(30),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_PERIOD_CONTROL PRIMARY KEY (PERIOD_YYYYMM),
  CONSTRAINT CK_PERIOD_STATUS CHECK (STATUS IN ('OPEN','CLOSING','CLOSED'))
);

-- ---------------------------------------------------------------------------
-- 2.4  GL_ACCOUNT_MASTER
--      410100 Net Sales - Domestic
--      410900 Scheme Discount (contra)
--      411200 Credit Notes
-- ---------------------------------------------------------------------------
CREATE TABLE FIN_PROD.GL_ACCOUNT_MASTER
(
  GL_ACCOUNT_CD    VARCHAR2(10)   NOT NULL,
  GL_ACCOUNT_NM    VARCHAR2(120),
  ACCOUNT_TYPE     VARCHAR2(20),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_GL_ACCOUNT_MASTER PRIMARY KEY (GL_ACCOUNT_CD)
);

-- ---------------------------------------------------------------------------
-- 2.5  GL_JOURNAL_HDR
-- ---------------------------------------------------------------------------
CREATE TABLE FIN_PROD.GL_JOURNAL_HDR
(
  JOURNAL_ID       NUMBER(12)     NOT NULL,
  PERIOD_YYYYMM    VARCHAR2(6),
  SOURCE_CD        VARCHAR2(20),
  POSTED_TS        TIMESTAMP(6),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_GL_JOURNAL_HDR PRIMARY KEY (JOURNAL_ID)
);

-- ---------------------------------------------------------------------------
-- 2.6  GL_JOURNAL_LINE
-- ---------------------------------------------------------------------------
CREATE TABLE FIN_PROD.GL_JOURNAL_LINE
(
  JOURNAL_LINE_ID  NUMBER(12)     NOT NULL,
  JOURNAL_ID       NUMBER(12)     NOT NULL,
  GL_ACCOUNT_CD    VARCHAR2(10),
  DR_AMT           NUMBER(16,2),
  CR_AMT           NUMBER(16,2),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_GL_JOURNAL_LINE PRIMARY KEY (JOURNAL_LINE_ID),
  CONSTRAINT FK_GLJL_HDR FOREIGN KEY (JOURNAL_ID)
    REFERENCES FIN_PROD.GL_JOURNAL_HDR (JOURNAL_ID)
);

-- ---------------------------------------------------------------------------
-- 2.7  AR_OPEN_ITEM
--      Receivables ageing. The ONLY source for dashboard D11 Credit and
--      Receivables Exposure. D11 does NOT source credit notes from anywhere.
--      If an artifact needs to describe D11's data it says receivables ageing
--      from AR_OPEN_ITEM and stops there.
-- ---------------------------------------------------------------------------
CREATE TABLE FIN_PROD.AR_OPEN_ITEM
(
  AR_ITEM_ID       NUMBER(12)     NOT NULL,
  CUST_ID          NUMBER(10),
  INVOICE_ID       NUMBER(12),
  DUE_DT           DATE,
  OPEN_AMT         NUMBER(16,2),
  AGEING_BUCKET    VARCHAR2(20),          -- 0-30 | 31-60 | 61-90 | 90+
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_AR_OPEN_ITEM PRIMARY KEY (AR_ITEM_ID)
);
CREATE INDEX FIN_PROD.IX_AR_CUST ON FIN_PROD.AR_OPEN_ITEM (CUST_ID, DUE_DT) TABLESPACE FIN_IDX;


PROMPT ====== SECTION 3: BCPL_EDW (12 model tables + 3 ETL control) ======

/* ----------------------------------------------------------------------------
   WAREHOUSE CONVENTIONS
   ----------------------------------------------------------------------------
   Warehouse tables do NOT carry the six OLTP audit columns. Per CANON.md
   section 9.4 they carry a light load stamp instead:
       LOAD_DT     DATE       when the row was loaded
       UPD_DT      DATE       on SCD2 dimensions that update in place
       BATCH_ID    NUMBER(10) on facts, joins to ETL_BATCH_CONTROL.BATCH_ID
   There is no DW_LOAD_ID, no DW_INSERT_TS, no DW_UPDATE_TS and no SRC_SYS_CD.
   Those were the superseded registry's convention. Do not use them.

   SURROGATE KEYS
       Every DIM_* has a NUMBER surrogate key ending _KEY, populated from a
       sequence. Facts join on the _KEY only, never on the natural key.

   SCD2 FLAG SPELLING
       CURRENT_FLG. Not CURRENT_FLAG. CANON.md section 9.4 governs, and the
       whole VAR-004 story is written in terms of CURRENT_FLG.
       SCD2 is live on DIM_CUSTOMER and DIM_PRODUCT from 06-May-2026. Before
       that both were SCD1, so rows built before the conversion do not carry a
       meaningful version history.

   UNKNOWN MEMBER CONVENTION   (see VAR-007)
       Every DIM_* carries a reserved row with surrogate key = -1 representing
       UNKNOWN / NOT APPLICABLE. When a fact load cannot resolve a dimension
       lookup (late arriving master data, a scheme whose validity window had
       already been retrospectively closed, a customer created after the
       dimension extract ran) the mapping substitutes -1 rather than rejecting
       the row. Nothing is written to ETL_ERROR_LOG when this substitution
       happens, it is a silent default in the mapping. So a fact row that
       landed on -1 looks perfectly healthy in the load audit.
       Also note DIM_DATE breaks its own YYYYMMDD key format for its -1 row.
       Reports that inner join or filter on a dimension attribute instead of
       using an outer join simply drop those rows. That is the VAR-007
       symptom: 2.0% of invoiced volume, 8,140 lines a month on average,
       11,902 at the Jan-2026 peak.
---------------------------------------------------------------------------- */

-- ---------------------------------------------------------------------------
-- 3.1  DIM_DATE            5,844 rows, 01-Apr-2015 to 31-Mar-2031
--      Fiscal columns follow the FY convention in the header of this file.
--      FISCAL_QTR is written 'FY26-Q1'. FISCAL_YEAR is written 'FY26'.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.DIM_DATE
(
  DATE_KEY            NUMBER(8)    NOT NULL,   -- YYYYMMDD. The UNKNOWN row is -1, which is not YYYYMMDD.
  FULL_DATE           DATE,
  DAY_OF_MONTH        NUMBER(2),
  DAY_NAME            VARCHAR2(10),
  WEEK_OF_YEAR        NUMBER(2),
  MONTH_NUM           NUMBER(2),
  MONTH_NAME          VARCHAR2(10),
  CAL_QTR             NUMBER(1),
  CAL_YEAR            NUMBER(4),
  FISCAL_MONTH_NUM    NUMBER(2),               -- 1 = April
  FISCAL_QTR          VARCHAR2(8),             -- 'FY26-Q1'
  FISCAL_YEAR         VARCHAR2(4),             -- 'FY26'
  IS_MONTH_END_FLG    CHAR(1),
  IS_WORKING_DAY_FLG  CHAR(1),
  LOAD_DT             DATE,
  CONSTRAINT PK_DIM_DATE PRIMARY KEY (DATE_KEY)
);
COMMENT ON COLUMN BCPL_EDW.DIM_DATE.FISCAL_YEAR IS 'FY label named for the ending year. FY26 = 01-Apr-2025 to 31-Mar-2026.';

-- ---------------------------------------------------------------------------
-- 3.2  DIM_CUSTOMER        2,140 current rows, approx 6,900 projected Mar-2027
--      SCD2 from 06-May-2026 (was SCD1).
--      *** VAR-004 LIVES HERE. On a territory reassignment the closing row's
--          EFF_END_DT is set to the same timestamp as the new row's
--          EFF_START_DT and CURRENT_FLG is left 'Y' on BOTH rows, so a fact
--          row joins to two dimension rows. 61 customers have overlapping
--          effective dates, 18 carry two current rows. Fails DQ-R-07. ***
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.DIM_CUSTOMER
(
  CUSTOMER_KEY        NUMBER(10)   NOT NULL,   -- -1 is the UNKNOWN member
  CUSTOMER_ID         NUMBER(10),              -- natural key, = OMS_PROD.CUSTOMER.CUST_ID
  CUSTOMER_CODE       VARCHAR2(20),
  CUSTOMER_NAME       VARCHAR2(120),
  CUSTOMER_TYPE       VARCHAR2(20),
  TERRITORY_CODE      VARCHAR2(12),
  REGION_CODE         VARCHAR2(6),
  STATE_CODE          VARCHAR2(6),
  DEPOT_CODE          VARCHAR2(12),
  CREDIT_LIMIT_AMT    NUMBER(14,2),
  EFF_START_DT        DATE,
  EFF_END_DT          DATE,
  CURRENT_FLG         CHAR(1),                 -- NOT CURRENT_FLAG
  LOAD_DT             DATE,
  UPD_DT              DATE,
  CONSTRAINT PK_DIM_CUSTOMER PRIMARY KEY (CUSTOMER_KEY)
);
CREATE INDEX BCPL_EDW.IX_DIMCUST_NK ON BCPL_EDW.DIM_CUSTOMER (CUSTOMER_ID, CURRENT_FLG) TABLESPACE EDW_IDX;
-- No unique constraint on (CUSTOMER_ID, CURRENT_FLG='Y'). If there were one,
-- VAR-004 would have raised an error instead of doubling the revenue.

-- ---------------------------------------------------------------------------
-- 3.3  DIM_PRODUCT         1,246 rows
--      SCD2 from 06-May-2026. SCD1 was proposed 14-Apr-2026 and superseded
--      (CON-6, ADR-003). MRP revisions drive most of the version churn.
--      Carries the UNKNOWN member at PRODUCT_KEY = -1. See VAR-007.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.DIM_PRODUCT
(
  PRODUCT_KEY         NUMBER(10)   NOT NULL,   -- -1 is the UNKNOWN member
  SKU_ID              NUMBER(10),
  SKU_CODE            VARCHAR2(30),
  SKU_DESC            VARCHAR2(200),
  BRAND_CODE          VARCHAR2(10),
  BRAND_NAME          VARCHAR2(60),
  CATEGORY_CODE       VARCHAR2(10),
  CATEGORY_NAME       VARCHAR2(60),
  PACK_SIZE           VARCHAR2(20),
  UOM                 VARCHAR2(5),
  MRP_AMT             NUMBER(12,2),
  HSN_CODE            VARCHAR2(10),
  ACTIVE_FLG          CHAR(1),
  EFF_START_DT        DATE,
  EFF_END_DT          DATE,
  CURRENT_FLG         CHAR(1),
  LOAD_DT             DATE,
  CONSTRAINT PK_DIM_PRODUCT PRIMARY KEY (PRODUCT_KEY)
);
CREATE INDEX BCPL_EDW.IX_DIMPROD_NK ON BCPL_EDW.DIM_PRODUCT (SKU_ID, CURRENT_FLG) TABLESPACE EDW_IDX;

-- ---------------------------------------------------------------------------
-- 3.4  DIM_GEOGRAPHY       22 rows, SCD1. Natural key DEPOT_CODE.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.DIM_GEOGRAPHY
(
  GEO_KEY             NUMBER(6)    NOT NULL,   -- -1 is the UNKNOWN member
  DEPOT_CODE          VARCHAR2(12),
  DEPOT_NAME          VARCHAR2(80),
  CITY                VARCHAR2(60),
  STATE_CODE          VARCHAR2(6),
  STATE_NAME          VARCHAR2(60),
  REGION_CODE         VARCHAR2(6),
  REGION_NAME         VARCHAR2(30),
  LOAD_DT             DATE,
  CONSTRAINT PK_DIM_GEOGRAPHY PRIMARY KEY (GEO_KEY)
);

-- ---------------------------------------------------------------------------
-- 3.5  DIM_SCHEME          5 rows, SCD1. Natural key SCHEME_ID.
--      Scheme lookups are the ones that fail most often in the fact load,
--      because the source validity window gets closed retrospectively.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.DIM_SCHEME
(
  SCHEME_KEY          NUMBER(8)    NOT NULL,   -- -1 is the UNKNOWN member
  SCHEME_ID           NUMBER(8),
  SCHEME_CODE         VARCHAR2(30),
  SCHEME_NAME         VARCHAR2(120),
  SCHEME_TYPE         VARCHAR2(10),
  START_DT            DATE,
  END_DT              DATE,
  LOAD_DT             DATE,
  CONSTRAINT PK_DIM_SCHEME PRIMARY KEY (SCHEME_KEY)
);

-- ---------------------------------------------------------------------------
-- 3.6  DIM_SALESREP        610 current rows, SCD2.
--      *** REP NAMES ARE NEVER PRINTED IN ANY ARTIFACT. There is no name
--          column here and there must not be one. Employee codes only,
--          in BCPL-EMP-04412 form. ***
--      Loaded by MAP_DIM_SALESREP, which is refreshed ad hoc rather than
--      nightly. Feeds D10 Sales Rep Productivity, which is dropped and is
--      NOT in the nine at go-live.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.DIM_SALESREP
(
  SALESREP_KEY        NUMBER(8)    NOT NULL,   -- -1 is the UNKNOWN member
  EMP_ID              VARCHAR2(20),
  ROLE_CODE           VARCHAR2(20),
  TERRITORY_CODE      VARCHAR2(12),
  MANAGER_EMP_ID      VARCHAR2(20),
  EFF_START_DT        DATE,
  EFF_END_DT          DATE,
  CURRENT_FLG         CHAR(1),
  LOAD_DT             DATE,
  CONSTRAINT PK_DIM_SALESREP PRIMARY KEY (SALESREP_KEY)
);

-- ---------------------------------------------------------------------------
-- 3.7  TAX_RATE_MASTER     214 rows
--      *** NOT a dimension, and deliberately so. It is a straight
--          truncate-and-reload copy of FIN_PROD.TAX_RATE_MASTER holding
--          CURRENT RATES ONLY, with NO effective dating, although the source
--          table is effective dated. That is the root cause of VAR-006:
--          the Chandanaa HSN 3401 change from 18% to 12% on 01-Oct-2025 was
--          applied retrospectively to Apr-Sep 2025. Fails DQ-R-15. ***
--      Superseded by DIM_TAX_RATE on 26-Aug-2026 under CHG0021339, but the
--      table itself is still there. Do not delete it from schema_edw.sql.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.TAX_RATE_MASTER
(
  HSN_CODE            VARCHAR2(10),
  GST_RATE_PCT        NUMBER(5,2),
  LOAD_DT             DATE
  -- no EFF_START_DT. no EFF_END_DT. no CURRENT_FLG. That is the bug.
);

-- ---------------------------------------------------------------------------
-- 3.8  DIM_TAX_RATE
--      The VAR-006 remediation. Live from 26-Aug-2026 under CHG0021339.
--      Effective dated, so a historic invoice resolves the rate that was in
--      force on its own invoice date.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.DIM_TAX_RATE
(
  TAX_RATE_KEY        NUMBER(8)    NOT NULL,   -- -1 is the UNKNOWN member
  HSN_CODE            VARCHAR2(10),
  GST_RATE_PCT        NUMBER(5,2),
  EFF_START_DT        DATE,
  EFF_END_DT          DATE,
  CURRENT_FLG         CHAR(1),
  LOAD_DT             DATE,
  CONSTRAINT PK_DIM_TAX_RATE PRIMARY KEY (TAX_RATE_KEY)
);

-- ---------------------------------------------------------------------------
-- 3.9  FACT_INVOICE_LINE
--      *** 34,182,556 rows at the 31-May-2026 profiling run. Covers
--          01-Apr-2021 onward. ***
--      INTENDED GRAIN: one row per source invoice line.
--      ACTUAL GRAIN BEFORE REMEDIATION: one row per source invoice line PER
--      EXTRACT. That degradation is the bug family behind VAR-001, VAR-003
--      and VAR-008, and it happens because MAP_FACT_INVOICE_LINE uses
--      IKM Oracle Control Append, which is insert only, on a fixed rolling
--      24 hour predicate with no merge key and no batch guard.
--      Fails DQ-R-09.
--      Remediation is the key-based merge planned for R2026.09 under ADR-004.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.FACT_INVOICE_LINE
(
  INVOICE_LINE_KEY    NUMBER(14)   NOT NULL,
  INVOICE_ID          NUMBER(12),
  INVOICE_LINE_ID     NUMBER(12),
  DATE_KEY            NUMBER(8),
  CUSTOMER_KEY        NUMBER(10),
  PRODUCT_KEY         NUMBER(10),
  GEO_KEY             NUMBER(6),
  SALESREP_KEY        NUMBER(8),
  SCHEME_KEY          NUMBER(8),
  QTY_CS              NUMBER(12,3),
  QTY_EA              NUMBER(12,3),
  GROSS_AMT           NUMBER(16,2),
  SCHEME_DISC_AMT     NUMBER(16,2),            -- double counted. VAR-003.
  CASH_DISC_AMT       NUMBER(16,2),
  TAX_AMT             NUMBER(16,2),
  NET_AMT             NUMBER(16,2),
  SRC_DELETE_FLAG     CHAR(1),                 -- carried through from source. 'Y'/'N'/NULL. Fails DQ-R-12.
  LOAD_DT             DATE,
  BATCH_ID            NUMBER(10),
  ODI_SESS_NO         NUMBER(12),
  CONSTRAINT PK_FACT_INVOICE_LINE PRIMARY KEY (INVOICE_LINE_KEY)
);
CREATE INDEX BCPL_EDW.IX_FIL_DATE ON BCPL_EDW.FACT_INVOICE_LINE (DATE_KEY) LOCAL TABLESPACE EDW_IDX;
CREATE INDEX BCPL_EDW.IX_FIL_CUST ON BCPL_EDW.FACT_INVOICE_LINE (CUSTOMER_KEY, DATE_KEY) LOCAL TABLESPACE EDW_IDX;
CREATE INDEX BCPL_EDW.IX_FIL_PROD ON BCPL_EDW.FACT_INVOICE_LINE (PRODUCT_KEY) LOCAL TABLESPACE EDW_IDX;
-- *** THERE IS NO UNIQUE CONSTRAINT ON INVOICE_LINE_ID. THAT IS THE POINT. ***
-- A unique key here would have raised ORA-00001 on the first duplicate insert
-- in 2021 and none of this would have happened.

-- ---------------------------------------------------------------------------
-- 3.10 FACT_SECONDARY_SALES     9,940,180 rows
--      One row per distributor per SKU per day, from the DMS upload.
--      Coverage is 74% of distributors and the feed lags 5 days. That
--      incompleteness is a standing caveat and is why Vikram Sethi's numbers
--      move. Loaded by LP_SECONDARY_UPLOAD at 04:00 IST. Frequently no file.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.FACT_SECONDARY_SALES
(
  SECONDARY_KEY       NUMBER(14)   NOT NULL,
  DATE_KEY            NUMBER(8),
  CUSTOMER_KEY        NUMBER(10),
  PRODUCT_KEY         NUMBER(10),
  GEO_KEY             NUMBER(6),
  QTY_CS              NUMBER(12,3),
  VALUE_AMT           NUMBER(16,2),
  SRC_FILE_NM         VARCHAR2(120),
  LOAD_DT             DATE,
  BATCH_ID            NUMBER(10),
  CONSTRAINT PK_FACT_SECONDARY_SALES PRIMARY KEY (SECONDARY_KEY)
);

-- ---------------------------------------------------------------------------
-- 3.11 FACT_ORDER_LINE          12,604,881 rows
--      One row per order line. Feeds fill rate, dashboard D06.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.FACT_ORDER_LINE
(
  ORDER_LINE_KEY      NUMBER(14)   NOT NULL,
  ORDER_ID            NUMBER(12),
  ORDER_LINE_ID       NUMBER(12),
  DATE_KEY            NUMBER(8),
  CUSTOMER_KEY        NUMBER(10),
  PRODUCT_KEY         NUMBER(10),
  GEO_KEY             NUMBER(6),
  ORDER_QTY_CS        NUMBER(12,3),
  SERVED_QTY_CS       NUMBER(12,3),
  LOAD_DT             DATE,
  BATCH_ID            NUMBER(10),
  CONSTRAINT PK_FACT_ORDER_LINE PRIMARY KEY (ORDER_LINE_KEY)
);

-- ===========================================================================
-- THERE IS NO BCPL_EDW.FACT_CREDIT_NOTE.
--
-- Do not create one. Do not add a commented-out CREATE TABLE for one. Do not
-- add a TODO, a placeholder, a roadmap comment or a "planned for Phase 2"
-- note. In schema_edw.sql the absence must be COMPLETELY SILENT: the file
-- simply does not contain the table, and nothing draws attention to that.
--
-- The absence IS the evidence for VAR-005 and for demo question Q5. Fact
-- F-CN-STRUCT is owned by schema_edw.sql (TECH-SQL-EDW) and it is owned by
-- virtue of the table not being there.
--
-- The reason there is no such table is fact F-CNGAP and is EXCLUSIVE to
-- DOC-05. Do not explain it here or anywhere else.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- 3.12 SEC_USER_REGION
--      Row level security mapping for Power BI. 4 RLS roles, by REGION_CODE.
--      128 named users at go-live, 41 of them Sales Ops.
-- ---------------------------------------------------------------------------
CREATE TABLE BCPL_EDW.SEC_USER_REGION
(
  USER_UPN            VARCHAR2(120) NOT NULL,
  REGION_CODE         VARCHAR2(6)   NOT NULL,
  LOAD_DT             DATE
);

-- ---------------------------------------------------------------------------
-- ETL CONTROL TABLES (3). Not part of the 12 model tables. No business data.
-- ---------------------------------------------------------------------------

-- 3.C1 ETL_BATCH_CONTROL
--      One row per load plan run. EXTRACT_HIGH_TS is the extract high water
--      mark and is persisted ONLY by the closing step of a successful plan,
--      P_ETL_BATCH_CLOSE. Before the R2026.07 fix of 08-Jul-2026 it was
--      advanced at the START of the plan, so a mid-plan failure moved the
--      window past rows that were never loaded. Silent data loss, no error.
--      That was half of VAR-008.
--      A 'DONE' row means "the plan reached its last step". It does NOT mean
--      the data is right. Every night that produced a VAR-003 duplicate has a
--      green row in here.
CREATE TABLE BCPL_EDW.ETL_BATCH_CONTROL
(
  BATCH_ID            NUMBER(10)   NOT NULL,
  LOAD_PLAN_NAME      VARCHAR2(60),
  BUSINESS_DATE       DATE,
  START_TS            TIMESTAMP(6),
  END_TS              TIMESTAMP(6),
  STATUS              VARCHAR2(15),            -- RUNNING | DONE | FAILED
  ROWS_INSERTED       NUMBER(12),
  ROWS_REJECTED       NUMBER(12),
  EXTRACT_HIGH_TS     TIMESTAMP(6),
  RESTART_COUNT       NUMBER(4),
  CONSTRAINT PK_ETL_BATCH_CONTROL PRIMARY KEY (BATCH_ID)
);
CREATE INDEX BCPL_EDW.IX_EBC_PLAN ON BCPL_EDW.ETL_BATCH_CONTROL (LOAD_PLAN_NAME, BUSINESS_DATE) TABLESPACE EDW_IDX;
-- Stale RUNNING rows from plans that aborted before the closing step sit here
-- for ever. Several exist. The ops dashboard shows jobs in flight for months.

-- 3.C2 ETL_ERROR_LOG
--      Rejected rows copied on from the E$ tables by a post-step. Note what
--      never reaches it: a dimension lookup that resolved to the -1 UNKNOWN
--      member is a perfectly valid row. It violates no constraint, is never
--      rejected, never logged, never counted.
CREATE TABLE BCPL_EDW.ETL_ERROR_LOG
(
  ERROR_ID            NUMBER(12)   NOT NULL,
  BATCH_ID            NUMBER(10),
  OBJECT_NM           VARCHAR2(60),
  ERROR_TS            TIMESTAMP(6),
  ERROR_TEXT          VARCHAR2(4000),
  CONSTRAINT PK_ETL_ERROR_LOG PRIMARY KEY (ERROR_ID)
);
CREATE INDEX BCPL_EDW.IX_EEL_BATCH ON BCPL_EDW.ETL_ERROR_LOG (BATCH_ID) TABLESPACE EDW_IDX;

-- 3.C3 ETL_PARAM
--      Holds a row PARAM_NAME = 'FIN_PERIOD_OPEN' whose PARAM_VALUE is a
--      YYYYMM string.
--      *** WHAT THAT ROW IS FOR, and the fact that somebody has to set it by
--          hand, is fact F-MANUAL and is EXCLUSIVE to DOC-02. Other artifacts
--          may mention that ETL_PARAM exists. They may not explain this row.
CREATE TABLE BCPL_EDW.ETL_PARAM
(
  PARAM_NAME          VARCHAR2(60) NOT NULL,
  PARAM_VALUE         VARCHAR2(200),
  UPD_TS              TIMESTAMP(6),
  UPD_BY              VARCHAR2(30),
  CONSTRAINT PK_ETL_PARAM PRIMARY KEY (PARAM_NAME)
);


PROMPT ====== SECTION 4: UNKNOWN MEMBER SEED ROWS ======

-- These run once at warehouse build and after any dimension truncate/reload.
-- Sequences are set to start above 0 so they never collide with -1.
-- Keep these in sync. If a dimension is rebuilt and this script is not re-run,
-- every fact row whose lookup fails resolves to nothing instead of landing on
-- UNKNOWN, and the row count in the fact silently differs.

INSERT INTO BCPL_EDW.DIM_DATE (DATE_KEY, FULL_DATE, FISCAL_QTR, FISCAL_YEAR)
VALUES (-1, NULL, 'UNK', 'UNK');

INSERT INTO BCPL_EDW.DIM_CUSTOMER (CUSTOMER_KEY, CUSTOMER_ID, CUSTOMER_CODE, CUSTOMER_NAME, EFF_START_DT, EFF_END_DT, CURRENT_FLG)
VALUES (-1, -1, 'UNKNOWN', 'UNKNOWN CUSTOMER', TO_DATE('01-JAN-1900','DD-MON-YYYY'), TO_DATE('31-DEC-4712','DD-MON-YYYY'), 'Y');

INSERT INTO BCPL_EDW.DIM_PRODUCT (PRODUCT_KEY, SKU_ID, SKU_CODE, SKU_DESC, EFF_START_DT, EFF_END_DT, CURRENT_FLG)
VALUES (-1, -1, 'UNKNOWN', 'UNKNOWN PRODUCT', TO_DATE('01-JAN-1900','DD-MON-YYYY'), TO_DATE('31-DEC-4712','DD-MON-YYYY'), 'Y');

INSERT INTO BCPL_EDW.DIM_GEOGRAPHY (GEO_KEY, DEPOT_CODE, DEPOT_NAME, STATE_CODE, REGION_CODE, REGION_NAME)
VALUES (-1, 'UNKNOWN', 'UNKNOWN DEPOT', '00', 'UNK', 'UNKNOWN');

INSERT INTO BCPL_EDW.DIM_SCHEME (SCHEME_KEY, SCHEME_ID, SCHEME_CODE, SCHEME_NAME, SCHEME_TYPE)
VALUES (-1, -1, 'UNKNOWN', 'NO SCHEME / UNRESOLVED', 'UNK');

INSERT INTO BCPL_EDW.DIM_SALESREP (SALESREP_KEY, EMP_ID, ROLE_CODE, CURRENT_FLG)
VALUES (-1, 'UNKNOWN', 'UNKNOWN', 'Y');

INSERT INTO BCPL_EDW.DIM_TAX_RATE (TAX_RATE_KEY, HSN_CODE, GST_RATE_PCT, CURRENT_FLG)
VALUES (-1, 'UNKNOWN', 0, 'Y');

COMMIT;

-- Note the EFF_END_DT high value: 31-DEC-4712, not 31-DEC-9999. Karthik
-- Subramanian's repo note on MAP_DIM_CUSTOMER says so explicitly and warns
-- that switching to the SCD2 KM without a full reload will not match them.


PROMPT ====== SECTION 5: STG_ORION LANDING TABLES ======

-- Physically inside the EDW instance, not inside ORION. Truncate-and-load
-- each night unless stated. Disposable; shapes mirror their sources with a
-- LOAD_DT added. Listed here so nobody invents a fourteenth one.
--
--   STG_CUSTOMER
--   STG_CUSTOMER_TERRITORY_HIST
--   STG_SKU_MASTER
--   STG_INVOICE_HEADER
--   STG_INVOICE_LINE
--   STG_ORDER_HEADER
--   STG_ORDER_LINE
--   STG_SCHEME_MASTER
--   STG_DEPOT_MASTER
--   STG_TERRITORY_MASTER
--   STG_TAX_RATE
--   STG_SECONDARY_SALES          (file fed from the DMS drop, not over the link)
--   STG_CREDIT_NOTE              *** EXISTS AND IS EMPTY ***
--
-- STG_CREDIT_NOTE: its mapping MAP_STG_CREDIT_NOTE was built in 2021, ran for
-- about fourteen months, and was DISABLED ON 14-NOV-2022 when the load window
-- got tight. The last row in the table carries LOAD_DT = 14-NOV-2022. Nothing
-- downstream ever consumed it. This is a genuine discoverable and it may
-- appear in DOC-02, schema_edw.sql, control_m_schedule.txt and CH-01.
-- It is NOT the same fact as F-CNGAP. Check fact_ownership.csv before putting
-- the dormant mapping and the missing fact table in the same document.
--
-- Plus the ODI generated work tables, which accumulate because
-- DELETE_TEMPORARY_OBJECTS is left at No:
--   C$_0STG_INVOICE_LINE, I$_FACT_INVOICE_LINE, E$_FACT_INVOICE_LINE,
--   SNP_CHECK_TAB


PROMPT ====== SECTION 6: CROSS INSTANCE PLUMBING ======

-- Database link used by the ODI LKM. It is a PRIVATE link owned by STG_ORION
-- on the EDW instance, pointing at the read only account on ORION:
--   CREATE DATABASE LINK ORION_PRD CONNECT TO OMS_RO IDENTIFIED BY <vault>
--     USING 'orion-db-prd-01';
--
-- ONE link, not two. OMS_PROD and FIN_PROD are schemas in the same ORION
-- instance, so both are reached over ORION_PRD. Anyone who tells you there is
-- a separate finance link is remembering the pre-2021 arrangement.
--
-- *** ORION_PRD IS THE VAR-003 MISDIRECTION. *** Link latency is real and
-- measurable and it was the leading suspect for months. It was RULED OUT at
-- the architecture review on 14-Apr-2026 (T-04) on AWR evidence: 4.1 minutes
-- of dblink wait across the whole load, 38 ms average round trip, 6,412 round
-- trips, 1.2% of elapsed. Latency makes a load slow. It does not make an
-- amount wrong. Do not let an artifact dated after 14-Apr-2026 present the
-- link as the cause.
--
-- Read only grants to OMS_RO, one line per table, maintained by hand in
-- grants_oms_ro_v2_FINAL_revised.sql on the SharePoint library. Not in Git.
-- Not reproduced here.
--
-- *** FIN_PROD holds a direct UPDATE grant on OMS_PROD.INVOICE_LINE, granted
-- in 2014 and never reviewed. That grant is what allows the month end package
-- in FIN_PROD to rewrite order-to-cash invoice lines. It is fact F-GRANT,
-- owned by DOC-01 and permitted in schema_oltp.sql, T-02, DOC-03, EM-092 and
-- CH-01. See procs_canon.md and CANON.md section 11.
GRANT UPDATE ON OMS_PROD.INVOICE_LINE TO FIN_PROD;

-- Standby orion-db-dr-01 at the Hyderabad DC is a physical standby and is NOT
-- used for reporting. Nothing extracts from it. Do not put a job on it.

-- ============================================================================
-- SYNTHETIC — generated for internal demo. No real entity depicted.
-- ============================================================================
