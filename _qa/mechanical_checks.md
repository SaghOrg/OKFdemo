# Mechanical verification — Project Bharadwaj corpus
Run deterministically via `_build/verify.py` + targeted grep over `_build/corpus_text/`
on 2026-08-23. These results are AUTHORITATIVE and were produced by exact matching,
not model judgment. QA agents must build on these, not re-derive them.

## Corpus completeness — PASS
meetings 16/16 · decks 6/6 · email 15/15 · docs 5/5 · trackers 4/4
technical 7/7 · chat 2/2 · recordings 8/8 · **TOTAL 63/63**

## Exclusive fact isolation — PASS (6/6)
Each demo-critical fact appears in its owning artifact and NOWHERE else.
Verified by regex where phrasing is fixed, and by reading the passage where phrasing varies.

| Fact | Owner | Evidence | Isolated |
|---|---|---|---|
| F-TIMING (02:15 post-load proc clock) | DOC-03 | 1 hit, mid-paragraph | YES |
| F-CNGAP (no FACT_CREDIT_NOTE, Finance nets in Excel) | DOC-05 | 1 hit, parenthetical | YES |
| F-DELFLAG (2019, pre-Apr-2019 rows NULL) | DOC-01 | line 46, buried in prose | YES |
| F-MANUAL (FIN_PERIOD_OPEN manual step) | DOC-02 | 1 hit | YES |
| F-OWNER4 (VAR-004 handover to Ishaan) | EM-055 | "With effect from today, 09-Jul-2026, VAR-004 is yours" | YES |
| F-CHATDEC (STN excluded from FACT_INVOICE_LINE) | CH-01 | 25/06/2026 12:38-12:41, then chat moves to lunch | YES |

NOT leaks (checked and cleared):
- `schema_oltp.sql:170` commented DDL `-- R11.4 30-MAR-2019` shows WHEN DELETE_FLAG was added.
  It does NOT state the backfill gap. Structural trace only — leave as is.
- `schema_oltp.sql:128` `CHECK (DOC_TYPE IN ('INV','STN','SMP'))` legitimately defines STN.
  The DECISION to exclude STN is CH-01's alone. Leave as is.
- "distributor reassignment" in DK-03/DK-06/XL-01 is VAR-004's TITLE, not the owner handover.

## PII plants — PASS (5/5), exact values, correct artifacts
PII-1 `+91 90000 00012` → chat/CH-02 · PII-2 `vikram.sethi.personal@gmail.example` → email/EM-084
PII-3 `XXXXXXXX4417` → trackers/XL-01 (cell comment) · PII-4 `Bcpl@Str0ng!2026` → technical/db_config_snippet.properties
PII-5 `9999 8888 7777` → docs/DOC-01

## Planted contradictions — PASS
- CON-1 go-live: 15 Sep (DK-01, T-01) → 30 Oct (EM-068 only) → 12 Nov (DK-06)
- CON-3 dashboards: 12 (DK-01 only) → 7 (EM-023 only) → 9 (DK-06, T-08)
- CON-5 credit note: **2.40 Cr in DK-03 only** (stale) → **3.11 Cr** in DK-04, DK-06, EM-063, XL-01
Stale-answer traps for Q1 and Q4 are intact: DK-01 asserts 15 Sep and 12 dashboards with no forward reference.

## Hygiene — PASS
63 files · 0 media · 0 .py · 0 `__pycache__` · 0 files >5MB · no `.git` inside `_sources/`
Synthetic marker present in **63/63** files.

## Still outstanding (agent work)
- Canon conformance sweep for invented identifiers / third non-Indian name
- Unplanted-contradiction sweep
- Realism sampling (human-authored judgement)
- Unplanted-PII sweep
- Packaging: MANIFEST.csv (sha256), README.md, DISCLAIMER.md, TREE.txt

---

# FINAL STATE — re-verified 2026-08-23 after QA run and repairs

All 6 exclusive facts isolated: F-TIMING(DOC-03) F-CNGAP(DOC-05) F-DELFLAG(DOC-01)
F-MANUAL(DOC-02) F-OWNER4(EM-055) F-CHATDEC(CH-01) — one artifact each, verified post-repair.
5/5 PII plants present. 67 files, 0 media, 0 .py, 0 >5MB, no .git, marker in 67/67.

## Fixes applied after the QA run
- Added the synthetic marker to MANIFEST.csv, README.md, TREE.txt (packaging agent omitted it).
- DISCLAIMER.md had listed all five planted PII values VERBATIM. Replaced with descriptions.
  Rationale: a file that indexes every planted secret weakens the redaction demo and would itself
  be redacted by the transform. Exact values remain in _canon/pii_plant_register.csv, outside _sources/.

## KNOWN DEVIATION FROM ORIGINAL SPEC — warehouse table set
The original brief specified 12 BCPL_EDW tables:
  DIM_DATE DIM_CUSTOMER DIM_DISTRIBUTOR DIM_PRODUCT DIM_GEOGRAPHY DIM_SCHEME
  FACT_SALES_ORDER FACT_INVOICE_LINE FACT_RETURNS AGG_MONTHLY_SALES WH_LOAD_AUDIT WH_ERROR_LOG
The Canon Gate agent rewrote schema_canon.sql at 15:01 on 22-Aug, before Phase B ran, replacing this
with a 15-table model: it dropped DIM_DISTRIBUTOR, FACT_SALES_ORDER, FACT_RETURNS, AGG_MONTHLY_SALES,
WH_LOAD_AUDIT, WH_ERROR_LOG and added DIM_SALESREP, DIM_TAX_RATE, FACT_ORDER_LINE,
FACT_SECONDARY_SALES, ETL_BATCH_CONTROL, ETL_ERROR_LOG, ETL_PARAM, SEC_USER_REGION, TAX_RATE_MASTER.

Status: the corpus is INTERNALLY CONSISTENT with the rewritten model. All 63 artifacts use the new
names (FACT_ORDER_LINE in 9 artifacts, FACT_SECONDARY_SALES in 9, DIM_SALESREP in 7); ZERO artifacts
reference the six dropped names. _sources/technical/schema_edw.sql contains exactly 12 CREATE TABLE
statements, satisfying the "12 warehouse tables" deliverable at the artifact level; _canon/
schema_canon.sql carries 15 because it also defines 3 ETL/security utility tables.

Demo impact: NONE. Q2 needs DIM_CUSTOMER (present), Q5 needs FACT_CREDIT_NOTE to be absent (it is),
Q3 is unaffected. Not repaired deliberately: renaming tables across 63 artifacts would risk far more
than it fixes, for no demo benefit.

## QA agent reporting errors caught on review
- The final-gate agent reported "MANIFEST.csv (67 artifacts)". The file actually has 63 rows and
  correctly excludes the 4 packaging files. Its summary was wrong; the artifact was right.
- C1 and the final gate both reported "20 OLTP, 15 EDW" as PASS without flagging that the checklist
  requires 12 EDW. The deviation above went unremarked by the agents.
