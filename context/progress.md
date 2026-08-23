---
type: context
title: Progress
description: What is done, what is in flight, and what has not started on Project
  Drishti, tracked against the eight variances, the dashboard build, and the cutover
  plan.
tags:
- progress
- status
- variance
- VAR-001
- VAR-002
- VAR-003
- VAR-004
- VAR-005
- VAR-006
- VAR-007
- VAR-008
- dashboard-build
- uat
generated:
  by: process:claude-sonnet/context
  at: 2026-08-23 11:30:00+00:00
sources:
- resource: /_sources/meetings/2026-09-22_steering_committee.txt
  id: T-08
  title: Steering committee
  author: Rajeev Menon
  last_modified: '2026-09-22'
- resource: /_sources/chat/CH-02_whatsapp_uat_group.txt
  id: CH-02
  title: WhatsApp UAT group export
  author: Priya Nair
  last_modified: '2026-10-30'
---


# Progress

This is a summary. Each variance's full diagnostic history, evidence, and remediation detail lives in
its own concept file under `/concepts/variances/` — follow the links, do not stop here.

## Done

| Item | Closed | Detail |
|---|---|---|
| `VAR-001` — FY26 Q1 revenue overstated (DELETE_FLAG filter missing) | 12-Jun-2026, `CHG0021184` | [/concepts/variances/var-001-q1-revenue-overstated.md](/concepts/variances/var-001-q1-revenue-overstated.md) |
| `VAR-002` — Month-end boundary drift (UTC/IST date key) | 12-Jun-2026, `CHG0021207`, `ADR-005` | [/concepts/variances/var-002-date-key-timezone.md](/concepts/variances/var-002-date-key-timezone.md) |
| `VAR-006` — GST rate mishandled (no effective dating) | 28-Aug-2026, `CHG0021339` | [/concepts/variances/var-006-tax-rate-retroactive.md](/concepts/variances/var-006-tax-rate-retroactive.md). Two verification steps were still open at the moment of closure — see the file. |
| `VAR-008` — Feb duplicate load | Reconciliation closed 02-Apr-2026; structural batch-id guard deployed later, 08-Jul-2026 with `R2026.07` | [/concepts/variances/var-008-feb-duplicate-load.md](/concepts/variances/var-008-feb-duplicate-load.md) — the closed-vs-deployed gap is in `/log.md` |
| `DIM_CUSTOMER` design — SCD2 | Decided `ADR-002`, 06-May-2026 | [/decisions/20260506-dim-customer-scd2.md](/decisions/20260506-dim-customer-scd2.md) |
| `DIM_PRODUCT` design — SCD2 (reversing the April SCD1 proposal) | Decided `ADR-003`, 06-May-2026 | [/decisions/20260506-dim-product-scd2.md](/decisions/20260506-dim-product-scd2.md) — reversal is in `/log.md` |
| Data quality baseline assessment | Readout 18-Jun-2026 (`T-06`), 71/100 overall, 24 rules, 9 failing | source tables/DQ figures cited across the variance files |
| Dashboard scope | Settled at 9 dashboards, confirmed `T-08`/`DK-06`, 22-Sep-2026 | full 12 → 7 → 9 history in `/log.md`; scope table in `/context/data-architecture.md` |
| ORION patch to R12.2.9 | Weekend of 12-20-Sep-2026, "went ok" (`CH-01`, 18-Sep) | one form issue in the morning, fixed same day |
| UAT | Effectively complete as of 30-Oct-2026: 12 of 14 scripts fully closed, 2 closed with comment (known stockist-figure issue, not a new defect), nothing open that blocks sign-off | `CH-02`. Formal sign-off still due 06-Nov-2026. |

## In flight

| Item | State | Detail |
|---|---|---|
| `VAR-003` — Scheme discount double-count (INR 1.70 Cr) | Root cause confirmed and accepted (06-May-2026); remediation approach agreed (`ADR-004`, key-based merge on `INVOICE_LINE_ID`); measured on the UAT box 24-Sep-2026 ("more than the append... not frightening" — Ishaan Bhatt); written target `R2026.09` (30-Sep-2026) passed with no confirmation it was hit; **no committed close date** | [/concepts/variances/var-003-scheme-discount-double-count.md](/concepts/variances/var-003-scheme-discount-double-count.md), [/decisions/20260922-var003-close-date-not-committed.md](/decisions/20260922-var003-close-date-not-committed.md) |
| `VAR-004` — Duplicate facts on distributor reassignment (INR 65 L, 61 customers, 18 with two current rows) | Root cause and scale confirmed; fix not yet built. Owner handed from Farida Contractor to Ishaan Bhatt (`EM-055`, 09-Jul-2026) — the tracker was never updated to reflect this | [/concepts/variances/var-004-scd2-territory-reassignment.md](/concepts/variances/var-004-scd2-territory-reassignment.md); ownership change in `/log.md` |
| `VAR-005` — Credit notes absent from warehouse (INR 3.11 Cr, validated) | Impact validated (21-Jul-2026); **no remediation approach, no fix owner, no target date** anywhere in the read corpus; a hard external deadline (31-Dec-2026, Klarissen year end) is now attached by Marijke van der Berg | [/concepts/variances/var-005-credit-notes-absent.md](/concepts/variances/var-005-credit-notes-absent.md); the 2.40 Cr → 3.11 Cr revision is in `/log.md` |
| `VAR-007` — Late-arriving SKUs to UNKNOWN member (2.0% of invoiced volume) | Open. Ritwik Ghosh has flagged the reporting consequence (Product Mix page disagrees with Primary Sales page) but as of `EM-081` (02-Sep-2026) "nothing has gone in for this one. no mapping change, no fix." | [/concepts/variances/var-007-late-arriving-sku-unknown-member.md](/concepts/variances/var-007-late-arriving-sku-unknown-member.md) |
| UAT sign-off | Due 06-Nov-2026; content-complete per `CH-02` but not yet formally signed | see `/context/active-context.md` |
| Cutover / freeze note | `AI-62` (Ananya Krishnan) to send master-data and ORION-availability freeze note to Vikram Sethi, no date given as of `T-08` | see `/context/active-context.md` |

## Not started / open questions with no owner

- **D11 (Credit and Receivables Exposure)** is in go-live scope, but no `FACT_CREDIT_NOTE` table exists
  and no artifact in the read corpus explains how credit notes will be sourced for it. This silence is
  consistent across every source that discusses D11.
- **Stockist-level drill-down** on every dashboard page, not just Primary Sales Performance and
  Distributor Scorecard — requested by Vikram Sethi, objected to by Ritwik Ghosh on secondary-sales
  data-quality grounds. Unresolved, no owner. See
  [/decisions/20260805-dashboard-stockist-drilldown-unresolved.md](/decisions/20260805-dashboard-stockist-drilldown-unresolved.md).
- **VAR-005 fix owner.** `AI-58` (Shalini Iyer, Ananya Krishnan) to name one, due "before the next
  steerco" — no steerco after `T-08` appears in the read corpus, so this is open at the end of it.
- **D02 (Secondary Sales Coverage), D08 (GST and Tax Summary), D10 (Sales Rep Productivity)** — cut
  from go-live scope on 30-Mar-2026 and never reinstated (D04 and D11 were; these three were not). No
  Phase 2 date is committed for them in the read corpus.
- **OBIEE decommission** — targeted for 90 days after go-live (~Feb-2027); go-live itself has not
  happened yet as of the end of the read corpus, so this has not started.
## Referenced by

- [Knowledge Base Index](/index.md)

