# ODI 12c inventory - sales & finance daily chain

BCPL / project Bharadwaj. Technical canon, written up from the work repo export
`ODI_SALES_FIN_export_v3_FINAL_revised.xml` plus operator notes.

gen-seed 20260822

---

> ## PRECEDENCE - RECONCILED AT THE PHASE A EXIT GATE, 22-Aug-2026
>
> **`CANON.md` in this directory is the master fact sheet and it is BINDING.**
> **This file now uses CANON.md's object names throughout. There are no open name
> collisions between the two any more.**
>
> An earlier revision of this file carried a different registry. Every name in the
> left hand column below is now DEAD and appears nowhere in this file. None of them
> may appear in any artifact in `_sources/`. They are listed once, here, only so that
> nobody reintroduces one from memory.
>
> | dead name | the name that governs |
> |---|---|
> | agent `OracleDIAgent1` | agent **`OracleDIAgent1`** |
> | `MAP_STG_ORDER_HEADER` | **`MAP_STG_ORDER_HEADER`** (and `MAP_STG_ORDER_LINE`) |
> | `MAP_DIM_CUSTOMER` | **`MAP_DIM_CUSTOMER`** |
> | `MAP_DIM_PRODUCT` | **`MAP_DIM_PRODUCT`** |
> | `MAP_AGG_MONTHLY_SALES` | no equivalent. CANON has no monthly aggregate table. Gone. |
> | `ETL_BATCH_CONTROL` / `ETL_ERROR_LOG` | **`ETL_BATCH_CONTROL`** / **`ETL_ERROR_LOG`** |
> | `P_ETL_BATCH_CLOSE` | **`P_ETL_BATCH_CLOSE`** (CANON.md §11) |
>
> Safe to use anywhere: ODI **12.2.1.4.0**, agent `OracleDIAgent1`, port **20910**,
> load plans `LP_DAILY_SALES` and `LP_MONTHEND_FIN`, mappings `MAP_STG_INVOICE_LINE`
> and `MAP_FACT_INVOICE_LINE`, the `ORION_PRD` link, the `STG_ORION` staging schema,
> `LKM Oracle to Oracle (DBLINK)`, `IKM Oracle Control Append`,
> `IKM Oracle Incremental Update`, `CKM Oracle`, the 01:00 IST trigger, and VAR-001 /
> VAR-003 / VAR-005 / VAR-006 / VAR-007 / VAR-008 as described below.
>
> **Section 5.3 defers wholesale to CANON.md §10.2** for `MAP_FACT_INVOICE_LINE`.
> That mapping is the one the whole corpus turns on and CANON.md's version of it is
> the one to use.
>
> **Timing exclusivity.** This file states that the warehouse load starts at 01:00 IST
> and is finished with the source at about 02:05 IST. It states nothing about what runs
> afterwards. The times **02:15**, **02:40** and **02:55**, and any ordering claim
> between the load and the finance package, are fact `F-TIMING` and belong to `DOC-03`
> alone. See CANON.md §11 and `procs_canon.md`.

---

> Scope note. The production work repo holds 47 mappings across 9 project folders.
> Only the **SALES_FIN** folder is covered here. Everything else is out of scope.
>
> **Within SALES_FIN, CANON.md §10.1 registers four load plans and §10.2 registers
> twenty-two mappings. That list is the complete inventory and it governs.** This
> document writes up **two** load plans and **six** mappings in detail, the ones the
> corpus turns on. The others exist and may be named in artifacts; they simply have no
> defect worth documenting.
>
> Load plans not detailed here: `LP_SECONDARY_UPLOAD` (daily 04:00 IST, picks up the DMS
> file drop for `FACT_SECONDARY_SALES`, frequently no file) and `LP_DIM_REFRESH_FULL`
> (ad hoc full dimension rebuild, last run 09-Jan-2026).
>
> Mappings not detailed here: `MAP_STG_CUSTOMER`, `MAP_STG_CUSTOMER_TERRITORY_HIST`,
> `MAP_STG_SKU_MASTER`, `MAP_STG_INVOICE_HEADER`, `MAP_STG_ORDER_LINE`,
> `MAP_STG_SCHEME_MASTER`, `MAP_STG_DEPOT_MASTER`, `MAP_STG_TERRITORY_MASTER`,
> `MAP_STG_TAX_RATE`, `MAP_DIM_GEOGRAPHY`, `MAP_DIM_SCHEME`, `MAP_DIM_SALESREP`,
> `MAP_DIM_DATE` (one-off, last run 2021), `MAP_TAX_RATE_MASTER`, `MAP_FACT_ORDER_LINE`,
> `MAP_FACT_SECONDARY_SALES`. Spell them exactly like that.

---

## 1. Environment

| item | value |
|---|---|
| ODI version | 12.2.1.4.0 (12c) |
| Master repository | `ODI_MASTER` (on the EDW instance) |
| Work repository | `ODI_WORK` (on the EDW instance) |
| Dev repositories | `ODI_MASTER_DEV` / `ODI_WORK_DEV` on `edw-db-dev-01` |
| Agent | `OracleDIAgent1` |
| Agent type | standalone agent, host `edw-app-prd-02.bcpl.local`, port 20910 |
| Contexts | `GLOBAL`, `DEV`, `PROD` |
| Scheduler | Control-M 9.0.20, folder `BCPL_EDW_DAILY`, job `BCPL_EDW_DAILY_LOAD_START` |

One production agent. No load balancing, no parent/child setup. If the agent is down
the load does not run and Control-M raises a late-start alert.

Repository objects are exported to a SharePoint document library, not to Git. That is
a standing finding, not a detail.

### Logical schemas / topology

| logical schema | physical | notes |
|---|---|---|
| `ORION_SRC` | `OMS_PROD` + `FIN_PROD` on `orion-db-prd-01`, over `ORION_PRD` | read only account `OMS_RO` |
| `EDW_STG` | `STG_ORION` on `edw-db-prd-01` | landing tables + C$ / I$ / E$ work tables |
| `EDW_TGT` | `BCPL_EDW` on `edw-db-prd-01` | the warehouse |

`STG_ORION` sits **inside the EDW database**, not inside ORION. People get this wrong
in conversation constantly and it matters, because it means the staging tables are on
the far side of the database link from the source.

One link. `ORION_PRD`, private, owned by `STG_ORION`, pointing at
`OMS_RO@orion-db-prd-01`. There is not a second finance link. There used to be, before
the 2021 consolidation, and half the documentation still implies there is.

---

## 2. Variables

### `#GLOBAL.LAST_EXTRACT_TS`

Global variable. Type **Alphanumeric (30)**, not Date. It was a Date variable
originally and the agent's NLS settings kept mangling it, so in 2019 it was changed to
a string and every mapping now does an explicit
`TO_DATE(...,'YYYY-MM-DD HH24:MI:SS')` on it.

Refresh query, runs on logical schema `EDW_TGT`:

```sql
SELECT TO_CHAR( NVL( MAX(EXTRACT_HIGH_TS)
                   , TO_TIMESTAMP('2015-01-01 00:00:00','YYYY-MM-DD HH24:MI:SS'))
              ,'YYYY-MM-DD HH24:MI:SS')
  FROM BCPL_EDW.ETL_BATCH_CONTROL
 WHERE LOAD_PLAN_NAME = 'LP_DAILY_SALES'
   AND STATUS         = 'DONE'
```

Used in the staging mappings as:

```
    SRC.LAST_UPD_DT >  TO_DATE('#GLOBAL.LAST_EXTRACT_TS','YYYY-MM-DD HH24:MI:SS')
AND SRC.LAST_UPD_DT <= TO_DATE('#GLOBAL.EXTRACT_HIGH_TS','YYYY-MM-DD HH24:MI:SS')
```

**The important part: `MAP_FACT_INVOICE_LINE` does not use this variable at all.** It
carries a hardcoded `LAST_UPD_DT >= TRUNC(SYSDATE) - 1` predicate instead. So the one
mapping that matters most runs on a fixed rolling 24 hour window with no high water
mark and no memory of what it has already loaded. Two consequences, both real:

* a night that is skipped is never recovered, because nothing tracks that it was missed
* a row touched in source after the extract is picked up again the following night, on
  the same fixed window, with no way for the mapping to know it has seen that row before

That second one is the mechanical half of VAR-003 and VAR-008. It is not a subtle bug,
it is just an old mapping nobody revisited.

The high water mark is persisted into `ETL_BATCH_CONTROL.EXTRACT_HIGH_TS` only when
`P_ETL_BATCH_CLOSE` writes the closing row at the end of a successful plan.

---

## 3. Load plans

### 3.1 `LP_DAILY_SALES`

Triggered by Control-M at **01:00 IST**, every day including Sundays. Scenario
`SCEN_LP_DAILY_SALES` version 003. Restart type: restart from failed step.

Step tree, and the Control-M in-flow markers against the measured reality:

| step | package | in-flow marker | measured, typical |
|---|---|---|---|
| 1 | `PKG_STG_EXTRACT` (`MAP_STG_ORDER_HEADER`, `MAP_STG_INVOICE_LINE`, others) | 01:00 | 01:00 - 01:38 |
| 2 | `PKG_DIM_LOAD` (`MAP_DIM_CUSTOMER`, `MAP_DIM_PRODUCT`, ...) | 01:40 | 01:38 - 01:50 |
| 3 | `PKG_FACT_LOAD` (`MAP_FACT_INVOICE_LINE`, ...) | 02:00 | 01:50 - 01:58 |
| 4 | `PKG_POST_LOAD_CHECKS`, then `P_ETL_BATCH_CLOSE` | 02:35 | 01:58 - 02:05 |

Frozen numbers:

| item | value |
|---|---|
| Average elapsed | **58 minutes** (01:00 -> 01:58) |
| P95 elapsed | 71 minutes |
| **Typical completion including post-load checks and the audit close** | **~02:05 IST** |
| Worst month-end night in the Feb-Apr 2026 sample | 3 h 12 min, finished **04:12 IST** |
| Business availability SLA | 05:30 IST |
| SLA breaches in FY26 Q4 | two: 14-Feb-2026 and 02-Mar-2026 |
| Average invoice lines per night | 21,400 (range 6,200 Sundays to 48,900 month-end) |
| Session numbers referenced | `SESS_884012`, `SESS_901337`, `SESS_918744` |

Note the step 4 in-flow marker says 02:35 and the measured average says the plan is
done by 01:58. Both are in the record. The marker is a Control-M scheduling artefact
from when the plan was slower, nobody has retimed it, and it is the reason people
quote wildly different completion times from memory. **The number to use for the
warehouse being finished with the source is ~02:05.**

Dimensions load before facts, which is right, but each loads from a source read taken
at its own step start. A customer created at 01:45 is in neither the dimension nor
resolvable by the fact step, so the fact lands on the -1 UNKNOWN member. VAR-007.

### 3.2 `LP_MONTHEND_FIN`

Working day +1 of the following fiscal month. Control-M job `BCPL_EDW_MONTHEND_FIN`,
WD+1 03:00, on-request. It requires a manual step before it can run.

**That manual step is EXCLUSIVE to DOC-02 (fact `F-MANUAL`). Do not describe it, do
not hint at it, do not name what has to be set by hand. This document names only that
the plan is submitted manually.**

It loads the finance aggregates and the GL summary for the closed period. It does not
touch the order side and it does not re-run the dimension mappings. Anything that only
ever went wrong on the OMS side is not corrected by the month end run.

---

## 4. Knowledge modules in use

### 4.1 `LKM Oracle to Oracle (DBLINK)`

Used by every source-to-staging step, over the `ORION_PRD` link. Creates a view in the
source, then an `INSERT /*+ APPEND */ ... SELECT` across the link into the C$ table in
`STG_ORION`.

| option | value | comment |
|---|---|---|
| `AUTO_DISABLE_FK` | No | |
| `DELETE_TEMPORARY_OBJECTS` | **No** | left at No after a 2022 debug session. C$ tables accumulate in `STG_ORION`. Housekeeping is a weekly cron, not ODI. |
| `CREATE_SYNONYM` | No | |

**Latency under load.** This LKM is visibly slow when ORION is busy.
`MAP_STG_INVOICE_LINE` stages in about 23 minutes on a normal night. On a heavy night
it has taken 70+ minutes for the same step and the agent session sits in
`SQL*Net message from dblink` the whole time. Real, measurable in the step durations,
worth fixing on its own merits.

**It is NOT the cause of VAR-003.** It was the leading suspect from the moment the
variance was raised in T-03 on 24-Mar-2026, because it is the most visible thing wrong
with the chain and because the bad nights and the slow nights overlapped.
**Ruled out at the architecture review, T-04, on 14-Apr-2026.** The evidence of record
is the AWR report for `edw-db-prd-01` covering 23-Mar-2026 01:00 to 03:00. These figures
are frozen in CANON.md §18.3; do not recompute them and do not quote different ones:

| item | value |
|---|---|
| `SQL*Net message from dblink` total wait | **4.1 minutes** across the whole load |
| Average round trip | **38 ms** |
| Round trips | **6,412** |
| Share of load elapsed attributable to the link | **1.2%** |
| Intra-DC network latency, Mumbai | 0.4 ms |

Two corroborating observations, both recorded against the investigation:

1. Nights where the link was fast and the plan closed early produced the same variance
   as nights where it closed at 04:12. Latency and variance do not correlate.
2. Mechanically, latency changes *when* the extract finishes. It does not change *what
   the source rows contained at the moment they were read*, and it does not change what
   happens to those rows afterwards. The duplicated amounts are exact duplicates, not
   partial or torn rows, which is not what a transport problem produces.

Karthik Subramanian's line in T-04, in substance: a latency problem makes the load slow,
it does not make the numbers wrong.

The `ORION_PRD` link is the VAR-003 misdirection. It is a good, plausible, technically
literate wrong answer, which is exactly why it survived as long as it did. It is not
the answer.

### 4.2 `IKM Oracle Control Append`

The load-bearing one. Used on **`MAP_FACT_INVOICE_LINE`**, the highest value target
in the warehouse.

| option | value |
|---|---|
| `TRUNCATE` | **false** |
| `FLOW_CONTROL` | **false** |
| `DELETE_ALL` | No |
| `ANALYZE_TARGET` | No |

`IKM Oracle Control Append` **does not merge**. Every row the incremental predicate
returns is inserted. There is no update branch, no update key, nothing that could
recognise a row it has already seen. Combined with the fixed rolling 24 hour predicate
in 5.3, that means a source row touched after it was loaded comes back the next night
and is inserted **a second time**. The grain of `FACT_INVOICE_LINE` degrades from one
row per invoice line to one row per invoice line *per extract*. That is the bug family
behind VAR-001, VAR-003 and VAR-008.

Remediation is the key-based merge on `INVOICE_LINE_ID` planned for `R2026.09` under
ADR-004. Until then the only guard is the batch-id check added in `R2026.07`, which
stops a *deliberate re-run* duplicating a night. It does nothing about a row that comes
back on its own because something in the source touched it.

**The other IKM in the chain.** The staging targets and every dimension target use
`IKM Oracle Incremental Update` instead, configured update-else-insert on the declared
update key, `TRUNCATE`/`DELETE_ALL` No, `STATIC_CONTROL` No everywhere, `ANALYZE_TARGET`
No. So the dimensions merge correctly and the fact does not. Nobody has ever been able
to explain why the fact mapping was built differently; the working theory is that it was
cloned from a load that genuinely was append-only and nobody revisited it.

### 4.3 `CKM Oracle`

Flow control. Rejects go to `E$_<target>` in `STG_ORION` and are copied on into the
error log by a post-step. `RECYCLE_ERRORS` Yes on the staging mappings.

The CKM only runs where `FLOW_CONTROL` is true. It is **configured but not enabled** on
`MAP_FACT_INVOICE_LINE`. So the single highest value table in the warehouse loads with
no flow control.

And note what flow control would not catch anyway: a dimension lookup that resolved to
the -1 UNKNOWN member is a perfectly valid row. It violates no constraint, is never
rejected, never logged, never counted.

---

## 5. Mappings

### 5.1 `MAP_STG_ORDER_HEADER`

* **Sources** the order header and order line tables, plus the applied-scheme detail
* **Target** the order staging table in `STG_ORION`
* **KM** LKM Oracle to Oracle (DBLINK) / IKM Oracle Incremental Update / CKM Oracle, flow control on
* **Filter** incremental window on `GREATEST(header.LAST_UPD_DT, line.LAST_UPD_DT)`, plus `NVL(DELETE_FLAG,'N') = 'N'`
* **Known defect** the incremental window does not include the applied-scheme row's own
  `LAST_UPD_DT`. If a scheme row is rewritten and neither the header nor the line is
  touched, the order is not re-extracted at all. Open. This is why the order side of
  VAR-003 is intermittent rather than consistent.

### 5.2 `MAP_STG_INVOICE_LINE`

* **Sources** `INVOICE_LINE` joined to `INVOICE_HEADER` on `INVOICE_ID`
* **Target** `STG_ORION.STG_INVOICE_LINE`
* **KM** LKM Oracle to Oracle (DBLINK) / IKM Oracle Incremental Update / CKM Oracle, flow control on
* **Filters** `NVL(DELETE_FLAG,'N') = 'N'` on both, incremental window on `GREATEST(...)`
* **Known defect** none currently open. This is the step that shows the DBLINK latency
  most clearly because it is the largest volume. Slow is not the same as wrong.

### 5.3 `MAP_FACT_INVOICE_LINE`

**This mapping is specified in CANON.md §10.2 and that specification governs.** What
follows is a summary; if it disagrees with CANON.md, CANON.md is right.

| property | value |
|---|---|
| Source | `STG_ORION.STG_INVOICE_LINE` joined to `STG_ORION.STG_INVOICE_HEADER` on `INVOICE_ID` |
| Target | `BCPL_EDW.FACT_INVOICE_LINE` |
| LKM | `LKM Oracle to Oracle (DBLINK)` on the `ORION_PRD` link |
| IKM | **`IKM Oracle Control Append`**, `TRUNCATE = false`, `FLOW_CONTROL = false`. Insert only. No merge. |
| CKM | `CKM Oracle`, configured but not enabled |
| Incremental predicate | `STG_INVOICE_LINE.LAST_UPD_DT >= TRUNC(SYSDATE) - 1` |
| `DATE_KEY`, before fix | from the UTC `CREATED_TS`. **VAR-002.** |
| `DATE_KEY`, after `CHG0021207` (03-Jun-2026) | from `INVOICE_DT` |
| `DELETE_FLAG` filter, before fix | **none at all**. **VAR-001.** |
| `DELETE_FLAG` filter, after `CHG0021184` (03-Jun-2026) | `NVL(IL.DELETE_FLAG,'N') = 'N'` |
| `DOC_TYPE` filter, before 25-Jun-2026 | `IH.DOC_TYPE <> 'SMP'` |
| `DOC_TYPE` filter, from R2026.07 | `IH.DOC_TYPE = 'INV'` - **this change is `F-CHATDEC` and is EXCLUSIVE to CH-01. Do not describe it elsewhere.** |
| Rejects | `E$_FACT_INVOICE_LINE` |

**Why insert-only is the load-bearing detail.** `IKM Oracle Control Append` does not
merge. Every row the incremental predicate returns is inserted. So when a source row is
touched after it has already been loaded, its `LAST_UPD_DT` moves into the next night's
24 hour window and the mapping inserts **a second copy of the same invoice line**. The
grain silently degrades from one row per invoice line to one row per invoice line *per
extract*. That is the bug family behind VAR-001, VAR-003 and VAR-008, and the
remediation is the key-based merge planned for R2026.09 under ADR-004.

**VAR-001, closed.** Until 03-Jun-2026 this mapping had no `DELETE_FLAG` filter
whatsoever, so logically deleted invoice lines were loaded and counted. The mapping had
been cloned from an older one written before `DELETE_FLAG` existed (the flag was
introduced across the OLTP tables in 2019) and the clone was never revisited. Fixed
under `CHG0021184`, release `R2026.06`, deployed 03-Jun-2026, with the correct
`NVL(...)` form rather than a bare `= 'N'`. **Closed.** It does not explain anything
observed after 03-Jun-2026 and should not be offered as an explanation for it.

**VAR-007, open.** Failed dimension lookups resolve to `-1` silently. Nothing reaches
the error log, and with flow control off the CKM does not run at all. Scheme lookups
fail most often, because the source scheme validity window gets closed retrospectively.
A report that inner joins to `DIM_SCHEME` drops those rows entirely.

### 5.4 `MAP_DIM_CUSTOMER`

* **Source** the customer master, over `ORION_PRD`
* **Target** `BCPL_EDW.DIM_CUSTOMER`
* **KM** LKM DBLINK / IKM Oracle Incremental Update, flow control on
* **SCD2 from 06-May-2026.** It was SCD1 before that. The conversion is part of the
  engagement, not a pre-existing state, and rows built before the conversion do not
  have a meaningful version history.
* **Logic** two pass, hand built, the SCD KM is not used: hash the tracked attributes,
  and where the hash differs close the current row (`EFF_END_DT`, `CURRENT_FLG = 'N'`)
  and insert the new version with `CURRENT_FLG = 'Y'`.
* **Known defect, VAR-004, OPEN.** On a territory reassignment the closing row's
  `EFF_END_DT` is set to **the same timestamp as the new row's `EFF_START_DT`**, and
  `CURRENT_FLG` is left `'Y'` on **both** rows. A fact row whose date falls on the
  boundary therefore joins to two dimension rows and the amount is counted twice.
  61 customers have overlapping effective dates; 18 carry two current rows. Fails
  `DQ-R-07` (100% threshold, 99.16% actual) and `DQ-R-23`. Worked example
  `DIST-W-0241` Mahalaxmi Distributors, reassigned 17-Apr-2026 from `TER-W-014` to
  `TER-W-011`. Impact 65 L. Owner Ishaan Bhatt from 09-Jul-2026.
  There is no unique constraint on `(CUSTOMER_ID, CURRENT_FLG='Y')` in the target, so
  nothing raises an error when it happens.
* **Second known defect, minor.** Effectivity is dated at day grain from `SYSDATE` on
  the load machine, not from the source change timestamp. Two changes to one customer
  on the same day collapse into one version. Accepted, not on the variance register.
* Repo description field on this mapping, verbatim: *"do not switch this to the SCD2 KM
  without a full reload - the SCD2 rows built before the conversion carry EFF_END_DT
  31-DEC-4712 not 9999 and the KM will not match them. - Karthik"*

### 5.5 `MAP_DIM_PRODUCT`

* **Source** the SKU master
* **Target** `BCPL_EDW.DIM_PRODUCT`
* **KM** LKM DBLINK / IKM Oracle Incremental Update, flow control on
* **SCD2 from 06-May-2026.** SCD1 was proposed on 14-Apr-2026 and superseded.
* **Logic** same two pass hash-diff pattern. MRP revisions drive most of the version churn.
* **Known defect** the UOM conversion lookup is not deduplicated and the source has no
  unique constraint on it. Where duplicates exist the lookup returns more than one row,
  the mapping takes whichever comes back first, and the case quantity flips between two
  values across loads, which opens a spurious version. Handful of SKUs. Open, low
  priority.

### 5.6 `MAP_STG_CREDIT_NOTE`   (disabled)

* **Source** `OMS_PROD.CREDIT_NOTE` joined to `OMS_PROD.CREDIT_NOTE_LINE` on `CN_ID`, over `ORION_PRD`
* **Target** `STG_ORION.STG_CREDIT_NOTE`
* **KM** LKM Oracle to Oracle (DBLINK) / IKM Oracle Incremental Update / CKM Oracle
* **Status** built in 2021, ran for about fourteen months, **disabled on 14-Nov-2022**
  when the load window got tight. It has not run since. The last row in
  `STG_CREDIT_NOTE` carries `LOAD_DT = 14-NOV-2022`.
* **Downstream** none, and that is the point. Nothing ever consumed the staging table.
  There is no credit note fact table for it to feed. Disabling it cost nothing at the
  time and nobody has looked at it since.
* **Known defect** none. The mapping works. It is simply switched off, and the switch
  is the only record of the decision. No change ticket, no note in the load plan, no
  mention in the job inventory beyond the word "disabled" in a status column.

Note for anyone writing artifacts: the *disabled mapping* (`F-STG-CN-DORMANT`, owned by
DOC-02) and the *missing fact table* (`F-CNGAP`, exclusive to DOC-05) are two different
facts with two different owners. Check `fact_ownership.csv` before putting both in one
document.

---

## 6. Variance register cross reference

| id | where it lives | status |
|---|---|---|
| VAR-001 | `MAP_FACT_INVOICE_LINE` had no `DELETE_FLAG` filter | **CLOSED** `CHG0021184`, 03-Jun-2026 |
| VAR-002 | `DATE_KEY` derived from the UTC `CREATED_TS` | **CLOSED** `CHG0021207`, 03-Jun-2026 |
| VAR-003 | not an ODI defect. Source-side recalculation. See `procs_canon.md`. | OPEN, remediation R2026.09 |
| VAR-004 | `MAP_DIM_CUSTOMER` SCD2 effective-dating defect, see 5.4 | OPEN |
| VAR-005 | no credit note fact, and no enabled credit note mapping | OPEN |
| VAR-006 | tax rate copy carries no effective dating | **CLOSED** `CHG0021339`, 26-Aug-2026 |
| VAR-007 | silent `-1` UNKNOWN member substitution in the fact load | OPEN |
| VAR-008 | `LP_DAILY_SALES` not idempotent, a re-run appends | **FIXED** R2026.07, 08-Jul-2026 |

### VAR-005 and the disabled mapping

There is a staging table for credit notes in `STG_ORION` and it is empty. Its mapping
was built in 2021, ran for about fourteen months, and was **disabled on 14-Nov-2022**
when the load window got tight. Nothing downstream ever consumed it, and there is no
credit note fact table to consume it into.

Note for anyone writing artifacts: the *disabled mapping* and the *missing fact table*
are two different facts with two different owners in `fact_ownership.csv`. Check the
register before putting both in one document.

### VAR-008 detail

`LP_DAILY_SALES` was not safe to re-run. Two causes.

1. `MAP_FACT_INVOICE_LINE` is insert-only on a fixed 24 hour predicate. Re-running it
   for the same business date simply inserts the same rows again. There was no batch
   identifier on the target to detect it and no key to merge on.
2. The high water mark used to be advanced at the **start** of the plan. A failure at a
   later step left the window already moved, so a restart from failed step extracted
   with a low bound that had skipped the failed window. Silent data loss, no error.

Fixed in R2026.07, deployed 08-Jul-2026: a batch-id guard on the load plan, and the
high water mark is now only persisted by `P_ETL_BATCH_CLOSE` at the end of a
successful run. Re-runs after that date are safe. Re-runs before it may have left
artefacts nobody has gone back and cleaned.

---

## 7. Things this document deliberately does not answer

* why the numbers move overnight after a load that reported success. That is
  `procs_canon.md`, and the timing detail there is exclusivity-controlled. Nothing in
  this document states what runs after 02:05, and nothing in it may be extended to.
* the manual step in front of `LP_MONTHEND_FIN` (DOC-02 only)
* the `DOC_TYPE = 'INV'` change (CH-01 only)
* the reporting layer
* the eight non-SALES_FIN project folders

TODO: get the C$ housekeeping cron documented somewhere, it is currently only in one
person's crontab.

---

SYNTHETIC — generated for internal demo. No real entity depicted.
