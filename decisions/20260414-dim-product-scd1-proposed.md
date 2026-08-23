---
type: decision
title: "DIM_PRODUCT proposed as SCD1 (overwrite, no history)"
description: At the architecture review, Karthik Subramanian proposed DIM_PRODUCT as SCD1 rather than SCD2, on the grounds that SKU attributes rarely change and unit price/gross amount are frozen on the fact row regardless. Agreed in the room with no objection. Superseded three weeks later.
tags:
  - decision
  - dim-product
  - scd1
  - scd2
  - product-mix
  - mrp
status: superseded
superseded_by: /decisions/20260506-dim-product-scd2.md
generated:
  by: process:claude-sonnet/decisions
  at: 2026-08-23T11:03:46Z
sources:
  - resource: /_sources/meetings/2026-04-14_architecture_review.txt
    id: T-04
    title: Architecture review
    author: Karthik Subramanian
    last_modified: "2026-04-14"
updated: "2026-04-14"
---

# DIM_PRODUCT proposed as SCD1 (overwrite, no history)

**Deciders:** Karthik Subramanian (proposer), Ananya Krishnan, Farida Contractor, Aniruddh Deshpande,
Ishaan Bhatt, Priya Nair, Neha Gokhale, Sneha Pillai (attendees, `T-04`). No client business sponsor
(Shalini Iyer, Rajeev Menon) was present at `T-04`; this was treated as a technical call.

## Context and problem statement

Coming out of the `DIM_CUSTOMER` SCD2 discussion earlier in the same session, Karthik Subramanian
proposed the opposite treatment for `DIM_PRODUCT`: "product is much simpler, and my proposal here is
the opposite — I am proposing SCD1 for DIM_PRODUCT, overwrite." His stated reasoning: SKU attributes
"basically do not change" — a SKU is created with a brand, category, pack size, UOM, MRP and HSN code
and sits that way for its life; the only thing that changes routinely is whether it is active. Versioning
every SKU would produce "a dimension full of rows that are identical to the previous row" for no
benefit.

Priya Nair raised a specific concern: MRP is revised periodically (a soap SKU had been revised
recently, requiring an explanation to Finance), and under SCD1 old invoices would show the current MRP
if MRP were read from the dimension. Karthik Subramanian's answer: unit price and gross amount are
frozen on the fact row at load time and are never re-derived from the dimension, so the fact — not the
dimension — is the source of realisation history. Ishaan Bhatt separately noted that overwriting would
lose the audit trail on the 37 SKUs with a null `CATEGORY_CODE` once somebody fills the value in; Neha
Gokhale's view was that this belongs in the data-quality layer, not as a reason to version the
dimension.

## Decision drivers

- SKU population is small (1,246 rows, 862 active) and, per Karthik Subramanian, will stay small:
  "it is tiny today and it will be tiny in 2030."
- Realisation and pricing history are believed to live entirely on the fact row (unit price, gross
  amount), not on the dimension, so SCD2 on `DIM_PRODUCT` was seen as solving a problem the fact table
  already solves.
- SCD1 is the simpler build: "from the load side SCD1 is obviously easier, I have no objection"
  (Farida Contractor, `T-04`).
- The null-`CATEGORY_CODE` audit-trail concern was judged better handled in the data-quality layer
  than by versioning the whole dimension (Neha Gokhale, `T-04`).

## Considered options

1. **SCD2** on `DIM_PRODUCT`, mirroring `DIM_CUSTOMER`. Not pursued at this session.
2. **SCD1** on `DIM_PRODUCT`. Chosen.

## Decision outcome

Chosen: **SCD1 (overwrite)**. "So, SCD1 for product, unless somebody has a strong objection" —
no objection raised in the room. Recorded with the explicit caveat that it could change: "I will write
it up as SCD1 for product and put the reasoning in, and if it turns out later that we need the
history we will change it, it is a smaller change than the customer one" (Karthik Subramanian, `T-04`).

### Consequences

- Good: Simpler build and load, matching the load-side preference expressed on the record.
- Bad (realised three weeks later): the premise that pricing history lives entirely on the fact turned
  out not to cover the Product Mix and Contribution dashboard's requirement to resolve *pack size and
  MRP as they stood at the time of a historic invoice*, not merely unit price. See
  [/decisions/20260506-dim-product-scd2.md](/decisions/20260506-dim-product-scd2.md).
- Neutral: This position was explicitly left open to revision rather than presented as final — "product
  is decided... customer is open" was how Ananya Krishnan summarised the state of play at the end of
  `T-04`, meaning DIM_PRODUCT was, in the room's own language, the more settled of the two even though
  it did not hold.

## Evidence

| Claim | Source |
|---|---|
| Karthik Subramanian's SCD1 proposal and reasoning (SKU attributes rarely change, fact carries frozen price) | `/_sources/meetings/2026-04-14_architecture_review.txt` (T-04) |
| Priya Nair's MRP concern, answered by pointing to the fact row | `/_sources/meetings/2026-04-14_architecture_review.txt` (T-04) |
| No objection from Farida Contractor or Aniruddh Deshpande; agreed in the room with a stated caveat it could be revisited | `/_sources/meetings/2026-04-14_architecture_review.txt` (T-04) |

## Follow-ups

- [x] Karthik Subramanian to write up the SCD1 reasoning formally — superseded before being written up;
      see [/decisions/20260506-dim-product-scd2.md](/decisions/20260506-dim-product-scd2.md).

## Related concepts

- [/concepts/tables/bcpl-edw-dim-product.md](/concepts/tables/bcpl-edw-dim-product.md)
- [/decisions/20260506-dim-product-scd2.md](/decisions/20260506-dim-product-scd2.md) — supersedes this record, ADR-003
