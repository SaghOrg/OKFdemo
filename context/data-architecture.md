---
type: context
title: Data Architecture
description: The pipeline from ORION (OLTP) through ODI and Control-M into BCPL_EDW
  (the warehouse) and out to Power BI — the map. Table detail lives in /concepts/tables/,
  not here.
tags:
- data-architecture
- orion
- oms-prod
- fin-prod
- odi
- control-m
- bcpl-edw
- star-schema
- obiee
- power-bi
- nightly-load
- lp-daily-sales
generated:
  by: process:claude-sonnet/context
  at: 2026-08-23 11:30:00+00:00
sources:
- resource: /_sources/docs/DOC-02_odi_job_inventory.docx
  id: DOC-02
  title: ODI job inventory - SALES_FIN folder
  author: Farida Contractor
  last_modified: '2026-03-20'
- resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
  id: DOC-01
  title: ORION OLTP schema notes
  author: Aniruddh Deshpande
  last_modified: '2026-03-09'
- resource: /_sources/technical/control_m_schedule.txt
  id: TECH-CTLM
  title: Control-M job schedule export, folder BCPL_EDW_DAILY
  author: Farida Contractor
  last_modified: '2026-03-18'
- resource: /_sources/technical/db_config_snippet.properties
  id: TECH-PROPS
  title: ODI/JDBC connection properties fragment
  author: Farida Contractor
  last_modified: '2026-03-12'
---


# Data architecture

This is a map of the pipeline, not the territory. Every table named below has its own concept file
under `/concepts/tables/` with grain, columns, and known issues — follow the links rather than
expecting the detail here. Every named defect below is a `VAR-NNN` with its own file under
`/concepts/variances/`; this document says where each one sits in the pipeline, not how it works.

## The pipeline, end to end

```
ORION (OLTP)                STG_ORION                  BCPL_EDW (warehouse)         Reporting
Oracle 19c                  (lives INSIDE the EDW       Oracle 19c, star schema
OMS_PROD + FIN_PROD          instance, despite the           
                              name)
   |                            |                            |
   |--- ORION_PRD dblink ------>|--- ODI 12c load ---------->|--- OBIEE 11g (legacy,
   |    (STG_ORION -> OMS_RO@       (dims before facts,          decommission 90 days
   |     orion-db-prd-01,           01:00-02:05 IST,             after go-live)
   |     one link, no second        Control-M-triggered)
   |     link for finance)                                   |--- Power BI (target,
                                                                    DRISHTI_SALES dataset)
```

## Source: ORION

Custom Oracle order-to-cash OLTP, built 2009 by Sahyadri Softech Pvt Ltd (relationship ended 2014, no
design documents survive). Oracle Database 19c, host `orion-db-prd-01.bcpl.local` (Mumbai, 2-node RAC),
standby `orion-db-dr-01` (Hyderabad, not used for reporting). Two schemas matter here:

- **`OMS_PROD`** — order to cash. See [/concepts/tables/oms-prod-customer.md](/concepts/tables/oms-prod-customer.md),
  [/concepts/tables/oms-prod-order-header.md](/concepts/tables/oms-prod-order-header.md),
  [/concepts/tables/oms-prod-order-line.md](/concepts/tables/oms-prod-order-line.md),
  [/concepts/tables/oms-prod-invoice-header.md](/concepts/tables/oms-prod-invoice-header.md),
  [/concepts/tables/oms-prod-invoice-line.md](/concepts/tables/oms-prod-invoice-line.md),
  [/concepts/tables/oms-prod-invoice-line-archive.md](/concepts/tables/oms-prod-invoice-line-archive.md),
  [/concepts/tables/oms-prod-credit-note.md](/concepts/tables/oms-prod-credit-note.md) and
  [/concepts/tables/oms-prod-credit-note-line.md](/concepts/tables/oms-prod-credit-note-line.md) (see
  VAR-005 — no fact table receives these today),
  [/concepts/tables/oms-prod-scheme-master.md](/concepts/tables/oms-prod-scheme-master.md),
  [/concepts/tables/oms-prod-sku-master.md](/concepts/tables/oms-prod-sku-master.md),
  [/concepts/tables/oms-prod-territory-master.md](/concepts/tables/oms-prod-territory-master.md),
  [/concepts/tables/oms-prod-customer-territory-hist.md](/concepts/tables/oms-prod-customer-territory-hist.md),
  [/concepts/tables/oms-prod-depot-master.md](/concepts/tables/oms-prod-depot-master.md).
- **`FIN_PROD`** — GL, AR, tax, month-end packages. See
  [/concepts/tables/fin-prod-gl-account-master.md](/concepts/tables/fin-prod-gl-account-master.md),
  [/concepts/tables/fin-prod-gl-journal-hdr.md](/concepts/tables/fin-prod-gl-journal-hdr.md),
  [/concepts/tables/fin-prod-gl-journal-line.md](/concepts/tables/fin-prod-gl-journal-line.md),
  [/concepts/tables/fin-prod-ar-open-item.md](/concepts/tables/fin-prod-ar-open-item.md),
  [/concepts/tables/fin-prod-period-control.md](/concepts/tables/fin-prod-period-control.md),
  [/concepts/tables/fin-prod-scheme-accrual.md](/concepts/tables/fin-prod-scheme-accrual.md),
  [/concepts/tables/fin-prod-tax-rate-master.md](/concepts/tables/fin-prod-tax-rate-master.md).
  `FIN_PROD` also holds `PKG_MONTH_END`, the package at the centre of `VAR-003` — see
  [/concepts/variances/var-003-scheme-discount-double-count.md](/concepts/variances/var-003-scheme-discount-double-count.md).
  It has held a direct `UPDATE` grant on `OMS_PROD.INVOICE_LINE` since 2014, never reviewed since
  (`EM-092`, 08-Oct-2026).
- `OMS_RO` — the read-only account extracts connect through. `ODI_STG_RD` — the ODI reader account.

## The link and staging

One database link, **`ORION_PRD`**, private to `STG_ORION`, pointing at `OMS_RO@orion-db-prd-01`. There
is no second link for finance, despite a persistent belief to the contrary left over from
pre-2021-consolidation documentation (`DOC-02`). This link is the subject of the `VAR-003` false trail —
see the variance file for why it was blamed and how it was cleared.

**`STG_ORION`** is the staging schema — physically **inside the `BCPL_EDW` database instance**, named
for what it holds, not where it lives. It holds `STG_*` landing tables plus ODI's `C$`/`I$`/`E$` work
tables. The `LKM Oracle to Oracle (DBLINK)` knowledge module lands every source-to-staging step here via
`INSERT /*+ APPEND */ ... SELECT` across the link; `C$` work tables accumulate because
`DELETE_TEMPORARY_OBJECTS` is off, and cleanup is an undocumented weekly cron in one person's crontab,
outside both Control-M and ODI (`DOC-02` §6.1, §8).

## ETL: ODI 12c

**Oracle Data Integrator 12.2.1.4.0.** Master repository `ODI_MASTER`, work repository `ODI_WORK`, both
on the EDW instance. One standalone agent, `OracleDIAgent1`, host `edw-app-prd-02.bcpl.local`, port
`20910` — no failover; if the agent is down at 01:00 the load simply does not run (`DOC-02` §2). Farida
Contractor calls mappings "interfaces," an ODI 11g habit — see `/context/glossary.md`.

Two knowledge modules do almost all of the work, and the choice between them is where `VAR-001` and
`VAR-003`/`VAR-008` live:

- **`IKM Oracle Incremental Update`** — on every staging target and every dimension target. Update-else-
  insert on a declared key. A row that comes across twice updates in place. Used everywhere **except**
  `MAP_FACT_INVOICE_LINE`.
- **`IKM Oracle Control Append`** — on `MAP_FACT_INVOICE_LINE` only. Insert-only, no update branch, no
  key. Combined with that one mapping's hardcoded rolling `LAST_UPD_DT >= TRUNC(SYSDATE)-1` window
  (it does not use the shared `#GLOBAL.LAST_EXTRACT_TS` high-water-mark variable that every other
  interface uses), a row touched again after extraction — by anything, including `PKG_MONTH_END` — comes
  back the following night and is appended a second time. This is the shared mechanical root of
  `VAR-003` and `VAR-008`. `ADR-004` (see
  [/decisions/20260506-var003-remediation-key-based-merge.md](/decisions/20260506-var003-remediation-key-based-merge.md))
  rebuilds this one mapping as a key-based merge on `INVOICE_LINE_ID`.

**Control table:** [/concepts/tables/bcpl-edw-etl-batch-control.md](/concepts/tables/bcpl-edw-etl-batch-control.md)
(`ETL_BATCH_CONTROL`) — one row per load plan run; `P_ETL_BATCH_CLOSE` is the last step and the only
thing that commits it. Rejects land in `ETL_ERROR_LOG` — see
[/concepts/tables/bcpl-edw-etl-error-log.md](/concepts/tables/bcpl-edw-etl-error-log.md) — but only where
flow control (`CKM Oracle`) is enabled, which it is **not** on `MAP_FACT_INVOICE_LINE`. Load-plan
parameters (e.g. the finance close period, set by hand before `LP_MONTHEND_FIN` runs, with no validation
if it is left stale) live in
[/concepts/tables/bcpl-edw-etl-param.md](/concepts/tables/bcpl-edw-etl-param.md) (`ETL_PARAM`).

**Load plans:**

| Load plan | Trigger | What it does |
|---|---|---|
| `LP_DAILY_SALES` | Control-M `BCPL_EDW_DAILY_LOAD_START`, 01:00 IST daily including Sundays | Stages order/invoice activity, loads dimensions then facts, runs post-load checks, closes the batch. Not idempotent — see `VAR-008`. |
| `LP_MONTHEND_FIN` | Control-M `BCPL_EDW_MONTHEND_FIN`, WD+1 03:00, on-request only | Loads finance aggregates and GL summary for the period just closed. Does not touch the order side or re-run dimensions — a month-end run does not fix a bad month, it summarises it (`DOC-02` §5). |
| `LP_SECONDARY_UPLOAD` | 04:00, for the SFA (secondary sales) feed upload | Frequently has no file waiting; does not fail, just does nothing — an absent feed and a successful one look identical (`DOC-02` §8). Feeds [/concepts/tables/bcpl-edw-fact-secondary-sales.md](/concepts/tables/bcpl-edw-fact-secondary-sales.md), coverage 74%, lag 5 days. |

### The nightly load window, in numbers

Steps run in this order inside `LP_DAILY_SALES`: `PKG_STG_EXTRACT` → `PKG_DIM_LOAD` → `PKG_FACT_LOAD`
→ `PKG_POST_LOAD_CHECKS` + `P_ETL_BATCH_CLOSE`. Dimensions load before facts.

| Item | Value |
|---|---|
| Average elapsed | 58 minutes (01:00 → 01:58) |
| Typical completion, checks and close included | **~02:05 IST** — the number to use; the Control-M in-flow markers (01:40/02:00/02:35) are stale scheduling artefacts nobody has retimed |
| P95 elapsed | 71 minutes |
| Worst month-end night sampled | 3h 12m, finished 04:12 IST |
| Business availability SLA | 05:30 IST |
| SLA breaches, FY26 Q4 | Two: 14-Feb-2026 (`SESS_884012`, see `VAR-008`) and 02-Mar-2026 (`SESS_901337`) |

## Scheduling: Control-M

**Control-M 9.0.20.** Folder `BCPL_EDW_DAILY` holds the warehouse jobs; folder `BCPL_ORION_OPS` is
ORION's own housekeeping, owned by a different team, out of scope here. **Control-M does not schedule
anything inside `FIN_PROD`** — `PKG_MONTH_END`'s nightly job runs via Oracle `DBMS_SCHEDULER` inside
ORION itself, invisible to a Control-M audit. This gap is exactly how `VAR-003` hid — see the variance
file.

## Target: BCPL_EDW

**Oracle Database 19c**, star schema, host `edw-db-prd-01.bcpl.local`, single instance. 4.1 TB
allocated, 2.8 TB used.

**Facts:**
[/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) (the
hub — one row per source invoice line, `VAR-001`/`VAR-002`/`VAR-003`/`VAR-008` all sit on this table),
[/concepts/tables/bcpl-edw-fact-order-line.md](/concepts/tables/bcpl-edw-fact-order-line.md),
[/concepts/tables/bcpl-edw-fact-secondary-sales.md](/concepts/tables/bcpl-edw-fact-secondary-sales.md).
There is no `FACT_CREDIT_NOTE` — see `VAR-005`.

**Dimensions:**
[/concepts/tables/bcpl-edw-dim-customer.md](/concepts/tables/bcpl-edw-dim-customer.md) (SCD2, `ADR-002`,
`VAR-004`),
[/concepts/tables/bcpl-edw-dim-product.md](/concepts/tables/bcpl-edw-dim-product.md) (SCD2, `ADR-003`,
`VAR-007`'s `UNKNOWN` member),
[/concepts/tables/bcpl-edw-dim-date.md](/concepts/tables/bcpl-edw-dim-date.md) (fiscal calendar,
`VAR-002`'s `DATE_KEY`),
[/concepts/tables/bcpl-edw-dim-geography.md](/concepts/tables/bcpl-edw-dim-geography.md),
[/concepts/tables/bcpl-edw-dim-salesrep.md](/concepts/tables/bcpl-edw-dim-salesrep.md),
[/concepts/tables/bcpl-edw-dim-scheme.md](/concepts/tables/bcpl-edw-dim-scheme.md),
[/concepts/tables/bcpl-edw-dim-tax-rate.md](/concepts/tables/bcpl-edw-dim-tax-rate.md) — the
effective-dated `VAR-006` remediation that replaced the truncate-and-reload
[/concepts/tables/bcpl-edw-tax-rate-master.md](/concepts/tables/bcpl-edw-tax-rate-master.md) snapshot on
26-Aug-2026 (`CHG0021339`); both table concepts exist, the older one is what `VAR-006` describes as
broken.

**Security:**
[/concepts/tables/bcpl-edw-sec-user-region.md](/concepts/tables/bcpl-edw-sec-user-region.md) drives
Power BI row-level security by `REGION_CODE`.

## BI target: OBIEE → Power BI

**OBIEE 11g** (`11.1.1.9`) is the legacy layer — 41 catalogue reports, ~12 actually used, RPD last
touched 2019. Targeted for decommission 90 days after go-live.

**Power BI** is the target. Premium capacity `P1`, tenant `bharadwajcp`, workspace
`BCPL-DRISHTI-PRD` (plus `-DEV`/`-UAT`). On-premises gateway `bi-gw-prd-01.bcpl.local`. Dataset
**`DRISHTI_SALES`**, import mode, scheduled refresh **06:00 and 14:00 IST**. Reports are named
`DRISHTI - <dashboard name>`. Dashboard scope moved 12 → 7 → 9 over the engagement — see `/log.md` for
that history and `/context/progress.md` for where each of the 12 originally-scoped dashboards stands
today. Dashboard and metric concept files (`/concepts/dashboards/`, `/concepts/metrics/`) had not been
authored as of this writing; the dashboard scope decisions and meeting notes are the current source of
record for what each dashboard covers.

## Environments

| Env | ORION | EDW | ODI agent | Power BI workspace |
|---|---|---|---|---|
| PROD | `orion-db-prd-01` | `edw-db-prd-01` | `OracleDIAgent1` | `BCPL-DRISHTI-PRD` |
| UAT | `orion-db-uat-01` (refreshed monthly from PROD) | `edw-db-uat-01` | `OracleDIAgent_UAT` | `BCPL-DRISHTI-UAT` |
| DEV | `orion-db-dev-01` (refreshed on request — last refresh 11-Mar-2026, seven months stale by October) | `edw-db-dev-01` | `OracleDIAgent_DEV` | `BCPL-DRISHTI-DEV` |

## Known structural fragility (map only — see each variance for the mechanism)

- `MAP_FACT_INVOICE_LINE`'s insert-only load + fixed rolling window → `VAR-001` (no `DELETE_FLAG`
  filter, since fixed), `VAR-003` and `VAR-008` (rows re-appended when touched after extraction).
- `DATE_KEY` sourced from a UTC timestamp → `VAR-002` (fixed, `ADR-005`).
- `DIM_CUSTOMER`'s pre-SCD2 update-in-place behaviour on territory reassignment → `VAR-004` (open).
- No late-arriving dimension handling on `MAP_FACT_INVOICE_LINE` → `VAR-007` (open, `PRODUCT_KEY = -1`).
- `TAX_RATE_MASTER` truncate-and-reload with no effective dating → `VAR-006` (fixed, `DIM_TAX_RATE`).
- `MAP_STG_CREDIT_NOTE` disabled since 14-Nov-2022, never revived → `VAR-005` (open, no fact table).
- Version control for interface XML and DDL is a SharePoint library, not Git — an accepted, documented
  gap (`DOC-02` §2.2), not a variance.
## Referenced by

- [DIM_GEOGRAPHY](/concepts/tables/bcpl-edw-dim-geography.md)
- [DIM_SALESREP](/concepts/tables/bcpl-edw-dim-salesrep.md)
- [DIM_SCHEME](/concepts/tables/bcpl-edw-dim-scheme.md)
- [ETL_PARAM](/concepts/tables/bcpl-edw-etl-param.md)
- [FACT_ORDER_LINE](/concepts/tables/bcpl-edw-fact-order-line.md)
- [FACT_SECONDARY_SALES](/concepts/tables/bcpl-edw-fact-secondary-sales.md)
- [SEC_USER_REGION](/concepts/tables/bcpl-edw-sec-user-region.md)
- [AR_OPEN_ITEM (FIN_PROD)](/concepts/tables/fin-prod-ar-open-item.md)
- [GL_ACCOUNT_MASTER (FIN_PROD)](/concepts/tables/fin-prod-gl-account-master.md)
- [GL_JOURNAL_HDR (FIN_PROD)](/concepts/tables/fin-prod-gl-journal-hdr.md)
- [GL_JOURNAL_LINE (FIN_PROD)](/concepts/tables/fin-prod-gl-journal-line.md)
- [PERIOD_CONTROL](/concepts/tables/fin-prod-period-control.md)
- [SCHEME_ACCRUAL](/concepts/tables/fin-prod-scheme-accrual.md)
- [OMS_PROD.CUSTOMER](/concepts/tables/oms-prod-customer.md)
- [OMS_PROD.INVOICE_LINE_ARCHIVE](/concepts/tables/oms-prod-invoice-line-archive.md)
- [Order Line (OMS_PROD.ORDER_LINE)](/concepts/tables/oms-prod-order-line.md)
- [OMS_PROD.TERRITORY_MASTER](/concepts/tables/oms-prod-territory-master.md)

