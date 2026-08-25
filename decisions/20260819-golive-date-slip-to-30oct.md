---
type: decision
title: "Go-live date moves from 15-Sep to 30-Oct-2026"
description: The original 15-September-2026 go-live date, set at kickoff, is abandoned. Ananya Krishnan proposes 30-October-2026, driven by an ORION patch weekend that locks the source system for a week and by VAR-004/VAR-007 remaining open past when they were needed for a clean cutover. Rajeev Menon accepts on behalf of BCPL. Superseded six weeks later.
tags:
  - decision
  - go-live-date
  - cutover
  - UAT
  - VAR-004
  - VAR-007
  - ORION-patch
  - replanning
status: superseded
superseded_by: /decisions/20260922-golive-date-final-12nov.md
generated:
  by: process:claude-sonnet/decisions
  at: "2026-08-23T11:03:46Z"
sources:
  - resource: /_sources/decks/DK-01_kickoff_v3_FINAL.pptx
    id: DK-01
    title: "Kickoff: Data, Analytics & Reporting Transformation"
    author: Ananya Krishnan
    last_modified: "2026-02-11"
  - resource: /_sources/email/EM-068_golive_slip_30oct.eml
    id: EM-068
    title: "RE: RE: FW: Drishti - revised go live date (was: wk28 status pack)"
    author: Ananya Krishnan
    last_modified: "2026-08-19"
updated: "2026-08-19"
---

# Go-live date moves from 15-Sep to 30-Oct-2026

**Deciders:** Ananya Krishnan (proposed, on behalf of Northlane Analytics), Rajeev Menon (accepted, on
behalf of BCPL — "ok. 30 oct is accepted. I am not going to ask for a third date, so please make this
one stick"). **Informed:** the wider `drishti-steerco` distribution, `drishti-core`, and
`bcpl-datawarehouse@bharadwajcp.example`.

## Context and problem statement

`DK-01` (kickoff, 11-Feb-2026) set go-live for **Tuesday 15 September 2026** — the one date the deck's
own speaker notes flagged as the thing Rajeev Menon cared about most, to be said exactly that way and
not softened to "mid-September." By 18-Aug-2026, Ananya Krishnan judged the date no longer
recoverable and raised the slip proactively rather than let it surface at the next steering committee:
"I would rather flag this now than have it come out at the next steerco."

## Decision drivers

- **ORION R12.2.9 patch weekend, 12–20 September.** The source system is locked for that period —
  "we cannot cut over into it and we cannot run a controlled comparison against it while it is being
  patched" (`EM-068`, 18-Aug mail).
- **`VAR-004` and `VAR-007` will not be closed in time.** Both remain open on the remediation list and
  both affect numbers users would see on day one. Ananya Krishnan: "going live with either of them open
  is not something I am willing to recommend."
- **UAT cannot start before 05-Oct-2026** as a consequence of the above, and working backwards from
  that start, 15-Sep was already unrecoverable: "pretending otherwise for another three weeks helps
  nobody."

## Considered options

The mail records the outcome of Ananya Krishnan's own analysis rather than a set of dated alternatives
weighed with the client; the only number put forward is 30-Oct-2026, framed as the earliest date that
respects the ORION lock and the two open variances.

## Decision outcome

Chosen: **New plan date for go-live: Friday 30 October 2026.** Rajeev Menon accepted the same evening
(18-Aug) and asked that it be the last move: "let's not boil the ocean replanning everything, only the
dates that actually move." Ananya Krishnan confirmed the wider distribution the next morning
(19-Aug-2026, `EM-068`): "15-Sep is gone, please stop quoting it, including in anything that goes to
Klarissen."

### Consequences

- Good: The plan no longer assumes access to a source system that will be mid-patch, and no longer
  assumes two open variances close on a timeline nobody had committed to.
- Neutral: The remediation build scope, the dashboard build, and the September steering committee
  itself are explicitly unaffected — "what does not change: the remediation build scope, the dashboard
  build, and the September steerco."
- Neutral: No commercial impact stated for the date move itself; Rajeev Menon asked for a cost number
  if the move did carry one, and Ananya Krishnan committed to surfacing it before being asked again if
  that changed.
- Bad (realised at the next steering committee): 30-Oct-2026 also did not hold — see
  [/decisions/20260922-golive-date-final-12nov.md](/decisions/20260922-golive-date-final-12nov.md),
  which records a Klarissen Group calendar constraint (not a build or data problem) forcing a further
  move to 12-Nov-2026.

## Evidence

| Claim | Source |
|---|---|
| Original go-live date, 15-Sep-2026, "the only date that matters to Rajeev" | `/_sources/decks/DK-01_kickoff_v3_FINAL.pptx` |
| 15-Sep abandoned; reasons: ORION R12.2.9 patch weekend (12-20 Sep), VAR-004/VAR-007 still open, UAT cannot start before 05-Oct | `/_sources/email/EM-068_golive_slip_30oct.eml` |
| New date 30-Oct-2026 proposed by Ananya Krishnan, accepted by Rajeev Menon same evening, confirmed to the wider distribution 19-Aug-2026 | `/_sources/email/EM-068_golive_slip_30oct.eml` |
| Build scope, dashboard build and September steerco unaffected by the date move | `/_sources/email/EM-068_golive_slip_30oct.eml` |

## Follow-ups

- [ ] Karthik Subramanian to confirm remediation dates for VAR-004 and VAR-007, due the Friday
      following (`EM-068`).
- [ ] Farida Contractor and Karthik Subramanian to confirm the environment position before a UAT window
      is committed in writing (`EM-068`).
- [ ] Re-issue the timeline with the next weekly status pack (`EM-068`).

## Related concepts

- [/decisions/20260922-golive-date-final-12nov.md](/decisions/20260922-golive-date-final-12nov.md) — supersedes this record
- [/concepts/variances/var-004-scd2-territory-reassignment.md](/concepts/variances/var-004-scd2-territory-reassignment.md)
- [/concepts/variances/var-007-late-arriving-sku-unknown-member.md](/concepts/variances/var-007-late-arriving-sku-unknown-member.md)

## Referenced by

- [Steering committee — 22 September 2026](/meetings/2026-09-22_steering_committee.md)
