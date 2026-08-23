---
type: meeting-note
title: Data quality readout
description: First data quality assessment readout covering 14 OLTP and warehouse
  tables, 24 rules, with nine failures and aggregate score of 71/100.
tags:
- data quality assessment
- DQ-R rules
- rule failures
- uniqueness
- consistency
- validity
- completeness
- timeliness
- VAR-004
- VAR-006
- VAR-007
sources:
- resource: /_sources/meetings/2026-06-18_dq_readout.vtt
  id: T-06
  title: Data quality readout
  last_modified: '2026-06-18'
generated:
  by: process:claude-haiku/meetings
  at: 2026-08-23 11:14:53+00:00
---


## Summary

Neha Gokhale, Northlane Analytics' Data Quality Lead, walked through the first data quality assessment covering the period 04-May to 19-Jun-2026. The team profiled fourteen tables across ORION (seven) and the warehouse (seven), executing twenty-four DQ rules across five dimensions: completeness, validity, consistency, uniqueness, and timeliness.

Nine of twenty-four rules are failing. The aggregate score is 71/100. Neha emphasised that this is a baseline, not a trend—a second run will establish whether movement is happening. By dimension, scores are: completeness 68, validity 74, consistency 66, uniqueness 79, timeliness 91. Neha noted that consistency is the dimension where "most of the items that have a rupee number against them" cluster, and that materiality—not percentage—determines which failures matter. A rule can fail at 99.9% and still be the most serious one on the list.

All profiling numbers come from the 31-May-2026 run. Two fixes (DELETE_FLAG filter, DATE_KEY) were deployed after that on 03-Jun, so "some of these will look better next time" but Neha chose to report the actual run rather than a number she adjusted mentally.

Shalini Iyer (Head of Finance Systems) joined late from the closing call and immediately positioned her constraint: "whatever we discuss today, i need to be able to tie it back to the trial balance. If it is a rule failure that does not move a number i will look at it, but it is not my priority this month." Neha agreed to flag which items carry rupee impact and which do not.

## Variances referenced

Everything below is a variance concept, not a decision record — no decision was taken on any of
these in this meeting; each was surfaced or advanced by a DQ rule failure.

- [/concepts/variances/var-004-scd2-territory-reassignment.md](/concepts/variances/var-004-scd2-territory-reassignment.md) — surfaced by DQ-R-07 and DQ-R-23 (dual CURRENT_FLG='Y' rows on DIM_CUSTOMER after territory reassignment); Farida owns the effective-dating fix, committed 03-Jul-2026.

- [/concepts/variances/var-006-tax-rate-retroactive.md](/concepts/variances/var-006-tax-rate-retroactive.md) — surfaced by DQ-R-15 (validity, no effective dating on TAX_RATE_MASTER); Neha to raise VAR-006 with a remediation proposal by 24-Jun.

- [/concepts/variances/var-007-late-arriving-sku-unknown-member.md](/concepts/variances/var-007-late-arriving-sku-unknown-member.md) — surfaced by DQ-R-04 (completeness, no late-arriving dimension handling); to be raised as VAR-007 and assigned to reporting workstream by 24-Jun.

- [/concepts/variances/var-005-credit-notes-absent.md](/concepts/variances/var-005-credit-notes-absent.md) — raised by Shalini on credit notes; Ananya confirmed the open VAR-005, Shalini owner; Shalini to re-check sizing against trial balance by 10-Jul.

## Action items

**AI-37** | Neha | Circulate DQ profiling workbook and rule set with the deck | 19-Jun-2026 (tomorrow at latest)

**AI-38** | Meghna | Re-run profiling on DIM_CUSTOMER after June release and confirm CURRENT_FLG='Y' count | 26-Jun-2026

**AI-39** | Farida | Fix effective dating on DIM_CUSTOMER SCD2 so only one row carries CURRENT_FLG='Y' | 03-Jul-2026 (cannot get to it before that; commit includes proper close-out date, not SYSDATE)

**AI-40** | Ananya | Reply to Vikram Sethi with customer-level detail on the 18 customers with dual current rows; copy Shalini; do not send workbook, just the 18 names | 19-Jun-2026 (today if time permits)

**AI-41** | Neha | Propose validity rule for GSTIN format on DIM_CUSTOMER for next rule set, with threshold 100% | 10-Jul-2026

**AI-42** | Ishaan | Confirm how many ORDER_LINE rows do not resolve to ORDER_HEADER and whether D06 (fill rate report) is affected; check whether issue is in landing, fact, or incremental window timing | 26-Jun-2026

**AI-43** | Neha | Raise VAR-006 (tax rate master effective dating) with remediation option on tracker | 24-Jun-2026

**AI-44** | Ananya | Raise VAR-007 (late-arriving dimensions) and assign to reporting workstream | 24-Jun-2026

**AI-45** | Shalini | Re-check credit note sizing (VAR-005) against trial balance period by period | 10-Jul-2026

## Open questions

**Vikram Sethi's contention.** Vikram sent three mails this morning (the third a forward of the second) saying: "eighteen stockist[s] cannot be the full picture, in north itself i am seeing more than that where the billing is not matching" and "also the tpr amount for nimbu[a] south is still wrong". Neha asked Ananya to clarify which rule he was challenging, noting "if he is saying the eighteen is understated, that is rule seven and i will go and re run it today; if he is saying a value in a report does not match his sheet, that is a reconciliation, and it is a different conversation and it is not mine." Shalini interjected: "it is the second one. It is always the second one." Ishaan then observed that Vikram is (a) conflating secondary sales with primary sales; (b) not filtering cancelled lines out of his own extract, so "his number will always be higher than ours, structurally, whatever we do". Neha confirmed: "the eighteen is the eighteen. It is a count of customer ids carrying two current rows in the dim, it is not a count of everything that is wrong in the world." The issue is deferred but Ananya will send Vikram the customer-level detail by name to close it down before steering committee.

**GSTIN format validation.** Shalini raised that customers are frequently rejected by downstream systems because GSTIN values are the wrong length or contain non-numeric characters where digits are required. Neha confirmed no rule exists for it in the current twenty-four rules because "it did not come up in the requirement session, and i write rules against what has been agreed, otherwise the rule set becomes my opinion". Shalini asked for it in the next set, not in six months. Meghna added that GSTIN was also not profiled in the source-side tables, so there is no baseline null rate or format-failure count. The action is for Neha to propose a validity rule with a 100% threshold by 10-Jul-2026, and Shalini committed to define what is acceptable (she said: "a hundred percent is acceptable").

**Order line orphans.** Meghna found order lines in the warehouse that do not resolve to a header. Priya asked if this affects D06 (fill rate report); Ishaan said "depends which side is missing, if the line is there and the header is not you get one answer, other way round you get another". Shalini asked how many. Meghna said the exact count is in the failures-by-table tab but she wants to check it twice before stating it. Neha backed her: "i am not going to quote a number that meghna has not signed off". Farida then noted that the foreign key from ORDER_HEADER to CUSTOMER was disabled in 2020 during master data cleanup and never put back, so there is no enforcement on that side. Ishaan said the ORDER_LINE to ORDER_HEADER constraint is still active, "so it should not be possible in the source at all". Ishaan committed to check whether the orphaning is happening in the landing or the fact, or if it is an incremental-window timing issue (header and line in same extract, so he later said "ignore my last, i will check it properly, i do not want to guess on the call"). Farida also noted the fact interface has no flow control, so ODI is not writing rejects to the error table—"we cannot see rejects, we can only see what is missing afterwards, which is a much worse position to be in".

**Unit of measure duplication.** Ishaan noted that ORDER_LINE quantities are in whatever UOM the order was placed in, not normalised to a base; conversion happens downstream. Priya recalled this caused monthly arguments: "which is why the cases and the eaches never agree, we used to argue about this every month". The product-dim lookup that does the conversion is not deduplicated—there is no unique constraint. Where duplicates exist, the lookup comes back with more than one row, and "the mapping just takes whichever one comes back first", which is non-deterministic and can flip between two values across loads. Each flip creates a spurious new version in DIM_PRODUCT via SCD2. Meghna said it is "a handful of skus", mostly pack-size products (kg, litres) not eaches, in the sample-failures tab. Shalini asked if it is moving a number. Neha said "not materially, no. It is low priority and i am saying that on the record so nobody comes back to me in september". Shalini said to park it. But Priya flagged that for D09 (Product Mix and Contribution) it will matter eventually because pack size sits on the version, so the report will show two pack sizes for one item. Ishaan agreed: "yeah for that report it will matter eventually. Eventually yes, not this month."

**Distributor scorecard dual totals.** Priya sent Ishaan a screenshot of an issue on the Distributor Scorecard (D03) showing two totals on the same page. Ishaan responded "i think it is the same eighteen thing honestly, it is the same shape", suggesting it relates to the DIM_CUSTOMER dual-current-flag issue. Priya said "that is what i thought also, because it was only three or four distributors". Neha asked to park this discussion to preserve time. Ishaan said he would look at the screenshot after the call.

**Missing 2016-2020 data in warehouse.** Priya asked whether the fact only goes back to 2021. Ishaan confirmed: "april twenty twenty one onwards in the fact, the source has from twenty sixteen". Priya then observed: "because in obie we always had this thing where the older years just were not there and nobody could say why". Ishaan: "yep, that is why". (Note: OBIEE transcript may have ASR garbling here as "obie" for "OBIEE".)

**credit notes variance sizing uncertainty.** Shalini expects VAR-005 to be larger than the 2.4 Cr unvalidated estimate. She told Ananya "shall we take it away and come back with something firmer" but then said "i will do it myself. Give me till the tenth of july and i will tie it back to the trial balance properly, period by period". Neha clarified that the 2.4 Cr figure is not in today's DQ presentation and nothing depends on it—"it is a variance line, it is not a DQ line, they are different lists". Shalini: "i understand the difference, i just want one of them to be right".
## Referenced by

- [Knowledge Base Index](/index.md)

