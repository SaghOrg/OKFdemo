---
type: decision
title: "Open question — VAR-003 close date not committed at the steering committee"
description: Karthik Subramanian declines to give the steering committee a close date for VAR-003, stating on the record that he and Aniruddh Deshpande have not yet agreed a position, despite ADR-004's written target release R2026.09 (30-Sep-2026) still standing in the tracker. No date is agreed in this session and no date has been committed as of the end of the read corpus.
tags:
  - decision
  - open-question
  - VAR-003
  - close-date
  - R2026.09
  - scheme-discount
  - steering-committee
status: draft
generated:
  by: process:claude-sonnet/decisions
  at: 2026-08-23T11:03:46Z
sources:
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
  - resource: /_sources/trackers/XL-01_variance_tracker_v7.xlsx
    id: XL-01
    title: Variance tracker v7
    author: Sneha Pillai
    last_modified: "2026-09-18"
updated: "2026-09-22"
---

# Open question — VAR-003 close date not committed at the steering committee

**Status: unresolved as of the end of the read corpus. The written target date (`R2026.09`,
30-Sep-2026, agreed under
[/decisions/20260506-var003-remediation-key-based-merge.md](/decisions/20260506-var003-remediation-key-based-merge.md))
still stands in the tracker, but the person accountable for it explicitly declined to reaffirm it in
front of the steering committee four days after that tracker was last saved.**

**Position held by:** Karthik Subramanian (declines to commit). **Affected:** Aniruddh Deshpande
(source-side owner, named as not yet aligned with Karthik). **Present, not intervening:** Rajeev Menon
(chair, pressed once then accepted the answer).

## Context and problem statement

At the 22-Sep-2026 steering committee, `VAR-003` (the scheme discount double-count) was walked as an
open item unchanged since the prior steerco. Karthik Subramanian was direct about the root cause being
source-side and outside the ETL, then was asked the natural follow-up: "so when does it close?" His
answer, on the record: "I am not going to give this group a close date today... because I do not have
one I believe I would rather come back with a date that holds. Ani is closest to it on the source side
and he and I have not agreed a position yet."

This sits alongside a separate, quieter tension already on the tracker: `XL-01` (saved 18-Sep-2026,
four days before this session) still shows Target Close `30-Sep-26` on the Register tab — the written
`R2026.09` target from `ADR-004` — while the spoken position in the room, four days later, is that no
date can be committed.

## What was and was not said

- Rajeev Menon pressed once — "why not" — and accepted Karthik Subramanian's answer without escalating
  it: "Ani is your best man on that, I agree."
- Marijke van der Berg's line about a different open item (`VAR-005`) applies here too, by contrast:
  she had asked for "an owner and options," not a date, on `VAR-005`. On `VAR-003`, an owner
  (Aniruddh Deshpande) already exists and is not in question; what is missing is agreement between him
  and Karthik Subramanian on a date, which neither party disputes is missing.
- Wei Lin Tan, not on the call but confirmed to read the pack carefully (per `DK-06`'s own speaker
  notes on other items), is told in the pack only that the stored procedure walkthrough (`DOC-03`) "has
  been circulated separately... no committed close date is being given today" — the pack does not
  overstate what was said in the room.
- One committee member states plainly that the circulated detail was not read: "the detail is written
  up, Karthik circulated the stored procedure walkthrough in April, it is all in there — I have not
  read it."

## Decision outcome

**No decision was made in this session.** No date was proposed, debated, or agreed. The steering
committee's own risk register (`DK-06`) records the position rather than resolving it: "no committed
close date. Source-side, owned by Aniruddh Deshpande. Karthik and Ani have not yet agreed a joint
position." This record exists to make that non-decision explicit and to prevent the written `30-Sep-26`
tracker date from being read as a reaffirmed commitment — it is not one, on the account of the person
who would have to reaffirm it.

## Evidence

| Claim | Source |
|---|---|
| Karthik Subramanian declines to give a close date; states he and Aniruddh Deshpande have not agreed a position | `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |
| Rajeev Menon accepts the answer without pressing further | `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |
| Steering committee pack records "no committed close date" and "not yet agreed a joint position" as the standing risk | `/_sources/decks/DK-06_steerco_sep2026.pptx` |
| Tracker (saved 18-Sep-2026, four days before this session) still shows Target Close 30-Sep-26 on the Register tab | `/_sources/trackers/XL-01_variance_tracker_v7.xlsx` |

## Follow-ups

- [ ] Karthik Subramanian and Aniruddh Deshpande to agree a joint position on the VAR-003 close date and
      bring a date that holds to a future steering committee — no owner-assigned due date given.
- [ ] Reconcile the tracker's written `R2026.09` / 30-Sep-2026 target against the spoken position — not
      done as of the end of the read corpus.

## Related concepts

- [/concepts/variances/var-003-scheme-discount-double-count.md](/concepts/variances/var-003-scheme-discount-double-count.md)
- [/decisions/20260506-var003-remediation-key-based-merge.md](/decisions/20260506-var003-remediation-key-based-merge.md) — the ADR-004 record whose target date is in question here

## Referenced by

- [Progress](/context/progress.md)
- [Steering committee — 22 September 2026](/meetings/2026-09-22_steering_committee.md)
