---
type: decision
title: "ADR-004 — VAR-003 remediation: rebuild MAP_FACT_INVOICE_LINE as a key-based merge"
description: Remediation approach for VAR-003 (scheme discount double-count), agreed at design sign-off. Leaves the ORION-side finance procedure untouched in Phase 1 and instead rebuilds MAP_FACT_INVOICE_LINE as a key-based merge on INVOICE_LINE_ID with a versioned re-extract, so a re-extracted line updates in place instead of appending again. Approach agreed; VAR-003 itself stays open.
tags:
  - decision
  - ADR-004
  - VAR-003
  - scheme-discount
  - MAP_FACT_INVOICE_LINE
  - key-based-merge
  - IKM-oracle-control-append
  - remediation
status: accepted
generated:
  by: process:claude-sonnet/decisions
  at: "2026-08-23T11:03:46Z"
sources:
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
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
updated: "2026-09-22"
---

# ADR-004 — VAR-003 remediation: rebuild MAP_FACT_INVOICE_LINE as a key-based merge

**Deciders:** Shalini Iyer, Karthik Subramanian, Ananya Krishnan, Farida Contractor, Aniruddh
Deshpande, Ishaan Bhatt, Sneha Pillai (`T-05`, full session attendance).

## Context and problem statement

`VAR-003` (the scheme discount double-count — see
[/concepts/variances/var-003-scheme-discount-double-count.md](/concepts/variances/var-003-scheme-discount-double-count.md))
was open and its investigation had not closed by design sign-off. The remediation approach did not
need to wait on where that investigation landed, because the underlying design fact was already known
independent of root cause: `MAP_FACT_INVOICE_LINE` loads via `IKM Oracle Control Append` — insert-only,
with no merge key and no way of recognising a line it has already loaded. Whatever causes a line to be
re-extracted, the load cannot correct it; it can only append it again.

Karthik Subramanian brought the decision to the table already having picked a position: "this is the
one I want signed off today, and it is ADR-004, and there are basically two options, and I have
already picked one, so tell me if you disagree."

## Decision drivers

- The ORION-side procedure driving the double-count is Finance's month-end close process, not a
  warehouse artifact. Shalini Iyer ruled out asking Finance to change it mid-programme: "that
  procedure is part of my close, I am not opening my close process in the middle of a programme, and
  I am certainly not doing it before year-end sign-off." Aniruddh Deshpande added that the package is
  from 2011 and "the people who wrote it are not there since 2014" — nobody would volunteer to touch
  it.
- The fact load's structural weakness (insert-only, no merge key) is the actual point of leverage: fix
  it once, on the warehouse side, and it stops mattering what ORION does.
- `INVOICE_LINE_ID` needed to be confirmed as a safe merge key — unique and never reused — before
  committing to it, including a check on the separate archive table which "is a different story"
  (Aniruddh Deshpande, `T-05`).

## Considered options

1. **Ask Finance to change the ORION procedure** so it stops rewriting `SCHEME_DISC_AMT` in a way that
   moves `LAST_UPD_DT` and causes re-extraction. Rejected outright and immediately — "no" (Shalini
   Iyer), agreed by Rajeev Menon ("agreed, do not touch Finance").
2. **Leave ORION alone in Phase 1; rebuild `MAP_FACT_INVOICE_LINE` as a key-based merge** on
   `INVOICE_LINE_ID`, with a versioned re-extract, replacing `IKM Oracle Control Append` on that one
   mapping only. Chosen.

## Decision outcome

Chosen: **Option 2 — key-based merge rebuild of `MAP_FACT_INVOICE_LINE`**, scoped to that one mapping
only ("that one interface only," confirmed by Farida Contractor and Karthik Subramanian). Agreed by
the full group on the record: "so, formally, are we agreed on the approach" / "agreed... agreed...
yes... yes... yes" (Ananya Krishnan and the room, `T-05`). Ananya Krishnan was explicit about the scope
of what was being signed off: "to be very clear, we are signing off the approach today, not the fix —
VAR-003 stays open on the tracker."

Because it does not depend on Finance changing a closed-off, unowned 2011 package, and it converts the
fact load's structural weakness (which also underlies `VAR-008`) into an idempotent, re-runnable load
— a proper rebuild rather than a patch, acknowledged as such: "that is a proper rebuild, that is not a
change" (Shalini Iyer) / "no, it is a rebuild, I am not pretending otherwise" (Karthik Subramanian).

### Consequences

- Good: The fact gains a real merge key on `INVOICE_LINE_ID`; a re-extract of an already-loaded line
  updates the existing row instead of inserting a duplicate. This also closes the same structural gap
  that caused `VAR-008` (see
  [/concepts/variances/var-008-feb-duplicate-load.md](/concepts/variances/var-008-feb-duplicate-load.md)).
- Bad: Not a small change — `FACT_INVOICE_LINE` is the largest table in the warehouse with years of
  history, and regression now has to cover re-running an already-loaded night, "which is not something
  the current test pack does at all" (`DOC-04` §11).
- Bad: Scheme discount on the fact remains wrong until the release ships. Shalini Iyer, on the record:
  "so this is not fixed today... and I still cannot use the discount number until then." She continued
  using her own workaround outside the warehouse in the interim.
  Target release `R2026.09`, 30-Sep-2026.
- Neutral: `VAR-003` itself is unaffected by this decision and stays open on the tracker until the
  release lands (confirmed again unchanged at the 22-Sep-2026 steering committee, `T-08`).
- Follow-up risk (not resolved as of `T-08`): Karthik Subramanian declined to commit to the 30-Sep-2026
  close date in front of the steering committee — see
  [/decisions/20260922-var003-close-date-not-committed.md](/decisions/20260922-var003-close-date-not-committed.md).

## Evidence

| Claim | Source |
|---|---|
| Two options on the table, ORION change ruled out immediately by Shalini Iyer, seconded by Rajeev Menon | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Chosen approach: leave ORION alone, rebuild MAP_FACT_INVOICE_LINE as a key-based merge on INVOICE_LINE_ID, scoped to that one mapping | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Formal group agreement; VAR-003 stays open, approach only is signed off | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Target release R2026.09 (30-Sep-2026) | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05); `/_sources/docs/DOC-04_dimension_strategy.docx` Appendix A ADR-004 |
| VAR-003 status unchanged and no committed close date as of 22-Sep-2026 | `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |

## Follow-ups

- [ ] Aniruddh Deshpande to confirm `INVOICE_LINE_ID` is unique and never reused, including a check of
      the archive table (`T-05` action item AI-34).
- [ ] Deliver the `MAP_FACT_INVOICE_LINE` rebuild with release `R2026.09`, target 30-Sep-2026 — open,
      not confirmed on track as of 22-Sep-2026 (`T-08`).
- [ ] Karthik Subramanian and Aniruddh Deshpande to agree a joint position and bring a committed close
      date to a future steering committee (`T-08`).

## Related concepts

- [/concepts/variances/var-003-scheme-discount-double-count.md](/concepts/variances/var-003-scheme-discount-double-count.md)
- [/concepts/variances/var-008-feb-duplicate-load.md](/concepts/variances/var-008-feb-duplicate-load.md) — shares the same structural weakness this rebuild fixes
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md)
- [/concepts/tables/oms-prod-invoice-line.md](/concepts/tables/oms-prod-invoice-line.md)
- [/decisions/20260922-var003-close-date-not-committed.md](/decisions/20260922-var003-close-date-not-committed.md) — open question on whether the target date still holds

## Referenced by

- [Data Architecture](/context/data-architecture.md)
- [Design sign-off](/meetings/2026-05-06_design_signoff.md)

## Related decisions

- [VAR-008 resolved: Finance restates February internally; batch-id guard rides with R2026.07](/decisions/20260402-var008-february-restatement-and-batch-guard.md)
