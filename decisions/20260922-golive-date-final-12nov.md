---
type: decision
title: "Go-live date moves from 30-Oct to 12-Nov-2026 (final)"
description: The Klarissen Group close blackout (26-Oct to 6-Nov CET) rules out cutting over inside that window, so the plan moves a second time. Cutover weekend 7-8 Nov, historical reload 9-11 Nov, business go-live Thursday 12-Nov-2026, hypercare to 11-Dec. Approved by the steering committee as a Group calendar constraint, not a build or data problem.
tags:
  - decision
  - go-live-date
  - cutover
  - klarissen
  - group-close-blackout
  - hypercare
  - steering-committee
status: accepted
supersedes: /decisions/20260819-golive-date-slip-to-30oct.md
generated:
  by: process:claude-sonnet/decisions
  at: "2026-08-23T11:03:46Z"
sources:
  - resource: /_sources/meetings/2026-09-22_steering_committee.txt
    id: T-08
    title: Steering committee
    author: Rajeev Menon
    last_modified: "2026-09-22"
  - resource: /_sources/decks/DK-06_steerco_sep2026.pptx
    id: DK-06
    title: Steering Committee, 22 September 2026
    author: Ananya Krishnan
    last_modified: "2026-09-22"
updated: "2026-09-22"
---

# Go-live date moves from 30-Oct to 12-Nov-2026 (final)

**Deciders:** Rajeev Menon (chair), Shalini Iyer, Vikram Sethi, Karthik Subramanian, Ananya Krishnan,
Sneha Pillai. **Consulted:** Marijke van der Berg (Klarissen Group, on the call for the full 45
minutes). Wei Lin Tan (Klarissen Group) was cc'd on the pack only and not on the call.

## Context and problem statement

The 30-Oct-2026 plan date (see
[/decisions/20260819-golive-date-slip-to-30oct.md](/decisions/20260819-golive-date-slip-to-30oct.md))
fell inside a constraint nobody had checked against it: Klarissen Group's own financial close calendar.
`DK-06`'s speaker notes are explicit about how this was to be framed to the committee: "this is NOT a
build problem, it is the Klarissen group close blackout — say that before anyone asks, it lands
better." Ananya Krishnan opened the agenda item exactly that way: "this is not a build or a data
problem, it is a Group calendar constraint."

## Decision drivers

- **The Klarissen Group close blackout runs 26 October to 6 November (CET).** No operating company may
  cut over inside that window — confirmed as an absolute rule, including read-only activity: "not even
  a read-only cutover, nothing goes in" (`T-08`).
- The blackout is a standing Group calendar item, not new information — "the UAT timeline catching up
  with a constraint that was always there," per `DK-06`'s own speaker notes, anticipating exactly the
  question ("since when do we know this") that Rajeev Menon might reasonably ask.
- The cutover therefore has to sit entirely on the clean side of the blackout, after UAT has run.
- The chosen date needed to stay outside BCPL's own November reporting-month sensitivities — Marijke
  van der Berg raised whether India numbers moving in November because of the cutover would be a
  problem; this was acknowledged but did not change the date, since the reload does not restate any
  values, only replays the same source rows.

## Considered options

No alternative date is discussed on the record; the shape of the plan (weekend cutover, midweek reload,
Thursday go-live) is presented as the proposal and accepted without a competing option being tabled.

## Decision outcome

Chosen: **Cutover weekend Saturday 7 – Sunday 8 November 2026; historical reload Monday 9 – Wednesday
11 November 2026; business go-live Thursday 12 November 2026; hypercare ends Friday 11 December 2026.**
Proposed by Ananya Krishnan and confirmed twice on the call, once by Marijke van der Berg and once at
the close of the agenda item by Rajeev Menon: "we have just done the date — cutover weekend seventh and
eighth November, go-live Thursday the twelfth of November" / "twelfth of November, noted, and that is
outside the Group close blackout." The committee's closing ask, read verbatim from `DK-06`'s final
slide, is to "hold the 12-November go-live date — no further replanning around it from this point" —
approved.

### Consequences

- Good: The plan is no longer at risk from a constraint that was always going to apply; no change to
  commercials from this revised shape — "the revised plan stays inside the capped fee."
- Good: Master data freeze for distributor/territory records is scheduled ahead of the cutover weekend
  (from the Friday evening before, 6-Nov), addressing the SCD2 closing-rule risk directly relevant to
  `VAR-004`.
- Bad / open: **November UAT resourcing is explicitly not yet agreed by Finance.** Shalini Iyer asked
  this be minuted separately rather than folded into a green status row: "Sneha, can you also note that
  I have not agreed the November resourcing yet" — carried as an open item, not as agreed capacity, on
  `DK-06`'s own instruction to whoever presents the pack.
- Neutral: This is stated to be the last planned move — "I am not going to ask for a third date"
  (Rajeev Menon, on the earlier 30-Oct move) and "no further replanning around it from this point"
  (`DK-06`, on this one) — but no artifact after 22-Sep-2026 is in the read corpus to confirm the date
  held through to cutover.

## Evidence

| Claim | Source |
|---|---|
| 30-Oct-2026 plan falls inside the Klarissen Group close blackout (26-Oct to 6-Nov CET); no cutover activity permitted in that window | `/_sources/decks/DK-06_steerco_sep2026.pptx`; `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |
| Revised milestones: cutover weekend 7-8 Nov, reload 9-11 Nov, go-live 12-Nov, hypercare to 11-Dec | `/_sources/decks/DK-06_steerco_sep2026.pptx`; `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |
| No change to commercials; framed explicitly as a Group calendar constraint, not a build/data problem | `/_sources/decks/DK-06_steerco_sep2026.pptx` |
| November UAT resourcing not yet agreed by Finance, minuted as an open item at Shalini Iyer's request | `/_sources/decks/DK-06_steerco_sep2026.pptx`; `/_sources/meetings/2026-09-22_steering_committee.txt` (T-08) |
| Committee's closing ask: hold the 12-Nov date, no further replanning | `/_sources/decks/DK-06_steerco_sep2026.pptx` |

## Follow-ups

- [ ] Ananya Krishnan to recirculate the plan with the cutover weekend and go-live date marked up,
      including the master data freeze note, due 24-Sep-2026 (`T-08` action item AI-56).
- [ ] Sneha Pillai to circulate UAT slots and the tester allocation, due 28-Sep-2026 (`T-08` action item
      AI-57).
- [ ] Business (Finance/Sales Ops) to confirm UAT tester nominations for the October window — open as
      of 22-Sep-2026.
- [ ] November UAT resourcing to be agreed by Finance — explicitly not yet agreed, no owner or date
      given beyond the open-item flag.

## Related concepts

- [/decisions/20260819-golive-date-slip-to-30oct.md](/decisions/20260819-golive-date-slip-to-30oct.md) — the record this supersedes
- [/concepts/variances/var-004-scd2-territory-reassignment.md](/concepts/variances/var-004-scd2-territory-reassignment.md) — motivates the pre-cutover master data freeze

## Referenced by

- [Steering committee — 22 September 2026](/meetings/2026-09-22_steering_committee.md)
