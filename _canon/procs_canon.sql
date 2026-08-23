--------------------------------------------------------------------------------
-- procs_canon.sql
-- CANON-INTERNAL. Phase A output. NOT an artifact. NOT part of _sources/.
--
-- Purpose: freeze the CODE SHAPES that the technical artifacts must reproduce:
-- the PKG_MONTH_END package, the P_ETL_BATCH_CLOSE signature, the STG_ORION
-- landing list, and the MAP_FACT_INVOICE_LINE load written out as SQL. So that
-- pkg_month_end.pkb, the ODI mapping export, the sample CSV and XL-04 cannot
-- drift apart.
--
-- *** TABLE DDL LIVES IN schema_canon.sql, AND ONLY THERE. ***
-- Reconciled at the Phase A exit gate on 22-Aug-2026. This file used to carry a
-- second, shorter copy of the OMS_PROD / FIN_PROD / BCPL_EDW CREATE TABLE
-- statements. Two copies of the same DDL is exactly how the audit column names
-- drifted in the first place, so the copy is gone. For any table, column,
-- datatype, constraint or index, read schema_canon.sql. It implements CANON.md
-- section 9 exactly:
--     OMS_PROD 13 tables, FIN_PROD 7 tables  (20 OLTP tables)
--     BCPL_EDW 15 tables  (12 model + 3 ETL control)
--     STG_ORION 13 landing tables
--     and NO BCPL_EDW.FACT_CREDIT_NOTE.
--
-- HOW TO USE
--   * Object and column names here are EXACT. Reproduce them character for character.
--   * The formatting here is deliberately clean. The ARTIFACTS must not be.
--     Source artifacts carry generated-DDL noise, inconsistent comment style, stale
--     comments, tab and space mixing, and the occasional column nobody can explain.
--   * DO NOT copy this file into _sources/. Write the artifacts yourself, using
--     these names.
--
-- The six OLTP audit columns, reconciled spelling (CANON.md section 20.3), because
-- this is the thing people get wrong:
--     CREATED_BY, CREATED_DT, LAST_UPD_BY, LAST_UPD_DT, ACTIVE_FLG, DELETE_FLAG
-- with CREATED_TS TIMESTAMP(6) in place of CREATED_DT on the transaction tables
-- (INVOICE_HEADER, INVOICE_LINE, INVOICE_LINE_ARCHIVE, ORDER_HEADER, CREDIT_NOTE,
-- SCHEME_ACCRUAL). Never CREATED_DATE, LAST_UPDATED_DATE, LAST_UPDATED_BY or
-- ACTIVE_FLAG. LAST_UPD_DT is the column the incremental extract keys off.
--
-- ⚠ EXCLUSIVITY: the schedule of FIN_PROD.PKG_MONTH_END is fact F-TIMING and belongs
--   to DOC-03 alone. It is stated in CANON.md section 11 under an exclusivity banner
--   and is DELIBERATELY OMITTED FROM THIS FILE so that it cannot be copied by
--   accident into a technical artifact. No 02:15, no 02:40, no 02:55, no ordering.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 3. FIN_PROD.PKG_MONTH_END  -- the package behind VAR-003
--    Reproduce the SHAPE of the body in _sources/technical/pkg_month_end.pkb.
--    Do NOT reproduce any schedule. There is none in this file, on purpose.
--------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE FIN_PROD.PKG_MONTH_END AS
  PROCEDURE P_ADJUST_REVENUE          (p_period IN VARCHAR2 DEFAULT NULL);
  PROCEDURE P_RECALC_SCHEME_DISCOUNT  (p_period IN VARCHAR2);
  PROCEDURE P_POST_GL_SUMMARY         (p_period IN VARCHAR2);
  PROCEDURE P_CLOSE_PERIOD            (p_period IN VARCHAR2);
END PKG_MONTH_END;
/

-- Body shape. The defect is the additive UPDATE with no idempotency guard and no
-- run marker. Touching the row bumps LAST_UPD_DT, which is the column the nightly
-- incremental extract keys off.
--
-- CREATE OR REPLACE PACKAGE BODY FIN_PROD.PKG_MONTH_END AS
--
--   PROCEDURE P_RECALC_SCHEME_DISCOUNT (p_period IN VARCHAR2) IS
--     v_delta NUMBER(16,2);
--   BEGIN
--     FOR r IN (SELECT il.INVOICE_LINE_ID, il.SKU_ID, il.QTY_CS, il.SCHEME_ID,
--                      ih.CUST_ID
--                 FROM OMS_PROD.INVOICE_LINE il,
--                      OMS_PROD.INVOICE_HEADER ih
--                WHERE il.INVOICE_ID = ih.INVOICE_ID
--                  AND TO_CHAR(ih.INVOICE_DT,'YYYYMM') = p_period)
--     LOOP
--        v_delta := F_SCHEME_ENTITLEMENT(r.CUST_ID, r.SCHEME_ID, r.QTY_CS);
--
--        UPDATE OMS_PROD.INVOICE_LINE
--           SET SCHEME_DISC_AMT = NVL(SCHEME_DISC_AMT,0) + v_delta,   -- ADDITIVE
--               NET_AMT         = GROSS_AMT - (NVL(SCHEME_DISC_AMT,0) + v_delta)
--                                 - NVL(CASH_DISC_AMT,0) + NVL(TAX_AMT,0),
--               LAST_UPD_DT     = SYSDATE
--         WHERE INVOICE_LINE_ID = r.INVOICE_LINE_ID;
--
--        MERGE INTO FIN_PROD.SCHEME_ACCRUAL ... ;
--     END LOOP;
--     COMMIT;
--   END P_RECALC_SCHEME_DISCOUNT;
--
--   PROCEDURE P_ADJUST_REVENUE (p_period IN VARCHAR2 DEFAULT NULL) IS
--     v_period VARCHAR2(6) := p_period;
--   BEGIN
--     IF v_period IS NULL THEN
--        SELECT PERIOD_YYYYMM INTO v_period
--          FROM FIN_PROD.PERIOD_CONTROL WHERE STATUS = 'OPEN' AND ROWNUM = 1;
--     END IF;
--     P_RECALC_SCHEME_DISCOUNT(v_period);
--     P_POST_GL_SUMMARY(v_period);
--   END P_ADJUST_REVENUE;
--
-- END PKG_MONTH_END;
-- /
--
-- Header comments to reproduce in the artifact, stale and misleading, verbatim in spirit:
--   -- Sahyadri Softech Pvt Ltd, 2011
--   -- month end revenue adjustment. run manually by FIN team after period close.
--   -- 2014 : slab logic added for QPS schemes. -AD
--   -- 2019 : no change


--------------------------------------------------------------------------------
-- 4. BCPL_EDW.P_ETL_BATCH_CLOSE
--    The warehouse-side routine. Final in-plan step of LP_DAILY_SALES and of
--    LP_MONTHEND_FIN. Writes the closing row of ETL_BATCH_CONTROL and persists
--    the extract high water mark. Half of the VAR-008 fix, 08-Jul-2026: before
--    that the high water mark advanced at the START of the plan, so a mid-plan
--    failure moved the window past rows that were never loaded.
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE BCPL_EDW.P_ETL_BATCH_CLOSE
  ( p_load_plan_name   IN VARCHAR2
  , p_load_plan_run_no IN NUMBER
  , p_status           IN VARCHAR2 DEFAULT 'DONE'
  , p_business_dt      IN DATE     DEFAULT TRUNC(SYSDATE) - 1
  );
/

-- Shape of what it does:
--   UPDATE BCPL_EDW.ETL_BATCH_CONTROL
--      SET END_TS          = SYSTIMESTAMP,
--          STATUS          = p_status,
--          ROWS_INSERTED   = <from the plan step counters>,
--          ROWS_REJECTED   = <from the plan step counters>,
--          EXTRACT_HIGH_TS = <the high water mark for this run>,
--          RESTART_COUNT   = NVL(RESTART_COUNT,0) + <1 if a row already existed>
--    WHERE LOAD_PLAN_NAME = p_load_plan_name
--      AND BUSINESS_DATE  = p_business_dt
--      AND STATUS         = 'RUNNING';
--   COMMIT;
--
-- Two things to know, and both matter:
--   1. If the plan aborts before this step the RUNNING rows are never closed.
--      The next run correctly falls back to the last good high water mark, which
--      is safe, but the stale row sits there for ever. Several of these exist.
--   2. p_status comes from the load plan step, and a step that finished with
--      warnings reports as successful. A 'DONE' row means "the plan reached the
--      last step", NOT "the data is right". Every night that produced a VAR-003
--      duplicate has a green row in ETL_BATCH_CONTROL.


--------------------------------------------------------------------------------
-- 5. STG_ORION landing tables
--    Names only. Shapes mirror the OMS_PROD / FIN_PROD source tables plus
--    LOAD_DT DATE and BATCH_ID NUMBER(10).
--------------------------------------------------------------------------------
-- STG_CUSTOMER, STG_CUSTOMER_TERRITORY_HIST, STG_SKU_MASTER, STG_INVOICE_HEADER,
-- STG_INVOICE_LINE, STG_ORDER_HEADER, STG_ORDER_LINE, STG_SCHEME_MASTER,
-- STG_DEPOT_MASTER, STG_TERRITORY_MASTER, STG_TAX_RATE, STG_SECONDARY_SALES,
-- STG_CREDIT_NOTE  <-- exists, empty, last LOAD_DT 14-NOV-2022, mapping disabled
--
-- ODI work tables that may appear: C$_0STG_INVOICE_LINE, I$_FACT_INVOICE_LINE,
-- E$_FACT_INVOICE_LINE, SNP_CHECK_TAB.


--------------------------------------------------------------------------------
-- 6. The MAP_FACT_INVOICE_LINE load, in SQL, as it behaved BEFORE remediation.
--    This is what the 20-May-2026 ODI export encodes. Reproduce the SHAPE, not
--    this text, in odi_mapping_export_MAP_FACT_INVOICE_LINE.xml.
--------------------------------------------------------------------------------
-- INSERT INTO BCPL_EDW.FACT_INVOICE_LINE ( ... )
-- SELECT  SEQ_FACT_INVOICE_LINE.NEXTVAL,
--         IL.INVOICE_ID,
--         IL.INVOICE_LINE_ID,
--         TO_NUMBER(TO_CHAR(IH.CREATED_TS,'YYYYMMDD')),   -- VAR-002: UTC timestamp
--         DC.CUSTOMER_KEY, DP.PRODUCT_KEY, DG.GEO_KEY, DS.SALESREP_KEY, DSC.SCHEME_KEY,
--         IL.QTY_CS, IL.QTY_EA, IL.GROSS_AMT, IL.SCHEME_DISC_AMT, IL.CASH_DISC_AMT,
--         IL.TAX_AMT, IL.NET_AMT, IL.DELETE_FLAG, SYSDATE, :BATCH_ID, :SESS_NO
--   FROM  STG_ORION.STG_INVOICE_LINE IL
--         JOIN STG_ORION.STG_INVOICE_HEADER IH ON IH.INVOICE_ID = IL.INVOICE_ID
--         LEFT JOIN BCPL_EDW.DIM_CUSTOMER DC ON DC.CUSTOMER_ID = IH.CUST_ID
--                                           AND DC.CURRENT_FLG = 'Y'      -- VAR-004
--         LEFT JOIN BCPL_EDW.DIM_PRODUCT  DP ON DP.SKU_ID = IL.SKU_ID     -- VAR-007
--         ...
--  WHERE  IL.LAST_UPD_DT >= TRUNC(SYSDATE) - 1
--    AND  IH.DOC_TYPE <> 'SMP';
--    -- no DELETE_FLAG predicate at all                                    -- VAR-001
--    -- IKM Oracle Control Append, TRUNCATE=false, FLOW_CONTROL=false      -- VAR-008
--
-- After remediation (03-Jun-2026, CHG0021184 and CHG0021207):
--    TO_NUMBER(TO_CHAR(IH.INVOICE_DT,'YYYYMMDD'))
--    AND NVL(IL.DELETE_FLAG,'N') = 'N'
-- After 08-Jul-2026 (R2026.07, the undocumented chat decision, F-CHATDEC, CH-01 only):
--    AND IH.DOC_TYPE = 'INV'

-- SYNTHETIC — generated for internal demo. No real entity depicted.
