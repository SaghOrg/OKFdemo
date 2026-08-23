-- ============================================================================
-- ORION schema extract - OMS_PROD + FIN_PROD
-- source........: orion-db-prd-01.bcpl.local (Oracle Database 19c Enterprise
--                  Edition, 19.18.0.0.0), 2-node RAC, Mumbai primary DC
-- extracted by..: aniruddh.deshpande
-- extract date..: 04-MAR-2026 00:14:37 IST
-- method........: DBMS_METADATA.GET_DDL, spooled from sqlplus, storage
--                  clauses and physical attributes stripped for readability.
--                  tablespace names kept.
-- for...........: karthik.subramanian / OLTP discovery, ref 3/3 session
-- note: this is not the full metadata export, only the tables we actually
-- talked about tuesday. if something is missing just ask, dont assume it
-- does not exist.
-- owner of this file after handover: TBC
-- ============================================================================

SET DEFINE OFF
WHENEVER SQLERROR CONTINUE

-- ----------------------------------------------------------------------------
-- audit columns. every OMS_PROD / FIN_PROD table carries these six at the end
-- of the column list: CREATED_BY, CREATED_DT, LAST_UPD_BY, LAST_UPD_DT,
-- ACTIVE_FLG, DELETE_FLAG. exception is the transaction tables, where the
-- created column is a TIMESTAMP called CREATED_TS instead of CREATED_DT
-- (app server writes it). INVOICE_LINE_ARCHIVE only carries five, no
-- DELETE_FLAG, table was closed off in 2016.
-- CREATED_BY / LAST_UPD_BY values you will see: ODI_LOAD, BATCH_OMS,
-- SVC_FINBATCH, DMS_IFACE, SFA_IFACE, and the old APPS on pre-2018 rows.
-- everybody just calls it the delete flag in conversation, ACTIVE_FLG is a
-- separate thing, business availability, not the same as Delete_Flag itself
-- ----------------------------------------------------------------------------

-- =========================== OMS_PROD (13 tables) ===========================

-- 1.1 CUSTOMER. 2,140 rows. STATUS_FLG is a business column, not one of the
-- six audit columns, dont mix it up with ACTIVE_FLG.
CREATE TABLE OMS_PROD.CUSTOMER
(
  CUST_ID          NUMBER(10)     NOT NULL,
  CUST_CODE        VARCHAR2(20)   NOT NULL,
  CUST_NAME        VARCHAR2(120)  NOT NULL,
  CUST_TYPE        VARCHAR2(20),          -- DISTRIBUTOR | MODERN_TRADE | INSTITUTIONAL
  TERRITORY_CD     VARCHAR2(12),
  DEPOT_CD         VARCHAR2(12),
  CREDIT_LIMIT     NUMBER(14,2),
  STATUS_FLG       CHAR(1),               -- A active, I inactive. business status
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

-- 1.2 CUSTOMER_TERRITORY_HIST. source side territory history, append mostly,
-- edited in place when someone notices a mistake. EFF_TO_DT null means still
-- in force. no PK on this table, only an index, this is as found.
CREATE TABLE OMS_PROD.CUSTOMER_TERRITORY_HIST
(
  CUST_ID          NUMBER(10)     NOT NULL,
  TERRITORY_CD     VARCHAR2(12)   NOT NULL,
  EFF_FROM_DT      DATE           NOT NULL,
  EFF_TO_DT        DATE,
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1)
);
CREATE INDEX OMS_PROD.IX_CTH_CUST ON OMS_PROD.CUSTOMER_TERRITORY_HIST (CUST_ID, EFF_FROM_DT) TABLESPACE OMS_IDX;
-- no unique constraint on (CUST_ID, EFF_FROM_DT), never was one, nobody has
-- added it, we did this in 2017 also -ani

-- 1.3 SKU_MASTER. 1,246 rows. brand codes in use: SUV NMB KSG CHD TRG RKS,
-- nothing else. CATEGORY_CD has no NOT NULL, some rows exploit that.
CREATE TABLE OMS_PROD.SKU_MASTER
(
  SKU_ID           NUMBER(10)     NOT NULL,
  SKU_CODE         VARCHAR2(30)   NOT NULL,
  SKU_DESC         VARCHAR2(200),
  BRAND_CD         VARCHAR2(10),
  CATEGORY_CD      VARCHAR2(10),
  PACK_SIZE        VARCHAR2(20),
  UOM              VARCHAR2(5),           -- KG | LT | EA
  MRP              NUMBER(12,2),
  HSN_CODE         VARCHAR2(10),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_SKU_MASTER PRIMARY KEY (SKU_ID)
);
CREATE UNIQUE INDEX OMS_PROD.UX_SKU_CODE  ON OMS_PROD.SKU_MASTER (SKU_CODE) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_SKU_LUD   ON OMS_PROD.SKU_MASTER (LAST_UPD_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_SKU_BRAND ON OMS_PROD.SKU_MASTER (BRAND_CD, CATEGORY_CD) TABLESPACE OMS_IDX;

-- 1.4 INVOICE_HEADER. 8,902,144 rows at last profiling run. DOC_TYPE mix at
-- that same run: INV 94.7%, STN 4.7%, SMP 0.6%. INVOICE_DT is a DATE in IST,
-- CREATED_TS is a TIMESTAMP, app server writes it.
CREATE TABLE OMS_PROD.INVOICE_HEADER
(
  INVOICE_ID       NUMBER(12)     NOT NULL,
  INVOICE_NO       VARCHAR2(20)   NOT NULL,
  INVOICE_DT       DATE           NOT NULL,
  DOC_TYPE         VARCHAR2(4),               -- INV | STN | SMP
  CUST_ID          NUMBER(10),
  DEPOT_CD         VARCHAR2(12),
  ORDER_ID         NUMBER(12),
  INVOICE_STATUS   VARCHAR2(20),
  TOTAL_GROSS_AMT  NUMBER(16,2),
  TOTAL_NET_AMT    NUMBER(16,2),
  CREATED_BY       VARCHAR2(30),
  CREATED_TS       TIMESTAMP(6),
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_INVOICE_HEADER PRIMARY KEY (INVOICE_ID),
  CONSTRAINT CK_INVHDR_DOCTYPE CHECK (DOC_TYPE IN ('INV','STN','SMP')),
  CONSTRAINT CK_INVHDR_DEL     CHECK (DELETE_FLAG IN ('Y','N'))
);
CREATE UNIQUE INDEX OMS_PROD.UX_INVHDR_NO ON OMS_PROD.INVOICE_HEADER (INVOICE_NO) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVHDR_DT   ON OMS_PROD.INVOICE_HEADER (INVOICE_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVHDR_CUST ON OMS_PROD.INVOICE_HEADER (CUST_ID, INVOICE_DT) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVHDR_LUD  ON OMS_PROD.INVOICE_HEADER (LAST_UPD_DT) TABLESPACE OMS_IDX;
-- no index on CREATED_TS itself, only on INVOICE_DT and LAST_UPD_DT

-- 1.5 INVOICE_LINE. 61,847,220 rows at last profiling run, from 01-APR-2016.
-- older lines are sitting in INVOICE_LINE_ARCHIVE only.
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
  SCHEME_DISC_AMT  NUMBER(16,2),
  CASH_DISC_AMT    NUMBER(16,2),
  TAX_AMT          NUMBER(16,2),
  NET_AMT          NUMBER(16,2),
  SCHEME_ID        NUMBER(8),
  CREATED_BY       VARCHAR2(30),
  CREATED_TS       TIMESTAMP(6),
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_INVOICE_LINE PRIMARY KEY (INVOICE_LINE_ID),
  CONSTRAINT FK_INVLINE_INVHDR FOREIGN KEY (INVOICE_ID)
    REFERENCES OMS_PROD.INVOICE_HEADER (INVOICE_ID),
  CONSTRAINT CK_INVLINE_DEL CHECK (DELETE_FLAG IN ('Y','N'))
);
CREATE INDEX OMS_PROD.IX_INVLINE_INV ON OMS_PROD.INVOICE_LINE (INVOICE_ID) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVLINE_SKU ON OMS_PROD.INVOICE_LINE (SKU_ID) TABLESPACE OMS_IDX;
CREATE INDEX OMS_PROD.IX_INVLINE_LUD ON OMS_PROD.INVOICE_LINE (LAST_UPD_DT) TABLESPACE OMS_IDX;
-- leaving this here as found, generated by the old change ticket, commented
-- out already in the source, not by me:
-- ALTER TABLE OMS_PROD.INVOICE_LINE ADD (DELETE_FLAG CHAR(1) DEFAULT 'N');  -- R11.4  30-MAR-2019

-- 1.6 INVOICE_LINE_ARCHIVE. pre 01-APR-2016 lines. same shape as INVOICE_LINE
-- minus DELETE_FLAG, column never existed here, table was closed off in 2016.
-- five of the six audit columns only, this is deliberate not an omission by me
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
);

-- 1.7 ORDER_HEADER
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
-- FK to CUSTOMER was disabled in the 2020 master data cleanup and never put
-- back, karthik asked about this on the call, told him will check and revert,
-- still pending, leaving the statement here for reference only:
-- ALTER TABLE OMS_PROD.ORDER_HEADER ADD CONSTRAINT FK_ORDHDR_CUST FOREIGN KEY (CUST_ID) REFERENCES OMS_PROD.CUSTOMER (CUST_ID);

-- 1.8 ORDER_LINE. qty is in the ordering UOM, not normalised, conversion
-- happens downstream only.
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

-- 1.9 SCHEME_MASTER. five rows only, entire scheme universe:
-- 5501 QPS-Q1-SUV, 5514 MTH-CHD-OCT, 5522 SLB-TRG-FEST, 5533 TPR-NMB-SOUTH,
-- 5540 QPS-KSG-H2
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

-- 1.10 CREDIT_NOTE. this exists in ORION, FY26 volume 9,318 documents. types
-- in use: DAMAGE, RETURN, RATE_DIFF, OFF_INV_ADJ, SCHEME.
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

-- 1.11 CREDIT_NOTE_LINE. 31,204 rows FY26.
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

-- 1.12 DEPOT_MASTER. 22 rows. North 6, West 6, South 5, East 5.
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

-- 1.13 TERRITORY_MASTER. 118 rows. EMP_ID is the territory owner in
-- BCPL-EMP-nnnnn form. rep names not printed anywhere, codes only, kindly
-- do not add a name column here later, it will get asked for eventually
CREATE TABLE OMS_PROD.TERRITORY_MASTER
(
  TERRITORY_CD     VARCHAR2(12)   NOT NULL,
  TERRITORY_NAME   VARCHAR2(80),
  REGION_CD        VARCHAR2(6),
  EMP_ID           VARCHAR2(20),
  CREATED_BY       VARCHAR2(30),
  CREATED_DT       DATE,
  LAST_UPD_BY      VARCHAR2(30),
  LAST_UPD_DT      DATE,
  ACTIVE_FLG       CHAR(1),
  DELETE_FLAG      CHAR(1),
  CONSTRAINT PK_TERRITORY_MASTER PRIMARY KEY (TERRITORY_CD)
);


-- =========================== FIN_PROD (7 tables) ============================
-- FIN_PROD is the finance schema, same ORION instance as OMS_PROD, separate
-- schema. GL, receivables, tax rates, scheme accruals, period control. it
-- does NOT hold invoicing, that is in OMS_PROD only.

-- 2.1 TAX_RATE_MASTER. source table, effective dated.
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

-- 2.2 SCHEME_ACCRUAL. one row per customer per scheme per period.
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

-- 2.3 PERIOD_CONTROL. one row per fiscal period.
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

-- 2.4 GL_ACCOUNT_MASTER
-- 410100 Net Sales - Domestic / 410900 Scheme Discount (contra) / 411200 Credit Notes
-- NTOE: this table + the two journal tables below were built by the old FIN
-- DBA team before ODI came in, they use table_PK style constraint names, not
-- the PK_table convention everywhere else. left as is, not renaming it.
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
  CONSTRAINT GL_ACCOUNT_MASTER_PK PRIMARY KEY (GL_ACCOUNT_CD)
);

-- 2.5 GL_JOURNAL_HDR
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

-- 2.6 GL_JOURNAL_LINE
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

-- 2.7 AR_OPEN_ITEM. receivables ageing.
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


-- ============================== grants ======================================
-- read only grants for the extract accounts, only the tables we needed for
-- the discovery pack, not the full list, ask me if something else is needed

GRANT SELECT ON OMS_PROD.CUSTOMER       TO OMS_RO;
GRANT SELECT ON OMS_PROD.SKU_MASTER     TO OMS_RO;
GRANT SELECT ON OMS_PROD.INVOICE_HEADER TO OMS_RO;
GRANT SELECT ON OMS_PROD.INVOICE_LINE   TO OMS_RO;
GRANT SELECT ON OMS_PROD.INVOICE_HEADER TO ODI_STG_RD;
GRANT SELECT ON OMS_PROD.INVOICE_LINE   TO ODI_STG_RD;
-- remaining OMS_RO / ODI_STG_RD grants (one line per table) are maintained by
-- hand on the sharepoint library, not reproduced here

-- direct grant, dates to 2014, nobody on this side has revisited it since.
-- this is what lets FIN_PROD's month end package update invoice lines
-- directly inside OMS_PROD. flagging only because karthik asked in the OLTP
-- session whether FIN_PROD can touch OMS_PROD tables at all - yes, this is
-- how -ani
GRANT UPDATE ON OMS_PROD.INVOICE_LINE TO FIN_PROD;

-- SYNTHETIC — generated for internal demo. No real entity depicted.
