---
type: decision
title: "VAR-008 resolved: Finance restates February internally; batch-id guard rides with R2026.07"
description: The February reload question parked at T-03 is resolved by mail, before the architecture review it was deferred to. Chosen approach is effectively Option 1 from T-03 (no reload; Finance restates the month internally) plus a structural fix — a batch-id guard on the load plan, deployed with the June/July release rather than as a one-off patch, so a deliberate re-run cannot duplicate a batch again.
tags:
  - decision
  - VAR-008
  - february-duplicate-load
  - batch-id-guard
  - R2026.07
  - reconciliation
  - LP_DAILY_SALES
status: accepted
supersedes: /decisions/20260324-var008-february-reload-deferred.md
generated:
  by: process:claude-sonnet/decisions
  at: "2026-08-23T11:03:46Z"
sources:
  - resource: /_sources/email/EM-072_feb_duplicate_load_chain.eml
    id: EM-072
    title: "February reconciliation - LP_DAILY_SALES re-run 14-Feb (five-level forwarded chain)"
    author: Farida Contractor
    last_modified: "2026-08-21"
updated: "2026-04-02"
---

# VAR-008 resolved: Finance restates February internally; batch-id guard rides with R2026.07

**Deciders:** Ananya Krishnan (closed the item, on behalf of Northlane Analytics). **Consulted:**
Farida Contractor, Ishaan Bhatt. **Informed:** Shalini Iyer, Priya Nair, Vikram Sethi, Sneha Pillai,
Karthik Subramanian.

## Context and problem statement

The choice of how to handle February's duplicated batch was explicitly parked at `T-03` (24-Mar-2026)
pending the architecture review three weeks later — see
[/decisions/20260324-var008-february-reload-deferred.md](/decisions/20260324-var008-february-reload-deferred.md).
In practice, the question was resolved sooner, by email, on **02-Apr-2026** — before the architecture
review (14-Apr-2026) ever discussed it. This record captures that resolution and the reasoning behind
it, quoted from Ananya Krishnan's close-out mail (preserved in full in the forwarded chain, `EM-072`,
21-Aug-2026).

By the time of the close-out, Ishaan Bhatt had confirmed the duplicate total (INR 2.9 Cr, exact INR
2,94,10,000) and its signature (exact duplicates, same `INVOICE_LINE_ID`, arriving together under one
load date) independently of Farida Contractor's own working.

## Decision drivers

- Farida Contractor's `T-03` warning still held: reloading February through the mapping as it then
  stood risked compounding the problem, not fixing it.
- A number was needed quickly — Vikram Sethi's downstream quarter file depended on it, and the item had
  already sat unresolved since the 6-Mar first flag.
- The structural weakness (no batch-id guard on `LP_DAILY_SALES`, so a manual resubmit duplicates an
  entire night) needed a permanent fix regardless of what was done about the one bad month, but did not
  need to be rushed in as an emergency patch: "that is the right call, I would rather it went through
  the normal route" (Ananya Krishnan, `EM-072`).

## Considered options

This resolution corresponds to **Option 1** from the three laid out at `T-03` — leave the already-
loaded data alone and have Finance carry a correcting adjustment — combined with a structural fix for
recurrence, rather than Option 2 (delete the duplicate batch) or Option 3 (truncate and reload
February). No artifact records why Options 2/3 were dropped rather than Option 1 chosen on their
merits; the mail states the outcome, not a comparison.

## Decision outcome

Chosen: **February is not reloaded or truncated. Finance restates the month internally so it
reconciles**, and a **batch-id guard** is added to the load plan so a deliberate re-run of an
already-loaded batch is rejected rather than appended again — agreed to ride with the `R2026.07`
release rather than go in as a one-off patch. Ananya Krishnan, 02-Apr-2026: "this is closed with effect
from today... Finance have restated February internally so the month reconciles now... Farida has
agreed a batch-id guard on the load plan and it rides with the R2026.07 release rather than going in
as a one-off patch."

Because it resolves Vikram Sethi's and Shalini Iyer's immediate need for a clean number without
touching a load mapping that still had the separate, unrelated `VAR-001` defect (no `DELETE_FLAG`
filter) live in it at the time.

### Consequences

- Good: February reconciles without a risky truncate-and-reload through a still-defective mapping.
- Good: The structural cause (no guard against a duplicate resubmission) gets a real fix, not just a
  one-off correction — though its actual production deployment trailed this closure by over three
  months. The guard shipped with `R2026.07` on **08-Jul-2026**, while the reconciliation item itself
  was marked closed on **02-Apr-2026**; the tracker's terse log line at closure ("batch id guard added,
  tested ok") reads as though the guard were already live, which it was not — see
  [/concepts/variances/var-008-feb-duplicate-load.md](/concepts/variances/var-008-feb-duplicate-load.md)
  for the full diagnostic history and this gap.
- Neutral: Explicitly separated from `VAR-001` on the same mail, to avoid the two being merged in
  people's minds — the FY26 Q1 revenue overstatement (cancelled/deleted lines counted as revenue,
  INR 4.2 Cr, the figure Shalini Iyer was not signing) is a different item, picked up in the root-cause
  session rather than here.
- Bad: The resolution happened by email close-out rather than in the session the team had told Shalini
  Iyer it would be decided in — a minor process gap, not a substantive one, since the outcome (Finance
  restatement, no reload) is exactly what Farida Contractor's `T-03` caution pointed toward.

## Evidence

| Claim | Source |
|---|---|
| Item closed 02-Apr-2026; duplicated value INR 2.9 Cr (exact INR 2,94,10,000), confirmed by Ishaan Bhatt against Farida Contractor's working | `/_sources/email/EM-072_feb_duplicate_load_chain.eml` |
| Resolution: Finance restates February internally so the month reconciles; no reload or truncate performed | `/_sources/email/EM-072_feb_duplicate_load_chain.eml` (Ananya Krishnan's 02-Apr close-out mail, quoted in full) |
| Batch-id guard agreed, deliberately riding with the R2026.07 release rather than as a one-off patch | `/_sources/email/EM-072_feb_duplicate_load_chain.eml` |
| VAR-001 explicitly kept separate from this closure | `/_sources/email/EM-072_feb_duplicate_load_chain.eml` |
| Guard's actual production deployment date, 08-Jul-2026, trailing the 02-Apr closure by over three months | `/_sources/email/EM-072_feb_duplicate_load_chain.eml` (Farida Contractor's 21-Aug summary mail) |

## Follow-ups

- [x] Farida Contractor: batch-id guard into `R2026.07`, target end-April — actually delivered
      08-Jul-2026 (see the closure/deployment gap noted above).
- [x] Shalini Iyer: note to Group on the February restatement, by 10-Apr-2026.
- [x] Sneha Pillai: close the row in the tracker.
- [ ] Vikram Sethi: come back on this thread, not a new one, if the North numbers still look off after
      the restatement — no follow-up on this point found in the read corpus.

## Related concepts

- [/decisions/20260324-var008-february-reload-deferred.md](/decisions/20260324-var008-february-reload-deferred.md) — the deferral this record resolves
- [/concepts/variances/var-008-feb-duplicate-load.md](/concepts/variances/var-008-feb-duplicate-load.md)
- [/concepts/variances/var-001-q1-revenue-overstated.md](/concepts/variances/var-001-q1-revenue-overstated.md) — explicitly kept separate from this closure
- [/decisions/20260506-var003-remediation-key-based-merge.md](/decisions/20260506-var003-remediation-key-based-merge.md) — the later, more general fix for the same insert-only load weakness
