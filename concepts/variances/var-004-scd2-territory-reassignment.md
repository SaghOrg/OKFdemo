---
type: variance
title: "VAR-004 — Duplicate facts on distributor reassignment"
description: On a distributor territory reassignment, DIM_CUSTOMER's SCD2 close logic sets the old row's EFF_END_DT to the same timestamp as the new row's EFF_START_DT and leaves CURRENT_FLG='Y' on both, so a fact row joins to two dimension rows and revenue doubles for that customer. 61 customers affected, 18 with two current rows.
resource: BCPL_EDW.DIM_CUSTOMER
tags:
  - variance
  - VAR-004
  - SCD2
  - dim-customer
  - territory-reassignment
  - distributor
  - stockist
  - channel-partner
  - duplicate-facts
  - current-flag
owner: Ishaan Bhatt
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
  - resource: /_sources/decks/DK-03_variance_rootcause_v2.pptx
    id: DK-03
    title: Variance root cause - working readout, v2
    author: Karthik Subramanian
    last_modified: "2026-05-05"
  - resource: /_sources/email/EM-055_var004_handover_ishaan.eml
    id: EM-055
    title: "VAR-004 duplicate rows on DIM_CUSTOMER - handover to Ishaan"
    author: Farida Contractor
    last_modified: "2026-07-09"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
---

## Observed

Invoice facts for a small number of distributors were joining to two `DIM_CUSTOMER` rows instead of
one, doubling reported revenue for those customers specifically. First flagged on the tracker
19-May-2026 (XL-01 change log), before it had a named mechanism — DK-03 (05-May-2026) describes it as
still emerging: "duplicate fact rows have been observed against a small number of distributor
records. The underlying trigger is still being isolated," with a slide marked "DRAFT - Ishaan to
confirm before Fri."

## Root cause, as derived from the sources

`DIM_CUSTOMER` was built as an SCD2 dimension (decided at design sign-off, 06-May-2026, per
`ADR-002`/`ADR-003` context — see also the SCD1/SCD2 reversal on `DIM_PRODUCT` recorded elsewhere).
On a territory reassignment the dimension is supposed to close the old row (`EFF_END_DT` set,
`CURRENT_FLG` flipped to `'N'`) and open a new one. Ishaan Bhatt, who found and explained the
mechanism at the June DQ readout (T-06): "it does open the new one, that part is fine, but the
closing row's eff end date is being set to the same timestamp as the new row's eff start date and the
current flag is left as y on both of them." Both rows are therefore simultaneously "current." When
the fact table joins on `CUSTOMER_KEY` to the current row, it matches two rows instead of one, and the
line's amount is counted against both — "for that distributor only... it is not a general
duplication" (Ishaan Bhatt, T-06).

Two structural facts make this possible and make it invisible in production:

- **No unique constraint** enforces "exactly one `CURRENT_FLG='Y'` row per `CUSTOMER_ID`" on the
  target table, so nothing errors when the bug fires: "there is no unique constraint on it in the
  target, so nothing errors... it just quietly doubles" (T-06).
- Territory reassignment is a real, recurring business event, not an edge case: per Aniruddh Deshpande
  at the architecture review (T-04, cited for context on the general mechanism, not this file's
  primary source set), realignments happen "three four times in a year" and move "fifty sixty
  parties" at once when they occur — so the failure mode is lumpy rather than uniform.

**Worked example**: `DIST-W-0241`, Mahalaxmi Distributors (Pune), reassigned 17-Apr-2026 from
`TER-W-014` to `TER-W-011`. Both rows still carried `CURRENT_FLG='Y'` as of the June DQ readout
(T-06) and again as confirmed by Farida Contractor "this morning" in her 09-Jul-2026 handover mail
(EM-055).

**Detection**: fails `DQ-R-07` (uniqueness: exactly one `CURRENT_FLG='Y'` row per `CUSTOMER_ID`,
threshold 100%, actual 99.16% — 18 of 2,140 customers) and the related `DQ-R-23` (every fact row
resolves to a current `DIM_CUSTOMER` row), measured on fact rows rather than customers (T-06).

**Scale**: 61 customers carry overlapping effective-date ranges; of those, 18 have actually ended up
with two simultaneously-current rows (T-06, EM-055). Farida Contractor's caveat on the count, worth
keeping attached to the number: "the 61 and the 18 came off Meghna's counts and I have not re-counted
since, so if you run it again and the number comes different..." (EM-055).

## Impact

**INR 65 lakh** (exact: INR 64,80,500), FY26. Described consistently as directional/estimated in the
earliest sources (DK-03: "this is an estimate, not yet a validated figure — treat it as directional")
and carried unchanged through T-06, EM-055, and T-08.

## Diagnostic history

| Date | Artifact | What happened |
|---|---|---|
| 19-May-2026 | XL-01 log | Raised on the tracker: "distributor reassignment causing dup facts, worked eg DIST-W-0241." |
| 05-May-2026 | DK-03 | Presented as an emerging, unconfirmed item — draft slide, no named owner on the register yet, mechanism not yet committed to in writing. |
| 18-Jun-2026 | T-06 | Full mechanism explained by Ishaan Bhatt. Worked example and DQ-R-07/DQ-R-23 counts formalized. Farida Contractor named as owner on the tracker at this point ("frida is the owner... it is with me"). Farida raises that any fix must set a real close-out date, not `SYSDATE`, when repairing the existing bad rows. |
| 09-Jul-2026 | EM-055 | Ownership handed from Farida Contractor to Ishaan Bhatt — see Ownership history below. |
| 22-Sep-2026 | T-08 | Restated to the steering committee: "sixty one distributors have overlapping effective dates, eighteen of them are carrying two current rows today." Owner given as Ishaan Bhatt, without reference to the earlier owner (consistent with the handover being final). |

No false-trail history on the root cause itself — unlike VAR-003, the mechanism was correctly
diagnosed by Ishaan Bhatt on first identification (T-06) and never revised.

## Status

**Open** at the end of the read corpus. Root cause and scale confirmed; fix not yet built. Farida
Contractor's stated design constraint for the eventual fix (T-06): do not simply flip `CURRENT_FLG` on
the existing bad rows without deciding what the true `EFF_END_DT` should have been — "not sysdate."
Action item `AI-39` assigned to Farida Contractor with a 03-Jul-2026 target in T-06, but this predates
the 09-Jul ownership handover to Ishaan Bhatt below, and no source in this read set confirms the fix
was delivered.

## Ownership history

**Old value**: Farida Contractor. **New value**: Ishaan Bhatt. **Changed on**: 09-Jul-2026.

- **Source of old value**: `XL-01_variance_tracker_v7.xlsx` (Register tab, VAR-004 row, Owner column
  reads "F. Contractor" as of the 18-Sep-2026 save — this is stale and was never updated); also
  `DK-03_variance_rootcause_v2.pptx` (05-May-2026, though as an unconfirmed draft, not a firm
  assignment); also T-06 (18-Jun-2026), where Farida Contractor is named as current owner on the call
  ("frida is the owner... it is with me").
- **Source of new value**: `EM-055_var004_handover_ishaan.eml` (09-Jul-2026), Farida Contractor to
  Ishaan Bhatt: "With effect from today, 09-Jul-2026, VAR-004 is yours. Please keep this mail as the
  handover record... Sneha, kindly change the owner against VAR-004 in the Tracker to Ishaan Bhatt. I
  will not update it from my side, two people editing the same file is how we ended up with three
  versions of it last time." The stated reason is bandwidth, not a disagreement about the diagnosis:
  "Reason is bandwidth on my side and nothing else. Month end support, the quarter close and the audit
  extracts run through July and most of August... VAR-004 needs somebody who is inside that interface
  every day and at the moment that is not me." Farida explicitly retained ownership of the
  `DIM_CUSTOMER` interface itself, distinct from the diagnostic/remediation work: "What I am not
  handing over is the DIM_CUSTOMER interface itself. Anything you want changed in it comes to me
  first as a change and I will schedule it."
- **Confirmed current as of**: T-08 (22-Sep-2026), where Ishaan Bhatt is named as owner without any
  reference to the earlier assignment.
- **Why this matters for anyone reading `XL-01` directly**: the tracker's Owner column for VAR-004
  still reads "F. Contractor" as saved 18-Sep-2026 — over two months after the handover mail. Per
  `EM-055` itself, this is because Farida deliberately declined to make the tracker edit and asked
  Sneha Pillai to do it, and evidently that edit was never carried through into this version of the
  workbook. **Per this concept file's `owner` field, the email wins**: current owner is recorded as
  Ishaan Bhatt.

This is logged in [/log.md](/log.md).

## Remediation

Not yet designed in the read corpus. Farida Contractor's stated constraint (T-06) — the fix must
compute a correct historical `EFF_END_DT` for the affected rows, not stamp them with the current
system date — is the only remediation direction on record. No change reference, ADR, or target release
appears for VAR-004 in any source read for this file.

## Comparison against the canon register

`variance_register_canon.csv` states the same mechanism (closing row's `EFF_END_DT` set to the new
row's `EFF_START_DT`, `CURRENT_FLG` left `'Y'` on both), the same scale (61 / 18), the same worked
example (`DIST-W-0241`, 17-Apr-2026, `TER-W-014`→`TER-W-011`), and the same impact figure
(INR 64,80,500). The canon file's own annotation states plainly: "VAR-004 owner is Ishaan Bhatt from
09-Jul-2026 (EM-055). `XL-01_variance_tracker_v7.xlsx` still shows 'F. Contractor' and that staleness
is deliberate." My independent reading of EM-055, T-06, XL-01, and T-08 confirms this exactly, down to
the mechanics of *why* the tracker never got updated (Farida asked Sneha to make the edit rather than
making it herself, to avoid a repeat of a prior multi-version tracker problem). **Full agreement**,
with the underlying reasoning traced in more depth than the canon's terse note.

## Related concepts

- [/concepts/tables/bcpl-edw-dim-customer.md](/concepts/tables/bcpl-edw-dim-customer.md) — the SCD2 dimension carrying the bug
- [/concepts/tables/oms-prod-customer-territory-hist.md](/concepts/tables/oms-prod-customer-territory-hist.md) — source-side territory history the SCD2 logic reads
- [/concepts/tables/oms-prod-customer.md](/concepts/tables/oms-prod-customer.md) — natural-key source of `DIM_CUSTOMER`
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) — the fact table that double-joins against the two current rows
