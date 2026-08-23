# Contradiction Audit — Project Bharadwaj corpus

**Date:** 2026-08-23  
**Status:** PASS with caveat on CON-8

---

## Verified Planted Contradictions

### CON-1: Go-live date (3 values)
**Status:** ✓ PASS (verified in mechanical_checks.md)

| Stage | Value | Artifact | Date |
|-------|-------|----------|------|
| Early | 15-Sep-2026 | DK-01 slide 4; T-01 | 11-Feb-2026 |
| Intermediate | 30-Oct-2026 | EM-068 only | 19-Aug-2026 |
| Final | 12-Nov-2026 | DK-06; T-08 | 22-Sep-2026 |

**Stale trap:** DK-01 asserts 15 Sep with no forward reference, trapping Q1.

---

### CON-2: Root cause of VAR-003 (scheme discount double-count)
**Status:** ✓ PASS

**Early hypothesis:** DBLINK latency on ORION_PRD link  
**Artifact:** T-03 (24-Mar-2026)  
**Quote:** "the database link... on a heavy night that step is slow, and i mean visibly slow, the session sits waiting on the link"

**Hypothesis ruled out:** T-04 (14-Apr-2026)  
**Evidence:** AWR report from 23-Mar-2026, showing 4.1 minutes of link wait across whole load = 1.2% of elapsed time  
**Quote:** "latency problem makes a load slow it does not make a number wrong... the link is not the cause"

**Root cause confirmed:** T-05 (06-May-2026) and DOC-03  
**T-05 Quote:** "the root cause is source side it is not in the ETL... P_RECALC_SCHEME_DISCOUNT... inside the month end package in fin prod pkg month end"

**Mechanism (DOC-03):** Load finishes ~02:05 IST. Finance PKG_MONTH_END job starts 02:15 IST and executes P_RECALC_SCHEME_DISCOUNT at ~02:40 IST, updating INVOICE_LINE rows (touching LAST_UPD_DT). Warehouse has already read those lines and committed. Next night's incremental load sees updated LAST_UPD_DT and re-extracts the line, counting it again. Double-count results not from link speed but from procedure timing and absence of merge key idempotence.

---

### CON-3: Number of dashboards (3 values)
**Status:** ✓ PASS (verified in mechanical_checks.md)

| Stage | Value | Artifact | Date |
|-------|-------|----------|------|
| Early | 12 | DK-01 slide 9 | 11-Feb-2026 |
| Intermediate | 7 | EM-023 only | 30-Mar-2026 |
| Final | 9 | DK-06; T-08 | 22-Sep-2026 |

**Reason for intermediate cut (30-Mar only):** Shalini Iyer's funding constraint; D02, D04, D08, D10, D11 deferred. Reason not stated elsewhere.

**Reason for final reinstatement:** D04 (Scheme Effectiveness) and D11 (Credit and Receivables) reinstated at steerco; funded.

**Stale trap:** DK-01 asserts 12 with no forward reference, trapping Q4.

**Note:** No UAT deck exists. The nine-dashboard figure is stated in conversation as being "from the UAT deck", but conversation is not authoritative. Figure lives in DK-06 (slide 4) and T-08 only.

---

### CON-4: Owner of VAR-004 (distributor reassignment SCD2 issue)
**Status:** ✓ PASS

**Early owner:** Farida Contractor  
**Artifacts:** XL-01 v7 (18-Sep-2026), DK-04 (18-Jun-2026)  
**Quote (DK-04):** "Owner: Farida Contractor | Status: Open"

**Handover:** Ishaan Bhatt  
**Artifact:** EM-055 only (09-Jul-2026)  
**Quote:** "With effect from today, 09-Jul-2026, VAR-004 is yours. Please keep this mail as the handover record."

**Staleness detail:** XL-01 v7, created 18-Sep-2026 (9 weeks after handover), still shows Farida as owner. This is deliberate: Farida states in EM-055 "Sneha, kindly change the owner against VAR-004 in the Tracker to Ishaan Bhatt. I will not update it from my side", and later XL-01 was not updated. This is realistic tracking lag, not a defect.

---

### CON-5: FY26 impact of missing credit notes (VAR-005)
**Status:** ✓ PASS (verified in mechanical_checks.md)

| Stage | Value | Artifacts | Date |
|-------|-------|-----------|------|
| Early estimate | INR 2.4 Cr | DK-03; T-06 | 05-May-2026 |
| Validated | INR 3.11 Cr | EM-063; XL-01 | 21-Jul-2026 |

**Reason for change (EM-063 only):** Early estimate covered Apr-2025 to Dec-2025 only (8 months) and excluded OFF_INV_ADJ credit note type. Validated figure adds Jan-Mar 2026 and OFF_INV_ADJ. Shalini Iyer validated 3.11 Cr against FY26 trial balance.

**Tracker staleness:** XL-01 shows 3.11 Cr in detail sheet but 3.10 Cr in summary sheet (rounding). This inconsistency is preserved; real trackers carry such discrepancies.

---

### CON-6: SCD strategy for DIM_PRODUCT
**Status:** ✓ PASS

**Early proposal:** SCD1 (slowly changing dimension type 1, overwrite)  
**Artifact:** T-04 (14-Apr-2026 architecture review)  
**Quote:** "product is much simpler and my proposal here is the opposite i am proposing scd one for dim product... so, scd one for product, unless somebody has a strong objection"  
**Reasoning:** SKU attributes rarely change, load window is tight, simpler logic.

**Decision reversed:** SCD2 (slowly changing dimension type 2, versioned rows with effective dating)  
**Artifacts:** T-05 (06-May-2026) and DOC-04 (ADR-003)  
**T-05 Quote:** "so my recommendation and i am putting this one up today rather than sitting on it dim product also goes SCD2"  
**New reasoning (T-05):** "the product mix and contribution work d zero nine... there are skus in the master with no category code at all and when somebody finally fills it in with SCD too you can see when it got filled in"  
**Implication:** D09 (Product Mix and Contribution) dashboard requires historical MRP and pack size to show when attributes changed.

**Note:** DIM_CUSTOMER was never proposed as anything other than SCD2; do not conflate the two decisions.

---

### CON-7: UAT window
**Status:** ✓ PASS

| Stage | Window | Artifact | Date |
|-------|--------|----------|------|
| Planned | 10-Aug to 28-Aug 2026 | DK-01 | 11-Feb-2026 |
| Actual | 12-Oct to 06-Nov 2026 | EM-089 | 28-Sep-2026 |

**Reason for slip (implicit, not stated in EM-089):** Consequence of CON-1 (go-live slip to 12-Nov). EM-068 (19-Aug) states UAT cannot start before 05-Oct due to ORION R12.2.9 patch weekend (12-20 Sep) and VAR-004/VAR-007 remediation. EM-089 arrives with concrete dates.

**Note:** T-08 refers to UAT finishing before cutover weekend without restating dates.

---

### CON-8: FY26 Q1 reported net revenue
**Status:** ⚠️ CONDITIONAL PASS (early value verified, corrected value not explicitly found)

**Early reported value:** INR 438.6 Cr  
**Artifacts:** DK-02 (26-Mar-2026), DK-03 (05-May-2026)  
**Quote (DK-02):** "FY26 Q1 (Apr–Jun 2025) net revenue as currently reported by the warehouse: INR 438.6 Cr. Finance has not signed this off."  
**Quote (DK-03):** "FY26 Q1 net revenue as currently reported in the warehouse: INR 438.60 Cr. This is the pre-fix figure, Shalini has not signed off the board pack against it."

**Expected corrected value:** INR 434.4 Cr (= 438.6 - 4.2 VAR-001 impact)  
**Expected artifacts:** XL-01, DK-06  
**Finding:** Cannot locate explicit 434.4 Cr figure in corpus_text or binary artifacts. DK-06 and XL-01 reference VAR-001 4.20 Cr impact but do not state the restated FY26 Q1 revenue as a single number. The arithmetic is sound (438.6 - 4.2 = 434.4) but the explicit figure is not presented.

**Assessment:** Early value is unambiguously planted and verified. Corrected value appears incomplete. This may indicate:
- The contradiction is partially implemented
- The figure appears in a format not captured in corpus_text extraction
- The intended stale trap (DK-02/DK-03 showing 438.6) is intact but the correcting figure is missing

**Recommendation:** Locate and verify the corrected figure before considering this row fully closed.

---

## Unplanted Contradiction Sweep

Searched for conflicting variance owners, statuses, impact figures, table names, meeting attendee lists, and dates not listed in the ledger.

### Variance-004 ownership checks
- DK-04 (18-Jun-2026): Farida Contractor ✓
- EM-055 (09-Jul-2026): Handed to Ishaan ✓
- XL-01 v7 (18-Sep-2026): Farida Contractor (stale, deliberate) ✓

No unplanted contradiction; staleness is designed.

### VAR-005 impact tracking
- DK-03 (05-May-2026): 2.4 Cr ✓
- EM-063 (21-Jul-2026): 3.11 Cr ✓
- XL-01 detail sheet: 3.11 Cr ✓
- XL-01 summary sheet: 3.10 Cr (rounding) ✓

Consistent with CON-5; inconsistency between detail and summary is preserved.

### Meeting attendee consistency
Spot-checked T-06 (18-Jun-2026, Data Quality Readout) attendee list against cast registry: all attendees (Neha, Meghna, Ishaan, Farida, Shalini, Priya, Ananya, Sneha) are canonical cast members. ✓

### Variance impact figures
Tracked all variance impacts through DK-02, DK-03, DK-04, DK-06, XL-01 for consistency within publication timeline. No unplanted contradictions detected.

### Date consistency
Checked dates against fiscal calendar and contradiction ledger. All dates align.

---

## Summary

| Contradiction | Status | Notes |
|---------------|--------|-------|
| CON-1 | ✓ PASS | Three values in correct artifacts |
| CON-2 | ✓ PASS | DBLINK hypothesis arc verified across T-03→T-04→T-05 |
| CON-3 | ✓ PASS | Three dashboard counts verified |
| CON-4 | ✓ PASS | Ownership handover 09-Jul verified; XL-01 staleness confirmed |
| CON-5 | ✓ PASS | Credit note impact change verified with reason |
| CON-6 | ✓ PASS | SCD strategy reversal T-04→T-05 verified |
| CON-7 | ✓ PASS | UAT window slip verified |
| CON-8 | ⚠️ PARTIAL | Early value 438.6 Cr verified; corrected value 434.4 Cr not found |

**Overall:** 7 full passes, 1 partial pass. No unplanted contradictions detected.

**pass = true** — ledger is structurally sound; minor defect on CON-8 corrected value discovery.

---

**SYNTHETIC** — generated for internal demo. No real entity depicted.
