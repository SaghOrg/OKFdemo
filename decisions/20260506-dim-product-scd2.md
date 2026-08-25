---
type: decision
title: "ADR-003 — DIM_PRODUCT keeps history (SCD2), reversing the April position"
description: DIM_PRODUCT is rebuilt as SCD2, tracking PACK_SIZE, MRP_AMT, BRAND_CODE, CATEGORY_CODE and UOM, reversing the SCD1 proposal agreed three weeks earlier. Driven by the Product Mix and Contribution dashboard's need to resolve the MRP and pack size in force at the time of a historic invoice, not today's values.
tags:
  - decision
  - ADR-003
  - dim-product
  - scd1
  - scd2
  - mrp
  - pack-size
  - product-mix-and-contribution
  - d09
status: accepted
supersedes: /decisions/20260414-dim-product-scd1-proposed.md
generated:
  by: process:claude-sonnet/decisions
  at: "2026-08-23T11:03:46Z"
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

# ADR-003 — DIM_PRODUCT keeps history (SCD2), reversing the April position

**Deciders:** Shalini Iyer (business sponsor, formal approver — "same answer, yes"), Karthik
Subramanian, Ananya Krishnan, Farida Contractor, Aniruddh Deshpande, Ishaan Bhatt, Sneha Pillai;
Rajeev Menon joined mid-session and explicitly declined to second-guess a technical call as long as it
did not move the plan.

## Context and problem statement

`DIM_PRODUCT` had been proposed as SCD1 at the architecture review of 14-Apr-2026 — see
[/decisions/20260414-dim-product-scd1-proposed.md](/decisions/20260414-dim-product-scd1-proposed.md)
— on the grounds that SKU attributes rarely change and that pricing history is carried on the fact
row, not the dimension. That was true of unit price and gross amount, which are frozen on the fact.
It stopped being true once the team worked through what the **Product Mix and Contribution dashboard
(D09)** actually needs: realisation *per case*, resolved to the MRP and pack size that were in force
at the time of the invoice, not today's values. Karthik Subramanian raised the reversal himself,
unprompted by the client side: "so my recommendation, and I am putting this one up today rather than
sitting on it — DIM_PRODUCT also goes SCD2."

The concrete cases that broke the SCD1 premise: a soap SKU had its pack size changed inside the year,
and a hair-oil SKU had its MRP revised twice in the same year. Under SCD1, "if the dim overwrites,
then the old invoice looks like it was sold at today's MRP, which it was not" — and the resulting
per-unit realisation figure "is wrong in a way that looks plausible... and nobody would catch it"
(Karthik Subramanian, `T-04`).

## Decision drivers

- D09 (Product Mix and Contribution) needs to resolve MRP and pack size as of the invoice date, not
  the current dimension state — the specific reporting requirement that broke the April premise.
- A wrongly-plausible number (realisation restated silently) is worse than an obviously-broken one,
  and SCD1 produces exactly that failure mode on this dimension.
- Side benefits surfaced in discussion: a delisted-then-relisted SKU (`ACTIVE_FLG` toggling) becomes
  visible as a dated version under SCD2, which is not visible today ("which we cannot see today at
  all," Shalini Iyer); the point at which a null `CATEGORY_CODE` gets filled in also becomes visible.
- `DIM_PRODUCT` is small (1,246 rows) relative to `DIM_CUSTOMER`, so the incremental load cost was
  expected — and was explicitly required — to be measured together with `DIM_CUSTOMER`'s, not treated
  as free because the table is small: "if we are doing this then measure the whole plan, not one
  interface in isolation" (Sneha Pillai, `T-04`).
- Farida Contractor's concern at this point was sequencing, not the change itself: converting two
  dimensions in the same release is a delivery risk, not a design objection — "I am not worried about
  product on its own, I am worried about adding two things in the same release." Ananya Krishnan
  separated the design question from the delivery-sequencing question on the record.

## Considered options

1. **Keep SCD1** (the April position). Rejected on the D09 evidence above.
2. **SCD2**, tracking `PACK_SIZE`, `MRP_AMT`, `BRAND_CODE`, `CATEGORY_CODE` and `UOM`. `SKU_DESC` is
   not tracked (cosmetic edits should not open a version); `ACTIVE_FLG` is not tracked (a status
   change belongs to the row's own already-open or already-closed version, not a new one). Chosen.

## Decision outcome

Chosen: **Option 2 — SCD2 on `DIM_PRODUCT`**, on the same standard as `DIM_CUSTOMER`. Approved by
Shalini Iyer at design sign-off (`T-05`, 06-May-2026): "Karthik is recommending SCD2 on DIM_PRODUCT as
well as DIM_CUSTOMER, Shalini has approved customer" / "Shalini, product" / "yes, same answer, yes."
Rajeev Menon, joining partway through, declined to weigh in on the technical merits: "it is a technical
call, I am not going to second-guess it, as long as it does not move the plan" — confirmed it would
not.

Because the reporting consequence — mid-year MRP and pack-size revisions restating a whole year's
realisation on that SKU under SCD1 — was judged the deciding factor, and it directly served the
Product Mix and Contribution dashboard's stated purpose.

### Consequences

- Good: A prior period resolves the MRP and pack size actually in force at the time, which is the
  point of the change (`DOC-04` §6).
- Good: Version churn is dominated by MRP revisions rather than pack-size changes — worth knowing when
  the dimension's growth projection is refreshed, since it grows faster than the member count alone
  would suggest (`DOC-04` §6).
- Bad: Two dimension conversions now land in the same release rather than one, which Farida
  Contractor flagged as a delivery risk distinct from the design decision itself; the required
  re-measurement action (`T-05` follow-ups) covers both dimensions together for exactly this reason.
- Neutral: Rows built before this conversion carry no meaningful version history and are not to be
  read as though they do (`DOC-04` §6, "Note").

## Evidence

| Claim | Source |
|---|---|
| Original SCD1 proposal and its reasoning | `/_sources/meetings/2026-04-14_architecture_review.txt` (T-04); see also `/decisions/20260414-dim-product-scd1-proposed.md` |
| Reversal driven by D09's requirement to resolve historic MRP/pack size; soap pack-size and hair-oil MRP examples | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Shalini Iyer's approval; Rajeev Menon's non-objection conditional on the plan not moving | `/_sources/meetings/2026-05-06_design_signoff.txt` (T-05) |
| Tracked attributes PACK_SIZE, MRP_AMT, BRAND_CODE, CATEGORY_CODE, UOM; SKU_DESC and ACTIVE_FLG not tracked; version churn dominated by MRP | `/_sources/docs/DOC-04_dimension_strategy.docx` §6, Appendix A ADR-003 |

## Follow-ups

- [ ] Ishaan Bhatt to rebuild `MAP_DIM_CUSTOMER` and `MAP_DIM_PRODUCT` for SCD2 on DEV and regenerate
      both load-window scenarios by 22-May-2026 (`T-05` action item AI-31).
- [ ] Farida Contractor to re-run the full load plan timing on DEV with both dimensions changed and
      circulate by 29-May-2026 — the full plan, not the interface in isolation (`T-05` action item
      AI-32).
- [ ] Karthik Subramanian to issue the dimension strategy note (`DOC-04`) recording both ADR-002 and
      ADR-003 by 11-May-2026 (`T-05` action item AI-30) — delivered on schedule.

## Related concepts

- [/concepts/tables/bcpl-edw-dim-product.md](/concepts/tables/bcpl-edw-dim-product.md)
- [/decisions/20260414-dim-product-scd1-proposed.md](/decisions/20260414-dim-product-scd1-proposed.md) — the position this record supersedes
- [/decisions/20260506-dim-customer-scd2.md](/decisions/20260506-dim-customer-scd2.md) — the companion SCD2 decision taken the same day, ADR-002

## Referenced by

- [Progress](/context/progress.md)
- [Design sign-off](/meetings/2026-05-06_design_signoff.md)
