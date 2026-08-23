---
type: decision
title: "ADR-005 — DATE_KEY on FACT_INVOICE_LINE derived from INVOICE_DT, not CREATED_TS"
description: Fix for VAR-002 (month-end boundary drift). DATE_KEY is derived from the IST business date INVOICE_HEADER.INVOICE_DT instead of the UTC application-server timestamp CREATED_TS, so invoices raised late on the last day of a month stop keying into the next month. Signed off at design sign-off; deployed under CHG0021207 in the June release alongside VAR-001.
tags:
  - decision
  - ADR-005
  - VAR-002
  - date-key
  - dim-date
  - timezone
  - CHG0021207
  - month-end-boundary
status: accepted
generated:
  by: process:claude-sonnet/decisions
  at: 2026-08-23T11:03:46Z
sources:
  - resource: /_sources/meetings/2026-04-14_architecture_review.txt
    id: T-04
    title: Architecture review
    author: Karthik Subramanian
    last_modified: "2026-04-14"
  - resource: /_sources/meetings/2026-05-06_design_signoff.txt
    id: T-05
    title: Design sign-off
    author: Karthik Subramanian
    last_modified: "2026-05-06"
  - resource: /_sources/docs/DOC-04_dimension_strategy.docx
    id: DOC-04
    title: BCPL_EDW Dimension Strategy (Appendix A, ADR-001 to ADR-005)
    author: Karthik Subramanian
    last_modified: "2026-05-11"
updated: "2026-05-11"
---

# ADR-005 — DATE_KEY on FACT_INVOICE_LINE derived from INVOICE_DT, not CREATED_TS

**Deciders:** Shalini Iyer, Karthik Subramanian, Ananya Krishnan, Farida Contractor, Aniruddh
Deshpande, Ishaan Bhatt, Sneha Pillai (`T-05`).

## Context and problem statement

`DATE_KEY` on `FACT_INVOICE_LINE` was being derived from `INVOICE_HEADER.CREATED_TS`, a timestamp
written by the application server in UTC. `INVOICE_DT`, a `DATE` column on the same header, is in IST
and is the actual business date of the invoice. Ishaan Bhatt found the mismatch while investigating why
March figures had moved: "any invoice raised after 18:30 IST on the last day of a month goes into the
next month." The bug was invisible until then — "nobody did" know CREATED_TS was UTC (Aniruddh
Deshpande, `T-04`) — and it explained a recurring, previously unexplained pattern: Priya Nair
recognised it immediately as the source of a monthly finance question about why the last day of the
reconciliation report always looked short.

## Decision drivers

- The fix is mechanically small — "a one-line change in the mapping" (Aniruddh Deshpande, `T-04`) —
  but not small in effect: it is "a nine-month restatement" against the loaded history (Karthik
  Subramanian, `T-04`), and Farida Contractor confirmed the interface should simply be using
  `INVOICE_DT`.
- Impact quantified at roughly INR 90 lakh across FY26 — a boundary effect that nets out mostly at the
  year level but moves individual months, mattering most at quarter-end (Ishaan Bhatt / Karthik
  Subramanian, `T-04`).
- Every other dimensional date key in the warehouse needed the same rule stated explicitly, not just
  this one fact: derive from the business date column, never from an audit timestamp (`DOC-04`
  Appendix A, ADR-005 consequences).
- Restating affected periods has a business communication cost: Shalini Iyer asked directly whether her
  already-signed monthly numbers would move, and whether she would need to explain the movement — both
  answered yes, with Karthik Subramanian committing to an invoice-by-invoice walk if she wanted one.

## Considered options

No alternative derivation was seriously discussed on the record — once the UTC/IST mismatch was
understood, deriving from `INVOICE_DT` was the only option raised. The substantive discussion was
about consequence and communication, not about whether to make the change.

## Decision outcome

Chosen: **Derive `DATE_KEY` from `INVOICE_HEADER.INVOICE_DT`. `CREATED_TS` is not used to derive any
dimensional key anywhere in `BCPL_EDW`.** Where an audit timestamp is genuinely wanted it is stored as
a plain attribute, labelled UTC, so the next person does not have to work it out (`DOC-04` Appendix A).
Signed off at `T-05`, 06-May-2026: "and the fix is that we key off invoice_dt, and I am writing that up
as ADR-005, the change is CHG0021207" (Karthik Subramanian).

### Consequences

- Good: Invoices raised late in the evening on the last day of a month land in the correct month going
  forward.
- Bad: Affected periods restate when the change deploys — a small movement between two months for the
  invoices concerned. Shalini Iyer flagged the communication burden this creates for Finance and asked
  for (and was promised) an invoice-level walkthrough.
- Neutral: Deployed in the same release window as `VAR-001`'s fix (the `DELETE_FLAG` predicate,
  `CHG0021184`) — "both together" (Farida Contractor, `T-05`), under change reference `CHG0021207`.

## Evidence

| Claim | Source |
|---|---|
| CREATED_TS is UTC, INVOICE_DT is IST; invoices after 18:30 IST on month-end land in the next month | `/_sources/meetings/2026-04-14_architecture_review.txt` (T-04) |
| Impact ~INR 90 lakh across FY26, boundary effect | `/_sources/meetings/2026-04-14_architecture_review.txt` (T-04) |
| Fix: derive DATE_KEY from INVOICE_DT; change CHG0021207; deployed alongside VAR-001's fix in the same release | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Restated periods communicated to Finance; Shalini Iyer requests invoice-level detail | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Formal decision record and general rule (never derive a key from an audit timestamp) | `/_sources/docs/DOC-04_dimension_strategy.docx` Appendix A, ADR-005 |

## Follow-ups

- [ ] Karthik Subramanian to provide Shalini Iyer an invoice-by-invoice walk of the restated periods
      once the change deploys (`T-05`).
- [x] Deploy under `CHG0021207` — closed 12-Jun-2026 per the variance register (see
      [/concepts/variances/var-002-date-key-timezone.md](/concepts/variances/var-002-date-key-timezone.md)).

## Related concepts

- [/concepts/variances/var-002-date-key-timezone.md](/concepts/variances/var-002-date-key-timezone.md)
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md)
- [/concepts/tables/oms-prod-invoice-header.md](/concepts/tables/oms-prod-invoice-header.md)
- [/concepts/tables/bcpl-edw-dim-date.md](/concepts/tables/bcpl-edw-dim-date.md)
