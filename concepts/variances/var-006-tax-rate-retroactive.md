---
type: variance
title: "VAR-006 — GST rate change mishandled"
description: BCPL_EDW.TAX_RATE_MASTER was a truncate-and-reload snapshot of FIN_PROD.TAX_RATE_MASTER holding current rates only, with no effective dating, even though the source is effective-dated. The Chandanaa HSN 3401 rate change from 18% to 12% effective 01-Oct-2025 was therefore applied retrospectively to Apr-Sep 2025. Remediated by the effective-dated DIM_TAX_RATE.
resource: BCPL_EDW.TAX_RATE_MASTER
tags:
  - variance
  - VAR-006
  - GST
  - tax-rate
  - HSN
  - Chandanaa
  - effective-dating
  - DQ-R-15
  - DIM_TAX_RATE
owner: Neha Gokhale
generated:
  by: process:claude-sonnet/variances
  at: "2026-08-23T10:45:28Z"
sources:
  - resource: /_sources/meetings/2026-06-18_dq_readout.txt
    id: T-06
    title: Data quality readout
    author: Neha Gokhale
    last_modified: "2026-06-18"
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
  - resource: /_sources/email/EM-078_gst_rate_taxratemaster_effective_dating.eml
    id: EM-078
    title: "VAR-006 TAX_RATE_MASTER not effective dated - DQ-R-15 after CHG0021339"
    author: Neha Gokhale
    last_modified: "2026-08-27"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
  - resource: /_sources/technical/schema_edw.sql
    id: TECH-SQL-EDW
    title: BCPL_EDW DDL
    author: Ishaan Bhatt
    last_modified: "2026-04-07"
---

## Observed

Surfaced during the data quality profiling run of 31-May-2026, not through a Finance complaint: rule
`DQ-R-15` ("the GST rate carried on a fact row matches the rate that was in force on the invoice
date," threshold 99.9%) came back at **96.3%** — meaning 3.7% of lines carried a tax rate that did not
match what was actually in force on the invoice date (T-06: "so three point seven percent of lines
have the wrong tax on them").

## Root cause, as derived from the sources

`BCPL_EDW.TAX_RATE_MASTER` was a straight **truncate-and-reload** copy of `FIN_PROD.TAX_RATE_MASTER`,
holding **current rates only** — no `EFF_START_DT`, no `EFF_END_DT`, no `CURRENT_FLG`. Per Neha
Gokhale's write-up (EM-078): "The source table is effective dated. The warehouse copy was not. That
asymmetry is the whole of the defect, there is nothing cleverer going on." Aniruddh Deshpande confirms
this from the source side (EM-078, quoted reply): "in FIN_PROD the rate table is having eff from and
eff to since long, it is the copy on our side which was only keeping current rate, so source was
never wrong, only the picture in EDW was wrong... I had told this in the mail last year also when the
excise question came and at that time nobody wanted to touch it because it was working."

The specific trigger: **Chandanaa, HSN 3401** (soap), rate moved from **18% to 12% with effect from
01-Oct-2025**. Because the warehouse table only ever held the single current rate, every invoice line
resolving that HSN code — including lines from **April to September 2025**, when 18% was actually in
force — picked up 12% retroactively. Neha Gokhale, T-06: "the twelve percent got applied backwards, to
the whole year, to april through september twenty twenty five, which was at eighteen at the time."

## Impact

**INR 40 lakh** (exact: INR 39,60,000), FY26. Neha Gokhale is explicit in EM-078 that this figure was
inherited from the register and not independently re-derived by the DQ workstream: "The register
carries 40 L against it, INR 39,60,000, FY26. I have not re-derived that and I am not proposing to."

## Diagnostic history

| Date | Artifact | What happened |
|---|---|---|
| 31-May-2026 | DQ profiling run | `DQ-R-15` fails at 96.3% against a 99.9% threshold. Failures concentrated on the Chandanaa HSN 3401 lines, April-September 2025. |
| 18-Jun-2026 | T-06 | Item explained live and raised as a new tracker entry (not previously on the register): "it is new, it is not on the tracker yet, it came out of the profiling... it will be var zero zero six." Neha Gokhale is careful to separate the data-quality framing from the Finance-filing question raised on the same call ("can somebody tell me whether this touches the filing or only the reporting" — Shalini Iyer answers she does not know and will check the filing side herself; Ananya Krishnan declines to answer a tax question on a DQ call). |
| 26-Aug-2026 | EM-078 (Ani's reply) | `CHG0021339` deployed overnight; `DIM_TAX_RATE` populated and live from that night. Old `TAX_RATE_MASTER` deliberately kept in place rather than dropped, citing a 2017 incident where a hasty table drop broke two reports for two days. |
| 27-Aug-2026 | EM-078 | Neha Gokhale re-runs `DQ-R-15` against the new structure the same morning and confirms it is back inside threshold, but deliberately withholds a new percentage from the pack — every other profiling figure in the DQ assessment is stated as of the 31-May run, and she does not want two run dates in one document ("the next full profiling run restates all of them together or none of them"). She also raises an open verification point: whether the new mapping filters on `ACTIVE_FLG`/`DELETE_FLAG` on the source table, or takes every row regardless — unconfirmed as of this email, owned by Karthik Subramanian and Farida Contractor. She states she will move VAR-006 to closed "tomorrow" (28-Aug) unless Shalini Iyer asks her to hold for a trial-balance tie-out first. |
| 28-Aug-2026 | XL-01 | Closed. Tracker comment on this row is candid about a residual gap: "DIM_TAX_RATE live, marking closed. honestly still waiting on someone to confirm the Sep invoices are picking the new rate correctly, dont think we have actually tested that yet tbh." |
| 22-Sep-2026 | T-08 | Confirmed closed to the steering committee, grouped with the other three closed items (VAR-001, VAR-002, VAR-008) in the INR 8.40 Cr closed total. |

No false-trail history — the mechanism (missing effective dating on a snapshot copy) was correctly
identified on first diagnosis and never revised.

## Status

**Closed** (28-Aug-2026), change reference `CHG0021339`. Worth flagging alongside the closure: as of
the last two sources that discuss it (EM-078, XL-01), two verification steps were explicitly still
outstanding at the moment of closure rather than fully signed off — whether the new mapping correctly
respects `ACTIVE_FLG`/`DELETE_FLAG` on the source rate table, and whether September invoices are
confirmed to be picking the new rate correctly. Both read as "closed, pending a confirmation nobody
had done yet" rather than "closed, fully verified."

## Owner

**Neha Gokhale** — consistent across T-06, EM-078, and XL-01. No ownership conflict.

## Remediation

Replaced by **`DIM_TAX_RATE`**, an effective-dated dimension (`TAX_RATE_KEY`, `EFF_START_DT`,
`EFF_END_DT`, `CURRENT_FLG`, per `schema_edw.sql`), joined by `HSN_CODE` and invoice date so a fact
resolves the rate that was actually in force on the invoice date rather than whatever is currently
loaded. Deployed under `CHG0021339`, 26-Aug-2026. Old `TAX_RATE_MASTER` retained rather than dropped,
deliberately, pending confirmation that nothing else still points at it.

## Comparison against the canon register

`variance_register_canon.csv` states the same mechanism, the same trigger (Chandanaa HSN 3401,
18%→12%, 01-Oct-2025), the same impact figure (INR 39,60,000), the same owner, and the same
open/close dates (opened 18-Jun-2026, closed 28-Aug-2026). Full agreement. One nuance the canon
register's single-line summary does not carry, which the sources do: the closure was recorded with
two verification steps still open (source-flag handling in the new mapping; September rate
confirmation), which is a genuinely softer close than the bare "Closed" status suggests on its own.

## Related concepts

- [/concepts/tables/bcpl-edw-tax-rate-master.md](/concepts/tables/bcpl-edw-tax-rate-master.md) — the flawed snapshot table this variance is about
- [/concepts/tables/bcpl-edw-dim-tax-rate.md](/concepts/tables/bcpl-edw-dim-tax-rate.md) — the effective-dated remediation
- [/concepts/tables/fin-prod-tax-rate-master.md](/concepts/tables/fin-prod-tax-rate-master.md) — the correctly effective-dated ORION source
- [/concepts/tables/oms-prod-sku-master.md](/concepts/tables/oms-prod-sku-master.md) — carries `HSN_CODE`, the join key into the tax rate tables
- [DIM_PRODUCT](/concepts/tables/bcpl-edw-dim-product.md)

## Referenced by

- [Progress](/context/progress.md)
- [Data quality readout](/meetings/2026-06-18_dq_readout.md)
