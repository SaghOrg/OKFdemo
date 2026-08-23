---
type: meeting-note
title: Design sign-off
description: Design decisions on dimension strategy (SCD2 for customer and product), root cause confirmation for VAR-003 scheme discount, and quick status on VAR-001 and VAR-002.
tags:
  - dimension-design
  - SCD2
  - var-003
  - var-001
  - var-002
  - scheme-discount
  - invoice-date
  - load-window
sources:
  - resource: /_sources/meetings/2026-05-06_design_signoff.vtt
    id: T-05
    title: Design sign-off meeting transcript
    last_modified: "2026-05-06"
generated:
  by: process:claude-haiku/meetings
  at: 2026-08-23T11:15:05Z
---

## Summary

Design sign-off meeting on 06-May-2026, 15:30–16:30 IST, chaired by Ananya Krishnan. The meeting resulted in three major design decisions and confirmed root cause on VAR-003.

The agenda covered: (1) dimension strategy — whether to implement SCD2 (Slowly Changing Dimension Type 2) on DIM_CUSTOMER and DIM_PRODUCT; (2) VAR-003 scheme discount root cause and the remediation approach; (3) quick status updates on VAR-001 (delete flag) and VAR-002 (date key).

Shalini Iyer (Finance) approved both dimension changes on the grounds of audit integrity and data accuracy. The team confirmed that the root cause of VAR-003 lies in the ORION finance procedure P_RECALC_SCHEME_DISCOUNT, not in the ETL. The approved remediation rebuilds MAP_FACT_INVOICE_LINE as a key-based merge rather than an append, with deployment scheduled for R2026.09 (30-Sep-2026).

## Decisions referenced

- [/decisions/20260506-dim-customer-scd2.md](/decisions/20260506-dim-customer-scd2.md) — ADR-002. Approval to implement SCD2 on DIM_CUSTOMER to preserve distributor territory history at invoice date.
- [/decisions/20260506-dim-product-scd2.md](/decisions/20260506-dim-product-scd2.md) — ADR-003. Approval to implement SCD2 on DIM_PRODUCT to preserve pack size and MRP at invoice date for contribution analysis.
- [/decisions/20260506-var003-remediation-key-based-merge.md](/decisions/20260506-var003-remediation-key-based-merge.md) — ADR-004. Approach to remediate VAR-003 by rebuilding MAP_FACT_INVOICE_LINE with key-based merge on invoice_line_id, leaving ORION finance procedure unchanged until R2026.09.
- [/decisions/20260506-var002-date-key-fix.md](/decisions/20260506-var002-date-key-fix.md) — Date key derivation fix (VAR-002) using INVOICE_DT instead of CREATED_TS.

## Action items

- **AI-30** | Karthik to write ADR-002 and ADR-003 (dimension strategy note) | Karthik | 11-May
- **AI-31** | Ishaan to rebuild MAP_DIM_CUSTOMER and MAP_DIM_PRODUCT for SCD2 on dev and regenerate both scenarios | Ishaan | 22-May
- **AI-32** | Farida to re-run full load plan timing on dev with both dimensions changed and circulate | Farida | 29-May
- **AI-33** | Karthik to write ADR-004 (VAR-003 remediation approach) | Karthik | 11-May
- **AI-34** | Ani to confirm invoice_line_id is unique and never reused (including archive tables) | Aniruddh | 13-May
- **AI-35** | Shalini to sign the dimension strategy note once circulated | Shalini | 15-May
- **AI-36** | Sneha to update variance tracker for VAR-003 root cause and status | Sneha | 08-May

## Open questions

**Dimension load window — Farida's risk flag.** Farida Contractor raised concern that adding SCD2 logic to both DIM_CUSTOMER and DIM_PRODUCT in the same release could impact the nightly load window, especially on month-end nights when "the window is the window" and no margin exists. She stated this is not a blocking issue ("no i am not blocking it") but a documented risk that stays on the risk list. She requested that the full load plan be re-measured on dev after Ishaan rebuilds both dimensions (AI-32) to confirm the impact remains within SLA. If the measured number comes back worse than the model, the team agreed to revisit the design. Ananya committed to record this risk; Farida confirmed the re-measurement must cover the whole plan, not just one interface in isolation.

**Stored procedure walkthrough — Shalini's technical review pending.** Karthik Subramanian wrote up the VAR-003 root cause as a nine-page technical document dated 28-Apr-2026 (with covering mail on 23-Apr), describing how the P_RECALC_SCHEME_DISCOUNT procedure in FIN_PROD.PKG_MONTH_END rewrites scheme discount amounts post-invoice. Shalini said she would "read the first page" and review Ani's notes on the same thread, then come back with questions. Karthik offered invoice-by-invoice reconciliation walks once the fix deploys.

**Invoice-date boundary movement.** When the DATE_KEY fix (VAR-002, keying off INVOICE_DT instead of CREATED_TS) deploys in June, Shalini's monthly numbers will shift at month boundaries for a small number of invoices (affecting ~90 lakh across FY26). Shalini said she will need to explain this to her stakeholders and requested invoice-level detail in advance. Karthik committed to provide the walk.

**VAR-003 timeline — open until September.** Shalini asked "does this mean my monthly numbers will move when the fix goes in?" and was told the scheme discount column stays incorrect in the warehouse until R2026.09 (30-Sep-2026) when the MAP_FACT_INVOICE_LINE merge deploys. In the interim, Shalini will continue using her shadow method to calculate the true scheme discount number. She stated "i do not love it but i understand it." The variance remains open on the tracker.

**Archive table invoice_line_id risk.** Ani flagged that whilst invoice_line_id is unique and never reused in the production tables, the archive table "is a different story" — IDs may overlap. He asked the team to check before committing to a key-based merge, saying "somebody one day will say let us load history from archive and then you will find the ids are overlapping." Karthik accepted this as an action (AI-34) for Ani to confirm by 13-May.

**Scenario regeneration in ODI.** Farida insisted that both dimension scenarios be regenerated properly in ODI, not patched, after Ishaan's rebuild. She said "last time somebody regenerated only one and then control em was calling the old version," and she wanted that mistake prevented. Ishaan agreed.

**SCD2 terminology.** The transcript shows ASR errors: "Oreo" for ORION, "Annie" for Ani, "SED 2" for SCD2, and numbers as "core" and "lac" instead of crore and lakh. Shalini repeatedly asked Karthik to explain what "SCD2" means because she never remembers which number is which; Karthik explained "SCD2 is the one that keeps the old row." Ishaan later added that side benefits include visibility into product category fill-in dates and SKU delisting/relisting periods.

**Trade promotion accrual vs. scheme discount vocabulary.** Shalini used "trade promotion accrual" throughout when referring to scheme discounts; the transcript also shows "secondary scheme" in context of sales ops. The mapping remains consistent: all three terms refer to the discount component on invoice lines. See [/context/glossary.md](/context/glossary.md).

**Ani's recognition.** Ananya explicitly acknowledged on the recording that "Ani found this, not us," referring to the discovery of P_RECALC_SCHEME_DISCOUNT as the root cause of VAR-003. Ani deflected credit ("it is my system, i should have found it earlier only") but Karthik noted that Ani identified the discrepancy in a week while Karthik had been staring at the mapping for a month.

**Rajeev's early exit and endorsement.** Rajeev Menon joined at 15:52 (partway through DIM_CUSTOMER discussion). Ananya summarized DIM_CUSTOMER SCD2 decision in 30 seconds; Rajeev replied "that is what shalini wanted" and "if shalini is happy i am happy" and "let us not boil the ocean on this one." He did not request technical detail. On VAR-003, he asked "then why is it on our tracker" if it is a finance problem, was told "because it is our number that is wrong at the end of it," and accepted it. He confirmed "do not touch finance" and requested the current variance amount (which Sneha committed to send from the tracker). His closing remark: "good meeting, this is the first one where we actually decided something."

