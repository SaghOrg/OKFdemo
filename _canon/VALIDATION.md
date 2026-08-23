# VALIDATION.md — Phase A EXIT GATE record

**Status: PASS. Gate cleared 22-Aug-2026. Downstream generation may proceed.**

This file is a *record*, not a source of fact. It says what was checked, what was broken and
what was changed. Where it restates a value, `CANON.md` remains the authority. No artifact in
`_sources/` may reference this file, quote it, or know it exists.

Gate scope: the eleven mandated canon files plus `procs_canon.sql`, which was found in
`_canon/` and is now formally part of the canon file set (`CANON.md` §20.1).

---

## 0. HEADLINE

The narrative half of the canon (`CANON.md` and the CSVs) and the technical half
(`schema_canon.sql`, `procs_canon.md`, `odi_canon.md`, `procs_canon.sql`) were written in
parallel against **two different object registries** and had never been merged. `CANON.md` §20
papered over this by declaring the companions subordinate, which is not a reconciliation: it
left ~40 downstream agents reading a `schema_canon.sql` in which almost every table name was
forbidden, and a `procs_canon.md` in which three of five procedures did not exist.

**That is fixed. There is now one object universe, one clock, one audit-column spelling and one
set of evidence figures.** The companions carry a short "dead names" register at the head so a
name from a superseded draft cannot be reintroduced from memory.

---

## 1. WHAT WAS CHECKED, AND THE RESULT

| # | Check | Result |
|---|---|---|
| 1 | All 11 canon files exist and are non-trivial | **PASS** (plus `procs_canon.sql`, adopted into the set) |
| 2 | `schema_canon.sql`: 20 OLTP tables, 12 `BCPL_EDW`, 6 audit columns, no `FACT_CREDIT_NOTE` | **FIXED, now PASS** — see §2.1 and the deviation in §4 |
| 3 | `odi_canon.md` 2 load plans / 6 mappings / 3 KMs; `procs_canon.md` 5 procedures | **FIXED, now PASS** |
| 4 | Cross-file name consistency, identical spelling | **FIXED, now PASS** |
| 5 | Narrative/technical divergence: clock, fiscal year, VAR root causes, DBLINK status, schema names | **FIXED, now PASS** |
| 6 | Exactly two non-Indian names in the cast | **PASS**, unchanged |
| 7 | 8 variance rows / ≥6 contradictions incl. CON-1..6 / ≥8 drift pairs and ≥3 asr / exactly 5 PII plants | **PASS**, unchanged |
| 8 | `fact_ownership.csv`: ≥21 rows, real artifact IDs, 6 exclusive facts fully excluded, `F-TIMING` to DOC-03 alone | **PASS**, statement tightened |
| 9 | `demo_answer_map.md` Q1-Q6, fragments map to real IDs, no single artifact answers Q1-Q5 | **PASS**, verified mechanically; IDs added |
| 10 | Every artifact ID in `timeline.csv`, dated Feb-Nov 2026 | **PASS**, unchanged |

Verified counts after the fixes:

```
files                 11 mandated + procs_canon.sql       all non-empty
schema_canon.sql      OMS_PROD 13 + FIN_PROD 7 = 20 OLTP tables
                      BCPL_EDW 15 = 12 model + 3 ETL control
                      audit block on 20/20 OLTP tables (19 x 6 cols, 1 x 5 by mandate)
                      CREATE TABLE BCPL_EDW.FACT_CREDIT_NOTE  ......  0 occurrences
odi_canon.md          load plans 2   mappings 6   knowledge modules 3
procs_canon.md        procedures 5
name registry         15 people, 2 non-Indian (Marijke van der Berg, Wei Lin Tan)
variance register     8 rows, VAR-001..VAR-008
contradiction ledger  8 rows, CON-1..CON-8
terminology map       126 rows, 39 asr, 110 non-canonical drift rows
pii plant register    5 rows -> CH-02, EM-084, XL-01, TECH-PROPS, DOC-01
fact_ownership        70 rows, 0 unknown artifact tokens
                      6 exclusive facts each exclude 54/54 other artifacts, 0 gaps
demo questions        Q1..Q6 defined; single-artifact answer possible for: none
timeline              55/55 artifact IDs present, 0 rows outside Feb-Nov 2026
```

---

## 2. WHAT WAS BROKEN, AND WHAT WAS DONE

### 2.1 `schema_canon.sql` was a different database (CRITICAL)

The file described `CUSTOMER_MASTER`, `ITEM_MASTER`, `ORD_HEADER`/`ORD_LINE`,
`ORD_STATUS_HIST`, `CUST_SHIP_TO`, `DISTRIBUTOR_MASTER`, `ITEM_UOM_CONV`, `PRICE_LIST`,
`PRICE_LIST_LINE`, `SCHEME_APPLIED`, `RETURN_HEADER`/`RETURN_LINE`,
`FIN_PROD.INVOICE_HEADER`/`INVOICE_LINE`, `CREDIT_NOTE_HEADER`, `GST_TAX_LINE`,
`DIM_DISTRIBUTOR`, `FACT_SALES_ORDER`, `FACT_RETURNS`, `AGG_MONTHLY_SALES`, `WH_LOAD_AUDIT`
and `WH_ERROR_LOG`. **Not one of the 34 objects `CANON.md` §9 names appeared in it as a live
table**, and it put invoicing in `FIN_PROD`, which `CANON.md` §20.2 explicitly forbids.

Rewritten end to end onto the `CANON.md` §9 universe. Preserved everything that was good and
not colliding: the `DELETE_FLAG` 2019 narrative, the flag and precision conventions, the
UNKNOWN-member convention, the seed rows, the cross-instance plumbing. Added per-table row
counts, the variance anchors, constraints and indexes, and the explicit "there is no
`FACT_CREDIT_NOTE`, and the absence must be silent" block.

### 2.2 The audit column collision (CRITICAL, and load-bearing)

`schema_canon.sql` mandated `CREATED_BY / CREATED_DATE / LAST_UPDATED_BY / LAST_UPDATED_DATE /
ACTIVE_FLAG / DELETE_FLAG` on every OLTP table. `CANON.md` §9.1 used `CREATED_DT / LAST_UPD_DT /
LAST_UPD_BY`. §20.3 "resolved" this by deleting the convention: it told agents to omit
`CREATED_BY` entirely and to put `ACTIVE_FLG` on `SKU_MASTER` only.

That is a bad resolution, because `LAST_UPD_DT` is the column the incremental extract keys off
and the whole VAR-003 evidence chain reads on it. Two spellings in circulation is exactly how
that chain breaks.

Resolved instead by **keeping the six-column convention and adopting the `CANON.md` spelling
for all six**, on all 20 OLTP tables, with two documented exceptions that are themselves
load-bearing:

* the created column is **`CREATED_TS TIMESTAMP(6)`, written in UTC**, on
  `INVOICE_HEADER`, `INVOICE_LINE`, `INVOICE_LINE_ARCHIVE`, `ORDER_HEADER`, `CREDIT_NOTE` and
  `SCHEME_ACCRUAL`. `INVOICE_HEADER.CREATED_TS` being UTC while `INVOICE_DT` is a `DATE` in IST
  **is** VAR-002. Making it a `DATE` would delete the variance.
* `INVOICE_LINE_ARCHIVE` carries five of the six. It has no `DELETE_FLAG`, per `CANON.md` §9.1,
  because the table was closed off in 2016, three years before the soft delete programme.

`CANON.md` §20.3 rewritten to record this. `CREATED_DATE`, `LAST_UPDATED_DATE`,
`LAST_UPDATED_BY` and `ACTIVE_FLAG` are now declared dead spellings.

### 2.3 The warehouse column collision (unflagged by anyone)

`schema_canon.sql` used `CURRENT_FLAG`, `DW_LOAD_ID`, `DW_INSERT_TS`, `DW_UPDATE_TS`,
`SRC_SYS_CD`, and keyed the fact on `DISTRIBUTOR_KEY` / `INVOICE_DATE_KEY`. `CANON.md` §9.4 uses
`CURRENT_FLG`, `LOAD_DT`, `UPD_DT`, `BATCH_ID`, `CUSTOMER_KEY`, `DATE_KEY`. Nothing flagged it.
`CURRENT_FLG` matters because the entire VAR-004 story is written in terms of two rows carrying
`CURRENT_FLG = 'Y'`. Resolved to the `CANON.md` spelling and recorded in a new `CANON.md` §20.4.

### 2.4 `procs_canon.md` documented three procedures that do not exist

`P_PURGE_CANCELLED_ORDERS`, `P_LOAD_AUDIT_CLOSE` and `P_REBUILD_PRICE_CACHE` are all on the
`CANON.md` §20.2 exclusion list, and `P_REBUILD_PRICE_CACHE` depended on `PRICE_LIST` tables
that do not exist either. Meanwhile `P_POST_GL_SUMMARY` and `P_CLOSE_PERIOD`, which **are** in
`CANON.md` §11, had no sections at all.

* `P_PURGE_CANCELLED_ORDERS` and `P_REBUILD_PRICE_CACHE` removed. The one genuinely valuable
  observation attached to the purge routine (a heavy soft-delete night made the reported number
  go **up**, which is how VAR-001 became visible) was preserved and rewritten to reference
  ORION housekeeping in Control-M folder `BCPL_ORION_OPS` as an **unnamed** job, which
  `CANON.md` §8 already blesses.
* `P_LOAD_AUDIT_CLOSE` renamed to **`P_ETL_BATCH_CLOSE`** and registered in `CANON.md` §11 as
  the one warehouse-side routine. Something has to write the closing row of `ETL_BATCH_CONTROL`
  and persist the high water mark, or the VAR-008 story has no mechanism. Its ~02:05 slot is
  **not** exclusive; it is part of `F-LOADSTART`.
* `P_POST_GL_SUMMARY` and `P_CLOSE_PERIOD` written up in full.

Five procedures, all five in `CANON.md` §11.

### 2.5 `odi_canon.md` used four dead object names

`ODI_AGENT_PROD01`, `MAP_STG_ORD_HEADER`, `MAP_DIM_CUSTOMER_SCD2`, `MAP_DIM_PRODUCT_SCD2`, plus
`WH_LOAD_AUDIT` / `WH_ERROR_LOG` in the variable refresh query, plus a whole section on
`MAP_AGG_MONTHLY_SALES` against a target table that does not exist. All corrected to
`OracleDIAgent1`, `MAP_STG_ORDER_HEADER`, `MAP_DIM_CUSTOMER`, `MAP_DIM_PRODUCT`,
`ETL_BATCH_CONTROL`, `ETL_ERROR_LOG`. The aggregate mapping section was replaced with
**`MAP_STG_CREDIT_NOTE`**, the mapping disabled on 14-Nov-2022, which the corpus actually needs
for VAR-005.

The knowledge-module section documented `IKM Oracle Incremental Update` as one of its three KMs
and relegated `IKM Oracle Control Append` to a footnote, which is backwards: Control Append on
`MAP_FACT_INVOICE_LINE` is the single load-bearing KM choice in the estate. §4.2 rewritten
around it, with Incremental Update documented inside it as what the staging and dimension
targets use. `CANON.md` §10.2 now carries the full four-KM roster so no KM name is unregistered.

VAR-004 was missing from the ODI variance cross-reference and from the `MAP_DIM_CUSTOMER`
defect list, even though `variance_register_canon.csv` locates it precisely there. Added.

A roster of the load plans and mappings `odi_canon.md` does **not** detail was added, so that a
downstream agent reading only that file does not conclude the estate has six mappings.

### 2.6 The clock diverged (CRITICAL, exclusivity leak)

`procs_canon.md` §2 carried the full batch clock including **`~02:40`** for
`P_RECALC_SCHEME_DISCOUNT` and **`~02:55`** for `P_POST_GL_SUMMARY`, and its own exclusivity
banner forbade 02:40. **Neither time existed anywhere in `CANON.md` §11, in `F-TIMING`, or in
the variance register.**

That is a live leak. `CANON.md` is binding and `procs_canon.md` is subordinate, so an agent
following the precedence order correctly would have found 02:15 forbidden and 02:40 unmentioned,
and could have written "the recalculation lands about twenty to three" into any artifact without
breaking a single stated rule. `F-TIMING` would have escaped DOC-03 through the back door.

Fixed by hoisting the whole ORION-side chain into `CANON.md` §11 as canon, and extending the
prohibition:

* `CANON.md` §11 banner now forbids **02:15, 02:40, 02:55 and any other clock time in the
  ORION-side chain**, in any rendering, plus any ordering claim.
* `fact_ownership.csv` `F-TIMING` statement extended identically.
* `CANON.md` §11 gained the timing table and the consequence chain now names ~02:05 and ~02:40.

Separately, the EDW side of the clock was inconsistent: `CANON.md` §8.1 stopped at "58 minutes,
01:00 -> 01:58" while both companions carried "~02:05 including post-load checks and the audit
close". Added to `CANON.md` §8.1 and to `F-LOADSTART`, explicitly marked **shared**, together
with the note that the Control-M in-flow markers of 01:40 / 02:00 / 02:35 are stale scheduling
artefacts from when the plan was slower. This is the reason people quote different completion
times from memory, and it is now stated once, in one place.

### 2.7 The DBLINK ruling-out had two different evidence sets

`CANON.md` §18.3 and `contradiction_ledger.csv` CON-2 ruled the link out at T-04 on 14-Apr-2026
on AWR evidence (4.1 minutes of wait, 38 ms round trip, 6,412 round trips, 1.2% of elapsed).
`odi_canon.md` §4.1 ruled it out "in April 2026" on three different pieces of evidence, never
mentioned the AWR, and asserted a **controlled Data Pump re-run** that appears in no timeline
row, has no owner and no artifact.

Reconciled to one version: the AWR figures are the evidence of record in all files. The two
corroborating observations that do not invent an event (no correlation between slow nights and
variance nights; latency changes *when*, not *what*) were kept and added to `CANON.md` §18.3 so
all three files say the same thing. The Data Pump experiment was deleted, with a note in
`CANON.md` §18.3 saying there were exactly two corroborating observations and not to invent a
third.

### 2.8 Two DDL files, one of them drifting

`procs_canon.sql` carried a second, shorter copy of the OLTP and EDW `CREATE TABLE` statements.
Two copies of the same DDL is precisely how the audit columns drifted in the first place. The
duplicate DDL was removed; `procs_canon.sql` now keeps only what is unique to it (the
`PKG_MONTH_END` package shape and body sketch, the `P_ETL_BATCH_CLOSE` signature, the
`STG_ORION` landing list, and the pre-remediation `MAP_FACT_INVOICE_LINE` load written out as
SQL) and points at `schema_canon.sql` for every table. **There is now exactly one DDL source of
truth.**

### 2.9 Smaller repairs

* `ETL_BATCH_CONTROL` gained `EXTRACT_HIGH_TS` and `RESTART_COUNT`. Both companions referenced
  them; `CANON.md` §9.4 did not list them, so both were technically inventions. Now registered.
* `demo_answer_map.md` referenced four technical fragments by filename only
  (`pkg_month_end.pkb`, `schema_edw.sql`, `schema_oltp.sql`, `control_m_schedule.txt`). Artifact
  IDs (`TECH-PKG`, `TECH-SQL-EDW`, `TECH-SQL-OLTP`, `TECH-CTLM`) added alongside, because the IDs
  are what `fact_ownership.csv` and `timeline.csv` key on.
* `demo_answer_map.md` gained a recorded fragmentation-verification result and a warning that
  widening any `may_also_appear_in` list requires re-running that check.
* `CANON.md` §20 rewritten from "these files disagree and this one wins" to a reconciliation
  record with a dead-name table. Version bumped to 1.1.
* `CANON.md` §0.7 updated so agents are not told to expect divergence that no longer exists.

---

## 3. FINAL AUTHORITATIVE VALUES

### 3.1 The nightly load clock (IST, every day including Sundays)

| Time | What | Scheduled by | Shared or exclusive |
|---|---|---|---|
| 00:45 | pre-check, source availability and link test | Control-M `BCPL_EDW_DAILY` | shared |
| **01:00** | **`LP_DAILY_SALES` starts.** Job `BCPL_EDW_DAILY_LOAD_START` fires `SCEN_LP_DAILY_SALES` v003 | Control-M `BCPL_EDW_DAILY` | shared, `F-LOADSTART` |
| 01:00 - 01:38 | `PKG_STG_EXTRACT` | in-flow | shared |
| 01:38 - 01:50 | `PKG_DIM_LOAD` | in-flow | shared |
| 01:50 - 01:58 | `PKG_FACT_LOAD`, including `MAP_FACT_INVOICE_LINE` | in-flow | shared |
| 01:58 - 02:05 | `PKG_POST_LOAD_CHECKS`, then `P_ETL_BATCH_CLOSE` | in-flow | shared |
| **~02:05** | **load complete. The extract has stopped reading the source.** | | shared, `F-LOADSTART` |
| **02:15** | **`PKG_MONTH_END.P_ADJUST_REVENUE` starts** | `DBMS_SCHEDULER` job `FIN_MTHEND_ADJ_NIGHTLY` inside ORION, `FREQ=DAILY; BYHOUR=2; BYMINUTE=15`, enabled 19-Nov-2014 | **EXCLUSIVE `F-TIMING`, DOC-03 only** |
| **~02:40** | **`P_RECALC_SCHEME_DISCOUNT` reaches the `OMS_PROD.INVOICE_LINE` update** | same job | **EXCLUSIVE `F-TIMING`, DOC-03 only** |
| **~02:55** | **`P_POST_GL_SUMMARY` posts the summarised journal** | same job | **EXCLUSIVE `F-TIMING`, DOC-03 only** |
| 03:05 | OBIEE cache seed | Control-M `BCPL_EDW_DAILY` | shared |
| 03:20 | alert summary mail | Control-M `BCPL_EDW_DAILY` | shared |
| 04:00 | secondary sales file pickup, `LP_SECONDARY_UPLOAD` | Control-M `BCPL_EDW_DAILY` | shared |
| 06:00 | Power BI dataset refresh trigger (from Aug 2026) | Control-M `BCPL_EDW_DAILY` | shared |

Frozen load-window numbers: average elapsed **58 minutes**, typical completion **~02:05**,
P95 **71 minutes**, worst month-end night in the Feb-Apr 2026 sample **3 h 12 min finishing
04:12**, business availability SLA **05:30**, SLA breached twice in FY26 Q4 (**14-Feb-2026** and
**02-Mar-2026**). Average 21,400 invoice lines a night, range 6,200 (Sundays) to 48,900
(month-end).

The Control-M in-flow markers of **01:40 / 02:00 / 02:35** against steps 2, 3 and 4 are stale
scheduling artefacts. They are in the record and they may appear in `control_m_schedule.txt`.
The number to use for the warehouse being finished with the source is **~02:05**.

`control_m_schedule.txt` must contain **no `FIN_PROD` job and no time in the 02:10 - 02:20
range.** Control-M schedules nothing inside `FIN_PROD`.

### 3.2 Fiscal year

**FY26 = 01 April 2025 to 31 March 2026.** The fiscal year is named for the calendar year in
which it **ends**. Fiscal period 1 is April, period 12 is March.

| Quarter | Months |
|---|---|
| FY26 Q1 | Apr, May, Jun 2025 |
| FY26 Q2 | Jul, Aug, Sep 2025 |
| FY26 Q3 | Oct, Nov, Dec 2025 |
| FY26 Q4 | Jan, Feb, Mar 2026 |
| FY27 Q1 | Apr, May, Jun 2026 |
| FY27 Q2 | Jul, Aug, Sep 2026 |
| FY27 Q3 | Oct, Nov, Dec 2026 |
| FY27 Q4 | Jan, Feb, Mar 2027 |

Written forms permitted: `FY26`, `FY26 Q1`, `Q1 FY26`, and `FY2026` rarely and only from
Klarissen. Never `FY 26`, never `fiscal 2026`, never `2026 Q1` for a fiscal quarter.

Klarissen Group N.V. reports **January to December**. The engagement runs Feb 2026 (FY26 Q4) to
Nov 2026 (FY27 Q3); go-live falls in **FY27 Q3**.

Identical text now appears in `CANON.md` §2 and in the header of `schema_canon.sql`. No other
canon file states a fiscal definition.

### 3.3 Go-live dates

| Value | Date | Stated in, and ONLY in |
|---|---|---|
| Original | **Tue 15-Sep-2026** | DK-01 slide 4, echoed in T-01 |
| First slip | **Fri 30-Oct-2026** | **EM-068 only.** The only artifact in the corpus containing that date, and the only one carrying the reason for the slip |
| Final | **Thu 12-Nov-2026** | T-08 and DK-06 |

Neither T-08 nor DK-06 may restate the 30-Oct value; they refer to the current plan date.

Surrounding dates, frozen: SOW signed 28-Jan-2026. Kickoff Wed 11-Feb-2026. Cutover weekend
Sat 07-Nov to Sun 08-Nov-2026. Historical reload Mon 09-Nov to Wed 11-Nov-2026. Hypercare ends
Fri 11-Dec-2026. OBIEE decommission 90 days after go-live.

UAT as planned in DK-01: 10-Aug to 28-Aug-2026. UAT as finally scheduled: **12-Oct to
06-Nov-2026**, in EM-089, echoed in CH-02. Sign-off due 06-Nov-2026.

Reason for the first slip (**EXCLUSIVE to EM-068**): the ORION R12.2.9 patch weekend of
12-20 Sep locks the source, and VAR-004 and VAR-007 remediation will not finish in time, so UAT
cannot start before 05-Oct.

Reason for the final date (**EXCLUSIVE to T-08, may be echoed in DK-06**): the Klarissen group
close blackout of 26-Oct to 06-Nov CET forbids a cutover inside that window.

### 3.4 Dashboard counts

**12 → 7 → 9.** Three values, two moves. The correct answer to "how many at go-live" is **9**.

| Count | Stated in, and ONLY in | Detail |
|---|---|---|
| **12** | **DK-01 slide 9** | D01 to D12, the original scope |
| **7** | **EM-023** (30-Mar-2026) | D01, D03, D05, D06, D07, D09, D12. EM-023 is also the only artifact carrying the reason for the cut |
| **9** | **DK-06 and T-08** (22-Sep-2026) | the seven plus **D04** Scheme Effectiveness and **D11** Credit and Receivables Exposure, reinstated |

T-07 and DK-05 are the artifacts about dashboard scope and they **never reach a number**. They
stop at "seven committed plus two candidates"; DK-05 shows seven wireframes plus two marked
`CANDIDATE - not funded`. That is the trap inside the trap: the most topically relevant
documents are the least conclusive.

There is **no UAT deck** in this corpus and none may be created, even though CON-3 records that
people sometimes attribute the nine to one.

D11 is in scope at go-live even though `FACT_CREDIT_NOTE` does not exist, and **no artifact
explains how credit notes will be sourced for it.** That silence is demo question Q6 and it is
load-bearing. An agent that closes the loop destroys the demo.

### 3.5 Object counts (frozen by this gate)

| Schema | Tables |
|---|---|
| `OMS_PROD` | **13** |
| `FIN_PROD` | **7** |
| **OLTP total** | **20** |
| `BCPL_EDW` model tables | **12** (8 dimension/reference, 3 fact, 1 security) |
| `BCPL_EDW` ETL control tables | **3** |
| **`BCPL_EDW` total** | **15** |
| `STG_ORION` landing tables | **13** |

`OMS_PROD`: `CUSTOMER`, `CUSTOMER_TERRITORY_HIST`, `SKU_MASTER`, `INVOICE_HEADER`,
`INVOICE_LINE`, `INVOICE_LINE_ARCHIVE`, `ORDER_HEADER`, `ORDER_LINE`, `SCHEME_MASTER`,
`CREDIT_NOTE`, `CREDIT_NOTE_LINE`, `DEPOT_MASTER`, `TERRITORY_MASTER`.

`FIN_PROD`: `TAX_RATE_MASTER`, `SCHEME_ACCRUAL`, `PERIOD_CONTROL`, `GL_ACCOUNT_MASTER`,
`GL_JOURNAL_HDR`, `GL_JOURNAL_LINE`, `AR_OPEN_ITEM`, plus the package `PKG_MONTH_END`.

`BCPL_EDW` model: `DIM_DATE`, `DIM_CUSTOMER`, `DIM_PRODUCT`, `DIM_GEOGRAPHY`, `DIM_SCHEME`,
`DIM_SALESREP`, `TAX_RATE_MASTER`, `DIM_TAX_RATE`, `FACT_INVOICE_LINE`, `FACT_SECONDARY_SALES`,
`FACT_ORDER_LINE`, `SEC_USER_REGION`. Control: `ETL_BATCH_CONTROL`, `ETL_ERROR_LOG`,
`ETL_PARAM`.

**`BCPL_EDW.FACT_CREDIT_NOTE` does not exist and must never be created**, not as DDL, not as a
comment, not as a TODO, not on a roadmap slide. In `schema_edw.sql` the absence must be
completely silent, because the absence *is* the evidence.

### 3.6 Variance totals (unchanged, restated for convenience)

Per artifact: DK-02 **9.70 Cr**, DK-03 **12.75 Cr**, DK-04 **13.15 Cr**, XL-01 v7 and DK-06
**13.85 Cr** of which **8.40 Cr closed** and **5.45 Cr open**.

The 5.45 / 5.46 discrepancy is deliberate: the tracker rounds VAR-005 to 3.10 in the summary
sheet while the detail sheet carries 3.11. **Do not fix it.**

---

## 4. DEVIATION FROM THE GATE SPECIFICATION, DECLARED

The gate specification required `schema_canon.sql` to hold **20 OLTP tables split 14 `OMS_PROD`
+ 6 `FIN_PROD`**, and **12 `BCPL_EDW` tables**. The delivered file holds **20 OLTP tables split
13 + 7**, and **15 `BCPL_EDW` tables of which 12 are model tables**.

The reason: **14 / 6 / 12 were the superseded file's own section-header counts**, and they
describe the dead registry, not `CANON.md`. `CANON.md` §9 yields 13 `OMS_PROD` + 7 `FIN_PROD`,
which reproduces the required OLTP total of 20 exactly. Making the split 14 / 6 would have
required either inventing a fourteenth `OMS_PROD` table or deleting a `FIN_PROD` table, and all
seven `FIN_PROD` tables are load-bearing:

`GL_ACCOUNT_MASTER` carries accounts 410100 / 410900 / 411200; `GL_JOURNAL_HDR` and
`GL_JOURNAL_LINE` are `P_POST_GL_SUMMARY`'s target; `SCHEME_ACCRUAL` is
`P_RECALC_SCHEME_DISCOUNT`'s target; `PERIOD_CONTROL` is what `P_ADJUST_REVENUE` resolves the
open period from and what `P_CLOSE_PERIOD` writes; `TAX_RATE_MASTER` is the effective-dated
source whose non-effective-dated warehouse copy *is* VAR-006; `AR_OPEN_ITEM` is the only source
for dashboard D11. Deleting any one of them breaks a variance or a dashboard.

Likewise `BCPL_EDW` genuinely holds 15 tables under `CANON.md` §9.4. Twelve of them carry
business data and are grouped as the model; the three `ETL_*` tables are batch control and are
sectioned separately and labelled. Both numbers are stated explicitly in the file header, in
`CANON.md` §9.4 and in §3.5 above, so no downstream agent has to count.

Between a spec figure and the binding fact sheet, the fact sheet wins. That is what the
precedence order says and it is the only choice that does not break the corpus.

---

## 5. RESIDUAL, KNOWN AND ACCEPTED

1. **`DIM_SALESREP` has no OLTP source table.** It holds 610 current rows;
   `OMS_PROD.TERRITORY_MASTER` holds 118 and one `EMP_ID` each. `MAP_DIM_SALESREP` is documented
   as refreshed ad hoc rather than nightly. No new table was invented, because that would break
   the 20-table OLTP total and widen the closed universe. Low impact: the only dashboard that
   used `DIM_SALESREP` is **D10 Sales Rep Productivity**, which is dropped and is not in the
   nine at go-live. Rep names are never printed anywhere regardless.
2. **VAR-008 closes on 02-Apr-2026 while its fix ships in `R2026.07` on 08-Jul-2026.**
   `CANON.md` §12 and `variance_register_canon.csv` agree on both dates, so this is internally
   consistent. It reads as a variance closed on agreement of the remedy rather than on delivery,
   which is how trackers actually behave. Left alone deliberately.
3. **`odi_canon.md` details 6 of the 22 registered mappings and 2 of the 4 load plans.** That is
   by design and is now stated at the head of the file, with the undetailed names listed so they
   are spelled correctly if an artifact needs one.
4. **`pii_plant_register.csv` `verified` is `pending` on all five rows.** Correct at this stage;
   QA flips it once each plant is confirmed present exactly once and nowhere else.

---

## 6. STANDING WARNINGS FOR DOWNSTREAM AGENTS

1. **`F-TIMING` is the most fragile thing in this corpus.** 02:15, 02:40 and 02:55 are now all
   forbidden outside DOC-03, along with any ordering claim between the load and the finance
   package. 01:00 and ~02:05 are shared and safe. If you find yourself writing "after the load"
   in anything that is not DOC-03, stop.
2. **Do not widen a `may_also_appear_in` list.** The Q1-Q5 fragmentation was verified
   mechanically against those columns. One careless addition can collapse a question into a
   single artifact and kill the demo at that question.
3. **The dead names in `CANON.md` §20.2 are dead.** They are listed only so they are not
   reintroduced. If you catch yourself typing `CUSTOMER_MASTER`, `WH_LOAD_AUDIT`, `CURRENT_FLAG`
   or `LAST_UPDATED_DATE`, you are working from a superseded draft.
4. **`FACT_CREDIT_NOTE` is never created and the Q6 decision does not exist.** No deferral, no
   Phase 2 note, no Power BI netting, no Finance-file source for D11. Where an artifact must
   discuss D11's data it says receivables ageing from `AR_OPEN_ITEM` and stops.
5. **Fifteen people, exactly two of them non-Indian.** A sixteenth name anywhere, including a cc
   line, a chat handle, a document property or a sample data row, fails the run.

---

SYNTHETIC — generated for internal demo. No real entity depicted.
