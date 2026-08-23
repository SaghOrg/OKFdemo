# Adversarial review — Stages 2 (tables), 5 (meeting notes), 7 (mechanics)

Reviewer: claude-sonnet, stage `review`. Method: read the actual concept/meeting files and the
actual `_sources/`/`_canon/` artifacts directly (not the stage reports), cross-checked against
`_canon/schema_canon.sql`, `_canon/fact_ownership.csv`, and `_canon/BRIEF.md`.

**Overall verdict: FAIL. pass=false.** Stage 2's output is compromised by a systemic, majority-of-files
sourcing defect. Stage 5 has a real, repeated pattern of fabricated/misdirected decision links in
roughly half its files. Stage 7's headline claim ("complete bidirectional link graph") is false for
the two highest-traffic tables in the KB and roughly half of `concepts/tables/`.

---

## 1. Invented / missing tables — PASS (no finding)

Every one of the 35 `CREATE TABLE` statements in `_canon/schema_canon.sql` (13 `OMS_PROD`, 7
`FIN_PROD`, 15 `BCPL_EDW`) has exactly one corresponding file in `concepts/tables/`, and every file in
`concepts/tables/` corresponds to a real table. Checked by full name-for-name reconciliation, including
the two easily-confused pairs `BCPL_EDW.TAX_RATE_MASTER` / `BCPL_EDW.DIM_TAX_RATE` (both present,
correctly distinguished) and `FIN_PROD.TAX_RATE_MASTER` / `BCPL_EDW.TAX_RATE_MASTER` (both present,
correctly distinguished). Stage 2 also correctly did **not** create a `FACT_CREDIT_NOTE` concept —
`schema_canon.sql` explicitly forbids this table existing anywhere, silently, as the evidence for
VAR-005/F-CNGAP, and no `concepts/tables/*credit-note*fact*` or similar file exists. This part of stage 2
is genuinely solid.

---

## 2. FLATTENED AMBIGUITY — mostly PASS, one real error, one minor smoothing

- **T-07 stockist argument (stage 5):** `meetings/2026-08-05_dashboard_scope_workshop.md` correctly
  keeps the three-way disagreement open. It quotes all three parties directly ("if I cannot see Trilok
  Traders separately then the dashboard is for someone else, not for me" / "that is not something a
  person reads" / "I am not against off-take being somewhere, I am against it being on the same page as
  a number I have to sign") and closes with "**The three positions did not converge.**" It also
  correctly reports "seven committed plus two candidates" and does not manufacture a nine-dashboard
  figure — matching `_canon/BRIEF.md`'s CON-3 register exactly ("T-07 ... does not arrive at nine").
  Vocabulary is quoted, not normalised: Vikram is "stockist" throughout, Marijke/Klarissen's "channel
  partner" is kept separate, and a dedicated "Vocabulary notes" section documents the drift rather than
  resolving it. **No finding here** — this file is the strongest of the three stages reviewed.

- **DOC-01 misrememberings:** DOC-01 explicitly flags itself as "typed from memory ... wherever i have
  written a column name from memory and it is slightly off, the table itself is the truth, not this
  file." I checked every DOC-01 passage cited in `oms-prod-invoice-line.md`, `oms-prod-invoice-header.md`,
  and `oms-prod-customer.md` against `schema_canon.sql` line-by-line (columns, types, FK enablement,
  the ORDER_HEADER→CUSTOMER disabled-FK story) and found no case where a DOC-01 misremembering was
  silently "corrected" into a concept file as an unflagged fact, and no case where DOC-01's language was
  reproduced verbatim where it actually conflicts with the DDL. **One real technical error was found**
  (not a flattening, an outright mistake — see §4.2) and **one minor smoothing**: `oms-prod-customer.md`
  states "Approximately 2,140 rows as of March 2026" as a plain fact, dropping DOC-01's own hedge that
  "that count is probably a year old" — Ani is uncertain about the *currency* of his own number and the
  concept quietly upgrades it to a dated fact.

---

## 3. MISSED DISCREPANCIES on the five high-traffic tables — PASS

`INVOICE_LINE`, `INVOICE_HEADER`, `CUSTOMER`, `DIM_CUSTOMER`, `FACT_INVOICE_LINE` were each diffed by
hand against DOC-01/DOC-05 prose and the DDL. Column lists, types, FK enablement status, the
DELETE_FLAG NULL/Y/N story, DOC_TYPE mix, and the SCHEME_DISC_AMT additive-rewrite mechanic all matched
between prose and DDL in the concept files, and where VAR-001/002/003/004 apply they are called out with
explicit "## Known data-quality issues" / "## Variance linkage" sections rather than being silently
absorbed into the main description. `oms-prod-invoice-line.md` correctly avoids restating the forbidden
DBLINK-timing detail (`F-VAR003-AREA` in `fact_ownership.csv` forbids clock times outside DOC-03) — it
says "source-side, not in the ETL" and stops there. No missed prose/DDL mismatch was found on these five
tables.

---

## 4. SOURCES CITED THAT DO NOT SUPPORT THE CLAIM — FAIL, this is the headline finding

**Sample of 15 factual claims checked against their cited source (exceeds the ≥12 requirement):**

| # | File | Claim | Cited source | Verdict |
|---|------|-------|--------------|---------|
| 1 | `oms-prod-invoice-line.md` | "61,847,220 rows as of the 31-May-2026 profiling run" | DOC-01, `/_canon/schema_canon.sql`, DOC-05 | **FAIL** — DOC-01 only says "six crore plus rows" (approximate); the exact figure is in `XL-02` (DQ profiling tracker), `CH-01`, `DK-04` and `/_sources/technical/schema_oltp.sql`, **none of which are cited**, and `/_canon/schema_canon.sql` is not a `_sources/` file at all (see 4.1). |
| 2 | `oms-prod-customer.md` | "`CK_CUSTOMER_TYPE`" listed under "**Unique constraint**" | DDL | **FAIL** — factually wrong, not just mis-sourced. `CK_CUSTOMER_TYPE` is a `CHECK` constraint in `schema_canon.sql` (`CONSTRAINT CK_CUSTOMER_TYPE CHECK (CUST_TYPE IN (...))`), not a unique constraint. See §4.2. |
| 3 | `oms-prod-customer.md` | "FK from ORDER_HEADER to CUSTOMER was disabled in 2020 during a master data cleanup ... orphan rows" | DOC-01 | **PASS** — near-verbatim match to DOC-01 line 53: "the foreign key from ORDER_HEADER to CUSTOMER was disabled in 2020 during the master data cleanup and never enabled back ... it will fail today because there are orphan rows in there from the cleanup itself." |
| 4 | `oms-prod-invoice-line.md` | Quote: "the SCHEME DISCOUNT amount you see on a line is the outcome of a decision that is not recorded anywhere in ORION" | DOC-01 | **PASS** — exact match, DOC-01 line 62. |
| 5 | `oms-prod-invoice-line.md` | Quote on the FIN_PROD UPDATE grant, "i have never sat down and checked what is actually using that grant" | DOC-01 | **PASS** — exact match, DOC-01 line 71. |
| 6 | `bcpl-edw-dim-customer.md` | Quote: "CREDIT_LIMIT_AMT bothers me slightly ... wrong the moment you look back at last year" | DOC-05 | **PASS** — exact match, DOC-05 line 43. |
| 7 | `bcpl-edw-dim-customer.md` | "MAP_DIM_CUSTOMER currently runs 4 min 12 sec ... month-end nights the full load finishes 04:10-04:12 IST ... SLA breach twice in FY26 Q4 (14-Feb and 02-Mar 2026)" — attributed **"From DOC-05 (Farida Contractor's concern)"** | DOC-05 (per the file's own attribution) | **FAIL, hard** — none of this appears in DOC-05 (`grep` for "4 min 12" / "MAP_DIM_CUSTOMER" against DOC-05's extracted text returns zero hits). Every one of these figures is verbatim from **EM-041** ("The interface for DIM_CUSTOMER runs 4 min 12 sec today"; "on a heavy month end the run has finished 04:10, 04:12. The availability SLA is 05:30"; "We have already breached twice this quarter, 14-Feb and 02-Mar"). EM-041 is not in this file's `sources:` array at all — the array only lists SCHEMA (a broken path, see 4.1), DOC-05 and DOC-01. This is a genuine claim, correctly quoted in substance, attributed to a source that does not contain it, while the source that does contain it is uncited. |
| 8 | `bcpl-edw-dim-customer.md` | "Current population: approximately 2,140 current rows ... Of the 2,140 current customers, 340 are DISTRIBUTOR type" | DOC-01 (implicit) | **PARTIAL** — figures match DOC-01 §4, but DOC-01 hedges "that count is probably a year old"; the concept states it as a current fact with no hedge, and DOC-01 isn't even in scope for a `BCPL_EDW` warehouse-side row count (it's an OLTP source doc being used to state a warehouse population number). |
| 9 | `2026-08-05_dashboard_scope_workshop.md` | Quote: "half the confusion on this project is two people using the same word for two things" (Ananya) | T-07 vtt | **PASS** — exact match, `2026-08-05_dashboard_scope_workshop.vtt` line 216. |
| 10 | `2026-08-05_dashboard_scope_workshop.md` | Decision link: "*Pending:* `[/decisions/20260805-seven-committed-dashboards.md](link)`" | (implicit: should resolve within repo) | **FAIL** — file does not exist, and the markdown itself is malformed (`link` is the literal URL text, not a path). See §5. |
| 11 | `2026-08-05_dashboard_scope_workshop.md` | Decision link: "*Pending:* `[/decisions/20260805-secondary-sales-data-quality-on-pages.md](link)`" | — | **FAIL** — file does not exist. The real, already-written file covering exactly this content, `decisions/20260805-dashboard-stockist-drilldown-unresolved.md`, existed in the repo **before** this meeting note was generated (`generated.at` 11:03:46Z vs. 11:15:00Z) and is not linked. |
| 12 | `2026-06-18_dq_readout.md` | Decision link: `[/decisions/var-006-tax-rate-master-effective-dating.md]` | — | **FAIL** — file does not exist at that path or any path. The real file is `concepts/variances/var-006-tax-rate-retroactive.md` (generated 10:45:28Z, before this meeting note), in a different directory with a different name, and is not linked. |
| 13 | `2026-09-22_steering_committee.md` | "`/decisions/20261112-go-live-date.md`" | — | **FAIL** — does not exist. Real file: `decisions/20260922-golive-date-final-12nov.md`. Not even rendered as a markdown link (plain text + "←" arrow). |
| 14 | `oms-prod-invoice-line.md` | "sources: ... `/_canon/schema_canon.sql`" (used for the whole column table) | — | **FAIL** — `_canon/schema_canon.sql` states in its own header "CANON-INTERNAL. Phase A output. **NOT an artifact. NOT part of `_sources/`**." The real, structurally-identical DDL source that should have been cited is `/_sources/technical/schema_oltp.sql` (verified: its `INVOICE_LINE` DDL is column-for-column identical to `schema_canon.sql`'s). |
| 15 | `bcpl-edw-dim-customer.md` | "sources: ... `/_sources/schema_canon.sql`" | — | **FAIL** — this exact path does not exist anywhere in the repo (`_canon/schema_canon.sql` exists; `_sources/schema_canon.sql` does not). A phantom citation. |

**Hit rate: 7 of 15 sampled claims fully verified (47%); 6 fail outright, 2 are partial/hedge-dropping.**
Restricting to the *content* accuracy of prose claims only (rows 1–9, dropping the pure link-existence
checks 10–15 which are analysed in §5), the hit rate is 6/9 (67%) — still well short of what a "reviewed"
knowledge base should show, and the two hardest failures (row 2, a flat technical error, and row 7, a
whole-paragraph misattribution to a source that doesn't contain it) are exactly the kind of error a human
reviewer would catch immediately on inspection.

### 4.1 — Systemic: citing `_canon/` or `_build/corpus_text/` instead of `_sources/`

This is the dominant defect in stage 2. The task's own sourcing rule states plainly: "Every factual
claim traces to a `_sources/` file" and gives the resource format as `/_sources/docs/DOC-03_....docx`.
`_canon/schema_canon.sql` itself says, unambiguously, that it is not part of `_sources/` and must not be
copied there. Despite this:

- **20 of 35** `concepts/tables/*.md` files (57%) cite `resource: /_canon/schema_canon.sql` directly.
- **2** of those also cite `resource: /_canon/variance_register_canon.csv` — another internal-only file.
- **7** files instead cite `resource: /_sources/schema_canon.sql` — a path that does not exist under
  `_sources/` *or* `_canon/` (a phantom hybrid of the two).
- **15** files cite `resource: /_build/corpus_text/docs/....docx.txt` — the pre-extracted plain-text
  working copy the task instructions say to *grep*, not to cite, instead of the real
  `/_sources/docs/....docx` artifact.

**Union across these three patterns: 27 of 35 table concept files (77%) carry at least one source
citation that does not point at a real `_sources/` artifact.** Only 8 files
(`fin-prod-ar-open-item.md`, `fin-prod-gl-account-master.md`, `fin-prod-gl-journal-hdr.md`,
`fin-prod-gl-journal-line.md`, `oms-prod-credit-note-line.md`, `oms-prod-credit-note.md`,
`oms-prod-depot-master.md`, `oms-prod-sku-master.md`) are clean. In every case checked, the
correctly-named replacement file exists and is trivially findable
(`_sources/technical/schema_oltp.sql`, `_sources/technical/schema_edw.sql`,
`_sources/docs/DOC-05_edw_target_model_notes.docx`, etc.) — this was not a case of missing source
material, it was citing the internal answer key and the internal working copy instead of doing the
one-directory-over lookup.

### 4.2 — A genuine technical error, not just a sourcing problem

`oms-prod-customer.md`, "## Constraints and indexes": **"Unique constraint: `CK_CUSTOMER_TYPE` enforces
CUST_TYPE ∈ {DISTRIBUTOR, MODERN_TRADE, INSTITUTIONAL}."** In `schema_canon.sql`:
`CONSTRAINT CK_CUSTOMER_TYPE CHECK (CUST_TYPE IN ('DISTRIBUTOR','MODERN_TRADE','INSTITUTIONAL'))` — a
`CHECK` constraint (the `CK_` prefix is even a giveaway), not a `UNIQUE` constraint. This is a plain
misreading of the DDL by stage 2, not a source-attribution issue.

---

## 5. MEETING NOTES RESTATING DECISION CONTENT INSTEAD OF LINKING — FAIL, ~half the files

Decisions (`generated.at` 2026-08-23T11:03:46Z) and variance concepts
(`generated.at` 2026-08-23T10:45:28Z) both existed in the repo **before** stage 5 ran
(`generated.at` 11:14:53–11:15:08Z for all 8 meeting notes), so stage 5 had real files available to link
to. It did not consistently use them:

- **`2026-04-14_architecture_review.md`** — the entire "## Decisions referenced" section is three full
  paragraphs of restated content (SCD1 rationale for DIM_PRODUCT, the SCD2 window-cost tension for
  DIM_CUSTOMER, and VAR-002's root cause/fix/impact figures) with **zero links**, even though
  `decisions/20260414-dim-product-scd1-proposed.md` exists dated to the exact same day and
  `concepts/variances/var-002-date-key-timezone.md` exists — neither is referenced.
- **`2026-06-18_dq_readout.md`** — "## Decisions referenced" restates the VAR-004 worked example
  (Mahalaxmi Distributors, DIST-W-0241, dates, 65 lakh), the VAR-006 root cause and 40 lakh figure, and
  the VAR-007 8,140/11,902-line statistics in full, each pointed at a fabricated
  `/decisions/var-00X-....md` path (wrong directory, wrong filename) instead of the real
  `concepts/variances/var-004-scd2-territory-reassignment.md`, `var-006-tax-rate-retroactive.md`, and
  `var-007-late-arriving-sku-unknown-member.md`, which all already existed.
- **`2026-08-05_dashboard_scope_workshop.md`** — two "*Pending*" links use literal `(link)` as the
  markdown URL (a rendering bug) and point at invented filenames; the real decision covering that exact
  content, `decisions/20260805-dashboard-stockist-drilldown-unresolved.md`, already existed and is
  unlinked anywhere in this file.
- **`2026-09-22_steering_committee.md`** — two references use a bare "←" arrow (not a markdown link at
  all) pointing at `/decisions/20261112-go-live-date.md` and `/decisions/go-live-reporting-scope.md`,
  neither of which exists; the real files are `decisions/20260922-golive-date-final-12nov.md` and
  `decisions/20260922-dashboard-scope-reinstated-7-to-9.md`.

Three of eight meeting notes (`2026-02-11`, `2026-03-24`, `2026-05-06`) get this right — real paths,
real markdown link syntax, no restatement beyond a one-line gloss. `2026-03-03` correctly defers with
"see decision records as they are written for..." (no decisions existed yet for that workstream at the
time, which is legitimate). So the failure is concentrated in exactly the four meetings (04-14, 06-18,
08-05, 09-22) that happened *after* the relevant decision/variance records already existed — i.e., stage
5 didn't check for existing records before inventing paths and restating their content, in the cases
where checking would have mattered.

---

## Stage-by-stage verdict

**Stage 2 (tables): FAIL.** Table inventory is complete and accurate (§1) and the five high-traffic
tables show no missed prose/DDL discrepancies (§3), but 27 of 35 files (77%) cite a source outside
`_sources/` — 20 of them citing a file whose own header says "NOT part of `_sources/`" — and one file
contains a flat factual error about a constraint type, and one file misattributes a paragraph of figures
to a source that doesn't contain them while leaving the actual source uncited. This is not spot noise;
it's the modal behavior of the stage.

**Stage 5 (meeting notes): FAIL, but with real strengths.** Ambiguity preservation is genuinely good —
T-07's stockist argument, DOC-01's vocabulary quoting, and the CON-3 dashboard-count trap are all handled
correctly, and quotes checked against the transcript are accurate. But half the "Decisions referenced"
sections either fabricate nonexistent decision paths (sometimes with broken markdown syntax) instead of
linking real, already-written decision/variance records, or restate those records' content wholesale
in-line — the opposite of the intended "link to it" behavior. Meeting notes generated after 04-14
onward are the affected ones; earlier ones are clean.

**Stage 7 (mechanics): FAIL** on its own headline claim. `LEARNINGS.md`'s stage 7 entry claims "Identified
76 files with incoming links. Added backlink sections ... to 70 files that had incoming links but lacked
backlink sections ... creating complete bidirectional link graph across the knowledge base." The repo has
only 69 non-index/log content files total (a number stage 7 itself states in the same entry), so "76
files with incoming links" is already arithmetically impossible. In `concepts/tables/`, 18 of 35 files
(51%) have no "## Referenced by" section at all, including the two most-referenced tables in the entire
sample: `bcpl-edw-fact-invoice-line.md` (18 real incoming links, confirmed by grep) and
`oms-prod-invoice-line.md` (9 real incoming links) — the central warehouse fact table and the busiest
OLTP table in the whole engagement got no backlinks. Index generation itself checks out (all 69 listed
links resolve to real files), so this is specifically a backlink-completeness failure, not a total
mechanics failure.

## Recommendation

Do not promote stages 2, 5, or 7's output as-is. Before this KB is presentable: (a) re-point every
`/_canon/`, `/_sources/schema_canon.sql`, and `/_build/corpus_text/` citation in `concepts/tables/` to
the matching real `_sources/` file; (b) fix the `CK_CUSTOMER_TYPE` constraint-type label and the
DIM_CUSTOMER load-performance misattribution; (c) replace the four meeting notes' fabricated decision
links with the real existing paths (all four already exist in the repo, this is a lookup fix, not new
authoring); (d) re-run backlink generation for `concepts/tables/` — 18 files need it, starting with
`bcpl-edw-fact-invoice-line.md` and `oms-prod-invoice-line.md`.
