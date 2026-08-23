-- ============================================================================
-- BCPL_EDW schema extract - warehouse model tables
-- source........: edw-db-prd-01.bcpl.local (Oracle Database 19c Enterprise
--                  Edition), single instance
-- extracted by..: farida.contractor
-- extract date..: 01-SEP-2026 09:14:02 IST
-- method........: DBMS_METADATA.GET_DDL, spooled from sqlplus. storage
--                  clauses stripped, tablespace names kept.
-- scope.........: model tables only - 8 dimension/reference, 3 fact, 1
--                  security = 12 tables. the three ETL control tables
--                  (batch control, error log, param) are not in this
--                  extract, ping ishaan if you need those as well.
-- as per my earlier mail dated 27-Aug, sending the structure only, no data.
-- ============================================================================

SET DEFINE OFF
WHENEVER SQLERROR CONTINUE

-- ----------------------------------------------------------------------------
-- warehouse conventions, for reference.
-- no OLTP style audit columns here. instead: LOAD_DT (when the row was
-- loaded), UPD_DT (on SCD2 dims that update in place), BATCH_ID (on facts).
-- every DIM_* has a NUMBER surrogate key ending _KEY, facts join on the key,
-- never the natural key.
-- SCD2 flag column is CURRENT_FLG. not CURRENT_FLAG, no trailing G-A-G, this
-- has been asked before so writing it here as well.
-- every DIM_* carries a reserved row, surrogate key = -1, for UNKNOWN / not
-- applicable. see the insert block at the bottom of this script.
-- ----------------------------------------------------------------------------

-- ODI staging tables (STG_ORION schema) are physically inside this same
-- instance, not inside ORION. listed for reference only, not created by this
-- script: STG_CUSTOMER, STG_CUSTOMER_TERRITORY_HIST, STG_SKU_MASTER,
-- STG_INVOICE_HEADER, STG_INVOICE_LINE, STG_ORDER_HEADER, STG_ORDER_LINE,
-- STG_SCHEME_MASTER, STG_DEPOT_MASTER, STG_TERRITORY_MASTER, STG_TAX_RATE,
-- STG_SECONDARY_SALES, STG_CREDIT_NOTE.
-- one of those, STG_CREDIT_NOTE, exists and is empty. its mapping
-- (MAP_STG_CREDIT_NOTE) was built in 2021 and got disabled on 14-Nov-2022
-- when the load window was tight that quarter, last row in the table still
-- carries LOAD_DT = 14-NOV-2022. nobody downstream ever picked it up.
-- as per my earlier mail, this is a separate point from anything to do with
-- reporting, just noting the table is there and dormant.

-- =========================== dimension / reference tables ===================

-- DIM_DATE. approx 5,844 rows, 01-Apr-2015 to 31-Mar-2031.
CREATE TABLE BCPL_EDW.DIM_DATE
(
  DATE_KEY            NUMBER(8)    NOT NULL,   -- YYYYMMDD, except the UNKNOWN row (-1)
  FULL_DATE           DATE,
  DAY_OF_MONTH        NUMBER(2),
  DAY_NAME            VARCHAR2(10),
  WEEK_OF_YEAR        NUMBER(2),
  MONTH_NUM           NUMBER(2),
  MONTH_NAME          VARCHAR2(10),
  CAL_QTR             NUMBER(1),
  CAL_YEAR            NUMBER(4),
  FISCAL_MONTH_NUM    NUMBER(2),               -- 1 = April
  FISCAL_QTR          VARCHAR2(8),             -- eg FY26-Q1
  FISCAL_YEAR         VARCHAR2(4),             -- eg FY26
  IS_MONTH_END_FLG    CHAR(1),
  IS_WORKING_DAY_FLG  CHAR(1),
  LOAD_DT             DATE,
  CONSTRAINT PK_DIM_DATE PRIMARY KEY (DATE_KEY)
);

-- DIM_CUSTOMER. 2,140 current rows. SCD2.
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
  CURRENT_FLG         CHAR(1),
  LOAD_DT             DATE,
  UPD_DT              DATE,
  CONSTRAINT PK_DIM_CUSTOMER PRIMARY KEY (CUSTOMER_KEY)
);
CREATE INDEX BCPL_EDW.IX_DIMCUST_NK ON BCPL_EDW.DIM_CUSTOMER (CUSTOMER_ID, CURRENT_FLG) TABLESPACE EDW_IDX;

-- DIM_PRODUCT. 1,246 rows. SCD2.
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

-- DIM_GEOGRAPHY. 22 rows. SCD1, natural key DEPOT_CODE.
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

-- DIM_SCHEME. 5 rows. SCD1, natural key SCHEME_ID.
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

-- DIM_SALESREP. approx 610 current rows. SCD2. EMP_ID natural key, in
-- BCPL-EMP-nnnnn form, no name column on this table and please do not add
-- one, refreshed ad hoc rather than on the nightly schedule.
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

-- TAX_RATE_MASTER. 214 rows. this is NOT a dimension, no surrogate key, no
-- SCD2, it is a straight truncate and reload copy of FIN_PROD.TAX_RATE_MASTER
-- carrying current rates only. the source table is effective dated, this
-- copy is not, and that gap is why the Chandanaa HSN 3401 change (18% to
-- 12%, effective 01-Oct-2025) got applied retrospectively back to Apr-Sep
-- 2025 as well, about 40 L impact. replaced by DIM_TAX_RATE below on
-- 26-Aug-2026 under CHG0021339, but as per my earlier mail we are keeping
-- this table, not dropping it.
CREATE TABLE BCPL_EDW.TAX_RATE_MASTER
(
  HSN_CODE            VARCHAR2(10),
  GST_RATE_PCT        NUMBER(5,2),
  LOAD_DT             DATE
);

-- DIM_TAX_RATE. the Effective Dated replacement for TAX_RATE_MASTER above,
-- live from 26-Aug-2026 (CHG0021339). a historic invoice now resolves the
-- rate that was actually in force on its own invoice date.
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

-- =========================== fact tables ====================================

-- FACT_INVOICE_LINE. 34,182,556 rows at last profiling run, covers
-- 01-Apr-2021 onward. grain: one row per source invoice line.
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
  SCHEME_DISC_AMT     NUMBER(16,2),
  CASH_DISC_AMT       NUMBER(16,2),
  TAX_AMT             NUMBER(16,2),
  NET_AMT             NUMBER(16,2),
  SRC_DELETE_FLAG     CHAR(1),                 -- carried through from source, Y / N / null
  LOAD_DT             DATE,
  BATCH_ID            NUMBER(10),
  ODI_SESS_NO         NUMBER(12),
  CONSTRAINT PK_FACT_INVOICE_LINE PRIMARY KEY (INVOICE_LINE_KEY)
);
CREATE INDEX BCPL_EDW.IX_FIL_DATE ON BCPL_EDW.FACT_INVOICE_LINE (DATE_KEY) LOCAL TABLESPACE EDW_IDX;
CREATE INDEX BCPL_EDW.IX_FIL_CUST ON BCPL_EDW.FACT_INVOICE_LINE (CUSTOMER_KEY, DATE_KEY) LOCAL TABLESPACE EDW_IDX;
CREATE INDEX BCPL_EDW.IX_FIL_PROD ON BCPL_EDW.FACT_INVOICE_LINE (PRODUCT_KEY) LOCAL TABLESPACE EDW_IDX;

-- FACT_SECONDARY_SALES. 9,940,180 rows. one row per distributor per SKU per
-- day, sourced from the DMS upload file.
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

-- FACT_ORDER_LINE. 12,604,881 rows. one row per order line.
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

-- =========================== security ========================================

-- SEC_USER_REGION. row level security mapping consumed by the Power BI
-- semantic model, 4 roles by REGION_CODE, 128 named users at go-live of
-- which 41 are sales ops.
CREATE TABLE BCPL_EDW.SEC_USER_REGION
(
  USER_UPN            VARCHAR2(120) NOT NULL,
  REGION_CODE         VARCHAR2(6)   NOT NULL,
  LOAD_DT             DATE
);


-- =========================== unknown member seed rows ========================
-- run once after build and again after any full dimension reload. if this
-- step is skipped after a reload, a fact lookup that cannot resolve just
-- returns nothing instead of landing on -1, and the fact row count quietly
-- goes off from what it should be. dont skip it.

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

-- note the EFF_END_DT high value used above is 31-DEC-4712, not 31-DEC-9999,
-- this trips people up if they reload without checking, seperate topic from
-- everything above, mentioning only because it comes up every time.

-- SYNTHETIC — generated for internal demo. No real entity depicted.
