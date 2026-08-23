---
type: variance
title: "VAR-003 — Scheme discount double-count"
description: A finance procedure inside ORION (FIN_PROD.PKG_MONTH_END.P_RECALC_SCHEME_DISCOUNT) additively rewrites SCHEME_DISC_AMT on invoice lines every night after the warehouse extract has already run, so the same delta is re-read and appended a second time. A database-link latency hypothesis was raised and ruled out before this was found.
resource: FIN_PROD.PKG_MONTH_END.P_RECALC_SCHEME_DISCOUNT
tags:
  - variance
  - VAR-003
  - scheme-discount
  - trade-promotion-accrual
  - TPR
  - scheme
  - dblink
  - database-link
  - false-trail
  - PKG_MONTH_END
  - source-side
owner: Aniruddh Deshpande
generated:
  by: process:claude-sonnet/variances
  at: 2026-08-23T10:45:28Z
sources:
  - resource: /_sources/meetings/2026-03-24_first_variance_findings.txt
    id: T-03
    title: First variance findings
    author: Ananya Krishnan
    last_modified: "2026-03-24"
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
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
  - resource: /_sources/docs/DOC-03_stored_procedure_walkthrough.docx
    id: DOC-03
    title: "PKG_MONTH_END and the batch close proc - walkthrough of the five routines"
    author: Aniruddh Deshpande
    last_modified: "2026-04-28"
  - resource: /_sources/decks/DK-03_variance_rootcause_v2.pptx
    id: DK-03
    title: Variance root cause - working readout, v2
    author: Karthik Subramanian
    last_modified: "2026-05-05"
  - resource: /_sources/technical/pkg_month_end.pkb
    id: TECH-PKG
    title: FIN_PROD.PKG_MONTH_END package body
    author: Aniruddh Deshpande
    last_modified: "2026-04-27"
  - resource: /_sources/technical/control_m_schedule.txt
    id: TECH-CTLM
    title: Control-M job schedule export, folder BCPL_EDW_DAILY
    author: Farida Contractor
    last_modified: "2026-03-18"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
---

## Observed

The scheme discount amount sitting on `FACT_INVOICE_LINE` did not tie to Finance's own trade
promotion accrual — Shalini Iyer's team was consistently short-changed relative to the warehouse:
"the warehouse is always higher always... never lower" (T-03). Unlike a random reconciliation gap,
this one only ever moved in one direction, which is what made it interesting rather than merely
annoying: "because a random error goes both ways this one only goes one way, so something is being
added and never taken away" (T-03).

## The false trail: the database link hypothesis (T-03, raised and believed)

At the first findings session (24-Mar-2026), the team looked at the fact rows behind the gap and
found the discount was being counted on **exact duplicate rows** — the same source invoice line
present more than once, same line id, same amount, different load date. Karthik Subramanian put
forward a specific, named hypothesis on the spot and asked for it to be recorded: **latency on the
`ORION_PRD` database link** was causing rows to be re-extracted into overlapping nightly windows.

The reasoning at the time was coherent, not careless. `MAP_FACT_INVOICE_LINE` loads via `IKM Oracle
Control Append` (insert-only, no merge), and the extract predicate is a rolling window
(`TRUNC(SYSDATE)-1`) that overlaps by design so late-arriving rows aren't lost. If a single night's
extract ran long enough — and the invoice-line interface was, by Aniruddh Deshpande's own account,
"the slowest thing in the whole plan" on a heavy night, sitting in `SQL*Net message from dblink` —
rows read late could fall inside the *next* night's window too, and get appended a second time with
nothing to catch it. Karthik was explicit about his own confidence level: "moderately confident, not
confident... it fits three things: the duplicates are exact, they are concentrated on the heavier
nights, and the link is measurably slow on exactly those nights." He also stated a clean falsification
test on the record: pull AWR data for a bad night and a clean night and see whether link wait tracks
the duplicates. The item went into the tracker explicitly as a hypothesis: "write it as, suspected
cause, latency on the orion prd database link causing rows to be re-extracted" — Ananya Krishnan
insisted the word "suspected" be recorded in capitals.

Shalini Iyer only "half agreed" even at the time, and Farida Contractor pushed back on the leap from
correlation to causation in the same meeting: "the link is slow, that is not in dispute... but slow is
slow, i do not see immediately how slow becomes wrong." Nobody had an answer to her objection that
day, and Sneha Pillai logged VAR-003 for the tracker with "cause... as suspected."

## The false trail ruled out (T-04, 14-Apr-2026)

Three weeks later, at the architecture review, Farida Contractor brought the AWR report for
`edw-db-prd-01`, 23-Mar-2026 01:00-03:00 — a normal night, deliberately chosen as "the night before
the meeting where you all said it is the link." The evidence:

- `SQL*Net message from dblink` total wait across the **entire load plan**: **4.1 minutes**.
- **6,412** round trips, average **38 ms** each ("intra data centre in mumbai we are at zero point
  four milliseconds, so thirty eight is high for a round trip but it is not a disaster").
- Share of total elapsed: **1.2%**.

Karthik Subramanian, the author of the original hypothesis, retracted it on the record and explained
*why* it was wrong rather than just that it was wrong: "a latency problem makes a load slow, it does
not make a number wrong... latency changes when the extract finishes, it does not change what the
extract read." Two further, independent observations closed the door:

1. **The duplicates are exact**, not partial or torn rows — same invoice line id, same amount, same
   everything, different load date only. A network problem would produce torn rows, partial batches,
   or rejects; `E$` (the error/reject table) was checked and was empty for the affected nights
   (Farida Contractor, T-04).
2. **No correlation between link speed and the variance.** Ishaan Bhatt compared a sample of nights
   where the plan closed early (link behaving) against nights that closed late, and found the same
   problem on both: "the fast nights have the same problem as the slow nights... there is no
   correlation... none, it is flat."

The session closed the item as: "database link hypothesis eliminated, root cause not identified,
investigation continuing" (Karthik Subramanian, read back by Sneha Pillai as the eighth action item).
Ananya Krishnan's closing comment is worth preserving verbatim for what it says about the discipline
being applied here: "i genuinely do not know, and i would rather say that than give you a second
wrong answer three weeks after the first one."

## The true mechanism (DOC-03, 28-Apr-2026 — the only place in the read corpus that states it)

The actual root cause is documented, in full, in exactly one artifact: **DOC-03**, a note Aniruddh
Deshpande wrote for Karthik Subramanian after finding it (T-05, design sign-off, records that Ani
found it in about a week: "you found it in a week, i had been staring at the mapping for a month" —
Karthik Subramanian). No transcript, deck, or tracker in the read set states the timing detail below;
DK-03's own speaker notes for the VAR-003 slide explicitly instruct the presenter to *stay* at the
surface level ("source-side, a finance procedure rewrites the scheme discount amount, that is all...
if pushed for more, the line to use is 'that's in the stored procedure walkthrough, let's take it
offline'"), and T-08 (22-Sep) confirms the detail was circulated but not necessarily read: "the
detail is written up, karthik circulated the stored procedure walkthrough in april, it is all in
there — i have not read it."

The mechanism, per DOC-03 and corroborated by the actual PL/SQL in `pkg_month_end.pkb`:

- `FIN_PROD.PKG_MONTH_END.P_ADJUST_REVENUE` is the driver of a small package built in 2011 and named
  for a monthly finance process it no longer is. In 2014 the scheme-accrual calculation it performs
  was moved from a manual, three-day, once-a-month spreadsheet exercise to a nightly automated job —
  but nobody renamed the package, fixed its header comment, or documented the change outside a change
  ticket nobody can find. "The name says twelve runs in a year. The job says three hundred and
  sixty-five." (DOC-03)
- The job is `FIN_MTHEND_ADJ_NIGHTLY`, an Oracle `DBMS_SCHEDULER` job owned by `FIN_PROD`, enabled
  19-Nov-2014, running daily. **It is not in Control-M** — it lives inside the ORION database itself,
  in a completely different scheduling mechanism from the warehouse's own jobs. `control_m_schedule.txt`
  confirms this by omission: no `FIN_MTHEND_ADJ_NIGHTLY` or `PKG_MONTH_END` job appears anywhere in
  the `BCPL_EDW_DAILY` folder export. DOC-03 is explicit about the consequence: "if you audit the
  batch estate from the scheduling documentation you will conclude that nothing runs against finance
  data at night, and you will be reading the documents correctly. The documents are just not
  complete."
- The driver calls `P_RECALC_SCHEME_DISCOUNT`, which recomputes cumulative scheme entitlement for
  every distributor active in the period — a legitimate business rule, since a distributor crossing a
  volume slab late in the month becomes entitled to the better rate on everything already billed that
  month, not just what they buy afterward. The procedure then does this, verbatim from `pkg_month_end.pkb`:

  ```sql
  UPDATE oms_prod.invoice_line
     SET scheme_disc_amt = NVL(scheme_disc_amt, 0) + v_upd_delta_tab(j),
         last_upd_by     = gc_pkg_name,
         last_upd_dt     = SYSDATE
   WHERE invoice_line_id = v_upd_id_tab(j);
  ```

  It **adds** a delta to whatever is currently on the row rather than setting the column to the
  recomputed value, and there is no idempotency guard, run marker, batch id, or history row anywhere
  on the line. Read literally from the code comment directly above it: "If this runs twice for the
  same customer, scheme and period, the same delta is added twice — nothing here checks for that and
  nothing here would notice."
- Critically, the update also bumps `LAST_UPD_DT` — the exact column every incremental extract in the
  landscape keys off, because there is no change-data-capture anywhere in this estate. DOC-03's own
  words on the timing that closes the loop: "load is starting 01:00 and on a normal night the last
  step is done and committed by about 02:05, and the finance job in ORION starts 02:15 and the scheme
  recalculation inside it reaches the invoice line update around 02:40, so by the time the amount on
  the line changes the warehouse has already read those lines and finished with the source for that
  business date, which is why the warehouse is sitting on the pre-adjustment scheme discount value,
  and why the same line comes across again on the next night once `LAST_UPD_DT` has moved, and gets
  counted a second time."

Put together with what T-03/T-04 already established about the load side (`IKM Oracle Control
Append` is insert-only, has no merge, and nothing on the fact table constrains a repeat key), the full
loop is: ORION touches the row after the warehouse has already extracted it for that business date →
the row's `LAST_UPD_DT` moves → the next night's incremental window picks the row up again as if it
were newly changed → the control-append load inserts it a second time, discount included. The
database link was never part of this loop at all; it only affects *when* the extract finishes, which
is a different thing from *what* it read.

One more piece of DOC-03 worth recording for anyone reasoning about detectability: `FIN_PROD` holds a
**direct UPDATE grant on `OMS_PROD.INVOICE_LINE`**, given in 2014 "for exactly this," never reviewed
since. A finance package silently rewriting order-to-cash invoice lines is not something anybody on
the warehouse side had a reason to go looking for — which is a large part of why the database link,
the most *visible* slow thing in the chain, absorbed the blame first. Karthik Subramanian said this
about himself, on the record, at T-04: "it was the most visible broken thing in the chain so it got
the blame, which is exactly how you get the wrong answer."

## Impact

**INR 1.70 Cr** (exact: INR 1,68,90,000), FY26. First sized in T-03 as "one point seven odd," unchanged
through to the 22-Sep-2026 steering committee, where it is still carried as "one point seven zero" in
the reported pack (Shalini Iyer, T-08).

## Diagnostic history

| Date | Artifact | What happened |
|---|---|---|
| 24-Mar-2026 | T-03 | Item raised. Duplicate-row signature identified. Database-link latency hypothesis proposed and logged as "suspected." |
| 14-Apr-2026 | T-04 | AWR evidence rules the link out (4.1 min total wait, 1.2% of elapsed, no correlation with duplicate incidence). Status recorded as "root cause not identified." |
| 27–28-Apr-2026 | DOC-03 | Aniruddh Deshpande documents the true mechanism in full: the `PKG_MONTH_END` nightly job, the additive update, the exact timing sequence. Circulated to Karthik. |
| 05-May-2026 | DK-03 | Root cause presented at surface level only ("source-side, a finance procedure rewrites the scheme discount amount") — deliberately, per the deck's own speaker notes, to keep the readout to 30 minutes and avoid a mechanism discussion in that room. |
| 06-May-2026 | T-05 | Root cause formally accepted as source-side and settled ("it is settled," Aniruddh Deshpande). Remediation approach (`ADR-004`) signed off: rebuild `MAP_FACT_INVOICE_LINE` as a key-based merge on `INVOICE_LINE_ID` rather than asking Finance to change a 2011 package mid-close. Target release `R2026.09`, 30-Sep-2026. |
| 22-Sep-2026 | T-08 | Root cause restated for the steering committee unchanged. Karthik Subramanian explicitly **declines to commit to the 30-Sep close date in front of the group**: "I am not going to give this group a close date today... I have not agreed a position [with Ani] yet." This is a real tension worth flagging: the tracker (`XL-01`, saved four days earlier) still shows Target Close `30-Sep-26` on the Register tab, and the change log entry from 02-Sep-2026 records "chased Ani and Karthik again for a target date on VAR-003, still TBC." The written target date and the spoken position are not the same thing as of the end of the read corpus. |

## Status

**Open** at the end of the read corpus. Root cause confirmed and accepted (06-May-2026); remediation
approach agreed (`ADR-004`, key-based merge rebuild of `MAP_FACT_INVOICE_LINE`); no confirmed close
date as of the 22-Sep-2026 steering committee, despite `R2026.09` / 30-Sep-2026 still standing as the
written target in the tracker.

## Owner

**Aniruddh Deshpande** — this is consistent across the sources actually read for this file (XL-01
register, T-08: "anirood owns it... ani, yes, anirood"). DK-03 (05-May-2026), which predates formal
ownership assignment, shows the register owner cell as "DW team (TBC)" with a speaker-note explanation
that ownership was deliberately not put on a named individual in writing before design sign-off the
next day: "the DW team is doing the actual analysis but ownership on the register hasn't been formally
assigned to a named individual yet... we don't want to commit that in writing before it's confirmed at
design sign-off tomorrow." By T-05 (06-May) the tracker owner is recorded as Aniruddh Deshpande with
build support from Karthik Subramanian's team, and this holds through XL-01 (18-Sep) and T-08
(22-Sep). No conflicting owner claim found in the read set.

## Remediation

`ADR-004`: leave the ORION-side package untouched (Farida Contractor, on the record, ruled out asking
Finance to change a package that "is part of my close" and "the people who wrote it are not there
since 2014"). Instead, rebuild `MAP_FACT_INVOICE_LINE` as a key-based merge on `INVOICE_LINE_ID`, with
`IKM Oracle Control Append` replaced so a re-extracted row with an unchanged key updates in place
instead of inserting again. Scoped to that one mapping. Target release `R2026.09` (30-Sep-2026); not
yet delivered as of the end of the read corpus, and (see Diagnostic history) not confirmed as still on
track as of 22-Sep-2026.

## Comparison against the canon register

`variance_register_canon.csv` marks this item's `root_cause` text as CANON-INTERNAL TRUTH, restricted
to `DOC-03` under `fact_ownership.csv` (facts `F-TIMING`, `F-ADDITIVE`). My own reading of DOC-03,
cross-checked directly against `pkg_month_end.pkb`, produces the identical mechanism: the same
package, the same procedure, the same additive `UPDATE`, the same `LAST_UPD_DT` side effect, the same
job name and 2014 history. **Full agreement** — this is one item where I was able to independently
verify the canon-internal fact against two primary sources (a written walkthrough and the actual
PL/SQL) rather than take it on trust. Where I have added detail beyond the canon's one-line summary is
the diagnostic narrative itself — the false trail's specific evidence, the AWR numbers, and the
open question over the 30-Sep close date — which the canon register does not carry (it only notes
"still open at the end of the corpus," which my reading confirms and sharpens).

## Related concepts

- [/concepts/tables/oms-prod-invoice-line.md](/concepts/tables/oms-prod-invoice-line.md) — `SCHEME_DISC_AMT`, the column rewritten in place
- [/concepts/tables/bcpl-edw-fact-invoice-line.md](/concepts/tables/bcpl-edw-fact-invoice-line.md) — target fact carrying the double-counted amount
- [/concepts/tables/oms-prod-scheme-master.md](/concepts/tables/oms-prod-scheme-master.md) — scheme slab definitions the recalculation reads
- [/concepts/tables/fin-prod-scheme-accrual.md](/concepts/tables/fin-prod-scheme-accrual.md) — the accrual table `P_RECALC_SCHEME_DISCOUNT` also writes, correctly, alongside the flawed invoice-line update
- [/concepts/tables/fin-prod-period-control.md](/concepts/tables/fin-prod-period-control.md) — drives which period `P_ADJUST_REVENUE` resolves and adjusts; closing a period does not stop the nightly job
- [/concepts/tables/fin-prod-gl-journal-hdr.md](/concepts/tables/fin-prod-gl-journal-hdr.md) and [/concepts/tables/fin-prod-gl-journal-line.md](/concepts/tables/fin-prod-gl-journal-line.md) — posted by `P_POST_GL_SUMMARY`, downstream of the same driver
