---
type: decision
title: "ADR-007 — Credit note netting threshold set at INR 25,000 per document"
description: Finance's monthly manual Excel net-down of revenue-affecting credit notes applies a materiality threshold of INR 25,000 per credit note document. Confirmed verbally by Shalini Iyer and captured live on 26-Aug-2026; no prior threshold value is recorded anywhere in this knowledge base, so this is a new fact rather than a change to one.
tags:
  - decision
  - ADR-007
  - VAR-005
  - credit-note
  - netting
  - netting-threshold
  - excel-netting
  - materiality
  - RATE_DIFF
  - OFF_INV_ADJ
status: accepted
captured_by: Sagnik Halder
generated:
  by: live-capture:claude-opus
  at: "2026-08-26T10:52:32Z"
sources:
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: EDW target model notes
    author: Karthik Subramanian
    last_modified: "2026-04-08"
  - resource: /_sources/email/EM-063_shalini_validated_credit_note_impact.eml
    id: EM-063
    title: "RE: FW: India FY2026 - channel partner credit notes"
    author: Shalini Iyer
    last_modified: "2026-07-21"
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
updated: "2026-08-26"
---

# ADR-007 — Credit note netting threshold set at INR 25,000 per document

**Status:** accepted
**Date:** 26-Aug-2026 — the date this was captured into the knowledge base. See the capture note below on why no earlier date is claimed.
**Deciders:** Shalini Iyer (Head of Finance Systems, BCPL — confirmation)
**Consulted:** none recorded
**Informed:** none recorded

## A note on how this was captured

**This has no `_sources/` artifact.** It was confirmed verbally by Shalini Iyer and dictated straight
into this knowledge base. No meeting is asserted, no mail or deck is claimed to contain it, and no
attendee beyond Shalini Iyer is named.

Two things about the date, stated plainly rather than smoothed over:

- The confirmation was reported as **already given**. No separate date for it was stated to the
  capture, and none is invented here. **26-Aug-2026 is the date of capture, not necessarily the date
  Finance decided.** If the decision date matters — and for a materiality threshold applied to a
  closed period it may — it needs to be established with Shalini Iyer and this record corrected.
- The word used was "now," which ordinarily implies a previous value. **No previous value exists in
  this knowledge base** (see below). Either the threshold was never recorded here before, or it
  changed from a figure this corpus never held. That ambiguity is unresolved and is a follow-up.

The `sources` array above is provenance for the **context** — the netting process itself, the
document population the threshold applies to, and the deadline pressure on it. It is **not**
provenance for the threshold figure. The threshold line rests on this capture alone.

## Context and problem statement

`VAR-005` — see
[/concepts/variances/var-005-credit-notes-absent.md](/concepts/variances/var-005-credit-notes-absent.md)
— has been open since 24-Apr-2026. There is no `FACT_CREDIT_NOTE` in `BCPL_EDW` and none has ever
been built, so the warehouse revenue line runs **gross** of credit notes. Finance closes that gap by
hand: a monthly net-down in Excel, outside the warehouse, deducting revenue-affecting credit notes
from gross invoice revenue (`DOC-05`).

That manual process is described in several places in this knowledge base. **What it has never
carried is a stated materiality threshold.** Before this record, a reader asking "which credit notes
does Finance actually net?" would have found the process described and the figure absent. This record
supplies the figure.

The population it applies to, per `EM-063` (21-Jul-2026): **1,206 documents**, **INR 3.11 Cr**
(exact: INR 3,11,20,000), FY26, restricted to the two credit note types that move the revenue line,
`RATE_DIFF` and `OFF_INV_ADJ`. The other 8,112 FY26 credit note documents (`DAMAGE`, `RETURN`,
`SCHEME`, INR 43.70 Cr) settle against provisions or the scheme accrual route and sit outside that
figure — and, on the reading captured here, outside this threshold too.

## Decision outcome

Chosen: **a materiality threshold of INR 25,000, applied per credit note document.**

Credit note documents at or below INR 25,000 are not netted individually in Finance's monthly Excel
net-down. The threshold is applied at **document** grain — the `OMS_PROD.CREDIT_NOTE` header — not at
line grain on `OMS_PROD.CREDIT_NOTE_LINE`.

### What this record does **not** say

Recorded as gaps rather than filled by inference:

- **Whether documents below the threshold are dropped or aggregated.** "Not netted individually"
  is what was confirmed. Whether they are netted in bulk, accrued elsewhere, or genuinely excluded
  is not stated here because it was not stated to the capture.
- **Whether the threshold applies to the gross or net document value**, or how a document carrying
  both `RATE_DIFF` and `OFF_INV_ADJ` lines is assessed against it.
- **Whether it applies retrospectively** to periods already closed, including the FY26 population
  behind the validated INR 3.11 Cr figure.
- **Who else agreed it.** `Consulted` and `Informed` are `none recorded` because nobody else was
  named. That is an absence of information, not evidence of a solo decision.

## An arithmetic observation, offered as a flag and not as an impact assessment

The validated FY26 population is INR 3,11,20,000 across 1,206 documents — a **mean of roughly
INR 25,800 per document**. The threshold sits essentially *at* that mean.

Nothing follows from this arithmetically: the distribution of those 1,206 documents is not in this
knowledge base, and a mean says nothing about how many fall either side of it. But a threshold
landing on the mean of the population it filters is worth someone looking at, because if the
distribution is at all typical, a material share of the 1,206 documents sits below INR 25,000 and
the amount excluded is not necessarily small.

**Nobody has quantified this.** It is raised here because the cross-link makes it visible and
because Klarissen Group has a hard **31-Dec-2026** deadline on VAR-005 (`T-08`, Marijke van der Berg:
"this must be resolved before our year end. not after it"). A threshold that changes the netted total
is a threshold that changes the number Klarissen is waiting for.

### Consequences

- **Good:** the netting process now has a stated, retrievable parameter. It was previously described
  without one, which meant anyone reconciling Finance's net-down against the warehouse had no way to
  know why a given credit note was or was not in it.
- **Bad:** VAR-005's validated impact figure (INR 3.11 Cr) was produced by tying documents back to
  the FY26 trial balance line by line, with no threshold mentioned in `EM-063`. Whether that figure
  was computed on a thresholded or unthresholded basis is now an open question that did not exist
  before this record.
- **Neutral:** this changes nothing about the warehouse. `BCPL_EDW` remains gross of credit notes;
  the threshold is a Finance-side control on a manual process outside it.

## Evidence

| Claim | Source |
|---|---|
| Finance nets revenue-affecting credit notes by hand in Excel each month, outside the warehouse; the EDW revenue line is gross of them | `/_sources/docs/DOC-05_edw_target_model_notes.docx` |
| Validated FY26 population: INR 3,11,20,000 across 1,206 documents, types `RATE_DIFF` and `OFF_INV_ADJ` only | `/_sources/email/EM-063_shalini_validated_credit_note_impact.eml` |
| The remaining 8,112 FY26 credit note documents (`DAMAGE`, `RETURN`, `SCHEME`, INR 43.70 Cr) settle against provisions or the scheme accrual route | `/_sources/email/EM-063_shalini_validated_credit_note_impact.eml` |
| Klarissen Group requires VAR-005 resolved before its 31-Dec-2026 year end | `/_sources/meetings/2026-09-22_steering_committee.txt` |
| **The INR 25,000 per-document threshold itself** | **No artifact. Verbal confirmation by Shalini Iyer, captured live 26-Aug-2026 — see the capture note above.** |

## A note on the ADR number

This is numbered **ADR-007**, not ADR-006. The register in `DOC-04` runs to ADR-005, so ADR-006 is
the next free number on `main` — but it is already claimed by an in-flight decision record for the
VAR-005 remediation (build `FACT_CREDIT_NOTE`) that has not yet merged. Taking ADR-006 here would
collide with it. The gap is deliberate.

## Related concepts

- [/concepts/variances/var-005-credit-notes-absent.md](/concepts/variances/var-005-credit-notes-absent.md) — the variance this threshold operates inside
- [/concepts/tables/oms-prod-credit-note.md](/concepts/tables/oms-prod-credit-note.md) — the document-grain header table the threshold is applied at
- [/concepts/tables/oms-prod-credit-note-line.md](/concepts/tables/oms-prod-credit-note-line.md) — the line-grain table the threshold is explicitly **not** applied at
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) — the warehouse revenue fact that stays gross of credit notes regardless of this threshold

## Follow-ups

- [ ] Establish the actual date Finance confirmed the threshold, and whether it replaced an earlier value — Shalini Iyer, no date set
- [ ] Confirm the treatment of documents below the threshold: dropped, aggregated, or accrued elsewhere — Shalini Iyer, no date set
- [ ] Confirm whether the validated INR 3.11 Cr / 1,206 document figure was computed with or without this threshold applied — Shalini Iyer, no date set
- [ ] If a credit note fact table is built for `BCPL_EDW`, decide whether this threshold moves into the warehouse logic or stays a Finance-side control — no owner recorded, no date set
