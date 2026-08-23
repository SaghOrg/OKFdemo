# Demo Readiness Report — Project Bharadwaj corpus
**Run date: 2026-08-23**

## Executive Summary

Q1-Q5 are **fully reconstructible** from the corpus. Q6 **zero coverage confirmed**. Demo gate **PASS**.

---

## Restatement of Mechanical Checks (AUTHORITATIVE)

Per `mechanical_checks.md`, the following are proven and not re-derived:
- **All 63 artifacts present** (16 meetings, 6 decks, 15 emails, 5 docs, 4 trackers, 7 technical, 2 chat, 8 recordings)
- **All 6 exclusive facts isolated to single artifact**:
  - F-TIMING (02:15 procedure) in DOC-03 alone
  - F-CNGAP (no FACT_CREDIT_NOTE, Finance nets in Excel) in DOC-05 alone
  - F-DELFLAG (2019, pre-Apr-2019 rows NULL) in DOC-01 alone
  - F-MANUAL (FIN_PERIOD_OPEN manual step) in DOC-02 alone
  - F-OWNER4 (VAR-004 handover to Ishaan) in EM-055 alone
  - F-CHATDEC (STN excluded from FACT_INVOICE_LINE) in CH-01 alone
- **All 5 PII plants present** with exact values
- **All 3 planted contradictions correctly structured**:
  - CON-1 go-live: 15 Sep → 30 Oct → 12 Nov
  - CON-3 dashboards: 12 → 7 → 9
  - CON-5 credit note: 2.40 Cr (stale in DK-03) → 3.11 Cr (validated)
- **Stale-answer traps intact**: DK-01 asserts 15 Sep and 12 dashboards with zero forward reference
- **Synthetic marker present in 63/63 files**

---

## Q1 — "When are we going live, and what changed?"

**Status: FULLY RECONSTRUCTIBLE**

### Fragment 1: Original date (F-GOLIVE-ORIG)

| Artifact | Quote |
|---|---|
| **DK-01** (slide 4) | "THE ONLY DATE THAT MATTERS TO RAJEEV ON THIS WHOLE DECK: Tuesday 15 September 2026." |
| **T-01** (meeting notes) | "Speaker 6: yes, 15 september 2026" |

### Fragment 2: First slip date and reason (F-GOLIVE-SLIP1, F-GOLIVE-REASON1)

| Artifact | Quote |
|---|---|
| **EM-068** | "To close the loop. The plan date for go live is now Friday 30 October 2026." |
| **EM-068** (reason) | "1. ORION is on the R12.2.9 patch weekend from 12 to 20 September. The source system is locked for that period. We cannot cut over into it and we cannot run a controlled comparison against it while it is being patched. 2. VAR-004 and VAR-007 will not be closed in time." |

**Confirmation**: EM-068 is **the only artifact in the corpus containing 30 October 2026**. The first slip is isolated here and dated 19-Aug-2026.

### Fragment 3: Final date and reason (F-GOLIVE-FINAL, F-GOLIVE-REASON2)

| Artifact | Quote |
|---|---|
| **T-08** (steering committee) | "<v Ananya Krishnan> and business go live on thursday the twelfth of november" |
| **DK-06** (slide 4) | "Business go-live \| Thursday 12 November 2026" |
| **T-08** (reason) | "<v Marijke van der Berg> the group close blackout is twenty six october to six november, cet." |

### Fragment 4: Cutover shape (F-CUTOVER)

| Artifact | Quote |
|---|---|
| **T-08** | "<v Ananya Krishnan> so the proposal is, cutover weekend saturday and sunday, seventh and eighth november [and business go live on thursday the twelfth of november]" |
| **DK-06** | "[SPEAKER NOTES slide 4]: D04 and D11 reinstated at Klarissen's request following the credit note escalation and the scheme discount work... does not move the 12-Nov date" |

### Fragment 5: Original and final UAT windows (F-UAT-ORIG, F-UAT-FINAL)

| Artifact | Quote |
|---|---|
| **DK-01** | "UAT \| 10-Aug-2026 to 28-Aug-2026" |
| **EM-089** | "UAT runs Monday 12 October 2026 to Friday 06 November 2026." |
| **CH-02** | "09/10/2026, 17:31 - Ananya Krishnan: Testing runs 12 October to 6 November." |

### Completeness Assertion

✓ All fragments present in separate artifacts  
✓ No single artifact contains the complete answer  
✓ Stale answer (15 Sep from DK-01) is recognizable as obsolete only when read against EM-068 and T-08/DK-06  
✓ The history of "what changed" requires all three dates in separate artifacts

---

## Q2 — "Why did we choose SCD2 for DIM_CUSTOMER?"

**Status: FULLY RECONSTRUCTIBLE**

### Fragment 1: Option raised (F-SCD2-OPTION)

| Artifact | Quote |
|---|---|
| **T-04** (architecture review, 14-Apr-2026) | "Speaker: a distributor gets moved from one territory to another... if a distributor moves territory in april, and we overwrite, then all of [the history is lost]" |
| **EM-041** (Karthik's note) | "I am proposing SCD2 on DIM_CUSTOMER. Before I write it up formally I want your view on what it does to the load" |

### Fragment 2: Objection (F-SCD2-OBJECTION)

| Artifact | Quote |
|---|---|
| **EM-041** (16-Apr-2026) | "With SCD2 that interface stops being an insert... My estimate is 12 to 15 minutes on a month end night." |
| **EM-041** | "We have already breached twice this quarter, 14-Feb and 02-Mar." |

### Fragment 3: Counter-analysis (F-SCD2-COUNTER)

| Artifact | Quote |
|---|---|
| **XL-03** (22-Apr-2026) | "Measured delta \| =B26-B25 \| +7 min 28 sec, measured not estimated" |
| **XL-03** | "Worst month-end finish, with SCD2 (adopted) \| ... 04:20:00 ... leaves 70 minutes of head room" |
| **EM-047** (covering note) | "[headline echoed]: measured load window cost is acceptable" |

### Fragment 4: Decision (F-SCD2-DECISION)

| Artifact | Quote |
|---|---|
| **T-05** (design sign-off, 06-May-2026) | "Speaker 4: so shalini formally as the business sponsor, are you approving approving SCD2 on dim customer / Speaker [Shalini]: yes and i have approved it just now" |

### Fragment 5: Rationale (F-SCD2-RATIONALE, F-ADR-REGISTER)

| Artifact | Quote |
|---|---|
| **DOC-04** (11-May-2026) | "ADR-002  DIM_CUSTOMER keeps history (SCD2) / Decision. DIM_CUSTOMER is SCD2, effective dated with EFF_START_DT, EFF_END_DT and CURRENT_FLG. Tracked attributes are TERRITORY_CODE, REGION_CODE, STATE_CODE, DEPOT_CODE and CUSTOMER_TYPE." |
| **DOC-04** | "Facts join on the surrogate key of the version that was valid at the invoice date, not on the current version." |
| **DOC-04** | "Reported sales for a closed period must not move with them. ADR-002." |

### Completeness Assertion

✓ No single artifact contains a complete answer  
✓ EM-041 has objection but a **wrong estimate** (12-15 min vs actual 7 min 28 sec)  
✓ XL-03 has measurement but no decision  
✓ DOC-04 has rationale but does not mention Farida's objection  
✓ Complete honest answer requires **all five fragments** across four formats (transcript, email, spreadsheet, design doc)

---

## Q3 — "What is actually causing the scheme discount double-count (VAR-003) and who owns it?"

**Status: FULLY RECONSTRUCTIBLE**

### Fragment 1: The misdirection (F-DBLINK-HYP)

| Artifact | Quote |
|---|---|
| **T-03** (24-Mar-2026) | "<v Speaker 4> correct one link, and the load knowledge module goes over it now on a heavy night that step is slow... the invoice line interface is the slowest thing in the whole plan and on a bad night it is not even close it just sits there in sql net message from the link" |
| **T-03** | "<v Karthik Subramanian> moderately confident, not confident it fits three things the duplicates are exact... the link is measurably slow on exactly those nights" |
| **DK-02** (deck carried the hypothesis) | Marked as pending mechanism discovery |

### Fragment 2: Hypothesis ruled out (F-DBLINK-RULEDOUT)

| Artifact | Quote |
|---|---|
| **T-04** (14-Apr-2026) | "<v Farida Contractor> top waits... total wait for the whole load four point one minutes" |
| **T-04** | "<v Speaker 1> yes that is the point and i want to say it properly because i was the one who got it wrong a latency problem makes a load slow it does not make a number wrong... latency changes when the extract finishes, it does not change what the extract read" |

### Fragment 3: The mechanism — EXCLUSIVE to DOC-03 (F-TIMING)

| Artifact | Quote |
|---|---|
| **DOC-03** | "load is starting 01:00 and on a normal night the last step is done and committed by about 02:05, and **the finance job in ORION starts 02:15** and the scheme recalculation inside it reaches the invoice line update around 02:40, so by the time the amount on the line changes the warehouse has already read those lines and finished with the source for that business date, which is why the warehouse is sitting on the pre adjustment scheme discount value, and **why the same line comes across again on the next night once LAST_UPD_DT has moved, and gets counted a second time**." |

**Verification**: This sentence exists **only in DOC-03**. Grep of entire corpus returns 1 hit. No other artifact states the 02:15 timing or the additive mechanism.

### Fragment 4: The area, without mechanism (F-VAR003-AREA)

| Artifact | Quote |
|---|---|
| **DK-03** | "Root cause is source-side, not in the ETL. A finance procedure inside ORION rewrites the scheme discount amount on invoice lines." |
| **XL-01** | "Root cause is source-side, not in the ETL - a finance procedure in ORION rewrites the scheme discount amount. See the stored procedure walkthrough (Ani/Karthik) for the detail." |

### Fragment 5: The flawed code (F-ADDITIVE, code form)

| Artifact | Quote |
|---|---|
| **TECH-PKG** (`pkg_month_end.pkb`) | "UPDATE oms_prod.invoice_line SET accrual_amt = v_accrual_total, scheme_disc_amt = v_accrual_total, last_upd_dt = SYSDATE WHERE invoice_hdr_id = v_hdr_id;" |
| **TECH-PKG** | "[No idempotency guard; comment states "run manually at month end"]" |

### Fragment 6: The grant (F-GRANT)

| Artifact | Quote |
|---|---|
| **TECH-SQL-OLTP** (`schema_oltp.sql`) | "GRANT UPDATE ON OMS_PROD.INVOICE_LINE TO FIN_PROD;" |
| **DOC-01** | "FIN_PROD holds an UPDATE grant on OMS_PROD.INVOICE_LINE, granted 2014, never reviewed" |
| **EM-092** | References to the grant being outside the Control-M job inventory |

### Fragment 7: Why nobody found it (F-MANUAL context)

| Artifact | Quote |
|---|---|
| **DOC-02** | "There is a row in BCPL_EDW.ETL_PARAM with PARAM_NAME = 'FIN_PERIOD_OPEN'... this step is not in the runbook. It is not written down anywhere at all before this document." |
| **TECH-CTLM** (`control_m_schedule.txt`) | "BCPL_EDW_MONTHEND_FIN ... (manual submit) ... Submitted manually, on request" |

**Interpretation**: The finance job is **outside Control-M** job inventory. The variance discovery focused on the nightly load (in Control-M). The finance job (not in Control-M) was therefore not examined for side effects on already-extracted data.

### Fragment 8: Ownership and decision (F-VAR003-OWNER, F-VAR003-DECISION)

| Artifact | Quote |
|---|---|
| **XL-01** | "VAR-003 \| Scheme discount double-count ... **Owner: Aniruddh Deshpande** ... Open ... 24-Mar-2026" |
| **T-05** | "<v Karthik Subramanian> map fact invoice line stops being an append we rebuild rebuild it as a key based merge on invoice line id with a versioned re extract" |
| **DOC-04** | "ADR-004  Remediation approach for VAR-003 / Fix is a key-based merge rebuild of MAP_FACT_INVOICE_LINE, ADR-004, planned R2026.09." |

### Completeness Assertion

✓ **DOC-03 is the ONLY artifact in the corpus containing the mechanism (02:15 timing)**  
✓ T-03 read alone gives a **wrong and confidently stated cause** (DBLINK latency)  
✓ TECH-PKG contains the flawed code but **no schedule**, so code alone does not explain why the problem occurs repeatedly  
✓ TECH-CTLM proves **absence by evidence**: the problem job is not in it  
✓ No single artifact answers "what / who / so-what"  
✓ Correct answer requires **all eight fragments** across six formats (transcript, document, code, DDL, email, tracker, control schedule)

---

## Q4 — "How many dashboards are in scope for go-live?"

**Status: FULLY RECONSTRUCTIBLE**

### Fragment 1: Original scope (F-DASH12)

| Artifact | Quote |
|---|---|
| **DK-01** (slide 9, 11-Feb-2026) | "12 DASHBOARDS IN SCOPE FOR GO-LIVE / [list] D01 through D12, exactly as listed here" |

### Fragment 2: First cut (F-DASH7, F-DASH7-REASON)

| Artifact | Quote |
|---|---|
| **EM-023** (30-Mar-2026) | "We are not doing twelve. It is seven. [Lists D01, D03, D05, D06, D07, D09, D12]" |
| **EM-023** (reason) | "Group has frozen the capex line that the BI licence uplift was sitting in. Without that uplift we can fund seven dashboards for go-live and we cannot fund twelve." |

**Verification**: EM-023 is the **only artifact in the corpus stating 7 dashboards** at the initial cut. This is 55 days before the next update and is then superseded.

### Fragment 3: Dashboard scope workshop result (F-DASH-CANDIDATES)

| Artifact | Quote |
|---|---|
| **T-07** (05-Aug-2026) | "<v Ananya Krishnan> okay so to close seven committed two candidates going up for a decision / <v Ritwik Ghosh> two marked candidate, not funded, yes" |
| **DK-05** (07-Aug-2026) | "Seven wireframes shown. Two marked **CANDIDATE - not funded**. Deferred to sponsor decision." |

**Critical observation**: T-07 and DK-05 **never state a final number**. They stop at "seven committed plus two candidates". An intuitive searcher for "dashboard scope" would find these as most topically relevant, and they would return **an inconclusive answer**.

### Fragment 4: Final scope and reason (F-DASH9, F-DASH9-REASON)

| Artifact | Quote |
|---|---|
| **T-08** (22-Sep-2026) | "<v Ananya Krishnan> nine dashboards live on the twelfth." |
| **DK-06** (22-Sep-2026) | "[SPEAKER NOTES slide 4]: D04 and D11 reinstated at Klarissen's request following the credit note escalation and the scheme discount work, funded from the Phase 2 budget line released in August." |
| **T-08** (reason) | "<v Ananya Krishnan> D04 and D11 reinstated" |

### Completeness Assertion

✓ No single artifact contains a complete answer  
✓ DK-01 has 12 with zero awareness that it is stale  
✓ EM-023 has 7 and the reason, but is superseded 5 months later without being cross-referenced  
✓ T-07 and DK-05 (the most topically relevant documents) **never state a final number** — they stop at 7+2 candidates  
✓ Only T-08 and DK-06 carry the final answer (9)  
✓ Naive retrieval strategies lead to **three different wrong answers**: 12 (from DK-01), 7 (from T-07/DK-05 if forced), or incomplete (from T-07/DK-05 if read as gospel)

---

## Q5 — "Why are credit notes missing from the warehouse, what is the impact, and who escalated it?"

**Status: FULLY RECONSTRUCTIBLE**

### Fragment 1: The gap, stated once, as an aside (F-CNGAP — EXCLUSIVE)

| Artifact | Quote |
|---|---|
| **DOC-05** (08-Apr-2026, parenthetical) | "There is no FACT_CREDIT_NOTE in BCPL_EDW; credit notes were left out of the 2021 build and Finance nets them by hand in Excel each month, so the warehouse revenue line is gross of them" |

**Verification**: This fact exists **only in DOC-05** as a parenthetical remark in the middle of a 16-page design note. It is buried and isolated.

### Fragment 2: Structural proof (F-CN-STRUCT)

| Artifact | Quote |
|---|---|
| **TECH-SQL-EDW** (`schema_edw.sql`) | "[Grep returns zero hits for FACT_CREDIT_NOTE]" |

**Interpretation**: The absence is **silent**. No comment, no TODO, no placeholder. The table does not exist and the schema does not acknowledge it should.

### Fragment 3: Data exists at source (F-CN-SOURCE)

| Artifact | Quote |
|---|---|
| **TECH-SQL-OLTP** (`schema_oltp.sql`) | "CREATE TABLE OMS_PROD.CREDIT_NOTE ... [plus] CREATE TABLE OMS_PROD.CREDIT_NOTE_LINE" |
| **TECH-SQL-OLTP** | "-- 1.10 CREDIT_NOTE. this exists in ORION, FY26 volume 9,318 documents." |

### Fragment 4: The escalation (F-CN-ESCALATION — EXCLUSIVE)

| Artifact | Quote |
|---|---|
| **EM-061** (14-Jul-2026, Marijke van der Berg to Rajeev Menon) | "The India channel partner credit notes are not in the warehouse at all. Since when is this known? ... Before the next audit call I need three things. The FY26 number. Who owns it. And the walk from what the warehouse reports to what your Finance team actually books." |

**Verification**: EM-061 is the **only artifact in the corpus containing Marijke's escalation**. She asks for the number but does not supply it.

### Fragment 5: Early, wrong impact (F-CN-24)

| Artifact | Quote |
|---|---|
| **DK-03** (05-May-2026) | "VAR-005 Credit notes absent from warehouse - INR 2.40 Cr - Open, Finance validating" |
| **DK-03** (speaker notes) | "This is Shalini's own working number, built quickly to get something into this pack, and she has not reconciled it against the full FY26 trial balance yet. It will very likely move once she does." |
| **T-06** | "[Repeats the 2.4 Cr figure in the data quality readout]" |

### Fragment 6: Validated impact and method (F-CN-31, F-CN-METHOD)

| Artifact | Quote |
|---|---|
| **EM-063** (21-Jul-2026) | "The validated credit note impact on net revenue for FY26 is INR 3,11,20,000, that is INR 3.11 Cr. Period covered is 01-Apr-2025 to 31-Mar-2026, the full FY26, not a part year." |
| **EM-063** (method explanation — EXCLUSIVE) | "On why this is different from the number in the May pack. That was a quick sizing, done in a day... It covered April 2025 to December 2025 only, so the whole of FY26 Q4 was missing from it, and it left out the OFF_INV_ADJ type completely. Put Jan to Mar back in, add OFF_INV_ADJ, and you arrive at 3.11 Cr." |
| **XL-01** | "impact validated by shalini against the trial balance... 31120000" |

**Verification**: The **method explanation** (why the 2.4 was wrong) appears **only in EM-063**. It does not appear in XL-01, the deck, or anywhere else in the corpus.

### Fragment 7: Tracked variance (F-VAR005-TITLE)

| Artifact | Quote |
|---|---|
| **XL-01** | "VAR-005 \| Credit notes absent from warehouse ... Owner: **Shalini Iyer** ... Open ... 24-Apr-26" |
| **DK-03, DK-04, DK-06** | VAR-005 appears in variance register tables |
| **T-06** | VAR-005 mentioned in data quality readout |
| **T-08** | VAR-005 referenced in steering committee context |

### Completeness Assertion

✓ **DOC-05 is the ONLY artifact stating the reason why** (credit notes left out of 2021 build)  
✓ TECH-SQL-EDW proves absence but says nothing about why or cost  
✓ EM-061 is the **ONLY artifact containing the escalation** (Marijke asking for the number)  
✓ DK-03 supplies a figure that is **wrong by 30 percent** and is the most retrievable statement of impact  
✓ EM-063 supplies the validated number but does **not restate the root cause**  
✓ **EM-063 is the ONLY artifact explaining why the 2.4 was wrong** (missing Q4, missing OFF_INV_ADJ type)  
✓ No single artifact answers the three-part question (why / what impact / who escalated)  
✓ Complete answer requires **all seven fragments** across five formats (document, DDL, email, spreadsheet, transcript)

---

## Q6 — THE WRITE-BACK TEST

**Status: ZERO COVERAGE CONFIRMED**

The decision (deferred `FACT_CREDIT_NOTE` to Phase 2, net credit notes in Power BI for go-live) exists in the real world of the demo. It does **not exist in the corpus**.

### Search verification

Searched entire corpus for:
- "defer" + "credit note" → 0 hits
- "phase 2" + "credit" → 0 hits
- "power bi" + "credit" + "semantic" / "net" / "upload" → 0 hits
- "d11" + "credit" + "file" / "upload" / "finance" → 0 hits
- "d07" + "credit" + "manual" / "upload" → 0 hits

### Critical evidence

**Tension is deliberately visible and unresolved:**

| Artifact | Fact |
|---|---|
| **DK-06, T-08** | D11 Credit and Receivables Exposure is **in scope for go-live on 12 Nov** |
| **TECH-SQL-EDW** | **No FACT_CREDIT_NOTE exists** in the warehouse |
| **XL-01** | VAR-005 is **Open** with no remediation or target date |
| **DOC-05** | Finance **nets credit notes in Excel**, not in Power BI |

**No artifact bridges this gap.** The silence is deliberate and load-bearing.

---

## Summary of Assertions

| Q | Correct Answer | Minimum Artifacts Needed | Formats Crossed | Status |
|---|---|---|---|---|
| Q1 | 12 Nov 2026 | DK-01/T-01, EM-068, T-08/DK-06 | deck, email, transcript | ✓ PASS |
| Q2 | Territory changes require SCD2; load cost measured and justified | T-04, EM-041, XL-03, T-05, DOC-04 | transcript, email, spreadsheet, document | ✓ PASS |
| Q3 | Source-side procedure at 02:15 additively rewrites scheme discounts; owner Aniruddh Deshpande | T-03, T-04, DOC-03, XL-01, TECH-PKG, TECH-CTLM, T-05, DOC-04 | transcript, document, code, DDL, spreadsheet | ✓ PASS |
| Q4 | 9 dashboards | DK-01, EM-023, T-07/DK-05, T-08/DK-06 | deck, email, transcript | ✓ PASS |
| Q5 | No fact table ever built; Finance nets in Excel; INR 3.11 Cr; escalated by Marijke | DOC-05, TECH-SQL-EDW, EM-061, EM-063, XL-01 | document, DDL, email, spreadsheet | ✓ PASS |
| Q6 | [Nothing in corpus] | None (zero coverage required) | [none] | ✓ PASS |

---

## Demo Readiness Gate Result

**PASS** — The corpus meets all requirements for the demo dry run:

1. ✓ All Q1-Q5 answer fragments are present in the corpus
2. ✓ Each question requires minimum 3-8 artifacts of different types
3. ✓ No single artifact contains a complete answer to any Q1-Q5
4. ✓ Stale-answer traps are intact (DK-01's 15 Sep and 12 dashboards)
5. ✓ Exclusive facts (F-TIMING, F-CNGAP, F-CN-ESCALATION, F-CN-METHOD) are confirmed isolated
6. ✓ Q6 write-back decision has zero coverage
7. ✓ All 63 artifacts present with correct mechanics

The corpus is ready for demo presentation.

---

**SYNTHETIC — generated for internal demo. No real entity depicted.**
