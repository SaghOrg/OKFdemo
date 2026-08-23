-- ============================================================================
-- FIN_PROD.PKG_MONTH_END  (PACKAGE BODY)
-- ----------------------------------------------------------------------------
-- Extracted from FIN_PROD, ORION PROD (orion-db-prd-01), for the Drishti
-- diagnostic review, 27-APR-2026 (Ani / Karthik).
--
-- Package specification is maintained separately in FIN_PROD and is not
-- reproduced here - see DBA_SOURCE / ALL_SOURCE for the current PACKAGE
-- (spec). This file is the BODY only, exactly as pulled.
-- ----------------------------------------------------------------------------
-- Purpose   : Period end revenue adjustment and scheme discount recompute.
--             Run manually by the FIN team at month end.
-- Schema    : FIN_PROD
-- Original author : ORION applications build team (Sahyadri Softech Pvt Ltd)
-- Created         : 14-MAR-2011
-- ----------------------------------------------------------------------------
-- Modification History
-- ----------------------------------------------------------------------------
-- Date         Author                        Description
-- -----------  ----------------------------  -------------------------------
-- 14-MAR-2011  Sahyadri Softech (build team)  Original version. Single-row
--                                             cursor loop, no bulk operations.
-- 06-SEP-2017  A. Deshpande (BCPL DBA)        Converted the per-row loop in
--                                             P_RECALC_SCHEME_DISCOUNT to a
--                                             BULK COLLECT / FORALL pattern,
--                                             box was struggling on the
--                                             high scheme volume months and
--                                             single row commits were the
--                                             bottleneck, will keep watching
--                                             it next few closes also.
--                                             -ani
-- 12-DEC-2019  S. Iyer (Finance Systems)      P_ADJUST_REVENUE no longer
--                                             takes a mandatory p_period
--                                             from the close checklist.
--                                             Resolves the open period from
--                                             PERIOD_CONTROL automatically.
--                                             Raised after the Apr-2019
--                                             close was run against the
--                                             wrong period by mistake.
-- 03-FEB-2024  F. Contractor (BCPL DW)        Added a WHEN OTHERS handler
--                                             around the GL posting step
--                                             so one bad account code does
--                                             not abort the whole month end
--                                             run. Logged via DBMS_OUTPUT
--                                             only, there was no error
--                                             table to write to and adding
--                                             one was out of scope at the
--                                             time.
-- ============================================================================

CREATE OR REPLACE PACKAGE BODY FIN_PROD.PKG_MONTH_END
AS

  gc_pkg_name    CONSTANT VARCHAR2(30)  := 'PKG_MONTH_END';
  gc_bulk_limit  CONSTANT PLS_INTEGER   := 500;
  gc_gl_revenue  CONSTANT VARCHAR2(10)  := '410100';   -- Net Sales - Domestic
  gc_gl_scheme   CONSTANT VARCHAR2(10)  := '410900';   -- Scheme Discount (contra)

  -- ==========================================================================
  -- P_RECALC_SCHEME_DISCOUNT
  --
  -- Recomputes scheme entitlement for every distributor with activity in
  -- the period and writes the recalculated amount back onto the invoice
  -- line. Trade scheme slabs are cumulative for the whole period, so a
  -- distributor who crosses a slab late in the period is entitled to the
  -- better rate on everything already billed this period - the line-level
  -- amount is EXPECTED to move as the period goes on. That part of the
  -- design is correct and intentional.
  -- ==========================================================================
  PROCEDURE P_RECALC_SCHEME_DISCOUNT (p_period IN VARCHAR2)
  IS
    v_period_start   DATE;
    v_period_end     DATE;
    v_line_ct        PLS_INTEGER := 0;
    v_accrual_total  NUMBER;
    v_new_pct        NUMBER;

    -- one row per customer/scheme combination with billed quantity in the
    -- period, aggregated across every line raised so far this period,
    -- not just the lines touched since the last time this ran
    CURSOR c_cust_scheme IS
      SELECT il.scheme_id,
             ih.cust_id,
             SUM(il.qty_cs)     AS tot_qty_cs
        FROM oms_prod.invoice_line   il,
             oms_prod.invoice_header ih
       WHERE il.invoice_id           = ih.invoice_id
         AND ih.invoice_dt           BETWEEN v_period_start AND v_period_end
         AND il.scheme_id            IS NOT NULL
         AND NVL(il.delete_flag,'N') = 'N'
       GROUP BY il.scheme_id, ih.cust_id;

    TYPE t_num_tab IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_scheme_tab   t_num_tab;
    v_cust_tab     t_num_tab;
    v_qty_tab      t_num_tab;

    rec_scheme     oms_prod.scheme_master%ROWTYPE;

    -- every line for one customer/scheme in the period - recomputed in
    -- full each time this procedure runs, whether or not it was touched
    -- on a previous run for the same period
    CURSOR c_lines (p_scheme_id IN NUMBER, p_cust_id IN NUMBER) IS
      SELECT il.invoice_line_id,
             il.gross_amt,
             il.scheme_disc_amt
        FROM oms_prod.invoice_line   il,
             oms_prod.invoice_header ih
       WHERE il.invoice_id           = ih.invoice_id
         AND il.scheme_id            = p_scheme_id
         AND ih.cust_id              = p_cust_id
         AND ih.invoice_dt           BETWEEN v_period_start AND v_period_end
         AND NVL(il.delete_flag,'N') = 'N';

    TYPE t_line_tab IS TABLE OF c_lines%ROWTYPE INDEX BY PLS_INTEGER;
    v_line_tab       t_line_tab;

    TYPE t_id_tab    IS TABLE OF oms_prod.invoice_line.invoice_line_id%TYPE;
    TYPE t_amt_tab   IS TABLE OF NUMBER;
    v_upd_id_tab     t_id_tab;
    v_upd_delta_tab  t_amt_tab;
    v_target_disc    NUMBER;

  BEGIN
    v_period_start := TO_DATE(p_period || '01', 'YYYYMMDD');
    v_period_end   := LAST_DAY(v_period_start);

    DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_RECALC_SCHEME_DISCOUNT - period '
                         || p_period || ' (' || TO_CHAR(v_period_start,'DD-MON-YYYY')
                         || ' to ' || TO_CHAR(v_period_end,'DD-MON-YYYY') || ')');

    OPEN c_cust_scheme;
    LOOP
      FETCH c_cust_scheme BULK COLLECT INTO v_scheme_tab, v_cust_tab, v_qty_tab
        LIMIT gc_bulk_limit;
      EXIT WHEN v_scheme_tab.COUNT = 0;

      FOR i IN 1 .. v_scheme_tab.COUNT LOOP

        BEGIN
          SELECT *
            INTO rec_scheme
            FROM oms_prod.scheme_master
           WHERE scheme_id = v_scheme_tab(i)
             AND v_qty_tab(i) BETWEEN NVL(slab_qty_from,0)
                                  AND NVL(slab_qty_to, v_qty_tab(i));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- no slab matches the accumulated quantity - most often a
            -- scheme whose validity window has since been closed
            -- retrospectively. Skip this customer/scheme this run.
            CONTINUE;
          WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('  overlapping slab rows on scheme_id '
                                 || v_scheme_tab(i) || ', skipped');
            CONTINUE;
        END;

        v_new_pct := rec_scheme.disc_pct;

        OPEN c_lines(v_scheme_tab(i), v_cust_tab(i));
        FETCH c_lines BULK COLLECT INTO v_line_tab;
        CLOSE c_lines;

        CONTINUE WHEN v_line_tab.COUNT = 0;

        v_upd_id_tab    := t_id_tab();
        v_upd_delta_tab := t_amt_tab();
        v_upd_id_tab.EXTEND(v_line_tab.COUNT);
        v_upd_delta_tab.EXTEND(v_line_tab.COUNT);
        v_accrual_total := 0;

        FOR j IN 1 .. v_line_tab.COUNT LOOP
          v_target_disc := ROUND(v_line_tab(j).gross_amt * v_new_pct / 100, 2);

          -- Delta is taken against whatever SCHEME_DISC_AMT holds right
          -- now, not against what the line was originally billed at. If
          -- this customer/scheme/period was already recalculated on an
          -- earlier run, the "current" value already includes that run's
          -- delta, and this run adds again on top of it.
          v_upd_id_tab(j)    := v_line_tab(j).invoice_line_id;
          v_upd_delta_tab(j) := v_target_disc - NVL(v_line_tab(j).scheme_disc_amt, 0);
          v_accrual_total    := v_accrual_total + v_target_disc;
        END LOOP;

        FORALL j IN v_upd_id_tab.FIRST .. v_upd_id_tab.LAST
          UPDATE oms_prod.invoice_line
             SET scheme_disc_amt = NVL(scheme_disc_amt, 0) + v_upd_delta_tab(j),
                 last_upd_by     = gc_pkg_name,
                 last_upd_dt     = SYSDATE
           WHERE invoice_line_id = v_upd_id_tab(j);

        -- No history row is kept for the value this replaces. No run
        -- marker is stamped anywhere on the line or on this procedure's
        -- own invocation. If this runs twice for the same customer,
        -- scheme and period, the same delta is added twice - nothing
        -- here checks for that and nothing here would notice.

        /* -------------------------------------------------------------
           DEBUG - disabled 2018, left in deliberately in case a specific
           customer/scheme needs walking through by hand again.
           Uncomment and set a customer id to trace one combination.

        IF v_cust_tab(i) = 100482 THEN
          FOR j IN 1 .. v_line_tab.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('  line ' || v_upd_id_tab(j)
                                 || ' before=' || v_line_tab(j).scheme_disc_amt
                                 || ' delta='  || v_upd_delta_tab(j)
                                 || ' pct='    || v_new_pct);
          END LOOP;
        END IF;
        ------------------------------------------------------------- */

        MERGE INTO fin_prod.scheme_accrual tgt
        USING (SELECT v_cust_tab(i)   AS cust_id,
                      v_scheme_tab(i) AS scheme_id,
                      p_period        AS period_yyyymm
                 FROM dual) src
           ON (    tgt.cust_id       = src.cust_id
               AND tgt.scheme_id     = src.scheme_id
               AND tgt.period_yyyymm = src.period_yyyymm)
         WHEN MATCHED THEN
           UPDATE SET accrual_amt = v_accrual_total,
                      last_upd_by = gc_pkg_name,
                      last_upd_dt = SYSDATE
         WHEN NOT MATCHED THEN
           INSERT (accrual_id, cust_id, scheme_id, period_yyyymm, accrual_amt,
                   posted_flg, created_by, created_ts, active_flg, delete_flag)
           VALUES (fin_prod.seq_scheme_accrual.NEXTVAL, v_cust_tab(i), v_scheme_tab(i),
                   p_period, v_accrual_total, 'N', gc_pkg_name, SYSTIMESTAMP, 'Y', 'N');

        v_line_ct := v_line_ct + v_upd_id_tab.COUNT;

      END LOOP;
    END LOOP;
    CLOSE c_cust_scheme;

    DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_RECALC_SCHEME_DISCOUNT - ' || v_line_ct
                         || ' line(s) adjusted for ' || p_period);

  EXCEPTION
    WHEN OTHERS THEN
      IF c_cust_scheme%ISOPEN THEN
        CLOSE c_cust_scheme;
      END IF;
      DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_RECALC_SCHEME_DISCOUNT failed for '
                           || p_period || ': ' || SQLERRM);
      RAISE;
  END P_RECALC_SCHEME_DISCOUNT;


  -- ==========================================================================
  -- P_POST_GL_SUMMARY
  --
  -- Posts the summarised journal for the period. Reads FIN_PROD.SCHEME_ACCRUAL
  -- for the discount contra side - whatever P_RECALC_SCHEME_DISCOUNT has just
  -- written for this period - and does not re-derive or check that figure.
  -- ==========================================================================
  PROCEDURE P_POST_GL_SUMMARY (p_period IN VARCHAR2)
  IS
    v_period_start  DATE;
    v_period_end    DATE;
    v_journal_id    NUMBER;
    v_revenue_amt   NUMBER := 0;
    v_scheme_amt    NUMBER := 0;
  BEGIN
    v_period_start := TO_DATE(p_period || '01', 'YYYYMMDD');
    v_period_end   := LAST_DAY(v_period_start);

    SELECT NVL(SUM(il.gross_amt), 0)
      INTO v_revenue_amt
      FROM oms_prod.invoice_line   il,
           oms_prod.invoice_header ih
     WHERE il.invoice_id           = ih.invoice_id
       AND ih.invoice_dt           BETWEEN v_period_start AND v_period_end
       AND NVL(il.delete_flag,'N') = 'N';

    SELECT NVL(SUM(accrual_amt), 0)
      INTO v_scheme_amt
      FROM fin_prod.scheme_accrual
     WHERE period_yyyymm      = p_period
       AND NVL(delete_flag,'N') = 'N';

    SELECT fin_prod.seq_gl_journal.NEXTVAL INTO v_journal_id FROM dual;

    INSERT INTO fin_prod.gl_journal_hdr
      (journal_id, period_yyyymm, source_cd, posted_ts, created_by, created_dt,
       active_flg, delete_flag)
    VALUES
      (v_journal_id, p_period, gc_pkg_name, SYSTIMESTAMP, gc_pkg_name, SYSDATE,
       'Y', 'N');

    INSERT INTO fin_prod.gl_journal_line
      (journal_line_id, journal_id, gl_account_cd, dr_amt, cr_amt,
       created_by, created_dt, active_flg, delete_flag)
    VALUES
      (fin_prod.seq_gl_journal_line.NEXTVAL, v_journal_id, gc_gl_revenue,
       0, v_revenue_amt, gc_pkg_name, SYSDATE, 'Y', 'N');

    INSERT INTO fin_prod.gl_journal_line
      (journal_line_id, journal_id, gl_account_cd, dr_amt, cr_amt,
       created_by, created_dt, active_flg, delete_flag)
    VALUES
      (fin_prod.seq_gl_journal_line.NEXTVAL, v_journal_id, gc_gl_scheme,
       v_scheme_amt, 0, gc_pkg_name, SYSDATE, 'Y', 'N');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_POST_GL_SUMMARY - journal ' || v_journal_id
                         || ' posted for ' || p_period || ', revenue=' || v_revenue_amt
                         || ', scheme_contra=' || v_scheme_amt);

  EXCEPTION
    WHEN OTHERS THEN
      -- Added 03-FEB-2024 (F. Contractor) - one bad account code used to
      -- abort the whole nightly run. This swallows the error instead;
      -- nothing else records that a posting failed for this period.
      DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_POST_GL_SUMMARY failed for '
                           || p_period || ': ' || SQLERRM);
  END P_POST_GL_SUMMARY;


  -- ==========================================================================
  -- P_ADJUST_REVENUE
  --
  -- Driver procedure. Resolves the open period from FIN_PROD.PERIOD_CONTROL
  -- when p_period is not supplied, then calls P_RECALC_SCHEME_DISCOUNT and
  -- P_POST_GL_SUMMARY in that order.
  -- ==========================================================================
  PROCEDURE P_ADJUST_REVENUE (p_period IN VARCHAR2 DEFAULT NULL)
  IS
    v_period     fin_prod.period_control.period_yyyymm%TYPE;
    rec_period   fin_prod.period_control%ROWTYPE;
  BEGIN
    IF p_period IS NULL THEN
      BEGIN
        SELECT period_yyyymm
          INTO v_period
          FROM fin_prod.period_control
         WHERE status = 'OPEN'
         ORDER BY period_yyyymm
         FETCH FIRST 1 ROW ONLY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE(gc_pkg_name
               || '.P_ADJUST_REVENUE - no OPEN period in PERIOD_CONTROL, nothing to do');
          RETURN;
      END;
    ELSE
      v_period := p_period;
    END IF;

    BEGIN
      SELECT *
        INTO rec_period
        FROM fin_prod.period_control
       WHERE period_yyyymm = v_period;

      IF rec_period.status = 'CLOSED' THEN
        -- P_CLOSE_PERIOD flips STATUS to CLOSED but this driver does not
        -- check for that before running. Closing a period does not stop
        -- this from adjusting it again; it just means the next call
        -- with p_period defaulted moves on to whatever period opens
        -- next. This one still goes ahead.
        DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_ADJUST_REVENUE - period ' || v_period
                             || ' is already CLOSED, adjusting anyway');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_ADJUST_REVENUE - no PERIOD_CONTROL row for '
                             || v_period || ', proceeding without one');
    END;

    DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_ADJUST_REVENUE - starting for ' || v_period);

    P_RECALC_SCHEME_DISCOUNT(v_period);
    P_POST_GL_SUMMARY(v_period);

    DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_ADJUST_REVENUE - complete for ' || v_period);

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_ADJUST_REVENUE failed for period '
                           || NVL(v_period, '(unresolved)') || ': ' || SQLERRM);
      RAISE;
  END P_ADJUST_REVENUE;


  -- ==========================================================================
  -- P_CLOSE_PERIOD
  --
  -- The only member of this package a human invokes deliberately, once a
  -- month. Flips PERIOD_CONTROL.STATUS to CLOSED and stamps who and when.
  -- ==========================================================================
  PROCEDURE P_CLOSE_PERIOD (p_period IN VARCHAR2)
  IS
  BEGIN
    UPDATE fin_prod.period_control
       SET status    = 'CLOSED',
           closed_ts = SYSTIMESTAMP,
           closed_by = USER
     WHERE period_yyyymm = p_period;

    IF SQL%ROWCOUNT = 0 THEN
      DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_CLOSE_PERIOD - no PERIOD_CONTROL row for '
                           || p_period || ', nothing updated');
    END IF;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_CLOSE_PERIOD - ' || p_period
                         || ' closed by ' || USER);

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(gc_pkg_name || '.P_CLOSE_PERIOD failed for '
                           || p_period || ': ' || SQLERRM);
      RAISE;
  END P_CLOSE_PERIOD;

END PKG_MONTH_END;
/

-- ============================================================================
-- SYNTHETIC — generated for internal demo. No real entity depicted.
-- ============================================================================
