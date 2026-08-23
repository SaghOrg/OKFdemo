# PL/SQL and batch inventory - the nightly chain

BCPL / project Bharadwaj. Technical canon. Five stored routines plus the schedule they
sit in. Read alongside `schema_canon.sql` (objects) and `odi_canon.md` (the ODI side).

gen-seed 20260822

---

> ## ⚠ EXCLUSIVITY BANNER - READ BEFORE USING ANYTHING IN THIS FILE
>
> This file states the mechanism behind VAR-003 **so that you can avoid writing it.**
> It mirrors the banner in `CANON.md` §11, which governs.
>
> **The sentence "P_ADJUST_REVENUE runs at 02:15 IST, after the 01:00 IST nightly load
> completes", and every paraphrase, hint, restatement or rounding of it, is EXCLUSIVE
> to `DOC-03` (`_sources/docs/DOC-03_stored_procedure_walkthrough.docx`).**
>
> No other artifact in `_sources/` may state:
> - the time **02:15** (or "quarter past two", "2.15 am", "02:15 hrs", "just after two"), or
> - the time **02:40**, the time **02:55**, or any other time in the OLTP-side chain below, or
> - that any procedure runs **after** the nightly load, or
> - that the recalculation **re-writes rows that have already been extracted**, or
> - the ordering of the load and the procedure in any form.
>
> `control_m_schedule.txt` must not contain any finance adjustment job and must not
> contain any time in the 02:10 - 02:20 range.
>
> `fact_ownership.csv` (`F-TIMING`) spells out every artifact ID. Canon may state this.
> `_sources/` may not. The non-exclusive area fact `F-VAR003-AREA` is what other
> artifacts are allowed to say; see the end of section 4a.

---

> ## PRECEDENCE - RECONCILED AT THE PHASE A EXIT GATE, 22-Aug-2026
>
> **`CANON.md` is BINDING and its §11 is the canonical stored procedure registry.**
> **This file now carries exactly the routines CANON.md registers, under CANON.md's
> names and signatures. There are no open collisions between the two any more.**
>
> An earlier revision of this file carried three routines that are not in CANON.md
> (`P_PURGE_CANCELLED_ORDERS`, `P_LOAD_AUDIT_CLOSE`, `P_REBUILD_PRICE_CACHE`) and
> omitted two that are (`P_POST_GL_SUMMARY`, `P_CLOSE_PERIOD`). That is fixed.
>
> | dead name | the name that governs |
> |---|---|
> | `P_PURGE_CANCELLED_ORDERS` | gone. ORION housekeeping is referenced only as an unnamed job in Control-M folder `BCPL_ORION_OPS`. |
> | `P_REBUILD_PRICE_CACHE` | gone. There is no price cache and no price list table in CANON.md §9. |
> | `P_LOAD_AUDIT_CLOSE` | **`P_ETL_BATCH_CLOSE`** in `BCPL_EDW`, writing `ETL_BATCH_CONTROL` |
> | `WH_LOAD_AUDIT` | **`ETL_BATCH_CONTROL`** |
>
> `P_RECALC_SCHEME_DISCOUNT` is a member of **`FIN_PROD.PKG_MONTH_END`**, called by
> `P_ADJUST_REVENUE`. It is not separately scheduled and it does not live in
> `OMS_PROD`.

---

## 1. Scope

Five routines. Four are members of `FIN_PROD.PKG_MONTH_END`; one is the warehouse-side
routine that closes a load plan run. All five are in CANON.md §11.

| routine | schema | when it runs (IST) |
|---|---|---|
| `PKG_MONTH_END.P_ADJUST_REVENUE` | `FIN_PROD` | 02:15 daily, `DBMS_SCHEDULER`, not Control-M |
| `PKG_MONTH_END.P_RECALC_SCHEME_DISCOUNT` | `FIN_PROD` | ~02:40, reached from inside the 02:15 run |
| `PKG_MONTH_END.P_POST_GL_SUMMARY` | `FIN_PROD` | ~02:55, reached from the same run |
| `PKG_MONTH_END.P_CLOSE_PERIOD` | `FIN_PROD` | not scheduled. Run once a month by Finance, by hand |
| `P_ETL_BATCH_CLOSE` | `BCPL_EDW` | not scheduled. Final in-plan step of `LP_DAILY_SALES`, ~02:03 to 02:05 |

**Every clock time in the `FIN_PROD` rows above is fact `F-TIMING` and is EXCLUSIVE to
`DOC-03`.** The `BCPL_EDW` row is not: the load finishing around 02:05 is part of the
load window story. What is forbidden is stating what happens *after* it.

---

## 2. THE CLOCK

The single most important table in this document. All times IST, all daily.

| time | what runs | scheduled by | owner |
|---|---|---|---|
| 00:45 | pre-check (source availability, link test) | Control-M `BCPL_EDW_DAILY` | EDW |
| **01:00** | **`LP_DAILY_SALES` starts** - job `BCPL_EDW_DAILY_LOAD_START` fires `SCEN_LP_DAILY_SALES` | Control-M `BCPL_EDW_DAILY` | EDW |
| 01:00 - 01:38 | `PKG_STG_EXTRACT` | in-flow | EDW |
| 01:38 - 01:50 | `PKG_DIM_LOAD` | in-flow | EDW |
| 01:50 - 01:58 | `PKG_FACT_LOAD`, including `MAP_FACT_INVOICE_LINE` | in-flow | EDW |
| 01:58 - 02:05 | `PKG_POST_LOAD_CHECKS`, then `P_ETL_BATCH_CLOSE` | in-flow | EDW |
| **~02:05** | **warehouse load complete. The extract has stopped reading the source.** | | |
| **02:15** | **`PKG_MONTH_END.P_ADJUST_REVENUE`** | **`DBMS_SCHEDULER` inside ORION** | Finance |
| **~02:40** | **`P_RECALC_SCHEME_DISCOUNT`**, reached from inside the 02:15 run | (same job) | Finance |
| **~02:55** | **`P_POST_GL_SUMMARY`**, reached from the same run | (same job) | Finance |
| 03:05 | OBIEE cache seed | Control-M `BCPL_EDW_DAILY` | EDW |
| 03:10 | ORION housekeeping, soft delete of cancelled documents | Control-M `BCPL_ORION_OPS` | ORION ops |
| 03:20 | alert summary mail | Control-M `BCPL_EDW_DAILY` | EDW |
| 03:30 | ORION housekeeping, second window | Control-M `BCPL_ORION_OPS` | ORION ops |
| 04:00 | secondary sales file pickup | Control-M `BCPL_EDW_DAILY` | EDW |
| Sun 04:00 | ORION housekeeping, weekly full pass | Control-M `BCPL_ORION_OPS` | ORION ops |

### The three facts to take away

1. The warehouse load **starts at 01:00** and has **stopped reading the source by about
   02:05**. Average elapsed is 58 minutes to the last mapping; the post-load checks and
   the audit close take it to ~02:05.
2. The first thing that changes money, `P_ADJUST_REVENUE`, starts at **02:15**. Ten
   minutes after the warehouse stopped reading.
3. Its scheme recalculation reaches the invoice lines at about **02:40**. Thirty five
   minutes after the warehouse stopped reading.

### The dependency that does not exist, and the job nobody could find

The warehouse jobs live in Control-M folder `BCPL_EDW_DAILY`. ORION's own housekeeping
lives in folder `BCPL_ORION_OPS` and is owned by a different team. There is no
in-condition, no out-condition and no resource lock between them.

**And `PKG_MONTH_END` is not in Control-M at all.** It is a `DBMS_SCHEDULER` job inside
ORION, owned by `FIN_PROD`:

```
job_name        => 'FIN_MTHEND_ADJ_NIGHTLY'
repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=15'
enabled         => 19-Nov-2014
```

Because it is outside Control-M it never appeared in the ODI or Control-M job
inventory. That is why it took two months to find. Anyone auditing the batch estate
from `control_m_schedule.txt` will conclude, correctly and uselessly, that nothing runs
against finance data after the load.

The ten minute gap between 02:05 and 02:15 is not a designed buffer. It is a
coincidence of two teams, in two tools, picking round numbers.

On month-end nights the gap is negative. The worst night in the Feb-Apr 2026 sample ran
3 h 12 min and finished at **04:12**, which is nearly two hours after the 02:15 job
started and well past the 02:40 recalculation. On nights like that the extract is
reading rows while they are being rewritten underneath it, which is a torn read on top
of everything else. The business availability SLA is 05:30, so none of those nights
looked like a failure to anybody.

---

## 3. `PKG_MONTH_END.P_ADJUST_REVENUE`

**Schema** FIN_PROD · **Package** `PKG_MONTH_END`
**Schedule** 02:15 IST daily, `DBMS_SCHEDULER` job `FIN_MTHEND_ADJ_NIGHTLY`. **Not in Control-M.**
**Typical runtime** the whole package run takes 40 to 55 minutes end to end.

### Purpose

Driver procedure. Resolves the open period from `FIN_PROD.PERIOD_CONTROL` when
`p_period` is null, then calls `P_RECALC_SCHEME_DISCOUNT` and `P_POST_GL_SUMMARY` in
that order. It is the entry point for the nightly revenue adjustment.

The package is called `PKG_MONTH_END` and its header comment still claims it is "run
manually by the FIN team at month end". **It runs every night, 365 nights a year, and
has since 2014.** That mismatch is the reason the effect compounds through the month
and presents as a growing variance rather than a one-off. Everyone who reads the
package name assumes twelve runs a year.

### Inputs

```
PROCEDURE P_ADJUST_REVENUE ( p_period IN VARCHAR2 DEFAULT NULL );
```

The scheduler job calls it with no argument, so `p_period` resolves from
`PERIOD_CONTROL`.

### Side effects

* Calls `P_RECALC_SCHEME_DISCOUNT(p_period)`. Everything that routine does is a side
  effect of this one. See section 4.
* Calls `P_POST_GL_SUMMARY(p_period)`, which posts the summarised journal.
* No persistent log of its own. What it adjusted, and by how much, is not recorded
  anywhere in the database.

### Known defects

1. **It runs after the warehouse extract.** 02:15 against a load that stops reading at
   about 02:05. Nothing it does is visible to the warehouse for that business date.
2. **It is invisible to every batch inventory.** `DBMS_SCHEDULER`, not Control-M, so it
   is absent from the scheduling documentation the ODI and EDW teams work from.
3. **The name lies.** "Month end" in the package name, daily in the schedule.
4. **No audit trail.** Reconstructing what was adjusted three months ago is not possible
   from the database.

**This is the primary contributor to VAR-003**, not because its logic is wrong but
because of when it runs and what its callee does to `LAST_UPD_DT`.

---

## 4. `PKG_MONTH_END.P_RECALC_SCHEME_DISCOUNT`

**Schema** FIN_PROD, member of `PKG_MONTH_END`
**Schedule** not independently scheduled. Called by `P_ADJUST_REVENUE`, and in a typical
run it reaches the invoice line update at about **02:40 IST**, the driver having spent
the first twenty five minutes resolving the period and building the accrual set.
**Typical runtime** 18 to 40 minutes depending on how many schemes are live.

### Purpose

Recomputes scheme entitlement for every distributor with activity in the period. Trade
scheme slabs are cumulative, so a distributor who crosses a slab late in the month
becomes entitled to a better rate on everything already bought that month. Yesterday's
discount can legitimately be wrong today. The recalculation itself is correct.

### Inputs

```
PROCEDURE P_RECALC_SCHEME_DISCOUNT ( p_period IN VARCHAR2 );
```

### Side effects

* Writes `FIN_PROD.SCHEME_ACCRUAL` (`ACCRUAL_ID`, `CUST_ID`, `SCHEME_ID`,
  `PERIOD_YYYYMM`, `ACCRUAL_AMT`, `POSTED_FLG`).
* **Updates `OMS_PROD.INVOICE_LINE.SCHEME_DISC_AMT` additively:**

  ```sql
  UPDATE OMS_PROD.INVOICE_LINE
     SET SCHEME_DISC_AMT = NVL(SCHEME_DISC_AMT,0) + v_delta
   WHERE ...
  ```

  **No idempotency guard. No run-marker column. No history row. No audit table.** The
  previous value is not retained anywhere. Run it twice and the amount goes up twice.
* Touching the row bumps `LAST_UPD_DT` to the current timestamp, which is about 02:40 on
  the day after the invoice.
* It can do this at all because `FIN_PROD` holds a direct `UPDATE` grant on
  `OMS_PROD.INVOICE_LINE`, granted in 2014 and never reviewed.

### Known defects

1. **Additive with no guard.** The single most consequential line in the estate.
   Nothing prevents the same delta being applied more than once, and nothing records
   that it was applied at all.
2. **In place, no history.** It is not possible to answer "what was this line's scheme
   discount on the 14th" from the database. Only "what is it now".
3. **It bumps `LAST_UPD_DT` on rows the warehouse has already extracted**, which is what
   feeds them back into the next night's incremental window.
4. **Cross-schema write from a package nobody downstream knows about.** A finance
   package rewriting order-to-cash invoice lines is not something the EDW team had any
   reason to look for.

---

## 4a. VAR-003, stated end to end

**Canon-internal. Do not reproduce outside DOC-03. See the banner at the top.**

Take one invoice line, business date D. Call the billed scheme discount `X` and the
recalculated delta `A`.

| when | what happens | `INVOICE_LINE.SCHEME_DISC_AMT` | `FACT_INVOICE_LINE` |
|---|---|---|---|
| during D | line invoiced | `X` | - |
| D+1 01:50-01:58 | `MAP_FACT_INVOICE_LINE` extracts and inserts | `X` | one row, `X` |
| D+1 ~02:05 | load completes, audit row written, everything green | `X` | one row, `X` |
| D+1 02:15 | `P_ADJUST_REVENUE` starts, outside Control-M | `X` | one row, `X` |
| D+1 ~02:40 | `P_RECALC_SCHEME_DISCOUNT` adds `A` additively and bumps `LAST_UPD_DT` | `X + A` | one row, `X` |
| D+2 01:50-01:58 | the fixed predicate `LAST_UPD_DT >= TRUNC(SYSDATE)-1` catches the row again. `IKM Oracle Control Append` is insert-only. | `X + A` | **two rows: `X` and `X + A`** |

Both halves are required.

* **The source-side half.** The recalculation adds to a column instead of setting it,
  with no guard and no marker, and bumps the change-capture column while doing it.
* **The warehouse-side half.** The fact mapping is insert-only on a fixed rolling 24
  hour window, with no merge key and no batch guard, so a row that comes back is a new
  row rather than a correction. The grain quietly degrades from one row per invoice line
  to one row per invoice line **per extract**.

Net effect: `SCHEME_DISC_AMT` is counted twice in `FACT_INVOICE_LINE`. Because the
package runs nightly rather than monthly, the effect compounds through the month and
looks like a variance that grows rather than a one-off error. **Estimated FY26 impact
INR 1.7 Cr.** That figure is frozen; do not recompute it, and do not use it outside the
artifacts `fact_ownership.csv` permits.

Every night this happened has a clean load audit. Nothing errored. Nothing restarted.
Nothing reached the error log.

### Ruled out, for the record

* **DBLINK latency on `ORION_PRD`.** Real, measurable, and the leading suspect for
  months. **Ruled out at T-04 on 14-Apr-2026** on AWR evidence: 4.1 minutes of link wait
  across the whole load, 38 ms average round trip, 6,412 round trips, 1.2% of elapsed.
  Frozen in CANON.md §18.3 and set out in `odi_canon.md` §4.1. This is the corpus's
  designed misdirection: a good, technically literate wrong answer.
* **VAR-001, the missing `DELETE_FLAG` filter.** A genuine defect that genuinely
  overstated sales, closed under `CHG0021184` on 03-Jun-2026. It cannot explain
  anything observed after that date.

### What other artifacts ARE allowed to say (`F-VAR003-AREA`)

"the scheme discount double-count originates in an ORION-side recalculation" · "a
finance procedure in ORION rewrites the discount amount" · "root cause is source-side,
not in ODI" · "see the stored procedure walkthrough for detail". None of those state a
time or an ordering.

---

## 5. `PKG_MONTH_END.P_POST_GL_SUMMARY`

**Schema** `FIN_PROD`, member of `PKG_MONTH_END`
**Schedule** not independently scheduled. Called by `P_ADJUST_REVENUE` after
`P_RECALC_SCHEME_DISCOUNT` returns, which in a typical run puts it at about **02:55 IST**.
**Typical runtime** 4 to 9 minutes.

### Purpose

Posts the summarised journal for the period to `FIN_PROD.GL_JOURNAL_HDR` and
`FIN_PROD.GL_JOURNAL_LINE`. Revenue goes to account `410100` (Net Sales - Domestic),
the scheme discount contra to `410900`, credit notes to `411200`.

### Inputs

```
PROCEDURE P_POST_GL_SUMMARY ( p_period IN VARCHAR2 );
```

### Side effects

* Inserts one journal header and its lines per period per run.
* Reads `FIN_PROD.SCHEME_ACCRUAL` for the accrual side, so it posts **whatever
  `P_RECALC_SCHEME_DISCOUNT` has just written**. It inherits that routine's arithmetic
  without checking it.
* Does not touch `OMS_PROD` at all.

### Known defects

1. **It posts a summary, so the GL nets out what the detail double-counts.** The journal
   is internally consistent and ties to `SCHEME_ACCRUAL`. It does not tie to
   `FACT_INVOICE_LINE`, because the warehouse holds the extra rows and the GL does not.
   This is exactly why Shalini Iyer's trial balance and the warehouse extract disagree
   and why "can we tie this back to the trial balance?" is the right question.
2. **It runs nightly like the rest of the package**, so a period accumulates repeated
   postings rather than one at close. Finance reverses them at close. Nobody outside
   Finance knows that happens.

---

## 6. `PKG_MONTH_END.P_CLOSE_PERIOD`

**Schema** `FIN_PROD`, member of `PKG_MONTH_END`
**Schedule** **not scheduled at all.** Run once a month, by hand, by someone in Finance.
It is the only member of the package a human ever invokes deliberately.
**Typical runtime** under a minute.

### Purpose

Flips `FIN_PROD.PERIOD_CONTROL.STATUS` to `CLOSED` for the period, and stamps
`CLOSED_TS` and `CLOSED_BY`.

### Inputs

```
PROCEDURE P_CLOSE_PERIOD ( p_period IN VARCHAR2 );
```

### Side effects

* `UPDATE FIN_PROD.PERIOD_CONTROL SET STATUS = 'CLOSED', CLOSED_TS = SYSTIMESTAMP, CLOSED_BY = USER WHERE PERIOD_YYYYMM = p_period;`
* Nothing else. It does not reverse anything, it does not recompute anything, and it
  does not stop the rest of the package running the next night.

### Known defects

1. **Closing a period does not stop the nightly adjustment.** `P_ADJUST_REVENUE`
   resolves "the open period" from `PERIOD_CONTROL`, so once a period is closed the
   driver simply picks up the next open one and carries on. Closing March does not
   freeze March; it just moves the target.
2. **`CLOSED_BY` is a database user, not a person.** In practice it is whichever
   shared Finance account was used. It is not an audit trail.
3. There is no `P_REOPEN_PERIOD`. Reopening is done with a manual `UPDATE`.

---

## 7. `P_ETL_BATCH_CLOSE`

**Schema** `BCPL_EDW` · **Schedule** not scheduled. Invoked as the final in-plan step of
`LP_DAILY_SALES`, typically 02:03 to 02:05, and at the end of `LP_MONTHEND_FIN`.

This is the warehouse-side routine, not part of `PKG_MONTH_END`. It is registered in
CANON.md §11 alongside the four finance procedures because the VAR-008 story does not
work without it.

### Purpose

Writes the closing row for a load plan run into `BCPL_EDW.ETL_BATCH_CONTROL` and
persists the extract high water mark that the next run's `#GLOBAL.LAST_EXTRACT_TS`
refresh reads.

### Inputs

```
PROCEDURE P_ETL_BATCH_CLOSE
  ( p_load_plan_name   IN VARCHAR2
  , p_load_plan_run_no IN NUMBER
  , p_status           IN VARCHAR2 DEFAULT 'DONE'
  , p_business_dt      IN DATE     DEFAULT TRUNC(SYSDATE) - 1
  );
```

### Side effects

* Sets `END_TS`, `STATUS` and the row counters on the open `ETL_BATCH_CONTROL` rows for
  that run.
* **Persists `EXTRACT_HIGH_TS`.** This is half of the VAR-008 fix from 08-Jul-2026.
  Before that the high water mark advanced at the start of the plan, so a mid-plan
  failure moved the window past rows that were never loaded.
* Increments `RESTART_COUNT` where a row already exists for the same plan and business
  date.
* Commits. It is the only thing in the plan that commits the batch control rows.

### Known defects

1. **It only closes what it is told to close.** If the plan aborts before this step, the
   `RUNNING` rows are never closed. The next run correctly falls back to the last good
   high water mark, which is safe, but the stale row sits there for ever and the ops
   dashboard shows a job that has been in flight for months. Several of these exist.
2. **`p_status` comes from the load plan step, and a step that finished with warnings
   reports as successful.** So a `DONE` row in `ETL_BATCH_CONTROL` means "the plan
   reached the last step", not "the data is right". **Every night that produced a
   VAR-003 duplicate has a green batch control row.** A clean load audit is not evidence
   of anything except that the plan ran.

---

## 8. Reference: what is scheduled where

```
Control-M 9.0.20, folder BCPL_EDW_DAILY          (owner: EDW)
    BCPL_EDW_DAILY_LOAD_START     01:00   SCEN_LP_DAILY_SALES
    BCPL_EDW_STG_EXTRACT          in-flow step 1
    BCPL_EDW_DIM_LOAD             in-flow step 2
    BCPL_EDW_FACT_LOAD            in-flow step 3
    BCPL_EDW_POSTCHK              in-flow step 4, ends with P_ETL_BATCH_CLOSE
    BCPL_EDW_OBIEE_CACHE_SEED     03:05
    BCPL_EDW_ALERT_SUMMARY        03:20
    BCPL_SFA_SECONDARY_UPLOAD     04:00
    BCPL_EDW_MONTHEND_FIN         WD+1 03:00, on-request
    BCPL_PBI_REFRESH_TRIGGER      06:00   (from Aug 2026)

Control-M 9.0.20, folder BCPL_ORION_OPS          (owner: ORION ops, different team)
    ORION's own housekeeping. Not itemised here and not itemised in
    control_m_schedule.txt either, which only covers BCPL_EDW_DAILY. Soft
    deletion of cancelled documents happens in this folder, which matters
    because it moves LAST_UPD_DT on everything it touches.

DBMS_SCHEDULER, inside ORION, owned by FIN_PROD  (owner: Finance)
    FIN_MTHEND_ADJ_NIGHTLY        FREQ=DAILY; BYHOUR=2; BYMINUTE=15
                                  -> PKG_MONTH_END.P_ADJUST_REVENUE
                                  -> P_RECALC_SCHEME_DISCOUNT  (~02:40)
                                  -> P_POST_GL_SUMMARY         (~02:55)
```

**Control-M schedules nothing inside `FIN_PROD`.** Three owners, three tools, no
cross-tool dependency of any kind. Everything is coordinated by wall clock and by
nobody in particular.

### The soft-delete side effect, and how VAR-001 became visible

The housekeeping in `BCPL_ORION_OPS` logically deletes cancelled documents that are past
their retention window. It never issues a physical `DELETE`; it sets
`DELETE_FLAG = 'Y'` and, in doing so, sets `LAST_UPD_DT` to `SYSDATE` on every row it
touches.

So a heavy housekeeping night presents the warehouse with a large batch of "changed"
rows whose only change is that they are now deleted. Against a fact mapping that had no
`DELETE_FLAG` filter at all and an insert-only IKM, that did not remove those rows from
the warehouse. It **duplicated** them. That is how VAR-001 became visible: the reported
number went **up** on heavy housekeeping nights, which is the opposite of what anyone
expects a purge to do, and it is why the first three weeks of the investigation looked
for a load defect rather than a filter defect.

Note that the housekeeping only sets `'Y'` on rows it processes. It leaves the pre-2019
`NULL` rows alone, which is correct and is why the population is three-valued for ever.
**Why those NULLs exist is fact `F-DELFLAG`, exclusive to DOC-01. Do not explain it.**

Operator note pinned in the ops handover doc, quoted as written:
*"if edw finishes late just let it run, the 0310 and 0330 jobs are on time triggers
they wont wait for it anyway"*

---

SYNTHETIC — generated for internal demo. No real entity depicted.
