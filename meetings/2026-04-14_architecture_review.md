---
type: meeting-note
title: Architecture review
description: Warehouse target model design decisions and variance root-cause investigation
tags:
- scd
- dimensions
- customer
- product
- date-key
- variance
- database-link
- timezone
sources:
- resource: /_sources/meetings/2026-04-14_architecture_review.vtt
  id: T-04
  last_modified: '2026-04-14'
generated:
  by: process:claude-haiku/meetings
  at: 2026-08-23 11:15:08+00:00
---


## Summary

The architecture review examined four pillars of the warehouse target model: fact grain, dimension conformance, and the root cause of scheme discount variances. The meeting eliminated the leading hypothesis (database link latency) and deferred the highest-risk dimension decision (customer SCD vs SCD1) pending performance measurement. Product dimension was decided as SCD1 (overwrite, no versioning), and the date dimension defect was confirmed as a UTC/IST mismatch, not a link problem.

Karthik presented the target model design notes sent on 8-Apr. Ani joined late from an ORION call. The meeting lasted 75 minutes and clarified three decision points: grain, whether customer should track history via effective dating, and why the initially-blamed database link is not the variance cause. By end of meeting, six action items were assigned to surface the data needed for the May sign-off meeting, including performance measurement of SCD2 load cost and clarification on whether existing OBIEE reports reference MRP values (which would break if customer versioning is adopted).

## Decisions referenced

- [/decisions/20260414-dim-product-scd1-proposed.md](/decisions/20260414-dim-product-scd1-proposed.md) — DIM_PRODUCT decided as SCD1 in this meeting; SKU attributes treated as effectively static, no pushback in the room.
- [/decisions/20260506-dim-customer-scd2.md](/decisions/20260506-dim-customer-scd2.md) — DIM_CUSTOMER SCD2 was raised here (Karthik proposed it against Farida's load-window concern) but **not decided at this meeting**; the decision itself was taken later, at the May design sign-off (T-05), once both the load-cost measurement and Farida's written position were in hand.
- [/concepts/variances/var-002-date-key-timezone.md](/concepts/variances/var-002-date-key-timezone.md) — VAR-002 root cause (DATE_KEY derived from a UTC timestamp instead of the IST invoice date) confirmed in this meeting; database-link hypothesis eliminated as the cause.

## Action items

| # | Description | Owner | Due |
|---|---|---|---|
| AI-01 | Build customer dimension with effective dating on DEV and measure load cost against a real night (not a sample). Send timings to Farida. | Karthik | 24-Apr-2026 |
| AI-02 | Send load window position on SCD2 customer dimension separately in writing. | Farida | This week (by 18-Apr) |
| AI-03 | Export the fact invoice line mapping (`MAP_FACT_INVOICE_LINE`) from ODI and send to Karthik. | Farida | Tomorrow (15-Apr) |
| AI-04 | Sequence the date key change offline with Farida. Not this week; next week. | Ishaan + Farida | Week of 21-Apr |
| AI-05 | Check the Despatch Analysis report in OBIEE RPD to confirm it uses `INVOICE_DT` (not `CREATED_TS`) for the date key. Revert to Priya with finding. | Priya | [No date given; Sneha to mail reminder] |
| AI-06 | Draft two DQ rules: (1) date key month equals invoice date month, 100% threshold; (2) one current row per customer, uniqueness, 100% threshold. Add to framework doc. | Neha | End of next week (by 25-Apr) |
| AI-07 | Write up the product dimension decision (SCD1) with reasoning. | Karthik | [No date given] |
| AI-08 | Variance investigation: database link hypothesis eliminated, root cause not identified. Investigation continuing. Review status at May sign-off. | Karthik | Review: May sign-off session |

## Open questions

**Customer dimension SCD choice.** SCD1 (overwrite) is simpler and faster, aligns with what Sales Ops expects ("which territory is this distributor today?"), but causes history restatement on territory reassignment. SCD2 (versioned) is more correct (finance asks "what actually happened?"), but add processing cost on realignment nights. Priya flagged a downstream risk: if customer versioning is adopted, existing OBIEE reports (41 in catalogue, 12 actively used) will break because they join on customer ID and will double-count when two versions have `CURRENT_FLG='Y'`. Karthik said decommissioning the legacy layer is a separate conversation, but Priya raised it for the tracker. **Unresolved: will the business accept the load window cost, and do we have capacity to handle OBIEE layer migration if we adopt SCD2?**

**Variance root cause.** Database link was blamed at T-03 (24-Mar variance findings meeting) but Farida's AWR shows 4.1 minutes total wait across the entire load (1.2% of elapsed time, 38ms average per round trip). The link is "slow but not wrong"—latency makes a load slow, not the data incorrect. Ishaan's correlation analysis (comparing fast nights to slow nights) showed the variance is flat; no fast/slow relationship to variance magnitude. Ani agreed the link is genuinely slow but said "slow is not wrong"; he suggested fixing it separately on performance merit. Three remaining hypotheses: (1) extract logic (incremental predicate on `LAST_UPD_DT` minus one day), (2) fact write logic (IKM Oracle Control Append has no guard against re-inserted rows; insert-only, no merge), (3) source data issue (Ani said data quality on `CUSTOMER_TERRITORY_HIST` is poor, source history not maintained). Karthik said he cannot rank likelihood without more data. Farida is confident in her extract and Control-M logic; she offered to send the ODI mapping export. **Unresolved: which of the three (or combination) is causing exact duplicates of entire invoice lines?**

**Scheme master count.** The master has 5 active schemes, but Vikram and Sales Ops talk about 30+ schemes. Karthik flagged: either the master is incomplete or the business is using "scheme" to mean something else (possibly "slabs" within a scheme). Priya to ask, but Ananya said not to ask Vikram this week (travelling); he will send multiple spreadsheets anyway. **Unresolved: should the 5 be 5 or are there unlisted schemes, or is this a vocabulary gap?**

**MRP reporting breakage risk.** Priya noted there is one OBIEE analysis showing MRP vs. realisation. Karthik said the fact carries actual `UNIT_PRICE` and `GROSS_AMOUNT` (frozen on the line), so MRP changes do not affect historical invoices unless someone pulls MRP from the dimension. Priya to check whether that report is actually used; if so, SCD1 is safer. Ananya said this is parked for now. **Unresolved: is the MRP vs. realization report active and relied on?**

**OBIEE decommission timing.** If customer versioning is adopted, OBIEE queries will break (join to customer ID, get two current rows per territory change, double-count). Priya flagged that the catalogue still holds 41 reports (12 used, 29 unused but not deleted). **Unresolved: how long do we maintain OBIEE if customer model changes? The 90-day post-go-live decommission window may be too tight.**

**Invoice line archive.** Ani noted that `INVOICE_LINE` table contains data from 2016 onwards only; anything before 2016 sits in an archive table that is not extracted and has not been touched since 2016. Any request for a 10-year trend will fail. Ishaan to document in the mapping sheet. **No action needed; noted as scope boundary.**

---

## Terminology notes

The transcript uses these terms interchangeably; see /context/glossary.md for canonical usage:

- "SCD2", "type two" (Neha said it explicitly because "half the room says it differently"), "versioned dimension" — all mean slowly-changing dimension type 2 with effective dating.
- "Interface" (Farida's term, habit from ODI 11g) = ODI mapping. Karthik says "mapping".
- "Scheme" vs. "secondary scheme" vs. "TPR" — business vocabulary is loose; Karthik flagged this.
- "Distributor" (most common), "party" (Ani's term from ORION), "stockist" (Vikram's term), "channel partner" (Klarissen term) — all refer to the same entity in the sales chain. See /context/glossary.md.
- "Scheme discount" (standard), "trade promotion accrual" (Shalini), "secondary scheme" (Farida), "TPR" (Vikram, loose) — all refer to promotional discounts.

**ASR transcription notes:**

- "Anirood" = Aniruddh Deshpande (meeting platform consistently misheard)
- "O'ryan" = ORION (auto-transcriber capitalized incorrectly)
- "Odie" = ODI (Oracle Data Integrator)
- "Buddy" = Baddi (plant name; audio likely unclear)
- "Rp d" = RPD (Repository)

---

## Next steps

Decisions to be finalized at the design sign-off meeting (T-05, week of 06-May):
1. Customer dimension SCD choice (pending Karthik's load measurement and Farida's written position)
2. Variance root-cause investigation status (pending further dig into extract, append, or source data)

Formal ADR (Architecture Decision Record) to be written for product dimension SCD1 decision, possibly others if finalized in May.
## Referenced by

- [Knowledge Base Index](/index.md)

