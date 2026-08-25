---
type: meeting-note
title: OLTP discovery with Ani
description: Detailed walkthrough of ORION source system architecture, table structures,
  audit columns, and data quality constraints. Ani provided institutional knowledge
  about the order-to-cash system built in 2009 and discovered several data issues
  requiring investigation.
tags:
- OLTP
- ORION
- source discovery
- customer master
- invoice
- order
- scheme
- data quality
- audit columns
- delete flag
- SCD2
sources:
- resource: /_sources/meetings/2026-03-03_oltp_discovery_ani.vtt
  id: T-02
  last_modified: '2026-03-03'
generated:
  by: process:claude-haiku/meetings
  at: "2026-08-23T11:15:05Z"
---


## Summary

Karthik Subramanian led a 90-minute discovery session with Aniruddh Deshpande (Ani), the Senior Oracle DBA at BCPL, to understand the ORION source system table structures, audit column patterns, and post-write row update mechanisms. The team walked through the order-to-cash tables (customer, SKU master, order, invoice, scheme master) and the finance-side tax rate table.

Ani is the institutional memory for the system. ORION was built in 2009 by Sahyadri Softech Pvt Ltd and went live that year. Sahyadri disengaged in 2014, and BCPL has been maintaining it since. No contact with the original vendor team remains. The team attempted a similar discovery in 2017 with no output, which Ani noted wryly: "They sat for two weeks, asked exactly the same questions, nothing came out of it."

Several data quality constraints and quirks were surfaced that will affect warehouse design:

1. **Customer territory changes are edited in-place.** The `CUSTOMER_TERRITORY_HIST` table has no primary key and no unique constraint. When a distributor moves territories, somebody enters wrong data, somebody corrects it by editing the row itself (not by appending a new row). This leaves overlapping rows with two open effective dates. Ani acknowledged "some parties are having overlapping rows, yes" but declined to give a number on the call.

2. **Delete flag has three values.** Most rows have `DELETE_FLAG = 'N'` (live) or `'Y'` (logically deleted), but old rows (before a certain unspecified date) have `DELETE_FLAG = null`. Any query that filters on `DELETE_FLAG = 'N'` silently loses those rows. The correct predicate is `NVL(DELETE_FLAG, 'N') = 'N'`.

3. **FIN_PROD schema has UPDATE grant on OMS_PROD.INVOICE_LINE** since 2014. This has never been reviewed. Ani confirmed it is sitting there in the grants.

4. **No scheme calculation logic documentation.** Scheme discount calculation changed in 2014 (slab handling moved from per-invoice to per-period). Ani made a sheet `scheme_calc_logic_2014.xls` at the time, which he will look for. He acknowledged "even after 2014 also some things changed," so the sheet is at best half correct.

5. **Brand-to-plant mapping is implicit in reports, not stored.** Priya noted that the OBIEE Despatch report splits by plant, derived from brand code (one brand is made in one plant). Karthik observed this is a modelling assumption sitting inside a report: "if that ever changes the report is silently wrong." Ani agreed but noted that change would be caught eventually: "everything in this system somebody noticed because the number moved. Nobody noticed because a validation failed."

6. **Invoice line table is large and archived.** Currently holds 61-62 million rows from April 2016 onward. Data before 2016 is in `INVOICE_LINE_ARCHIVE`, which has not been touched since it was cut off. The archive is missing the `DELETE_FLAG` column. Archive extraction is not in current scope.

7. **Nashik plant conversion was messy.** When the Nashik plant came onto the system, it was despatching but under the wrong depot code (old Bhiwandi) for nearly two months. Sales noticed because the west number went up and north went down. Ani got calls at 11pm. The plant has two production lines with different despatch timings. At month-end the second line invoices very late. The exact cutoff time needs confirmation from plant IT.

The team confirmed the nightly load shape: starts 01:00 IST, runs ~58 minutes average, SLA is 05:30 IST (plenty of headroom on normal nights, different story on month-end).

Farida confirmed that staging tables are full loads or full-day-window incremental extracts (on `last_upd_dt`, no CDC anywhere). The `CUSTOMER_TERRITORY_HIST` is a full nightly reload, which means any mess in the source comes across as-is.

Priya provided context on the reporting layer. OBIEE RPD was last modified in 2019. There are 41 catalogue reports, of which about 12 are actually used. She will send the exact list.

## Decisions referenced

- See decision records as they are written for: order-to-cash table structures, delete flag handling, SCD2 approach for dimension changes, inclusion/exclusion of archive tables.

## Action items

| ID | Description | Owner | Due date |
|---|---|---|---|
| AI-08 | Look for ORION Functional Spec 2009 (from Sahyadri Softech); stored on old drive, no longer accessible | Ani | 12-Mar (chase on 12th, do not wait for 13th) |
| AI-09 | Circulate schema notes for OMS_PROD and FIN_PROD tables, including delete flag predicate and audit column details | Ani | 09-Mar |
| AI-10 | Profile `DELETE_FLAG` values on `INVOICE_HEADER` and `INVOICE_LINE` to quantify rows with null/Y/N | Ishaan | 12-Mar |
| AI-11 | Resend row count for `INVOICE_LINE` staging table (both source count and landing table count, with dates); confirm which column each extract uses for date predicate | Farida | 10-Mar |
| AI-12 | Send list of OBIEE reports actually in use (said to be ~12 of 41 in catalogue) | Priya | 11-Mar |
| AI-13 | Circulate the open question list to the team | Karthik | 13-Mar |
| (untracked) | Count overlapping rows in `CUSTOMER_TERRITORY_HIST` (run in evening after 19:00 IST only, no daytime counts) | Ishaan | (evening, no date specified) |
| (untracked) | Check Nashik plant despatch cut-off times for line 2 at month-end with plant IT contact | Ishaan | (no date specified) |

Ishaan will start profiling the delete flag tonight, then count territory overlaps. Karthik asked for raw numbers, not a summary.

## Open questions

- **Which rows have null delete flag?** Ani said "old" but declined to specify a date on the call: "I do not want to give you a date on the call." Counts will come from AI-10.
- **Character encoding issues in party names.** Around 2019 (Ani was vague: "2018 end, 2019, I do not remember exactly the month"), the platform was migrated and character set changed. Most junk was fixed, but "some rows are still, uh, I will not say fixed." Some old party names still have question marks. Ani noted these rows will have `CREATED_BY = 'APPS'` (the migrated data marker).
- **Exact despatch cutoff for Nashik line 2.** Ani: "late, I do not want to guess. You ask the plant IT people, they will tell you exactly." This needs to be understood for month-end cutover planning.
- **What batch jobs or scheduled stored procedures update rows after creation?** Ani said there are housekeeping procs that "clean things up" (marking, tidying), but those are in a different Control-M folder owned by the ops team. He has not looked at that folder "in a long time" and cannot give exact timing. "Ask the ops people, they will tell you exactly."
- **How was the foreign key constraint on ORDER_HEADER→CUSTOMER disabled?** Ani said it was disabled "during the master data cleanup, some years back" and "was disabled and never enabled back." The constraint is commented out in the DDL. No documentation of why or when.
- **Scheme calculation.** The 2014 change moved slab calculation from per-invoice to per-period, but "after 2014 also some things changed." The historic sheet is incomplete.
- **Scheme code reuse.** Priya noted that scheme codes are reused, so renaming or recoding a scheme changes the grouping on historical reports without warning (the scheme ID on a line stays the same, but the scheme master name can change, and if they reuse the code for a new scheme entirely, historical reports group it with the new scheme).
- **Scheme validity window closure.** If `VALID_TO_DT` is updated on `SCHEME_MASTER` after an invoice line has already been created, the line still points at the old scheme ID, and a lookup on validity can fail. What happens then depends on application logic.
- **Late-arriving SKUs.** Ishaan asked about sequencing: if a new SKU is created and an invoice for it is raised the same day, when does it appear in the data? Ani said "sequencing is the product team problem, not mine." The question is parked for the dimension work.
- **Category null handling inconsistency.** `SKU_MASTER.CATEGORY_CD` has about 30-35 null rows (no NOT NULL constraint). OBIEE reports handle nulls inconsistently: one report has a CASE statement treating them as "Others", other reports show blank. This needs a consistent warehouse rule.

Priya also raised a question about "dealer" vs "distributor" in the OBIEE reports. The source `CUST_TYPE` has distributor, modern trade, institutional—no dealer. Someone in a report must be deriving dealer from `CUST_CODE`. Priya will check the analysis definition; Karthik parked it for later.

The team noted that the plant-to-brand derivation in the OBIEE Despatch report should be captured as a modelling assumption: "that is a modelling assumption sitting inside a report." Sneha captured that as a parked line item.

---

**Note on vocabulary.** Ani uses "party" (trade usage: "party master", "party code") and "distributor" for customer records. The BRIEF.md canon notes he says "scheme discount" and "delta" (not "variance"). He drops articles ("job was failing", "table is having 61 million rows") and writes in run-on sentences with commas. The ASR transcript garbled some terms: "Sai Adri" for Sahyadri Softech, "Buddy" for Baddi (Himachal plant), "Annie" for Aniruddh. Sneha confirmed spellings on the call. The transcript also transcribes "crore" as "core" and "lakh" as "lac"—this is an ASR quirk, not the speakers' words.

**Attendance note.** Priya joined late (she had a report issue in the morning). Ani participated from home on a laptop (headset in office). Ishaan stepped away briefly for a courier delivery. Farida left early for a vendor call at 12:30.

**Office note.** Karthik mentioned the team will be in the Andheri East office next week (Tuesday and Wednesday, 04-05 March).
## Referenced by

- [Knowledge Base Index](/index.md)

