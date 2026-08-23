# demo_answer_map.md — THE CANONICAL DEMO QUESTIONS AND THEIR FRAGMENTATION

**Status: BINDING. This file fixes the five demo questions plus the write-back test. They are not
specified anywhere upstream. What is written here is what the demo asks.**

The corpus exists to prove one thing: **no single document answers a real question about this
programme.** Every question below is answerable only by assembling fragments that live in different
artifacts, in different formats, written by different people, months apart, some of them stale and
wrong. If a downstream agent lets a complete answer land in one artifact, the demo fails at that
question and the artifact must be regenerated.

Notation: artifact IDs are as registered in `CANON.md` §15. Facts are as registered in
`fact_ownership.csv`. Every fact named here is enforced there. Where a fragment is a
technical file, the artifact ID is given first and the filename in brackets, because the
ID is what `fact_ownership.csv` and `timeline.csv` key on.

**Fragmentation, verified at the Phase A exit gate (22-Aug-2026).** For each of Q1 to Q5,
every fact tagged to that question in `fact_ownership.csv` was checked against the union of
its `owning_artifact_id` and `may_also_appear_in` columns. **For Q1, Q2, Q3, Q4 and Q5 there
is no artifact in the corpus that is permitted to carry every fragment of that question.**
The minimum artifact counts are Q1 five, Q2 five, Q3 nine, Q4 five and Q5 eight. Q6 has zero
coverage by design. If a downstream agent widens a `may_also_appear_in` list, that check has
to be re-run, because a single careless addition can collapse a question into one document.

---

## Q1 — "When are we going live, and what changed?"

**Type: stale trap.**

**The correct answer: 12 November 2026.**

A naive single-document reader opens `DK-01_kickoff_v3_FINAL.pptx`, sees a kickoff deck with
`FINAL` in the filename, reads slide 4, and answers **15 September 2026**. That answer is **wrong**,
it is eight weeks and two decisions out of date, and it is exactly what a retrieval system that
ranks by apparent authority will return. The word `FINAL` in the filename is deliberate bait.

### Fragments

| Fragment | Fact | Artifact | Detail |
|---|---|---|---|
| The original date | `F-GOLIVE-ORIG` | **DK-01** (slide 4 timeline), echoed in **T-01** | 15-Sep-2026, stated at kickoff on 11-Feb-2026 |
| The original UAT window that goes with it | `F-UAT-ORIG` | **DK-01** | 10-Aug to 28-Aug-2026 |
| The first slip, and the only place the intermediate value exists | `F-GOLIVE-SLIP1` | **EM-068** (19-Aug-2026) | moves to 30-Oct-2026 |
| Why it slipped | `F-GOLIVE-REASON1` | **EM-068** only | ORION R12.2.9 patch weekend 12-20 Sep locks the source; VAR-004 and VAR-007 remediation incomplete; UAT cannot start before 05-Oct |
| The final date | `F-GOLIVE-FINAL` | **T-08** and **DK-06** (22-Sep-2026) | 12-Nov-2026 |
| Why that date | `F-GOLIVE-REASON2` | **T-08**, echoed in **DK-06** | Klarissen group close blackout 26-Oct to 06-Nov CET forbids a cutover in that window |
| The cutover shape | `F-CUTOVER` | **DK-06**, echoed in **T-08** | cutover weekend 7-8 Nov, historical reload 9-11 Nov, go-live 12 Nov, hypercare to 11-Dec-2026 |
| The UAT window that follows from it | `F-UAT-FINAL` | **EM-089** (28-Sep-2026), echoed in **CH-02** | 12-Oct to 06-Nov-2026 |

### Assertions

- **No single artifact contains a complete answer to Q1.**
- DK-01 has the original date and nothing after it. It does not know it is stale.
- EM-068 has the first slip and the reason for it, but its date is superseded three weeks later.
  **EM-068 is the only artifact in the corpus containing the string 30 October 2026.**
- T-08 and DK-06 have the final date and the reason for it, and they deliberately do **not** restate
  the 30-Oct value. They refer to "the current plan date". So the *history* of the change cannot be
  reconstructed from the steerco material alone.
- Therefore "what changed" requires **three** artifacts of **three** different types: a deck, an
  email, and a meeting transcript plus its deck.

### Single-document failure mode for Q1

> A reader who consults only `DK-01_kickoff_v3_FINAL.pptx` answers **15 September 2026** and states it
> with confidence, because the document is titled FINAL, is authored by the engagement lead, and is
> internally consistent. Nothing in DK-01 signals that it has been superseded. The failure is silent:
> there is no contradiction visible inside the document, only outside it.
>
> A reader who consults only `EM-068` answers **30 October 2026**, which is wrong in a subtler and more
> dangerous way, because it looks like a correction and therefore looks current.

---

## Q2 — "Why did we choose SCD2 for DIM_CUSTOMER?"

**Type: decision archaeology.** No trap. The point is that a decision has a life cycle and the life
cycle is scattered across five artifacts in four formats.

### Fragments

| Stage | Fact | Artifact | Detail |
|---|---|---|---|
| Option raised | `F-SCD2-OPTION` | **T-04** (architecture review, 14-Apr-2026) | Karthik Subramanian raises SCD2 for DIM_CUSTOMER because a distributor territory reassignment must not restate history |
| Objection | `F-SCD2-OBJECTION` | **EM-041** (16-Apr-2026) only | Farida Contractor: SCD2 adds 12 to 15 minutes on month-end nights, the window has already been breached twice this quarter, 14-Feb and 02-Mar |
| Counter-analysis | `F-SCD2-COUNTER` | **XL-03** (22-Apr-2026), headline echoed in **EM-047** | measured +7 min 28 sec, worst month-end night moves from 04:12 to 04:20 IST, 70 minutes inside the 05:30 SLA |
| Decision | `F-SCD2-DECISION` | **T-05** (design sign-off, 06-May-2026) | SCD2 approved for DIM_CUSTOMER, and for DIM_PRODUCT |
| Rationale of record | `F-SCD2-RATIONALE`, `F-ADR-REGISTER` | **DOC-04** (11-May-2026), ADR-002 | the written rationale, plus the ADR register ADR-001 to ADR-005 |

### Assertions

- **No single artifact contains a complete answer to Q2.**
- T-04 has the option and none of the objection, the evidence, or the outcome.
- EM-041 has the objection and a **wrong number** (12 to 15 minutes). Read alone it suggests SCD2 was
  a bad idea.
- XL-03 has the measurement and no decision. It is a spreadsheet; it does not say what happened next.
- T-05 has the decision and does not restate the analysis.
- DOC-04 has the rationale as written up afterwards. It does not mention Farida Contractor's
  objection at all, which is normal and is the reason "why did we decide this" is not answerable
  from the design document.
- The honest answer needs the objection **and** the counter-analysis, otherwise the rationale reads
  as unopposed, which is a false picture of how the decision was actually taken.
- Related but distinct: **CON-6** in `contradiction_ledger.csv`. DIM_**PRODUCT** was proposed as SCD1
  at T-04 and reversed to SCD2 at T-05 under ADR-003. DIM_**CUSTOMER** was never proposed as anything
  but SCD2. An answer that conflates the two is wrong.

---

## Q3 — "What is actually causing the scheme discount double-count (VAR-003) and who owns it?"

**Type: misdirection plus single-source mechanism.** This is the hardest question in the set and the
one that most clearly defeats naive retrieval, because the *loudest* documents give the wrong cause.

### Fragments

| Stage | Fact | Artifact | Detail |
|---|---|---|---|
| The variance exists, sized and owned | `F-VAR003-IMPACT`, `F-VAR003-OWNER` | **XL-01** (tracker), also in the decks | INR 1.7 Cr, owner Aniruddh Deshpande, Open, opened 24-Mar-2026 |
| **The misdirection** | `F-DBLINK-HYP` | **T-03** (24-Mar-2026), carried in **DK-02** and in XL-01's early root-cause cell | blamed on latency over the `ORION_PRD` database link |
| Misdirection ruled out | `F-DBLINK-RULEDOUT` | **T-04** (14-Apr-2026) | AWR: 4.1 minutes of link wait across the whole load, 38 ms average round trip, 1.2 percent of elapsed. Latency makes a load slow, it does not make an amount wrong |
| The area, without the mechanism | `F-VAR003-AREA` | **DK-03**, **T-05**, **EM-092**, **CH-01**, XL-01 | "source-side, in ORION, not in the ETL" |
| **The mechanism** | `F-TIMING`, `F-ADDITIVE` | **DOC-03 ONLY** | a stored procedure runs after the nightly load and additively rewrites the invoice lines that were already extracted |
| The flawed code itself | `F-ADDITIVE` (code form) | **TECH-PKG** (`pkg_month_end.pkb`) | the additive `UPDATE`, no idempotency guard, a stale header comment claiming it is run manually at month end |
| Who could even do this | `F-GRANT` | **DOC-01**, **TECH-SQL-OLTP** (`schema_oltp.sql`), **EM-092** | `FIN_PROD` holds an UPDATE grant on `OMS_PROD.INVOICE_LINE`, granted 2014, never reviewed |
| Why nobody found it for two months | `F-MANUAL` context, and the Control-M listing | **DOC-02**, **TECH-CTLM** (`control_m_schedule.txt`) | the job inventory covers Control-M and ODI only, and the finance job is in neither |
| Confirmation and decision | `F-VAR003-DECISION` | **T-05**, ADR-004 in **DOC-04** | key-based merge on `INVOICE_LINE_ID`, versioned re-extract, ORION procedure untouched in Phase 1, planned `R2026.09` |

### Assertions

- **No single artifact contains a complete answer to Q3.**
- **DOC-03 is the only artifact in `_sources/` that contains the mechanism.** The sentence
  "P_ADJUST_REVENUE runs at 02:15 IST, after the 01:00 IST nightly load completes" exists once, in
  DOC-03, and `fact_ownership.csv` names every other artifact in its `must_not_appear_in`.
- DOC-03 does **not** contain the ownership, the impact figure, the tracker status, or the decision.
  It is a nine page technical walkthrough. It answers "what" and not "who" or "so what".
- TECH-PKG (`pkg_month_end.pkb`) contains the flawed code and **no schedule**, so the code alone does not
  explain the double-count. The code looks fine if you assume, as its own header comment says, that
  it is run manually once a month.
- TECH-CTLM (`control_m_schedule.txt`) is evidence of **absence**: the job that causes the problem is not in it.
- T-03 read alone gives a **wrong** and confidently stated cause.
- A correct answer must name the mechanism (DOC-03), the owner (XL-01, T-05), and ideally note that
  the first hypothesis was wrong (T-03 plus T-04).

---

## Q4 — "How many dashboards are in scope for go-live?"

**Type: stale trap.**

**The correct answer: 9.**

A naive single-document reader opens `DK-01_kickoff_v3_FINAL.pptx`, reads slide 9, and answers
**12**. Wrong, and wrong by two moves, not one.

### Fragments

| Fragment | Fact | Artifact | Detail |
|---|---|---|---|
| The original scope | `F-DASH12` | **DK-01** slide 9 | 12 dashboards, D01 to D12 |
| The cut | `F-DASH7` | **EM-023** (30-Mar-2026) | down to 7: D01, D03, D05, D06, D07, D09, D12 |
| Why it was cut | `F-DASH7-REASON` | **EM-023** only | Klarissen capex freeze on the BI licence uplift; the other five go to Phase 2 |
| The workshop that does not resolve it | `F-DASH-CANDIDATES` | **T-07** (05-Aug-2026), **DK-05** | seven committed plus two candidates, not funded, deferred to the sponsor |
| The final number | `F-DASH9` | **DK-06** and **T-08** (22-Sep-2026) | 9: the seven plus D04 Scheme Effectiveness and D11 Credit and Receivables Exposure |
| Why nine | `F-DASH9-REASON` | **T-08**, echoed in **DK-06** | D04 and D11 reinstated at Klarissen's request after the credit note escalation and the scheme discount work, funded from the Phase 2 line released in August |

### Assertions

- **No single artifact contains a complete answer to Q4.**
- DK-01 has 12 and no awareness of anything later.
- EM-023 has 7 and the reason, and is superseded five months later.
- T-07 and DK-05, the artifacts an intuitive searcher would reach for because they are literally
  about dashboard scope, **never state a final number at all.** They stop at "seven plus two
  candidates". This is the trap inside the trap: the most topically relevant documents are the least
  conclusive.
- Only DK-06 and T-08 carry 9.
- Note the recorded folklore in `contradiction_ledger.csv` CON-3: people sometimes attribute the
  nine-dashboard figure to "the UAT deck". **There is no UAT deck in this corpus.** A retrieval
  system that goes looking for one finds nothing, which is itself a useful demo moment.

### Single-document failure mode for Q4

> A reader who consults only `DK-01_kickoff_v3_FINAL.pptx` answers **12**. The slide is unambiguous,
> it lists all twelve by name, and the deck is the kickoff deck of record. There is no internal signal
> of staleness.
>
> A reader who consults only the dashboard-scope artifacts (T-07, DK-05) cannot answer at all, and if
> pushed will say **7**, because that is the last committed number those documents contain. Both the
> confident wrong answer and the under-confident wrong answer are on the table, from two different
> plausible retrieval strategies.

---

## Q5 — "Why are credit notes missing from the warehouse, what is the impact, and who escalated it?"

**Type: three-part question, three different fragments, plus a stale figure.**

### Fragments

| Part | Fact | Artifact | Detail |
|---|---|---|---|
| The gap, stated once, as an aside | `F-CNGAP` | **DOC-05 ONLY** (08-Apr-2026) | a parenthetical inside the target model discussion: there is no `FACT_CREDIT_NOTE` in `BCPL_EDW`, credit notes were left out of the 2021 build, Finance nets them by hand in Excel each month, so the warehouse revenue line is gross of them |
| Structural proof of the absence | `F-CN-STRUCT` | **TECH-SQL-EDW** (`schema_edw.sql`) | the warehouse DDL contains no credit note fact table. The absence is silent: no comment, no TODO, no commented-out DDL |
| The data does exist at source | `F-CN-SOURCE` | **TECH-SQL-OLTP** (`schema_oltp.sql`), DOC-01, DOC-05 | `OMS_PROD.CREDIT_NOTE` and `CREDIT_NOTE_LINE`, FY26 9,318 documents |
| The near miss | `F-STG-CN-DORMANT` | **DOC-02** | `STG_CREDIT_NOTE` exists and is empty; `MAP_STG_CREDIT_NOTE` was disabled on 14-Nov-2022 and nothing downstream ever consumed it |
| **The escalation** | `F-CN-ESCALATION` | **EM-061 ONLY** (14-Jul-2026) | Marijke van der Berg, Group CFO, to Rajeev Menon, copying Shalini Iyer and Wei Lin Tan: since when is this known, what is the FY26 number, who owns it, before the next audit call |
| The early, wrong impact | `F-CN-24` | **DK-03** (05-May-2026), repeated once in **T-06** | INR 2.4 Cr, presented without a provisional marker |
| The validated impact | `F-CN-31` | **EM-063** (21-Jul-2026) and **XL-01** | INR 3.11 Cr across 1,206 documents of type `RATE_DIFF` and `OFF_INV_ADJ`, validated against the FY26 trial balance |
| Why the early figure was wrong | `F-CN-METHOD` | **EM-063 ONLY** | it covered Apr-2025 to Dec-2025 only and excluded the `OFF_INV_ADJ` type entirely |
| The tracked variance | `F-VAR005-TITLE` | **XL-01**, decks, T-06, T-08 | VAR-005, owner Shalini Iyer, Open since 24-Apr-2026 |

### Assertions

- **No single artifact contains a complete answer to Q5.**
- DOC-05 says **why** and says it once, in brackets, in the middle of a sixteen page design note. It
  gives no impact and names no escalation, because in April neither existed.
- TECH-SQL-EDW (`schema_edw.sql`) proves the absence but says nothing about why or what it costs. Absence is only
  legible if you already know to look for the table.
- EM-061 is the escalation and contains **no** figure. Marijke is asking for the number, not
  supplying it.
- EM-063 supplies the number and the correction to the earlier estimate, and does not restate the
  root cause.
- DK-03 supplies a figure that is **wrong by 30 percent** and is the most deck-shaped, most
  retrievable statement of the impact in the corpus.
- XL-01 has the validated figure and the variance record, but not the escalation, not the reason,
  and not the history of the estimate. Its Change Log notes an update without repeating the old value.

---

## Q6 — THE WRITE-BACK TEST

**"What did we decide about credit notes for go-live?"**

**Coverage: ZERO. By design.**

The decision exists in the world of the demo. It does not exist in the corpus.

> **The decision.** In early October 2026, verbally, between Shalini Iyer, Karthik Subramanian and
> Ananya Krishnan: `FACT_CREDIT_NOTE` is deferred to Phase 2, and in the interim credit notes are
> netted inside the Power BI semantic model using the monthly Finance Excel file, so that D07 Revenue
> Reconciliation and D11 Credit and Receivables Exposure can go live on 12 November without the
> warehouse table. VAR-005 stays open and moves to the Phase 2 backlog.

This was never minuted, never emailed, never put on a slide, never entered in the tracker. It is what
the presenter introduces live, in the room, to demonstrate write-back: capturing a decision that the
corpus cannot possibly contain.

### Enforcement

`fact_ownership.csv` carries `F-Q6-ABSENT` with `owning_artifact_id = NONE` and every one of the 55
artifact IDs listed in `must_not_appear_in`. **No artifact may state or imply:**

- that a credit note fact table is deferred, planned, backlogged, or scheduled for a later phase;
- that credit notes will be netted, adjusted, or reconciled inside Power BI, inside a semantic model,
  inside a measure, or inside a dataset;
- that D11 or D07 will source credit notes from a Finance file, a manual upload, or a spreadsheet;
- that VAR-005 has an agreed remediation, a target date, or a forward plan of any kind;
- that anyone decided anything about credit notes after 21-Jul-2026.

Where an artifact must discuss D11's data, it says receivables ageing from `AR_OPEN_ITEM` and stops.
VAR-005 stays Open in XL-01 with an empty remediation cell. This silence is load-bearing. An agent
that "helpfully" closes the loop destroys the demo's most important moment.

The tension is deliberately visible and deliberately unresolved: D11 Credit and Receivables Exposure
is in the nine at go-live (DK-06, T-08) while `FACT_CREDIT_NOTE` does not exist (TECH-SQL-EDW, `schema_edw.sql`) and
VAR-005 is still open (XL-01). A sharp viewer will notice the hole. Nothing in the corpus fills it.

### What a correct write-back record would contain

When the presenter captures this decision live, the record written back should contain, at minimum:

| Field | Value |
|---|---|
| Record type | Architecture Decision Record |
| ID | **ADR-006** (next free in the DOC-04 register, which runs to ADR-005) |
| Title | Defer `FACT_CREDIT_NOTE` to Phase 2; net credit notes in the Power BI semantic model for go-live |
| Date | early October 2026, as stated by the presenter |
| Status | Accepted |
| Decision makers | Shalini Iyer (business sponsor, decision owner), Karthik Subramanian (architecture), Ananya Krishnan (delivery) |
| Forum | verbal, not minuted. Record it as such rather than inventing a meeting |
| Context | `BCPL_EDW` has no credit note fact table (VAR-005, open since 24-Apr-2026). Validated FY26 impact INR 3.11 Cr (EM-063). Escalated by the Group CFO on 14-Jul-2026 (EM-061). D07 and D11 are both in the nine dashboards committed for the 12-Nov-2026 go-live (DK-06, T-08) |
| Decision | Do not build `FACT_CREDIT_NOTE` for go-live. Net the revenue-affecting credit note types (`RATE_DIFF`, `OFF_INV_ADJ`) inside the `DRISHTI_SALES` semantic model from the monthly Finance file. Build the fact table in Phase 2 |
| Consequences | credit note figures in Power BI depend on a manual monthly file and inherit its timing and control weaknesses; the warehouse remains gross of credit notes; VAR-005 stays open and is carried into the Phase 2 backlog; a reconciliation note is needed on D07 and D11 |
| Alternatives considered | build `FACT_CREDIT_NOTE` before go-live and accept a slip past 12-Nov; drop D11 from the go-live scope and return to seven dashboards |
| Links | VAR-005; `F-CNGAP` in DOC-05; EM-061; EM-063; XL-01; DK-06; ADR register in DOC-04 |
| Follow-up | Shalini Iyer to confirm the Finance file cadence and owner. Review at the first hypercare checkpoint |
| Artifacts that would need updating if this were real | XL-01 VAR-005 row (remediation and target date), DOC-04 ADR register (add ADR-006), DOC-05 (the gap note), the D11 and D07 data source notes |

---

## SUMMARY TABLE — where every answer lives

| Q | Correct answer | Wrong answer a single document gives | Minimum artifacts to answer correctly | Formats crossed |
|---|---|---|---|---|
| Q1 | 12 November 2026 | 15 Sep 2026 (DK-01), or 30 Oct 2026 (EM-068) | DK-01 or T-01, EM-068, T-08 or DK-06 | deck, email, transcript |
| Q2 | Territory reassignment must not restate history; the load-window objection was measured and disproved | "because the design document says so" (DOC-04) | T-04, EM-041, XL-03, T-05, DOC-04 | transcript, email, spreadsheet, document |
| Q3 | A source-side finance procedure rewrites already-extracted invoice lines additively; owner Aniruddh Deshpande | "DBLINK latency" (T-03, DK-02) | T-03, T-04, DOC-03, XL-01, TECH-PKG | transcript, document, spreadsheet, code |
| Q4 | 9 | 12 (DK-01), or 7 (T-07, DK-05) | DK-01, EM-023, DK-06 or T-08 | deck, email, transcript |
| Q5 | No fact table was ever built and Finance nets in Excel; INR 3.11 Cr; escalated by Marijke van der Berg | INR 2.4 Cr (DK-03) | DOC-05, TECH-SQL-EDW, EM-061, EM-063, XL-01 | document, DDL, email, spreadsheet |
| Q6 | nothing in the corpus | any answer at all is a hallucination | none exist. This is the write-back test | none |

---

SYNTHETIC — generated for internal demo. No real entity depicted.
