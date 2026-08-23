---
type: variance
title: "VAR-005 — Credit notes absent from warehouse"
description: No credit note fact table was ever built in BCPL_EDW; the staging mapping for OMS_PROD.CREDIT_NOTE was disabled in 2022 and never revived. Finance nets revenue-affecting credit notes by hand in Excel, so the warehouse revenue line runs gross of them. Validated FY26 impact INR 3.11 Cr across 1,206 documents.
resource: OMS_PROD.CREDIT_NOTE
tags:
  - variance
  - VAR-005
  - credit-note
  - channel-partner-credit-notes
  - RATE_DIFF
  - OFF_INV_ADJ
  - trial-balance
  - Klarissen
  - group-audit
owner: Shalini Iyer
generated:
  by: process:claude-sonnet/variances
  at: 2026-08-23T10:45:28Z
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
  - resource: /_sources/docs/DOC-05_edw_target_model_notes.docx
    id: DOC-05
    title: EDW target model notes
    author: Karthik Subramanian
    last_modified: "2026-04-08"
  - resource: /_sources/decks/DK-03_variance_rootcause_v2.pptx
    id: DK-03
    title: Variance root cause - working readout, v2
    author: Karthik Subramanian
    last_modified: "2026-05-05"
  - resource: /_sources/email/EM-061_marijke_credit_note_escalation.eml
    id: EM-061
    title: "FW: India FY2026 - channel partner credit notes"
    author: Marijke van der Berg
    last_modified: "2026-07-14"
  - resource: /_sources/email/EM-063_shalini_validated_credit_note_impact.eml
    id: EM-063
    title: "RE: FW: India FY2026 - channel partner credit notes"
    author: Shalini Iyer
    last_modified: "2026-07-21"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
  - resource: /_sources/technical/control_m_schedule.txt
    id: TECH-CTLM
    title: Control-M job schedule export, folder BCPL_EDW_DAILY
    author: Farida Contractor
    last_modified: "2026-03-18"
---

## Observed

The revenue figure reported through `BCPL_EDW` does not reflect credit notes at all — it is gross of
them rather than net. This surfaced during the April close reconciliation (raised on the tracker
24-Apr-2026) and escalated sharply in July when Klarissen Group's FP&A function could not close its
own schedule without an India credit-note figure it had asked for twice.

## Root cause, as derived from the sources

There is no `FACT_CREDIT_NOTE` in `BCPL_EDW`, and none has ever been built. Per DOC-05 (the target
model notes), stated as a working aside rather than as its own topic: "There is no `FACT_CREDIT_NOTE`
in `BCPL_EDW`; credit notes were left out of the 2021 build and Finance nets them by hand in Excel each
month, so the warehouse revenue line is gross of them."

The gap is not total silence in ORION — `OMS_PROD.CREDIT_NOTE` and `CREDIT_NOTE_LINE` exist as source
tables, and a staging mapping (`MAP_STG_CREDIT_NOTE`, landing to `STG_ORION.STG_CREDIT_NOTE`) was
built in 2021 and ran for about fourteen months. It was **disabled on 14-Nov-2022 when the load window
got tight**, and has not run since; the last row it ever wrote carries `LOAD_DT = 14-NOV-2022`
(`control_m_schedule.txt`, Note 4). The staging table still physically holds those stale 2022 rows,
which is why querying it directly gives a confusing partial answer rather than an honest empty one.
Nothing downstream of staging was ever built to consume it in any case — there is no fact table for
credit notes to land in even if the extract were re-enabled.

## Impact

Two figures exist in the corpus for this item, and the gap between them is itself a documented,
resolved contradiction (see Diagnostic history):

- **Early estimate (DK-03, 05-May-2026)**: INR 2.40 Cr, FY26, explicitly caveated as directional in
  the deck's own speaker notes ("this is Shalini's own working number, built quickly to get something
  into this pack, and she has not reconciled it against the full FY26 trial balance yet... if she
  asks why it isn't fully validated, the honest answer is exactly that").
- **Validated figure (EM-063, 21-Jul-2026)**: **INR 3.11 Cr** (exact: INR 3,11,20,000), 1,206
  documents, types `RATE_DIFF` and `OFF_INV_ADJ` only — these are the two credit note types that move
  the revenue line. Total FY26 credit notes across all types: 9,318 documents, 31,204 lines; the
  remaining 8,112 documents (`DAMAGE`, `RETURN`, `SCHEME`, INR 43.70 Cr) settle against provisions or
  the scheme accrual route and do not sit inside the 3.11 Cr figure.

Shalini Iyer's own account of why the early number was wrong (EM-063, stated nowhere else in the read
corpus): "That was a quick sizing, done in a day, to give the programme an order of magnitude. It
covered April 2025 to December 2025 only, so the whole of FY26 Q4 was missing from it, and it left
out the `OFF_INV_ADJ` type completely. Put Jan to Mar back in, add `OFF_INV_ADJ`, and you arrive at
3.11 Cr. The May number was not wrong for what it was, it was wrong for what it got used for, which
is my fault as much as anybody's."

`XL-01` (18-Sep-2026) carries a rounding wrinkle worth preserving rather than "fixing": the Summary
sheet reports the closed/open split using VAR-005 rounded to **3.10 Cr**, while the detail sheet
(`VAR-005_detail`) carries the full **3,11,20,000**. Shalini's own instruction in EM-063: "please quote
the detail sheet if it is going anywhere near Group." This exact inconsistency was raised at the
22-Sep steering committee by Shalini Iyer ("one point seven zero plus sixty five lac plus three point
one one, that is five point four six, your summary says five point four five... it is that two sheets
in the same workbook say two different things and marijke's team reads both") and Ananya Krishnan
agreed to fix the sheet, but no source in this read set confirms it was actually corrected.

One data point from the `VAR-005_detail` sheet needs a redaction note: the Jan-26 `OFF_INV_ADJ` row
(INR 8,98,420) carries an annotation "manual adjustment - refund processed outside system, see note,"
and an Excel cell comment on that row names a specific bank account and IFSC code for the refund.
That comment is a planted PII artifact in the source corpus and is not reproduced here:
`[REDACTED — see /_sources/trackers/XL-01_variance_tracker_v7.xlsx]`. The only fact preserved from it
is that one Jan-26 `OFF_INV_ADJ` document was settled by manual bank transfer outside the normal
system flow, which is why it is annotated at all.

## Diagnostic history

| Date | Artifact | What happened |
|---|---|---|
| 24-Apr-2026 | XL-01 log | Raised on the tracker by Shalini Iyer during the April close reconciliation. |
| 05-May-2026 | DK-03 | Early working estimate presented: INR 2.40 Cr, explicitly caveated internally (speaker notes) as unvalidated, though the caveat was deliberately not printed on the slide itself. |
| 18-Jun-2026 | T-06 | Raised again at the DQ readout by Shalini Iyer ("what is happening on the credit notes... nobody is telling me anything"). Neha Gokhale is explicit that this is a variance-register item, not a data-quality rule, and that nothing in her DQ deck depends on the 2.4 Cr figure. Shalini commits to re-checking the sizing against the trial balance herself, target 10-Jul-2026. |
| 14-Jul-2026 | EM-061 | Marijke van der Berg (Klarissen Group, based in Amsterdam, CY reporting) escalates to Rajeev Menon: Klarissen's FP&A (Wei Lin Tan) has asked twice for the FY26 channel-partner credit note number and still does not have it. Marijke asks for three things: the number, who owns it, and the walk from warehouse to Finance's books. |
| 21-Jul-2026 | EM-063 | Shalini Iyer delivers the validated figure: INR 3.11 Cr, 1,206 documents, full FY26 period, and explains in writing why the May estimate undercounted (partial period, missing `OFF_INV_ADJ` type). This is the only artifact in the read corpus that carries the reason the early estimate was wrong. |
| 22-Sep-2026 | T-08 | Restated to the full steering committee, with Marijke van der Berg present. Validated figure confirmed (3.11 Cr / 1,206 documents / "in euro that is about zero point three four million," per Wei Lin Tan: "three hundred and thirty six thousand eight hundred at the budget rate"). Marijke is direct that this must resolve before Klarissen's 31-Dec year end, not after — "this must be resolved before our year end. not after it." Ananya Krishnan states she has no remediation plan to bring to the group yet and commits to return with options before the next steering committee. Marijke pushes for a date and an owner for the **fix**, distinct from Shalini Iyer's ownership of the **variance**: "shalini owns the variance. who owns the fix." Rajeev Menon: "that is the question i cannot answer inside this meeting... it stays open." |

## Status

**Open** at the end of the read corpus. Impact validated (21-Jul-2026); no remediation approach,
owner-for-the-fix, or target date exists anywhere in the sources read for this file. The 22-Sep-2026
steering committee ends this item explicitly unresolved, with a Klarissen-side deadline (31-Dec-2026
group year end) now attached to it that was not present earlier in the engagement.

## Owner

**Shalini Iyer** — consistent across every source (XL-01, DK-03, T-06, EM-061, EM-063, T-08). No
ownership conflict on the variance itself. Note the distinction the 22-Sep steering committee surfaces
explicitly: Shalini Iyer owns the *variance* (the diagnosis and sizing); nobody in the read corpus is
named as owning the *remediation* (a decision on what, if anything, gets built to close the gap).

## Remediation

None decided in the read corpus. No fact table, netting mechanism, or target release is named or
proposed anywhere in the sources read for this file. Ananya Krishnan's own words at the 22-Sep
steering committee are the clearest statement of where this stands: "I do not have a plan to put in
front of you today that I would stand behind."

## Comparison against the canon register

`variance_register_canon.csv` states the same mechanism (no `FACT_CREDIT_NOTE`, `STG_CREDIT_NOTE`
mapping disabled 14-Nov-2022, Excel netting outside the warehouse), the same validated impact
(INR 3,11,20,000, 1,206 documents, `RATE_DIFF`/`OFF_INV_ADJ`), and the same owner. Agreement is
complete on the facts stated. The canon register's `remediation` note for this item — "Open. Deferred
verbally (see Q6 — that deferral is deliberately absent from the corpus)" — points at something my
read set genuinely does not contain: no verbal deferral, no Phase 2 mention, and no credit-note netting
design appear anywhere in T-06, EM-061, EM-063, DK-03, DOC-05, XL-01, or T-08. What I read instead is
an explicitly *unresolved* status as of 22-Sep-2026, with Klarissen actively pressing for an owner and
a date that the engagement has not yet produced. I am recording this as the corpus reads, without
asserting a deferral decision I did not find evidence for.

## Related concepts

- [/concepts/tables/oms-prod-credit-note.md](/concepts/tables/oms-prod-credit-note.md) — source header table, never replicated to the warehouse
- [/concepts/tables/oms-prod-credit-note-line.md](/concepts/tables/oms-prod-credit-note-line.md) — source line table, same gap
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) — the revenue fact that runs gross of credit notes as a consequence
- [/concepts/tables/fin-prod-ar-open-item.md](/concepts/tables/fin-prod-ar-open-item.md) — the AR-side table that does exist in the warehouse and is the nearest thing to receivables visibility
