# CANON.md — Project "Bharadwaj" demo corpus master fact sheet

**Status: BINDING. Phase A output. Every downstream generation agent MUST read this file end to end before writing a single artifact.**

Authored: Phase A, generation seed `20260822`
Version: 1.1 (frozen after Phase A exit-gate reconciliation, 22-Aug-2026)
Scope: this file, together with `timeline.csv`, `variance_register_canon.csv`, `terminology_map.csv`,
`contradiction_ledger.csv`, `demo_answer_map.md`, `fact_ownership.csv`, `pii_plant_register.csv`,
and the technical companions `schema_canon.sql`, `procs_canon.sql`, `odi_canon.md` and
`procs_canon.md` (see §20), is the complete set of permitted facts for the corpus.
Nothing outside `_canon/` is a source of fact. `VALIDATION.md` records what the exit gate
checked and what it changed; it is a record, not a source of fact.

---

## 0. HOW TO USE THIS FILE

1. If a fact (a table, a column, a person, a date, a figure, an ID, a system, a filename) is **not in
   the Canon**, you do not invent it. You omit it, or you phrase around it.
2. `fact_ownership.csv` overrides everything. If a fact's `must_not_appear_in` column names your
   artifact ID, that fact must not appear in your output in any form, paraphrase, hint, allusion,
   rounded restatement, or "as discussed in..." pointer that reveals the value.
3. This file is **canon-internal**. It is not part of `_sources/`. Nothing in `_canon/` is ever
   distributed with the corpus, and no artifact may cite, quote, or reference a `_canon/` file.
4. Where this file states a fact that is flagged **EXCLUSIVE**, canon states it so that you can *avoid*
   it. Read the exclusivity banner. Do not reproduce.
5. Numbers are exact and frozen. Do not recompute, re-round, or "improve" them. If you need a number
   that is not here, look again; if it genuinely is not here, do not use a number at all.
6. All random choices in generator scripts are seeded with `20260822`. No network calls.
7. `_canon/` holds files from more than one Phase A agent. They were **reconciled at the
   exit gate on 22-Aug-2026** and no longer disagree. **Read §20 before using**
   `schema_canon.sql`, `procs_canon.md`, `odi_canon.md` or `procs_canon.sql`. This file still
   wins over all four on any point of difference, §20.2 closes the object universe and lists
   the dead names from the superseded drafts, and §20.3 fixes the audit column spelling.

---

## 1. THE SWAP TOKEN

The consultancy is called **Northlane Analytics**.

The literal string `Northlane Analytics` is the **single swap token** for this corpus. It is intended
to be find-and-replaced with a real consultancy name before a live demo. Therefore:

- Always write it in full and exactly as `Northlane Analytics`. Never abbreviate it to "Northlane",
  "NLA", "NA", "the Northlane team", or any inflected form in any artifact.
  Correct: "Northlane Analytics will own the mapping build."
  WRONG: "Northlane will own the mapping build." / "NLA to own." / "our Northlane colleagues".
- Refer to the firm generically as "the consultancy", "the delivery partner", "the vendor",
  "the Analytics partner", or by naming the individuals, when you want variety.
- The email domain `northlaneanalytics.example` is a second, separate swap token and must always
  appear exactly in that form (lowercase, one word).
- Do not build the token into compound words, filenames, footers with different casing, or
  possessives with punctuation ("Northlane Analytics'" is acceptable; "Northlane's" is not).

No other string in the corpus is a swap token. The client name `Bharadwaj Consumer Products Ltd` and
the parent `Klarissen Group N.V.` stay as they are.

---

## 2. FISCAL CALENDAR — READ THIS TWICE

Bharadwaj Consumer Products Ltd runs an **April to March** fiscal year. The fiscal year is named for
the calendar year in which it **ends**.

> **FY26 = 01 April 2025 to 31 March 2026.**
> **FY27 = 01 April 2026 to 31 March 2027.**

Quarters, spelled out, no exceptions:

| Fiscal quarter | Calendar months |
|---|---|
| FY26 Q1 | Apr 2025, May 2025, Jun 2025 |
| FY26 Q2 | Jul 2025, Aug 2025, Sep 2025 |
| FY26 Q3 | Oct 2025, Nov 2025, Dec 2025 |
| FY26 Q4 | Jan 2026, Feb 2026, Mar 2026 |
| FY27 Q1 | Apr 2026, May 2026, Jun 2026 |
| FY27 Q2 | Jul 2026, Aug 2026, Sep 2026 |
| FY27 Q3 | Oct 2026, Nov 2026, Dec 2026 |
| FY27 Q4 | Jan 2027, Feb 2027, Mar 2027 |

Consequences that every agent must respect:

- The engagement runs **Feb 2026 (FY26 Q4) to Nov 2026 (FY27 Q3)**. Go-live falls in **FY27 Q3**.
- "FY26 Q1 revenue overstated" (VAR-001) refers to **Apr-Jun 2025**, which is historic data, roughly
  nine months in the past at the time it is discovered in March 2026. Nobody in the corpus talks
  about FY26 Q1 as "this quarter".
- FY26 closes on 31 Mar 2026, six weeks after kickoff. The FY26 year-end close is happening *during*
  discovery. This is why Finance is short-tempered in March and April.
- FY27 planning is live from Feb 2026. Klarissen's budget rate for FY27 is fixed (see §4).
- Written forms permitted: `FY26`, `FY26 Q1`, `FY2026` (rare, Klarissen only), `Q1 FY26`.
  Never `FY 26`, never `fiscal 2026`, never `2026 Q1` for a fiscal quarter.
- Klarissen Group N.V. reports on a **January to December** calendar year. This mismatch is real and
  is mentioned occasionally by Marijke van der Berg and Wei Lin Tan. Klarissen's group close blackout
  window (26 Oct - 06 Nov 2026 CET) is what finally moves the go-live date.

---

## 3. THE CLIENT

**Bharadwaj Consumer Products Ltd** ("BCPL"), incorporated in India, FMCG.

| Attribute | Canonical value |
|---|---|
| Registered / head office | Bharadwaj House, Chakala, Andheri East, Mumbai 400093 |
| Founded | 1994 |
| Listed | No. 62% held by Klarissen Group N.V., balance held privately by the founding family and two domestic funds |
| FY25 net revenue (Apr 2024-Mar 2025) | INR 1,764 Cr |
| FY26 net revenue (Apr 2025-Mar 2026) | INR 1,842 Cr |
| FY26 EBITDA margin | 11.2% |
| Employees | approx. 2,400 (approx. 610 field sales) |
| Manufacturing plants | Nashik (Maharashtra) and Baddi (Himachal Pradesh) |
| Depots / CFAs | 22 |
| Distributors | **340** |
| Active SKUs | 862 (1,246 SKUs in master, incl. delisted) |
| Regions | North, West, South, East |

FY26 net revenue by quarter (use these, do not derive your own):

| Quarter | Reported (INR Cr) | Note |
|---|---|---|
| FY26 Q1 | 438.6 | later restated to 434.4 after VAR-001 fix |
| FY26 Q2 | 452.1 | |
| FY26 Q3 | 476.9 | festive season |
| FY26 Q4 | 474.4 | |
| **FY26 total** | **1,842.0** | restated 1,837.8 |

Distributor count by region: North 96, West 88, South 84, East 72. Total 340.
Depot count by region: North 6, West 6, South 5, East 5. Total 22.

Plants:
- **Nashik** — Home Care and Foods. Two lines. Feeds West, North, and part of South.
- **Baddi** — Personal Care and Hygiene. Fiscal-benefit zone unit, commissioned 2011. Feeds North and East.
  Baddi is transcribed by the meeting platform as "Buddy" (see `terminology_map.csv`, kind=asr).

Brands and categories (the whole product universe — do not invent brands):

| Brand code | Brand | Category | Plant | HSN | GST rate |
|---|---|---|---|---|---|
| SUV | Suvarn | Home Care (detergent powder / bar) | Nashik | 3402 | 18% |
| NMB | Nimbua | Home Care (dishwash bar / liquid) | Nashik | 3402 | 18% |
| KSG | Kesari Gold | Personal Care (hair oil) | Baddi | 3305 | 18% |
| CHD | Chandanaa | Personal Care (bathing soap) | Baddi | 3401 | 18% until 30-Sep-2025, **12% from 01-Oct-2025** |
| TRG | Tarang | Foods (tea) | Nashik | 0902 | 5% |
| RKS | Rakshak | Hygiene (handwash / floor cleaner) | Baddi | 3808 | 18% |

The Chandanaa (HSN 3401) rate change effective **01 October 2025** is the trigger for VAR-006.

Canonical SKU list (use these codes anywhere sample data is needed; 12 of the 862 active SKUs):

| SKU_ID | SKU_CODE | Description | Pack | UOM | MRP (INR) |
|---|---|---|---|---|---|
| 100411 | SUV-DP-1KG | Suvarn Detergent Powder 1 kg | 1 kg | KG | 185.00 |
| 100412 | SUV-DP-500G | Suvarn Detergent Powder 500 g | 500 g | KG | 99.00 |
| 100418 | SUV-DB-250G | Suvarn Detergent Bar 250 g | 250 g | EA | 32.00 |
| 100633 | NMB-DW-500ML | Nimbua Dishwash Liquid 500 ml | 500 ml | LT | 129.00 |
| 100634 | NMB-DB-190G | Nimbua Dishwash Bar 190 g | 190 g | EA | 22.00 |
| 101207 | KSG-HO-200ML | Kesari Gold Hair Oil 200 ml | 200 ml | LT | 165.00 |
| 101208 | KSG-HO-100ML | Kesari Gold Hair Oil 100 ml | 100 ml | LT | 92.00 |
| 101455 | CHD-SP-100G | Chandanaa Soap 100 g | 100 g | EA | 45.00 |
| 101456 | CHD-SP-4X100G | Chandanaa Soap 4x100 g pack | 400 g | EA | 168.00 |
| 101902 | TRG-TEA-250G | Tarang Tea 250 g | 250 g | KG | 145.00 |
| 101903 | TRG-TEA-1KG | Tarang Tea 1 kg | 1 kg | KG | 540.00 |
| 102310 | RKS-HW-200ML | Rakshak Handwash 200 ml | 200 ml | LT | 99.00 |

Canonical depot codes (12 of the 22, use these):
`DEP-MUM-01` Bhiwandi (West), `DEP-PUN-02` Pune (West), `DEP-AHM-03` Ahmedabad (West),
`DEP-DEL-04` Ghaziabad (North), `DEP-JAI-05` Jaipur (North), `DEP-LKO-06` Lucknow (North),
`DEP-CHD-07` Panchkula (North), `DEP-BLR-08` Bengaluru (South), `DEP-CHE-09` Chennai (South),
`DEP-HYD-10` Hyderabad (South), `DEP-KOL-11` Kolkata (East), `DEP-GUW-12` Guwahati (East).

Canonical distributor codes (use these when a named example is needed; names are firm names, not people):
`DIST-N-0142` Trilok Traders, Ghaziabad (North)
`DIST-N-0187` Raunaq Agencies, Jaipur (North)
`DIST-W-0233` Sahyog Enterprises, Bhiwandi (West)
`DIST-W-0241` Mahalaxmi Distributors, Pune (West)
`DIST-S-0318` Anantha Marketing, Bengaluru (South)
`DIST-S-0352` Vaigai Agencies, Madurai (South)
`DIST-E-0409` Bhattacharya & Sons, Howrah (East)
`DIST-E-0417` Kamrup Sales Corp, Guwahati (East)

`DIST-W-0241` Mahalaxmi Distributors is the worked example for VAR-004 (territory reassignment on
17 Apr 2026 from territory `TER-W-014` to `TER-W-011`). Use it whenever a concrete VAR-004 case is needed.

Scheme master (the whole scheme universe for the corpus):

| SCHEME_ID | SCHEME_CODE | Name | Type | Basis |
|---|---|---|---|---|
| 5501 | QPS-Q1-SUV | Suvarn quarterly purchase scheme | QPS | slab on quarterly cases |
| 5514 | MTH-CHD-OCT | Chandanaa monthly off-take scheme | MONTHLY | flat 4% |
| 5522 | SLB-TRG-FEST | Tarang festive slab | SLAB | 2%/3.5%/5% by slab |
| 5533 | TPR-NMB-SOUTH | Nimbua price reduction, South | TPR | INR 2 per unit |
| 5540 | QPS-KSG-H2 | Kesari Gold half-year scheme | QPS | slab on half-year cases |

---

## 4. THE PARENT

**Klarissen Group N.V.**, Netherlands. Registered office Amsterdam. Acquired **62%** of BCPL in
**2023** (share purchase completed 14 August 2023). Klarissen is a consumer-goods holding group with
operating companies in six countries; BCPL is its only Indian asset and its second-largest by revenue.

- Reporting calendar: **January to December**.
- Group reporting currency: **EUR**.
- FY27 group budget rate, frozen: **EUR 1 = INR 92.40**. Every EUR conversion in the corpus uses this
  rate and only this rate. (INR 3.11 Cr = EUR 336.8k. INR 1.7 Cr = EUR 184.0k. INR 13.85 Cr = EUR 1.50m.)
- Group close blackout for the November close: **26 Oct - 06 Nov 2026 CET**. No system cutover in any
  operating company is permitted inside this window. This is what moves the go-live to 12 Nov 2026.
- Klarissen mandated the BI programme. The business case sits with Group Finance, not with BCPL IT.
- Klarissen people write in CET/CEST and say "channel partner", never "distributor" and never "stockist".
- Klarissen email domain: `klarissen.example`.

CET/CEST note: Central European **Summer** Time (UTC+2) applies from 29 Mar 2026 to 25 Oct 2026. Before
and after that, CET is UTC+1. IST is UTC+5:30 all year. SGT is UTC+8 all year. Get the offsets right in
email headers and in "your 3pm is my..." remarks.

---

## 5. THE CONSULTANCY AND THE ENGAGEMENT

**Northlane Analytics** (swap token, see §1). India-based data and analytics consultancy, delivery
office in Bengaluru, client-facing team works out of BCPL's Andheri East office two to three days a week.

| Attribute | Canonical value |
|---|---|
| Client programme name | **Project Drishti** |
| Engagement code | `NL-BCPL-2026-014` |
| SOW reference | `NL-SOW-2026-014-R2`, signed 28 Jan 2026 |
| Client PO | `BCPL/IT/2026/00417` |
| Fee | INR 3.85 Cr excluding taxes, time and materials, capped |
| Duration | 42 weeks, 11 Feb 2026 to 11 Dec 2026 (inclusive of hypercare) |
| Team | 6 named consultants plus two unnamed offshore developers in Bengaluru |
| Steering committee | monthly; chaired by Rajeev Menon |

Programme phases (these are the only phase names permitted):

| Phase | Name | Window |
|---|---|---|
| Phase 1 | Discovery and Variance Root Cause | 11 Feb - 08 May 2026 |
| Phase 2 | Remediation and EDW Rebuild | 11 May - 25 Sep 2026 |
| Phase 3 | Power BI Build and UAT | 03 Aug - 06 Nov 2026 |
| Phase 4 | Cutover, Go-live and Hypercare | 07 Nov - 11 Dec 2026 |

Careful: "Phase 2" is used in TWO senses in this corpus and that ambiguity is deliberate and human.
(a) the programme phase above, and (b) "Phase 2" meaning "the next funded tranche of work after
go-live", which is where deferred scope goes (the credit-note fact table, the five dropped dashboards).
Sense (b) is the more common usage from Aug 2026 onward. Do not try to disambiguate it in artifacts.

Working conventions the corpus should reflect:
- Weekly working session Tuesday 16:00 IST (not minuted, referenced in passing).
- Status report every Friday from Ananya Krishnan (referenced, never generated as an artifact).
- Meeting recordings retained 90 days on the client tenant. Transcripts are auto-generated and bad.
- Sneha Pillai writes the circulated notes; the raw `.vtt` is the platform's auto-transcript.

---

## 6. NAME REGISTRY

This is the **complete and closed** list of named human beings in the corpus. Fifteen people. No agent
may introduce a sixteenth named person, not as a passing mention, not as an email cc, not as a
"someone from the Control-M team called X", not in a chat handle, not in a document property, not in a
sample data row, not as a Power BI report author, not in a footer.

Where a role needs to be referenced and no cast member fits, use an **unnamed role reference**:
"the Control-M administrator", "the Klarissen internal audit team", "the offshore developers",
"someone in Finance", "the Nashik plant IT contact", "the ORION support vendor".

### 6.1 People

| # | Name | Organisation | Origin of name | Email |
|---|---|---|---|---|
| 1 | Rajeev Menon | BCPL | Indian (Kerala) | rajeev.menon@bharadwajcp.example |
| 2 | Shalini Iyer | BCPL | Indian (Tamil) | shalini.iyer@bharadwajcp.example |
| 3 | Aniruddh Deshpande | BCPL | Indian (Maharashtra) | aniruddh.deshpande@bharadwajcp.example |
| 4 | Farida Contractor | BCPL | Indian (Parsi, Mumbai) | farida.contractor@bharadwajcp.example |
| 5 | Vikram Sethi | BCPL | Indian (Punjabi, Delhi) | vikram.sethi@bharadwajcp.example |
| 6 | Priya Nair | BCPL | Indian (Kerala) | priya.nair@bharadwajcp.example |
| 7 | Meghna Rao | BCPL | Indian (Karnataka) | meghna.rao@bharadwajcp.example |
| 8 | **Marijke van der Berg** | Klarissen Group N.V. | **NON-INDIAN (Dutch)** | marijke.vanderberg@klarissen.example |
| 9 | **Wei Lin Tan** | Klarissen Group N.V. | **NON-INDIAN (Singaporean Chinese)** | weilin.tan@klarissen.example |
| 10 | Ananya Krishnan | Northlane Analytics | Indian (Tamil) | ananya.krishnan@northlaneanalytics.example |
| 11 | Karthik Subramanian | Northlane Analytics | Indian (Tamil) | karthik.subramanian@northlaneanalytics.example |
| 12 | Ishaan Bhatt | Northlane Analytics | Indian (Gujarat) | ishaan.bhatt@northlaneanalytics.example |
| 13 | Neha Gokhale | Northlane Analytics | Indian (Maharashtra) | neha.gokhale@northlaneanalytics.example |
| 14 | Ritwik Ghosh | Northlane Analytics | Indian (Bengal) | ritwik.ghosh@northlaneanalytics.example |
| 15 | Sneha Pillai | Northlane Analytics | Indian (Kerala) | sneha.pillai@northlaneanalytics.example |

> **ASSERTION: exactly two (2) of the fifteen names in this corpus are non-Indian: Marijke van der Berg
> and Wei Lin Tan. Introducing a third non-Indian personal name anywhere in `_sources/` is a hard
> failure of the run.**

Email address spelling, frozen. Note the deliberate irregularity on #8:
- BCPL staff: `firstname.lastname@bharadwajcp.example`, all lowercase.
- Northlane Analytics staff: `firstname.lastname@northlaneanalytics.example`, all lowercase.
- Klarissen staff: `@klarissen.example`. Marijke's address is **`marijke.vanderberg@klarissen.example`**
  (the surname is compressed to one token by the Klarissen directory; she signs herself
  "Marijke van der Berg" and her mail display name is "van der Berg, Marijke"). Wei Lin Tan's address
  is **`weilin.tan@klarissen.example`**, display name "Tan, Wei Lin".
- Do not use initials-based addresses, do not use `@bcpl.example`, do not use `.com` anywhere.

Display-name conventions in `.eml` headers:
- BCPL and Northlane Analytics: `Firstname Lastname <address>` e.g. `Shalini Iyer <shalini.iyer@bharadwajcp.example>`
- Klarissen: `Lastname, Firstname <address>` e.g. `van der Berg, Marijke <marijke.vanderberg@klarissen.example>`

Distribution lists that exist (use freely, they are not people):
`bcpl-datawarehouse@bharadwajcp.example` (BCPL DW team: Farida, Ani, Priya, Meghna)
`bcpl-financesystems@bharadwajcp.example` (Shalini's team)
`drishti-core@northlaneanalytics.example` (the six named consultants)
`drishti-steerco@bharadwajcp.example` (Rajeev, Shalini, Vikram, Marijke, Ananya, Karthik)
`orion-support@bharadwajcp.example` (unmanned ticket queue)

### 6.2 Organisations

| Organisation | Role | Notes |
|---|---|---|
| Bharadwaj Consumer Products Ltd (BCPL) | the client | |
| Klarissen Group N.V. | 62% parent | |
| Northlane Analytics | the consultancy | SWAP TOKEN |
| Sahyadri Softech Pvt Ltd | built ORION in 2009 | relationship ended 2014, no design documents survive, referenced only in DOC-01, T-02 and CH-01. Nobody at BCPL has a contact there any more. |

No other organisation may be named. Software products named in the Canon (Oracle, Oracle Data
Integrator, OBIEE, Power BI, Control-M, Microsoft Teams, WhatsApp, Excel, SharePoint) are permitted
because the brief mandates them; they are products, not depicted entities.

### 6.3 Non-human names that are fixed

Hosts, schemas, jobs, workspaces and the like are listed in §8 and §9. Do not invent new ones.

---

## 7. CAST PROFILES

Each profile is binding: title, tenure, how they write, what they always say. Downstream agents must
keep every person's voice and vocabulary identical across the whole corpus. If two artifacts show the
same person writing differently, the corpus is broken.

### 7.1 BCPL

**Rajeev Menon — Chief Information Officer, BCPL.** Joined 2021 (5 years). Mumbai. Reports to the MD,
dotted line to Klarissen Group IT.
*Style:* very short. Two or three lines. Forwards things with a one-word comment on top ("Thoughts?",
"Please handle."). Chairs steerco, talks in outcomes and money, has no patience for schema detail.
Signs "Rajeev" or nothing at all. Sends mail from his phone in the evening, so occasional lowercase
starts and a "Sent from my phone" style truncation is in character.
*Pet phrase:* "let's not boil the ocean".
*Vocabulary:* "distributor", "variance", "the number", "the board pack".
*Sample:* `Ananya - noted. Let's not boil the ocean here. Only thing I care about for the 22nd is the date and the number of dashboards. Rajeev`

**Shalini Iyer — Head of Finance Systems, BCPL. Primary business sponsor.** 9 years at BCPL, 4 in this
role. Mumbai. Reports to the CFO of BCPL, works closely with Klarissen Group Finance.
*Style:* organised. Numbered lists. Always quotes figures to two decimals and always states the period
they belong to. Polite but relentless; chases with "gentle reminder" and then with a shorter mail.
Uses "Please find attached" and "Regards, Shalini". Writes during office hours, occasionally 07:20 IST.
*Pet phrase:* "can we tie this back to the trial balance?"
*Vocabulary:* she says **"trade promotion accrual"** for scheme discounts, **"reconciliation gap"** for
variance, "distributor", "credit note", "net revenue". She never says "stockist" and never says "delta".
*Sample:* `Karthik, 1. The Apr-Jun number in the extract is 438.60 Cr, my trial balance says 434.40 Cr. 2. That is a reconciliation gap of 4.20 Cr and I cannot sign the pack until it is explained. 3. Can we tie this back to the trial balance before Friday? Regards, Shalini`

**Aniruddh "Ani" Deshpande — Senior Oracle DBA, BCPL.** 14 years at BCPL, the longest-serving person on
the programme and the only one who was present when ORION was built. Mumbai. Institutional memory:
he remembers why things are the way they are and he is usually right.
*Style:* writes late at night, 22:30 to 01:30 IST, almost always. Long run-on sentences joined by
commas and "and". **Drops articles** ("job was failing", "table is having 61 million rows", "issue is
with the flag only"). Lowercase starts. Few full stops, lots of commas. Occasionally answers a question
you did not ask, with something crucial in the middle of it. Signs "-ani" or "ani". Everyone calls him
Ani; the meeting platform transcribes it as "Annie".
*Pet phrase:* "we did this in 2017 also".
*Vocabulary:* "scheme discount", "delta", "stockist" is NOT his word, he says "distributor" or
"party" (trade usage: "party master", "party code"). Says "proc" not "stored procedure". Says "the box"
for a server.
*Sample:* `farida this is coming since long, we did this in 2017 also, the flag was added later only so old rows are blank and if you put equal to N in filter then all old data will vanish, i had told this in the mail last year also, will check tomorrow morning after the run -ani`

**Farida Contractor — ODI/ETL Lead, BCPL.** 6 years at BCPL, previously 8 years elsewhere in ETL.
Mumbai. Owns the nightly load and the Control-M folder. Defensive about the load window because she
is the one who gets called at 05:00 when the SLA is missed.
*Style:* precise and slightly formal. Numbered points, timestamps everything to the minute, quotes job
names and session numbers. Says "as per my earlier mail" and means it. Attaches logs. Pushes back
hard on anything that adds elapsed time, then accepts evidence when it is given properly.
*Pet phrase:* "the window is the window".
*Vocabulary:* she says **"interface"** for an ODI mapping (a habit from ODI 11g), "load window",
"session", "scenario", "the run". She says "distributor". For scheme discounts she says
**"secondary scheme"** or "the scheme amount". Says "reconciliation" not "variance" when she can.
*Sample:* `Karthik, as per my earlier mail dated 16-Apr. 1. The interface for DIM_CUSTOMER currently runs 4 min 12 sec. 2. On month end nights the full run finishes 04:10-04:12. 3. We have already breached twice this quarter, 14-Feb and 02-Mar. The window is the window. If you can show me the measured number I will look at it again. Farida`

**Vikram Sethi — National Sales Operations Manager, BCPL.** 11 years at BCPL. Based Delhi, travels
constantly, mails from airports. **He is the person whose numbers never match.** Partly because he
quotes secondary sales when everyone else is quoting primary sales, partly because he works from a
spreadsheet that a regional coordinator maintains, and partly because he does not filter cancelled
invoices out of his own extract.
*Style:* fast and untidy. Lowercase starts, missing full stops, "pls", "revert" (meaning reply),
"do the needful", "kindly confirm". Typos he does not correct: "recieved", "seperate", "teh", "figuers".
Sends one-line mails and then three more in the next ten minutes. Attaches the wrong version.
*Pet phrase:* "my number is coming different".
*Vocabulary:* he says **"stockist"** for distributor, ALWAYS, without exception, in every artifact.
He says **"TPR"** and **"secondary scheme"** loosely for anything promotional. He says "billing" for
primary sales and "off-take" for secondary sales. He says "primary" and "secondary" as bare nouns.
He never says "channel partner". He never says "distributor".
*Sample:* `team my number is coming different again, north stockist billing for aug i am getting 41.7 cr but the report is showing 39.2 cr, pls check. also the TPR amount is not matching for nimbua south. kindly revert today itself as i have to send to rajeev sir. vikram`

**Priya Nair — BI Analyst, BCPL.** 3 years at BCPL, came in as an OBIEE report developer. Mumbai.
She is the person who actually knows what every legacy report contains and who uses it.
*Style:* helpful, slightly deferential to the consultants, careful. Uses "Kindly", "Just to confirm
my understanding", "Please correct me if I am wrong". Refers to screenshots she has attached.
Asks good clarifying questions. Long-ish emails with clear structure.
*Pet phrase:* "just to confirm my understanding".
*Vocabulary:* OBIEE vocabulary that does not map to Power BI: **"report"** (for what Ritwik calls a
"page"), **"prompt"** (for slicer/filter), **"dashboard page"**, "analysis", "agent" (for a scheduled
delivery). She says "distributor" and "scheme discount".
*Sample:* `Hi Ritwik, Just to confirm my understanding - in the new tool the prompt values will be shared across the whole report, or per page? In OBIEE we have one dashboard prompt at the top and all the analyses below it pick it up. Kindly clarify. Also attaching screenshot of the existing Distributor Scorecard report for reference. Thanks, Priya`

**Meghna Rao — Data Quality Analyst, BCPL.** 2 years at BCPL, first job was in a BPO reconciliation
team. Bengaluru, works remote, joins meetings on audio only.
*Style:* crisp and quantitative. Always cites row counts and percentages and always states the run
date the numbers came from. Slightly over-qualifies ("approximately", "as of the 31-May run",
"on a sample of 10,000 rows"). Short paragraphs. Rarely offers an opinion unless asked directly.
*Pet phrase:* "on a sample of...".
*Vocabulary:* "row count", "null rate", "profiling run", "failure", "distributor". She says
"scheme discount". She says "variance" only in the DQ sense (a rule failure count), which sometimes
confuses Finance.
*Sample:* `As of the 31-May profiling run: DELETE_FLAG is Y on 5,380,708 rows (8.7%), N on 47,251,124 (76.4%) and null on 9,215,388 (14.9%). On a sample of 10,000 of the null rows, all were created before 01-Apr-2019. Meghna`

**Marijke van der Berg — Group Chief Financial Officer, Klarissen Group N.V.** Amsterdam, CET/CEST.
On the BCPL board. She sponsored the programme at group level and she reads the numbers herself.
*Style:* **terse.** Two to four lines, no greeting, no sign-off beyond "M" or nothing. Never uses
exclamation marks. Asks one question and expects an answer to that question. When she is unhappy she
gets shorter, not longer. Writes at 07:xx or 19:xx CET. Occasionally a very slightly non-native
construction ("Since when is this known?", "This is since when open?"). Never rude, never warm.
*Pet phrase:* "Please advise."
*Vocabulary:* she says **"channel partner"**, ALWAYS, never "distributor" and never "stockist".
She says "credit note", "promo accrual" for scheme discounts, "the walk" or "the bridge" for a
variance explanation, "EUR" not "€" in email body text. She refers to BCPL as "India" ("the India
numbers", "your India close").
*Sample:* `Rajeev, the India channel partner credit notes are not in the warehouse at all. Since when is this known? I need the FY26 number and who owns it before the next audit call. Please advise. M`

**Wei Lin Tan — Group FP&A Manager, Klarissen Group N.V.** Singapore, SGT. Reports to Marijke.
Consolidates the operating companies and builds the group pack.
*Style:* structured and neutral. Bullet points. Always states the timezone when proposing a time
("14:00 SGT / 11:30 IST / 08:00 CEST"). Asks for reconciliations as "walks" or "bridges". Attaches
a template and asks for it back in that template. Signs "Wei Lin".
*Pet phrase:* "can you send the bridge?"
*Vocabulary:* "channel partner", "sell-in" for primary sales, "sell-out" for secondary sales,
"promo accrual", "constant currency", "the group pack", "EUR". Uses the 92.40 budget rate.
*Sample:* `Hi Ananya, Two things before Thursday: - Can you send the bridge from the 438.6 reported to the restated number, by month? - For the group pack I need it in EUR at 92.40. Happy to take a call 14:00 SGT / 11:30 IST / 08:00 CEST. Wei Lin`

### 7.2 Northlane Analytics

**Ananya Krishnan — Engagement Lead.** 9 years in consulting, 2 with Northlane Analytics. Bengaluru,
in Mumbai two or three days a week. Owns the client relationship and the plan.
*Style:* warm and structured. Opens with one line of context, then the substance, then owners and
dates. Uses "flagging", "to close the loop", "parking that for now", "I'll take that away".
Always ends an email with who does what by when. Sends the Friday status. Slightly too many
adverbs when she is managing bad news.
*Pet phrase:* "parking that for now".
*Vocabulary:* "distributor", "variance", "workstream", "the tracker", "scheme discount".
*Sample:* `Hi Shalini, To close the loop on Tuesday's discussion. We've re-cut the plan and I want to flag it before the steerco rather than in it. Detail below. Actions: Karthik to confirm the load impact by Fri 24th, I'll circulate a revised plan on Mon 27th. Parking the Phase 2 conversation for now. Best, Ananya`

**Karthik Subramanian — Data Architect.** 12 years, 5 with Northlane Analytics. Chennai, travels to
Mumbai. Writes the ADRs and the design documents. He is the one who works out what is actually wrong.
*Style:* precise, numbered, unhurried. Defines terms before using them. Writes in complete sentences
even in chat. Puts a "Context / Decision / Consequences" structure on anything important. Will say
"I don't know yet" and then say when he will know.
*Pet phrase:* "what's the grain?"
*Vocabulary:* he says **"SCD2"**, ALWAYS, in every artifact, never "slowly changing dimension type 2",
never "type 2", never "SCD Type 2". Also "grain", "conformed dimension", "surrogate key",
"effective dating", "late-arriving dimension", "idempotent". He says "distributor" and
"scheme discount". He says "variance".
*Sample:* `Farida, understood, and the concern is fair. Two things. 1. The measured cost of SCD2 on DIM_CUSTOMER is 7 min 28 sec, not 12-15, and I've put the measurement in the attached. 2. Even on the worst month-end night in the sample the run lands at 04:20, which is 70 minutes inside the SLA. If you want I'll walk through the model on Thursday. Karthik`

**Ishaan Bhatt — Analytics Engineer.** 4 years, all with Northlane Analytics. Ahmedabad, remote,
in Mumbai for the big weeks. Builds the mappings and does the digging.
*Style:* casual and fast. Lowercase in chat. Inline code and backticks. "yep", "quick one", "ah wait",
"ignore my last". Corrects himself in the next message rather than editing. In email he is more formal
but still short. Ends with "pushed a fix" or "will look".
*Pet phrase:* "pushed a fix".
*Vocabulary:* "mapping" (not "interface"), "the fact", "the dim", "merge", "distributor",
"scheme discount", "dupes". Says "SCD2" because Karthik says it.
*Sample:* `quick one - the 61 dupes are all customers who moved territory. both rows have CURRENT_FLG = 'Y' so the fact joins twice. checking whether the eff end date is being set to sysdate instead of sysdate-1. ah wait, ignore my last, it is being set to the same timestamp as the new row's start`

**Neha Gokhale — Data Quality Lead.** 7 years, 3 with Northlane Analytics. Pune. Runs the DQ
assessment and owns the rule set.
*Style:* rule-driven. Everything gets an ID (`DQ-R-07`) and a threshold and a materiality statement.
Tables rather than paragraphs. Will not accept a defect report that does not say which rule failed.
Polite but immovable about definitions.
*Pet phrase:* "against which rule?"
*Vocabulary:* "DQ rule", "threshold", "materiality", "completeness / validity / consistency /
uniqueness / timeliness" (the five dimensions she uses, in that order), "defect", "distributor".
*Sample:* `Vikram, before we chase this - against which rule? If it is completeness, that is DQ-R-04 and the threshold is 99.5%; we are at 98.0% on SKU which is a fail. If it is the value not matching, that is a different conversation and it belongs with the reconciliation, not with DQ. Neha`

**Ritwik Ghosh — BI Developer.** 5 years, 2 with Northlane Analytics. Kolkata, remote. Builds the
Power BI reports and the wireframes.
*Style:* visual and opinionated about layout. Talks in "tiles", "visuals", "slicers", "measures",
"one page one message". Asks about audience before he asks about data. Occasional Bengali-English
sentence tags ("no?", "na?"). Sends screenshots constantly.
*Pet phrase:* "one visual, one message".
*Vocabulary:* "page" (where Priya says "report"), "slicer" (where Priya says "prompt"), "measure",
"tile", "card", "bookmark", "distributor". Says "scheme discount".
*Sample:* `Priya - in Power BI the slicer sits on the page, and I can sync it across pages if we want, but I would not sync everything, it gets confusing. One visual, one message, na? Sending you two options as screenshots. Option B has the trend on top and the distributor table below.`

**Sneha Pillai — Business Analyst and note-taker.** 3 years with Northlane Analytics. Kochi, remote,
travels for workshops. Writes the circulated meeting notes, maintains the variance tracker and the
action log.
*Style:* minutes-writing. Third person, past tense, short sentences. Numbered actions with owner and
due date in the format `AI-14 | description | Owner | dd-Mmm`. Marks uncertainty honestly:
`[inaudible]`, `[name not captured]`, `[to be confirmed by Farida]`. Occasionally corrects herself in
a later line rather than editing the earlier one.
*Pet phrase:* "capturing that as an action".
*Vocabulary:* neutral and canonical: "distributor", "variance", "scheme discount", "SCD2" when
quoting Karthik. She sometimes leaves the raw transcript's mistakes in her notes when she was not
sure what was said.
*Sample:* `Farida raised the load window. She said the interface currently runs 4 min 12 sec and that the window has been breached twice this quarter. Karthik said he would measure it rather than estimate. Capturing that as an action. AI-11 | Measure SCD2 load cost on DEV and circulate | Karthik | 24-Apr`

---

## 8. SYSTEMS LANDSCAPE

Nothing outside this table exists. No SAP, no Salesforce, no Snowflake, no dbt, no Airflow, no cloud.

| System | Canonical description |
|---|---|
| **ORION** | The OLTP. Custom order-to-cash application built for BCPL in 2009 by Sahyadri Softech Pvt Ltd. Oracle Forms/Reports front end, later partially re-fronted in ADF. Database is **Oracle Database 19c Enterprise Edition, 19.18.0.0.0**. Nicknamed ORION by everyone; the formal name "Order and Invoicing System" is used only in DOC-01's first paragraph. Application release in force during the engagement: **R12.2.8**, with **R12.2.9** patched in over the weekend of 12-20 Sep 2026. |
| ORION schemas | **`OMS_PROD`** (order to cash: customers, SKUs, orders, invoices, credit notes, schemes) and **`FIN_PROD`** (GL, AR, tax rates, month-end packages). Also `OMS_RO` (a read-only account used by extracts) and `ODI_STG_RD` (the ODI reader account). |
| ORION host | `orion-db-prd-01.bcpl.local`, Mumbai primary DC, 2-node RAC. Standby `orion-db-dr-01` at Hyderabad DC, physical standby, not used for reporting. |
| **STG_ORION** | Staging schema. Physically **inside the EDW database instance**, not inside ORION. Holds `STG_*` landing tables plus ODI's `C$`/`I$`/`E$` work tables. |
| **BCPL_EDW** | The warehouse. **Oracle Database 19c**, star schema, on host `edw-db-prd-01.bcpl.local`. Single instance. 4.1 TB allocated, 2.8 TB used. Tablespaces `EDW_DATA`, `EDW_IDX`, `STG_DATA`. |
| DB link | `ORION_PRD` — a private database link in `STG_ORION` pointing at `OMS_RO@orion-db-prd-01`. Used by the extract mappings. This link is the subject of the VAR-003 misdirection in T-03. |
| **ODI** | **Oracle Data Integrator 12c, 12.2.1.4.0**. Master repository `ODI_MASTER`, work repository `ODI_WORK`, both on the EDW instance. Standalone agent **`OracleDIAgent1`** on `edw-app-prd-02.bcpl.local`, port **20910**. Farida calls mappings "interfaces" out of ODI 11g habit. |
| **OBIEE** | **Oracle Business Intelligence Enterprise Edition 11g, 11.1.1.9**. The legacy reporting layer. 41 catalogue reports, of which 12 are actually used. RPD last modified 2019. To be decommissioned 90 days after go-live. |
| Excel | The real reporting layer. Finance and Sales Ops both maintain shadow workbooks. Credit notes are netted here (see VAR-005). |
| **Power BI** | The target. Premium capacity **P1**, tenant `bharadwajcp`, workspace **`BCPL-DRISHTI-PRD`** (plus `-DEV` and `-UAT`). On-premises data gateway on `bi-gw-prd-01.bcpl.local`, standard mode, one cluster of two members. Dataset **`DRISHTI_SALES`**, import mode, scheduled refresh **06:00 and 14:00 IST**. Row-level security by `REGION_CODE` via a `SEC_USER_REGION` table. |
| **Control-M** | **Control-M 9.0.20**. Folder **`BCPL_EDW_DAILY`** holds the warehouse jobs. Folder `BCPL_ORION_OPS` holds ORION's own housekeeping and is owned by a different team. Control-M does **not** schedule anything inside `FIN_PROD`. |
| Ticketing | ServiceNow-style queue referenced only as "the ticket queue"; ticket IDs use the form `INC0045xxx` and `CHG0021xxx`. Named change requests: `CHG0021184` (DELETE_FLAG filter fix, deployed 03-Jun-2026), `CHG0021207` (DIM_DATE key fix, deployed 03-Jun-2026), `CHG0021339` (TAX_RATE_MASTER effective dating, deployed 26-Aug-2026). |
| Source control | Mapping XML exports and DDL are kept in a SharePoint document library, not in Git. This is a known finding and is mentioned in DOC-02 and CH-01. |

### 8.1 THE NIGHTLY LOAD — load-bearing, memorise it

> **The nightly load starts at 01:00 IST.**

This single fact is load-bearing for VAR-003 and it is repeated in `fact_ownership.csv` as a
**shared** fact (`F-LOADSTART`) which many artifacts may state. The *consequence* of the start time
(what runs after it) is exclusive to DOC-03. See §11 and the exclusivity banner there.

Canonical load-window numbers, frozen:

| Item | Value |
|---|---|
| Load plan | `LP_DAILY_SALES` |
| Control-M trigger | job `BCPL_EDW_DAILY_LOAD_START`, **01:00 IST, every day including Sundays** |
| Average elapsed | 58 minutes (01:00 -> 01:58 IST) |
| Typical completion **including** `PKG_POST_LOAD_CHECKS` and the batch close | **~02:05 IST** |
| P95 elapsed | 71 minutes |
| Worst month-end night in the Feb-Apr 2026 sample | 3 h 12 min, finished **04:12 IST** |
| Business availability SLA | **05:30 IST** |
| Nights the SLA was breached in FY26 Q4 | **two**: 14-Feb-2026 and 02-Mar-2026 |
| Average invoice lines per night | 21,400 |
| Range | 6,200 (Sundays) to 48,900 (month-end) |
| Rows into `FACT_INVOICE_LINE` per night, average | 21,400 |
| ODI session numbers referenced | `SESS_884012` (14-Feb re-run), `SESS_901337` (02-Mar), `SESS_918744` (a normal night, 21-May) |

On the Control-M in-flow markers: the folder still carries 01:40 / 02:00 / 02:35 against
steps 2, 3 and 4. Those are scheduling artefacts from when the plan was slower. Nobody
has retimed them, which is why people quote wildly different completion times from
memory. **The number to use for the warehouse being finished with the source is ~02:05.**
Stating that the load finishes around 02:05 is permitted wherever `F-LOADSTART` is
permitted. Stating anything about what runs *after* it is `F-TIMING` and is not.

### 8.2 Environments

| Env | ORION | EDW | ODI agent | Power BI workspace |
|---|---|---|---|---|
| PROD | `orion-db-prd-01` | `edw-db-prd-01` | `OracleDIAgent1` | `BCPL-DRISHTI-PRD` |
| UAT | `orion-db-uat-01` (refreshed monthly from PROD) | `edw-db-uat-01` | `OracleDIAgent_UAT` | `BCPL-DRISHTI-UAT` |
| DEV | `orion-db-dev-01` (refreshed on request, last refresh 11-Mar-2026) | `edw-db-dev-01` | `OracleDIAgent_DEV` | `BCPL-DRISHTI-DEV` |

The DEV ORION refresh being five months stale by August is a running complaint. The UAT EDW was not
sized for a full history reload, which is one of the reasons the plan moved.

---

## 9. DATA MODEL CANON

Object and column names below are **exact**. Any artifact that names a table or a column must use
these spellings. `procs_canon.sql` in this directory carries the same objects as DDL.

### 9.1 ORION — `OMS_PROD`

| Table | Key columns | Notes |
|---|---|---|
| `CUSTOMER` | `CUST_ID` (PK, NUMBER(10)), `CUST_CODE` VARCHAR2(20), `CUST_NAME` VARCHAR2(120), `CUST_TYPE` VARCHAR2(20) in ('DISTRIBUTOR','MODERN_TRADE','INSTITUTIONAL'), `TERRITORY_CD` VARCHAR2(12), `DEPOT_CD` VARCHAR2(12), `CREDIT_LIMIT` NUMBER(14,2), `STATUS_FLG` CHAR(1), `CREATED_DT` DATE, `LAST_UPD_DT` DATE, `LAST_UPD_BY` VARCHAR2(30) | 2,140 rows. 340 are DISTRIBUTOR type. |
| `CUSTOMER_TERRITORY_HIST` | `CUST_ID`, `TERRITORY_CD`, `EFF_FROM_DT`, `EFF_TO_DT` (nullable) | Source-side history. Overlapping rows exist. 61 customers have at least one overlap. |
| `SKU_MASTER` | `SKU_ID` (PK), `SKU_CODE`, `SKU_DESC`, `BRAND_CD`, `CATEGORY_CD`, `PACK_SIZE`, `UOM`, `MRP`, `HSN_CODE`, `ACTIVE_FLG`, `CREATED_DT`, `LAST_UPD_DT` | 1,246 rows, 862 active, 37 with null `CATEGORY_CD`. |
| `INVOICE_HEADER` | `INVOICE_ID` (PK), `INVOICE_NO` VARCHAR2(20), `INVOICE_DT` DATE, **`DOC_TYPE` VARCHAR2(4)** in ('INV','STN','SMP'), `CUST_ID`, `DEPOT_CD`, `ORDER_ID`, `INVOICE_STATUS`, `TOTAL_GROSS_AMT`, `TOTAL_NET_AMT`, `DELETE_FLAG` CHAR(1), `CREATED_TS` TIMESTAMP, `LAST_UPD_DT` DATE | `INVOICE_DT` is a DATE in IST. `CREATED_TS` is a TIMESTAMP written by the app server **in UTC**. This is the VAR-002 trap. `DOC_TYPE` mix: INV 94.7%, STN 4.7%, SMP 0.6%. |
| `INVOICE_LINE` | `INVOICE_LINE_ID` (PK, NUMBER(12)), `INVOICE_ID` (FK), `LINE_NO`, `SKU_ID`, `QTY_CS`, `QTY_EA`, `UNIT_PRICE`, `GROSS_AMT`, **`SCHEME_DISC_AMT`**, `CASH_DISC_AMT`, `TAX_AMT`, `NET_AMT`, `SCHEME_ID`, **`DELETE_FLAG` CHAR(1)**, `CREATED_TS` TIMESTAMP, `LAST_UPD_DT` DATE | **61,847,220 rows** as of 31-May-2026, from 01-Apr-2016. Older rows are in `INVOICE_LINE_ARCHIVE`. |
| `INVOICE_LINE_ARCHIVE` | same shape minus `DELETE_FLAG` | Pre-Apr-2016. Not extracted. Nobody has looked at it since 2016. |
| `ORDER_HEADER` / `ORDER_LINE` | `ORDER_ID`, `ORDER_NO`, `ORDER_DT`, `CUST_ID`, `ORDER_STATUS`, `DEPOT_CD` / `ORDER_LINE_ID`, `ORDER_ID`, `SKU_ID`, `QTY_CS`, `QTY_EA` | Used for fill-rate reporting (dashboard D06). |
| `SCHEME_MASTER` | `SCHEME_ID` (PK), `SCHEME_CODE`, `SCHEME_NAME`, `SCHEME_TYPE` in ('QPS','MONTHLY','SLAB','TPR'), `DISC_PCT`, `SLAB_QTY_FROM`, `SLAB_QTY_TO`, `VALID_FROM_DT`, `VALID_TO_DT`, `ACTIVE_FLG` | 5 canonical rows, see §3. |
| **`CREDIT_NOTE`** | `CN_ID` (PK), `CN_NO`, `CN_DT`, `CUST_ID`, **`CN_TYPE`** in ('DAMAGE','RETURN','RATE_DIFF','OFF_INV_ADJ','SCHEME'), `CN_STATUS`, `TOTAL_AMT`, `REF_INVOICE_ID`, `CREATED_TS`, `LAST_UPD_DT` | **Exists in the source.** FY26: 9,318 documents, INR 46.81 Cr total. |
| `CREDIT_NOTE_LINE` | `CN_LINE_ID` (PK), `CN_ID`, `SKU_ID`, `QTY`, `AMT`, `REASON_CD` | 31,204 rows FY26. |
| `DEPOT_MASTER` | `DEPOT_CD` (PK), `DEPOT_NAME`, `CITY`, `STATE_CD`, `REGION_CD` | 22 rows. |
| `TERRITORY_MASTER` | `TERRITORY_CD` (PK), `TERRITORY_NAME`, `REGION_CD`, `EMP_ID` | 118 rows. |

`DELETE_FLAG` semantics on `INVOICE_LINE` and `INVOICE_HEADER`:
`'Y'` = line cancelled or logically deleted. `'N'` = live. `NULL` = the row predates the column.
Distribution as of the 31-May-2026 profiling run, on `INVOICE_LINE`:
**`'Y'` 5,380,708 (8.7%) | `'N'` 47,251,124 (76.4%) | NULL 9,215,388 (14.9%)**. Sum 61,847,220.
The correct predicate is `NVL(DELETE_FLAG,'N') = 'N'`. Using `DELETE_FLAG = 'N'` silently drops
9.2 million historic rows. The reason the nulls exist is **EXCLUSIVE to DOC-01** (fact `F-DELFLAG`).

### 9.2 ORION — `FIN_PROD`

| Object | Notes |
|---|---|
| `GL_ACCOUNT_MASTER`, `GL_JOURNAL_HDR`, `GL_JOURNAL_LINE` | The GL. Revenue account `410100` (Net Sales - Domestic), scheme discount contra account `410900`, credit note account `411200`. |
| `AR_OPEN_ITEM` | Receivables ageing. Source for dashboard D11. |
| **`TAX_RATE_MASTER`** | `HSN_CODE`, `GST_RATE_PCT`, **`EFF_FROM_DT`, `EFF_TO_DT`** — the source table **is** effective-dated. The EDW copy is not. That is VAR-006. |
| `SCHEME_ACCRUAL` | `ACCRUAL_ID`, `CUST_ID`, `SCHEME_ID`, `PERIOD_YYYYMM`, `ACCRUAL_AMT`, `POSTED_FLG`. Written by the month-end package. |
| `PKG_MONTH_END` | PL/SQL package. See §11. **Handle with care.** |
| `PERIOD_CONTROL` | `PERIOD_YYYYMM`, `STATUS` in ('OPEN','CLOSING','CLOSED'), `CLOSED_TS`, `CLOSED_BY`. |

`FIN_PROD` holds a direct `UPDATE` grant on `OMS_PROD.INVOICE_LINE`, granted in 2014 and never
reviewed. This is how the month-end package can rewrite invoice lines. Ani knows; nobody else did.

### 9.3 `STG_ORION`

Landing tables, truncate-and-load each night unless stated:
`STG_CUSTOMER`, `STG_CUSTOMER_TERRITORY_HIST`, `STG_SKU_MASTER`, `STG_INVOICE_HEADER`,
`STG_INVOICE_LINE`, `STG_ORDER_HEADER`, `STG_ORDER_LINE`, `STG_SCHEME_MASTER`, `STG_DEPOT_MASTER`,
`STG_TERRITORY_MASTER`, `STG_TAX_RATE`, `STG_SECONDARY_SALES`, and **`STG_CREDIT_NOTE`**.

**`STG_CREDIT_NOTE` exists and is empty.** Its mapping `MAP_STG_CREDIT_NOTE` was built in 2021,
run for about fourteen months and disabled on **14-Nov-2022** when the load window got tight. Last
row in the table has `LOAD_DT = 14-NOV-2022`. Nothing downstream ever consumed it. This is a genuine
discoverable and it may appear in DOC-02, `schema_edw.sql`, `control_m_schedule.txt` and CH-01.
It is **not** the same fact as `F-CNGAP` (see `fact_ownership.csv`).

Plus ODI work tables: `C$_0STG_INVOICE_LINE`, `I$_FACT_INVOICE_LINE`, `E$_FACT_INVOICE_LINE`,
`SNP_CHECK_TAB`.

### 9.4 `BCPL_EDW` — the star schema

Dimensions:

| Table | Surrogate key | Natural key | SCD | Rows | Notes |
|---|---|---|---|---|---|
| `DIM_DATE` | `DATE_KEY` NUMBER(8) YYYYMMDD | `FULL_DATE` | n/a | 5,844 | 01-Apr-2015 to 31-Mar-2031. Columns: `DATE_KEY`, `FULL_DATE`, `DAY_OF_MONTH`, `DAY_NAME`, `WEEK_OF_YEAR`, `MONTH_NUM`, `MONTH_NAME`, `CAL_QTR`, `CAL_YEAR`, `FISCAL_MONTH_NUM`, `FISCAL_QTR` (e.g. 'FY26-Q1'), `FISCAL_YEAR` (e.g. 'FY26'), `IS_MONTH_END_FLG`, `IS_WORKING_DAY_FLG`. |
| `DIM_CUSTOMER` | `CUSTOMER_KEY` NUMBER(10) | `CUSTOMER_ID` | **SCD2 from 06-May-2026** (was SCD1) | 2,140 current / approx. 6,900 projected by Mar-2027 | Columns: `CUSTOMER_KEY`, `CUSTOMER_ID`, `CUSTOMER_CODE`, `CUSTOMER_NAME`, `CUSTOMER_TYPE`, `TERRITORY_CODE`, `REGION_CODE`, `STATE_CODE`, `DEPOT_CODE`, `CREDIT_LIMIT_AMT`, `EFF_START_DT`, `EFF_END_DT`, `CURRENT_FLG`, `LOAD_DT`, `UPD_DT`. |
| `DIM_PRODUCT` | `PRODUCT_KEY` NUMBER(10) | `SKU_ID` | **SCD2 from 06-May-2026** (SCD1 proposed 14-Apr-2026, superseded) | 1,246 | Columns: `PRODUCT_KEY`, `SKU_ID`, `SKU_CODE`, `SKU_DESC`, `BRAND_CODE`, `BRAND_NAME`, `CATEGORY_CODE`, `CATEGORY_NAME`, `PACK_SIZE`, `UOM`, `MRP_AMT`, `HSN_CODE`, `ACTIVE_FLG`, `EFF_START_DT`, `EFF_END_DT`, `CURRENT_FLG`, `LOAD_DT`. Has an `UNKNOWN` member at `PRODUCT_KEY = -1`. |
| `DIM_GEOGRAPHY` | `GEO_KEY` NUMBER(6) | `DEPOT_CODE` | SCD1 | 22 | `GEO_KEY`, `DEPOT_CODE`, `DEPOT_NAME`, `CITY`, `STATE_CODE`, `STATE_NAME`, `REGION_CODE`, `REGION_NAME`. |
| `DIM_SCHEME` | `SCHEME_KEY` NUMBER(8) | `SCHEME_ID` | SCD1 | 5 | `SCHEME_KEY`, `SCHEME_ID`, `SCHEME_CODE`, `SCHEME_NAME`, `SCHEME_TYPE`, `START_DT`, `END_DT`. |
| `DIM_SALESREP` | `SALESREP_KEY` NUMBER(8) | `EMP_ID` | SCD2 | 610 current | `SALESREP_KEY`, `EMP_ID`, `ROLE_CODE`, `TERRITORY_CODE`, `MANAGER_EMP_ID`, `EFF_START_DT`, `EFF_END_DT`, `CURRENT_FLG`. **Rep names are never printed in any artifact.** Use employee codes of the form `BCPL-EMP-04412`. |
| **`TAX_RATE_MASTER`** | none | `HSN_CODE` | **no effective dating at all** | 214 | Copy of the source table, truncate-and-reload nightly, current rates only. Root cause of VAR-006. Remediation: replaced by `DIM_TAX_RATE` (`TAX_RATE_KEY`, `HSN_CODE`, `GST_RATE_PCT`, `EFF_START_DT`, `EFF_END_DT`, `CURRENT_FLG`) on 26-Aug-2026 under `CHG0021339`. |

Facts:

| Table | Grain | Rows | Notes |
|---|---|---|---|
| `FACT_INVOICE_LINE` | intended: one row per source invoice line. actual before remediation: one row per source invoice line **per extract**, which is the bug family behind VAR-001, VAR-003 and VAR-008. | **34,182,556** as of the 31-May-2026 profiling run; covers 01-Apr-2021 onward | Columns: `INVOICE_LINE_KEY`, `INVOICE_ID`, `INVOICE_LINE_ID`, `DATE_KEY`, `CUSTOMER_KEY`, `PRODUCT_KEY`, `GEO_KEY`, `SALESREP_KEY`, `SCHEME_KEY`, `QTY_CS`, `QTY_EA`, `GROSS_AMT`, `SCHEME_DISC_AMT`, `CASH_DISC_AMT`, `TAX_AMT`, `NET_AMT`, `SRC_DELETE_FLAG`, `LOAD_DT`, `BATCH_ID`, `ODI_SESS_NO`. |
| `FACT_SECONDARY_SALES` | one row per distributor per SKU per day, from the DMS upload | 9,940,180 | Coverage is **74% of distributors** and the feed lags 5 days. This incompleteness is a standing caveat and is why Vikram's numbers move. |
| `FACT_ORDER_LINE` | one row per order line | 12,604,881 | Feeds fill rate. |
| **`FACT_CREDIT_NOTE`** | **DOES NOT EXIST** | — | There is no credit note fact table in `BCPL_EDW`. `schema_edw.sql` shows this structurally, by not containing it. Do not create it in any artifact. |

Control tables: `ETL_BATCH_CONTROL` (`BATCH_ID`, `LOAD_PLAN_NAME`, `BUSINESS_DATE`, `START_TS`,
`END_TS`, `STATUS`, `ROWS_INSERTED`, `ROWS_REJECTED`, `EXTRACT_HIGH_TS`, `RESTART_COUNT`),
`ETL_ERROR_LOG` (`ERROR_ID`, `BATCH_ID`, `OBJECT_NM`, `ERROR_TS`, `ERROR_TEXT`), **`ETL_PARAM`**
(`PARAM_NAME`, `PARAM_VALUE`, `UPD_TS`, `UPD_BY`), `SEC_USER_REGION` (`USER_UPN`, `REGION_CODE`).

`ETL_BATCH_CONTROL.EXTRACT_HIGH_TS` is the extract high water mark. It is persisted only
by the closing step of a successful plan (`P_ETL_BATCH_CLOSE`, §11). Before the
`R2026.07` fix of 08-Jul-2026 it was advanced at the *start* of the plan, which is half
of VAR-008. A `STATUS = 'DONE'` row means "the plan reached its last step", not "the data
is right"; every night that produced a VAR-003 duplicate has a green row here.

**Object counts, frozen.** `OMS_PROD` 13 tables, `FIN_PROD` 7 tables, 20 OLTP tables in
total. `BCPL_EDW` 15 tables: 12 model tables (8 dimension and reference, 3 fact, 1
security) plus 3 ETL control tables. `STG_ORION` 13 landing tables. `schema_canon.sql`
implements exactly this set and nothing else.

`ETL_PARAM` holds a row `PARAM_NAME = 'FIN_PERIOD_OPEN'`, `PARAM_VALUE` = a `YYYYMM` string. What
that row is for, and the fact that somebody has to set it by hand, is **EXCLUSIVE to DOC-02**
(fact `F-MANUAL`). Other artifacts may mention that `ETL_PARAM` exists. They may not explain this row.

---

## 10. ODI AND SCHEDULING CANON

### 10.1 Load plans

| Load plan | Schedule | Notes |
|---|---|---|
| **`LP_DAILY_SALES`** | nightly, triggered 01:00 IST by Control-M | Steps in order: `PKG_STG_EXTRACT` -> `PKG_DIM_LOAD` -> `PKG_FACT_LOAD` -> `PKG_POST_LOAD_CHECKS`. Scenario `SCEN_LP_DAILY_SALES` version 003. **Not idempotent before remediation** — a re-run appends. That is VAR-008. |
| **`LP_MONTHEND_FIN`** | monthly, working day +1, submitted manually | Loads the finance aggregates and the GL summary. Requires a manual step before it can run. That step is **EXCLUSIVE to DOC-02**. |
| `LP_SECONDARY_UPLOAD` | daily 04:00 IST | Picks up the DMS file drop for `FACT_SECONDARY_SALES`. Frequently no file. |
| `LP_DIM_REFRESH_FULL` | ad hoc | Full dimension rebuild. Last run 09-Jan-2026. |

### 10.2 Mappings (ODI 12c "mappings"; Farida calls them "interfaces")

`MAP_STG_CUSTOMER`, `MAP_STG_CUSTOMER_TERRITORY_HIST`, `MAP_STG_SKU_MASTER`,
`MAP_STG_INVOICE_HEADER`, `MAP_STG_INVOICE_LINE`, `MAP_STG_ORDER_HEADER`, `MAP_STG_ORDER_LINE`,
`MAP_STG_SCHEME_MASTER`, `MAP_STG_DEPOT_MASTER`, `MAP_STG_TERRITORY_MASTER`, `MAP_STG_TAX_RATE`,
`MAP_STG_CREDIT_NOTE` (**disabled 14-Nov-2022**),
`MAP_DIM_CUSTOMER`, `MAP_DIM_PRODUCT`, `MAP_DIM_GEOGRAPHY`, `MAP_DIM_SCHEME`, `MAP_DIM_SALESREP`,
`MAP_DIM_DATE` (one-off, last run 2021), `MAP_TAX_RATE_MASTER`,
**`MAP_FACT_INVOICE_LINE`**, `MAP_FACT_ORDER_LINE`, `MAP_FACT_SECONDARY_SALES`.

`MAP_FACT_INVOICE_LINE`, canonical detail (this is the mapping the whole corpus turns on):

| Property | Value |
|---|---|
| Source | `STG_ORION.STG_INVOICE_LINE` joined to `STG_ORION.STG_INVOICE_HEADER` on `INVOICE_ID` |
| Target | `BCPL_EDW.FACT_INVOICE_LINE` |
| LKM | `LKM Oracle to Oracle (DBLINK)` on the `ORION_PRD` link |
| IKM | **`IKM Oracle Control Append`**, `TRUNCATE = false`, `FLOW_CONTROL = false` — insert only, no merge, no flow control. This is why re-extracted rows duplicate. |
| CKM | `CKM Oracle` (configured but not enabled on this mapping) |
| Incremental predicate | `STG_INVOICE_LINE.LAST_UPD_DT >= TRUNC(SYSDATE) - 1` |
| `DATE_KEY` derivation, before fix | `TO_NUMBER(TO_CHAR(IH.CREATED_TS,'YYYYMMDD'))` — uses the UTC timestamp. **VAR-002.** |
| `DATE_KEY` derivation, after fix (`CHG0021207`, 03-Jun-2026) | `TO_NUMBER(TO_CHAR(IH.INVOICE_DT,'YYYYMMDD'))` |
| `DELETE_FLAG` filter, before fix | **none at all**. **VAR-001.** |
| `DELETE_FLAG` filter, after fix (`CHG0021184`, 03-Jun-2026) | `NVL(IL.DELETE_FLAG,'N') = 'N'` |
| `DOC_TYPE` filter, before 25-Jun-2026 | `IH.DOC_TYPE <> 'SMP'` (samples excluded; documented in XL-04) |
| `DOC_TYPE` filter, from release R2026.07 | `IH.DOC_TYPE = 'INV'` — this change is `F-CHATDEC` and is **EXCLUSIVE to CH-01** |
| Rejected rows | land in `E$_FACT_INVOICE_LINE` |

Knowledge modules in use across the whole SALES_FIN chain, and there are only these four:

| KM | Used on |
|---|---|
| `LKM Oracle to Oracle (DBLINK)` | every source-to-staging step, over `ORION_PRD` |
| `IKM Oracle Incremental Update` | the staging targets and **every** dimension target, update-else-insert on the declared update key |
| **`IKM Oracle Control Append`** | **`MAP_FACT_INVOICE_LINE` only.** Insert-only, no merge. This is the load-bearing one. |
| `CKM Oracle` | flow control where `FLOW_CONTROL` is true. Configured but **not enabled** on `MAP_FACT_INVOICE_LINE`. |

The XML export `odi_mapping_export_MAP_FACT_INVOICE_LINE.xml` in `_sources/technical/` is an
**as-was export taken on 20 May 2026**, i.e. before any of the fixes. It shows no `DELETE_FLAG`
filter, the `CREATED_TS`-based `DATE_KEY`, `IKM Oracle Control Append`, and the `DOC_TYPE <> 'SMP'`
filter. It is the evidence exhibit for VAR-001 and VAR-002. Do not put post-May state into it.

### 10.3 Control-M folder `BCPL_EDW_DAILY`

| Job | Time (IST) | Runs |
|---|---|---|
| `BCPL_EDW_DAILY_LOAD_START` | **01:00** | `SCEN_LP_DAILY_SALES` |
| `BCPL_EDW_STG_EXTRACT` | 01:00 (in-flow) | step 1 |
| `BCPL_EDW_DIM_LOAD` | 01:40 (in-flow) | step 2 |
| `BCPL_EDW_FACT_LOAD` | 02:00 (in-flow) | step 3 |
| `BCPL_EDW_POSTCHK` | 02:35 (in-flow) | step 4 |
| `BCPL_EDW_OBIEE_CACHE_SEED` | 03:05 | OBIEE cache seeding |
| `BCPL_EDW_ALERT_SUMMARY` | 03:20 | mails `bcpl-datawarehouse@bharadwajcp.example` |
| `BCPL_SFA_SECONDARY_UPLOAD` | 04:00 | `LP_SECONDARY_UPLOAD` |
| `BCPL_EDW_MONTHEND_FIN` | WD+1 03:00, on-request | `LP_MONTHEND_FIN` |
| `BCPL_PBI_REFRESH_TRIGGER` | 06:00 (from Aug 2026) | Power BI dataset refresh |

> **Control-M schedules nothing in `FIN_PROD`.** `control_m_schedule.txt` must not contain any
> finance adjustment job, and must not contain any time in the 02:10-02:20 range. It may carry a
> footer comment that jobs owned by other teams are not in this folder. That comment is a pointer,
> not the fact.

### 10.4 Release / change references

| Ref | Date | Content |
|---|---|---|
| `R2026.06` / `CHG0021184` | deployed 03-Jun-2026 | `NVL(DELETE_FLAG,'N') = 'N'` filter (VAR-001) |
| `R2026.06` / `CHG0021207` | deployed 03-Jun-2026 | `DATE_KEY` from `INVOICE_DT` (VAR-002) |
| `R2026.07` | deployed 08-Jul-2026 | `DOC_TYPE = 'INV'` filter (the undocumented chat decision), plus `LP_DAILY_SALES` batch-id guard |
| `R2026.08` / `CHG0021339` | deployed 26-Aug-2026 | `DIM_TAX_RATE` with effective dating (VAR-006) |
| `R2026.09` | planned 30-Sep-2026 | key-based merge on `FACT_INVOICE_LINE` (VAR-003 remediation, ADR-004) |

---

## 11. procs_canon — CANONICAL STORED PROCEDURE REGISTRY

> ## ⚠ EXCLUSIVITY BANNER — READ BEFORE USING ANYTHING IN THIS SECTION
>
> This section states the mechanism behind VAR-003 so that you can **avoid writing it**.
>
> **The sentence "P_ADJUST_REVENUE runs at 02:15 IST, after the 01:00 IST nightly load completes"
> and every paraphrase, hint, restatement or rounding of it, is EXCLUSIVE to `DOC-03`
> (`_sources/docs/DOC-03_stored_procedure_walkthrough.docx`).**
>
> No other artifact in `_sources/` may state:
> - the time **02:15** (or "quarter past two", "2.15 am", "02:15 hrs", "just after two"), or
> - the time **02:40**, the time **02:55**, or any other clock time in the ORION-side
>   chain below, in any rendering ("twenty to three", "around 2.40", "02:40 hrs"), or
> - that any procedure runs **after** the nightly load, or
> - that the recalculation **re-writes rows that have already been extracted**, or
> - the ordering of the load and the procedure in any form.
>
> The load's own times are a different matter. `01:00` and the ~`02:05` completion are
> fact `F-LOADSTART`, they are shared, and they may appear wherever `fact_ownership.csv`
> permits. What is forbidden is anything that says what happens next.
>
> The `must_not_appear_in` list for `F-TIMING` in `fact_ownership.csv` spells out every artifact ID.
> This is canon-internal text; canon may state it, `_sources/` may not.

`FIN_PROD.PKG_MONTH_END` — package specification (exact):

| Procedure | Signature | What it does |
|---|---|---|
| `P_ADJUST_REVENUE` | `(p_period IN VARCHAR2 DEFAULT NULL)` | Driver. Resolves the open period from `FIN_PROD.PERIOD_CONTROL` when `p_period` is null, then calls `P_RECALC_SCHEME_DISCOUNT` and `P_POST_GL_SUMMARY`. |
| `P_RECALC_SCHEME_DISCOUNT` | `(p_period IN VARCHAR2)` | Recomputes scheme entitlement for every distributor with activity in the period, writes `FIN_PROD.SCHEME_ACCRUAL`, and **updates `OMS_PROD.INVOICE_LINE.SCHEME_DISC_AMT` additively** — `SET SCHEME_DISC_AMT = NVL(SCHEME_DISC_AMT,0) + v_delta` — with no idempotency guard and no run-marker column. Touching the row bumps `LAST_UPD_DT`. |
| `P_POST_GL_SUMMARY` | `(p_period IN VARCHAR2)` | Posts the summarised journal to `GL_JOURNAL_HDR`/`GL_JOURNAL_LINE`. |
| `P_CLOSE_PERIOD` | `(p_period IN VARCHAR2)` | Flips `PERIOD_CONTROL.STATUS` to `CLOSED`, stamping `CLOSED_TS` and `CLOSED_BY`. Run once a month by Finance, by hand. It is the only member of the package a human invokes deliberately. Closing a period does **not** stop the nightly run; the driver simply resolves the next open period. |

Timing inside a typical run of the package, all IST, all **EXCLUSIVE to DOC-03**:

| time | what |
|---|---|
| **02:15** | `P_ADJUST_REVENUE` starts. Ten minutes after the warehouse stopped reading. |
| **~02:40** | `P_RECALC_SCHEME_DISCOUNT` reaches the `OMS_PROD.INVOICE_LINE` update. The driver spends the first twenty five minutes resolving the period and building the accrual set. |
| **~02:55** | `P_POST_GL_SUMMARY` posts the summarised journal. |

The whole package run takes 40 to 55 minutes end to end. On month-end nights the gap is
negative: the worst night in the Feb-Apr 2026 sample ran 3 h 12 min and finished 04:12,
which is nearly two hours after the 02:15 job started and well past the 02:40
recalculation. On nights like that the extract is reading rows while they are being
rewritten underneath it. The SLA is 05:30, so none of those nights looked like a failure.

There is one warehouse-side routine in the registry, and it is not part of the package:

| Procedure | Schema | Signature | What it does |
|---|---|---|---|
| **`P_ETL_BATCH_CLOSE`** | `BCPL_EDW` | `(p_load_plan_name IN VARCHAR2, p_load_plan_run_no IN NUMBER, p_status IN VARCHAR2 DEFAULT 'DONE', p_business_dt IN DATE DEFAULT TRUNC(SYSDATE)-1)` | Final in-plan step of `LP_DAILY_SALES` and `LP_MONTHEND_FIN`, ~02:03 to 02:05. Writes the closing row of `ETL_BATCH_CONTROL`, sets `END_TS`, `STATUS` and the counters, increments `RESTART_COUNT`, and **persists `EXTRACT_HIGH_TS`** (half the VAR-008 fix). It is the only thing in the plan that commits the batch control rows. Its existence and its ~02:05 slot are **not** exclusive; they are part of `F-LOADSTART`. |

Scheduling of the package (**exclusive detail, DOC-03 only**):
- It is **not** in Control-M. It is a `DBMS_SCHEDULER` job **inside ORION**, owned by `FIN_PROD`.
- Job name `FIN_MTHEND_ADJ_NIGHTLY`, `repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=15'`,
  enabled 19-Nov-2014, `last_start_date` observed by Karthik on 27-Apr-2026.
- The package is named "month end" but the job runs **every night**, which is the reason the effect
  compounds through the month and looks like a growing variance rather than a one-off.
- Because it is outside Control-M it never appeared in the ODI job inventory (DOC-02), which is why
  it took two months to find.

Consequence chain (canon-internal, do not reproduce outside DOC-03):
01:00 load extracts the invoice lines and is finished with the source by ~02:05 -> 02:15 the
job starts and at ~02:40 it recalculates and additively updates the same
lines in ORION, bumping `LAST_UPD_DT` -> next night the incremental predicate
(`LAST_UPD_DT >= TRUNC(SYSDATE)-1`) picks the same lines up again -> `IKM Oracle Control Append`
inserts them a second time -> `SCHEME_DISC_AMT` is counted twice in `FACT_INVOICE_LINE`.
Estimated FY26 impact **INR 1.7 Cr**.

What other artifacts ARE allowed to say about VAR-003 (the non-exclusive area fact,
`F-VAR003-AREA`): "the scheme discount double-count originates in an ORION-side recalculation",
"a finance procedure in ORION rewrites the discount amount", "root cause is source-side, not in ODI",
"see the stored procedure walkthrough for detail". None of those state the timing or the ordering.

`pkg_month_end.pkb` in `_sources/technical/` contains the package body: the additive `UPDATE`, the
missing guard, a stale header comment claiming the package is "run manually by the FIN team at month
end", an author tag of the form `-- Sahyadri Softech, 2011`, and a 2014 modification comment. It
contains **no schedule time** and no reference to the nightly load.

---

## 12. VARIANCE CANON

`variance_register_canon.csv` is the authoritative register. The `root_cause` column in that file is
**canon-internal truth**: an artifact may only state a root cause to the extent `fact_ownership.csv`
permits. In particular the VAR-003 root cause text in the register is a canon statement, not a
licence to print it.

Mechanisms in one line each, for agents who need to write around them:

| ID | One-line mechanism | Fix |
|---|---|---|
| VAR-001 | `MAP_FACT_INVOICE_LINE` had no `DELETE_FLAG` filter, so cancelled lines were counted as revenue. FY26 Q1 overstated. | `NVL(DELETE_FLAG,'N')='N'`, `CHG0021184`, 03-Jun-2026 |
| VAR-002 | `DATE_KEY` derived from `INVOICE_HEADER.CREATED_TS`, which the app writes in UTC. Invoices raised after 18:30 IST on the last day of a month land in the next month. | `DATE_KEY` from `INVOICE_DT`, `CHG0021207`, 03-Jun-2026, ADR-005 |
| VAR-003 | See §11. Exclusive. | ADR-004, planned `R2026.09`, 30-Sep-2026. **Still open at the end of the corpus.** |
| VAR-004 | On a distributor territory reassignment the SCD2 logic sets the closing row's `EFF_END_DT` to the same timestamp as the new row's `EFF_START_DT` and leaves `CURRENT_FLG='Y'` on both, so a fact row joins to two dimension rows. 61 customers affected, 18 with two current rows. | Open. Worked example `DIST-W-0241` Mahalaxmi Distributors, reassigned 17-Apr-2026 from `TER-W-014` to `TER-W-011`. |
| VAR-005 | There is no credit note fact table. Finance nets credit notes in Excel outside the warehouse. | Open. Deferred verbally (see Q6 — that deferral is deliberately absent from the corpus). |
| VAR-006 | `BCPL_EDW.TAX_RATE_MASTER` is a truncate-and-reload snapshot with no effective dating, so the Chandanaa HSN 3401 change from 18% to 12% on 01-Oct-2025 was applied retrospectively to Apr-Sep 2025. | `DIM_TAX_RATE`, `CHG0021339`, 26-Aug-2026 |
| VAR-007 | No late-arriving dimension handling. A SKU invoiced before `MAP_DIM_PRODUCT` has seen it routes to `PRODUCT_KEY = -1` (`UNKNOWN`) and stays there. 2.0% of invoiced volume, average 8,140 lines a month, peak 11,902 in Jan-2026. | Open. |
| VAR-008 | `LP_DAILY_SALES` was re-run manually on Sat 14-Feb-2026 after a first failure (session `SESS_884012`). `IKM Oracle Control Append` appended the whole night again. 2.9 Cr of duplicated sales sat in the February figures for three weeks. | Batch-id guard in `R2026.07`. Closed 02-Apr-2026. |

Cumulative variance quantified, **per artifact**, so decks do not contradict each other:

| Artifact | Items known | Total stated |
|---|---|---|
| DK-02 (26-Mar-2026) | VAR-001, 002, 003, 008 | **INR 9.70 Cr** |
| DK-03 (05-May-2026) | + VAR-004, VAR-005 at the early 2.4 Cr estimate | **INR 12.75 Cr** |
| DK-04 (18-Jun-2026) | + VAR-006; VAR-007 stated as a volume percentage, not money | **INR 13.15 Cr** quantified |
| XL-01 v7 (18-Sep-2026) | all eight, VAR-005 at the validated 3.11 Cr | **INR 13.85 Cr**, of which **8.40 Cr closed**, **5.45 Cr open** |
| DK-06 (22-Sep-2026) | all eight | **INR 13.85 Cr**, closed 8.40, open 5.45 |

Arithmetic, so nobody re-derives it wrongly:
closed = 4.20 + 0.90 + 0.40 + 2.90 = **8.40 Cr** (VAR-001, 002, 006, 008)
open = 1.70 + 0.65 + 3.11 = **5.46 Cr**, **stated as 5.45 Cr** everywhere because the tracker rounds
VAR-005 to 3.10 Cr in the summary sheet while the detail sheet carries 3.11. Keep this exact
inconsistency; it is the kind of thing that is in every real tracker. Do not "fix" it.

---

## 13. DASHBOARD CANON — the 12 / 7 / 9 story

The full inventory as first scoped. Dashboard IDs `D01`-`D12` are canonical and must be used
consistently wherever a dashboard is named.

| ID | Dashboard | In DK-01 (12) | After EM-023 (7) | At go-live (9) | Primary fact |
|---|---|---|---|---|---|
| D01 | Primary Sales Performance | yes | **yes** | **yes** | `FACT_INVOICE_LINE` |
| D02 | Secondary Sales Coverage | yes | dropped | dropped | `FACT_SECONDARY_SALES` |
| D03 | Distributor Scorecard | yes | **yes** | **yes** | `FACT_INVOICE_LINE` |
| D04 | Scheme Effectiveness | yes | dropped | **reinstated** | `FACT_INVOICE_LINE` + `DIM_SCHEME` |
| D05 | Stock and Despatch | yes | **yes** | **yes** | `FACT_INVOICE_LINE` |
| D06 | Order Fulfilment and Fill Rate | yes | **yes** | **yes** | `FACT_ORDER_LINE` |
| D07 | Revenue Reconciliation | yes | **yes** | **yes** | `FACT_INVOICE_LINE` |
| D08 | GST and Tax Summary | yes | dropped | dropped | `FACT_INVOICE_LINE` + `DIM_TAX_RATE` |
| D09 | Product Mix and Contribution | yes | **yes** | **yes** | `FACT_INVOICE_LINE` |
| D10 | Sales Rep Productivity | yes | dropped | dropped | `FACT_INVOICE_LINE` + `DIM_SALESREP` |
| D11 | Credit and Receivables Exposure | yes | dropped | **reinstated** | `AR_OPEN_ITEM` extract |
| D12 | Executive Summary (Group view) | yes | **yes** | **yes** | aggregate |

- **12** is stated in **DK-01 only** (slide 9, "Reporting scope").
- **7** is stated in **EM-023 only** as the new number, with Shalini's reason. T-07 and DK-05 work
  from the committed seven and may say "the seven committed" (that is permitted, see
  `fact_ownership.csv` `F-DASH7`), but neither may state that the number was ever 12, and neither
  may state the reason for the cut.
- **9** is stated in **DK-06 and T-08 only**.
- T-07 (05-Aug-2026) ends with "seven committed plus two candidates" and does **not** arrive at nine.
  DK-05 (07-Aug-2026) shows seven wireframes plus two marked `CANDIDATE - not funded`.
- D11 is in scope at go-live even though `FACT_CREDIT_NOTE` does not exist. **No artifact explains
  how credit notes will be sourced for D11.** That silence is deliberate: it is demo question Q6.

Power BI naming at go-live: reports are named `DRISHTI - <dashboard name>` in workspace
`BCPL-DRISHTI-PRD`, all on the single dataset `DRISHTI_SALES`.

---

## 14. PROJECT PLAN, MILESTONES AND DATES

Milestone dates. Where a date changed, all three values are given; see `contradiction_ledger.csv`
for which artifact may state which.

| Milestone | Value |
|---|---|
| SOW signed | 28-Jan-2026 |
| Kickoff | Wed 11-Feb-2026 |
| Discovery | 11-Feb-2026 to 27-Mar-2026 |
| Variance root-cause sprint | 09-Mar-2026 to 08-May-2026 |
| Data quality assessment | 04-May-2026 to 19-Jun-2026 |
| Remediation build | 15-Jun-2026 to 25-Sep-2026 |
| Dashboard build | 03-Aug-2026 to 09-Oct-2026 |
| UAT, as planned in DK-01 | 10-Aug-2026 to 28-Aug-2026 |
| UAT, as finally scheduled (EM-089) | 12-Oct-2026 to 06-Nov-2026 |
| Go-live, original (DK-01, T-01) | **Tue 15-Sep-2026** |
| Go-live, first slip (EM-068) | **Fri 30-Oct-2026** |
| Go-live, final (T-08, DK-06) | **Thu 12-Nov-2026** |
| Cutover weekend | Sat 07-Nov to Sun 08-Nov-2026 |
| Historical reload window | Mon 09-Nov to Wed 11-Nov-2026 |
| Hypercare ends | Fri 11-Dec-2026 |
| OBIEE decommission | 90 days after go-live |

Reason for the first slip (**EXCLUSIVE to EM-068**): the ORION R12.2.9 patch weekend runs 12-20 Sep
and locks the source system; and the VAR-004 and VAR-007 remediation will not be finished in time,
so UAT cannot start before 05-Oct.

Reason for the final date (**EXCLUSIVE to T-08, may be echoed in DK-06**): the Klarissen group close
blackout, 26-Oct to 06-Nov CET, forbids a cutover in that window. The steerco therefore takes the
cutover weekend of 7-8 Nov and a business go-live on Thu 12-Nov-2026, with hypercare to 11-Dec.

UAT canon: 14 UAT scripts (`UAT-01` to `UAT-14`), 9 testers, defect log kept in the WhatsApp group and
a spreadsheet that is never generated as an artifact. UAT sign-off due 06-Nov-2026.

Meeting canon. Times are IST. Every meeting is on the day of the week shown; do not get this wrong.

| ID | Date | Day | Time (IST) | Length | Title | Attendees |
|---|---|---|---|---|---|---|
| T-01 | 11-Feb-2026 | Wednesday | 15:00-16:00 | 60m | Kickoff and scope | Rajeev, Shalini, Vikram, Priya, Farida, Ananya, Karthik, Ritwik, Sneha; Marijke joins 15:00-15:20 only (10:30-10:50 CET) |
| T-02 | 03-Mar-2026 | Tuesday | 11:00-12:30 | 90m | OLTP discovery with Ani | Ani, Farida, Karthik, Ishaan, Priya, Sneha |
| T-03 | 24-Mar-2026 | Tuesday | 16:00-16:45 | 45m | First variance findings | Ananya, Karthik, Ishaan, Farida, Shalini, Vikram, Sneha |
| T-04 | 14-Apr-2026 | Tuesday | 14:00-15:15 | 75m | Architecture review | Karthik, Ishaan, Farida, Ani, Priya, Neha, Ananya, Sneha |
| T-05 | 06-May-2026 | Wednesday | 15:30-16:30 | 60m | Design sign-off | Karthik, Ananya, Shalini, Farida, Ani, Ishaan, Sneha; Rajeev joins at 15:52 |
| T-06 | 18-Jun-2026 | Thursday | 11:00-11:50 | 50m | Data quality readout | Neha, Meghna, Ishaan, Farida, Shalini, Priya, Ananya, Sneha |
| T-07 | 05-Aug-2026 | Wednesday | 10:00-11:30 | 90m | Dashboard scope workshop | Ritwik, Priya, Vikram, Shalini, Meghna, Ananya, Sneha; Wei Lin joins 10:00-11:00 (12:30-13:30 SGT) |
| T-08 | 22-Sep-2026 | Tuesday | 15:00-15:45 | 45m | Steering committee | Rajeev (chair), Shalini, Marijke (11:30-12:15 CEST), Vikram, Ananya, Karthik, Sneha |

Locations: T-01 and T-07 are in the Andheri East office, board room "Nashik" on the 4th floor, with
remote joiners. T-02, T-03, T-04, T-05, T-06 and T-08 are fully online. The office wifi in the
4th floor board room is bad and this shows up in the transcripts as dropouts.

---

## 15. ARTIFACT ID REGISTRY

55 artifact IDs. These IDs are used in `timeline.csv`, `fact_ownership.csv`,
`contradiction_ledger.csv` and `pii_plant_register.csv`. Filenames are exact and case-sensitive.
A meeting's `.vtt` and `.txt` share one ID.

### 15.1 Meetings — `_sources/meetings/`

| ID | Files | Date | Length |
|---|---|---|---|
| T-01 | `T-2026-02-11_kickoff_scope.vtt` / `.txt` | 11-Feb-2026 | 60m |
| T-02 | `T-2026-03-03_oltp_discovery.vtt` / `.txt` | 03-Mar-2026 | 90m |
| T-03 | `T-2026-03-24_variance_findings.vtt` / `.txt` | 24-Mar-2026 | 45m |
| T-04 | `T-2026-04-14_architecture_review.vtt` / `.txt` | 14-Apr-2026 | 75m |
| T-05 | `T-2026-05-06_design_signoff.vtt` / `.txt` | 06-May-2026 | 60m |
| T-06 | `T-2026-06-18_dq_readout.vtt` / `.txt` | 18-Jun-2026 | 50m |
| T-07 | `T-2026-08-05_dashboard_scope_workshop.vtt` / `.txt` | 05-Aug-2026 | 90m |
| T-08 | `T-2026-09-22_steerco.vtt` / `.txt` | 22-Sep-2026 | 45m |

### 15.2 Decks — `_sources/decks/`

| ID | Filename | Date | Author | Slides | Load-bearing content |
|---|---|---|---|---|---|
| DK-01 | `DK-01_kickoff_v3_FINAL.pptx` | 11-Feb-2026 | Ananya Krishnan | 18 | slide 4 timeline with **go-live 15-Sep-2026**; slide 9 **"12 dashboards"** |
| DK-02 | `DK-02_discovery_findings.pptx` | 26-Mar-2026 | Karthik Subramanian | 22 | VAR-001/002/003/008, **9.70 Cr**, VAR-003 root cause "under investigation" |
| DK-03 | `DK-03_variance_rootcause_v2.pptx` | 05-May-2026 | Karthik Subramanian | 16 | **12.75 Cr**, VAR-005 at the early **2.4 Cr**, VAR-003 area named but not the mechanism |
| DK-04 | `DK-04_dq_assessment.pptx` | 18-Jun-2026 | Neha Gokhale | 20 | DQ rules and scores, VAR-004, VAR-006, VAR-007, **13.15 Cr** |
| DK-05 | `DK-05_dashboard_wireframes.pptx` | 07-Aug-2026 | Ritwik Ghosh | 24 | 7 committed wireframes + 2 marked `CANDIDATE - not funded` |
| DK-06 | `DK-06_steerco_sep2026.pptx` | 22-Sep-2026 | Ananya Krishnan | 14 | **go-live 12-Nov-2026**, **9 dashboards**, **13.85 Cr** |

Deck conventions: 16:9. Footer on every slide reads
`Bharadwaj Consumer Products Ltd | Project Drishti | <deck short name> | <dd Mmm yyyy> | Confidential`.
Document properties: Author = the person above, Company = `Northlane Analytics`, and a revision count
that is implausibly high (DK-01 revision 14, DK-03 revision 9). Speaker notes exist on some slides and
are informal, half-finished, and occasionally contradict the slide. DK-01's filename says `v3_FINAL`
and slide 2 still says "v2 draft" in small type. Leave that in.

### 15.3 Email — `_sources/email/`

15 single-file `.eml` threads. Filenames `EM-0nn_<slug>.eml`.

| ID | Filename | Sent (IST unless noted) | From -> To | Subject |
|---|---|---|---|---|
| EM-012 | `EM-012_kickoff_logistics.eml` | Wed 04-Feb-2026 11:42 | Sneha Pillai -> drishti-core, Shalini, Priya | `Project Drishti - kickoff 11 Feb, logistics` |
| EM-023 | `EM-023_reporting_scope_change.eml` | Mon 30-Mar-2026 18:07 | Shalini Iyer -> Ananya, cc Rajeev, Priya | `RE: Reporting scope for go-live` |
| EM-041 | `EM-041_load_window_concern.eml` | Thu 16-Apr-2026 20:31 | Farida Contractor -> Karthik, cc Ani, Ananya | `RE: Architecture review actions - load window impact` |
| EM-047 | `EM-047_scd2_load_analysis.eml` | Thu 23-Apr-2026 09:18 | Karthik Subramanian -> Farida, cc Ani, Ananya | `RE: Architecture review actions - load window impact` (attaches `XL-03_scd2_load_impact.xlsx`) |
| EM-055 | `EM-055_var004_handover.eml` | Thu 09-Jul-2026 16:55 | Ananya Krishnan -> Farida, Ishaan, cc Neha, Sneha | `VAR-004 - handover` |
| EM-061 | `EM-061_credit_notes_india.eml` | Tue 14-Jul-2026 07:12 CEST | Marijke van der Berg -> Rajeev, cc Shalini, Wei Lin | `Credit notes - India` |
| EM-063 | `EM-063_credit_notes_validated.eml` | Tue 21-Jul-2026 19:44 | Shalini Iyer -> Marijke, cc Rajeev, Ananya, Wei Lin | `RE: Credit notes - India` |
| EM-068 | `EM-068_revised_plan_date.eml` | Wed 19-Aug-2026 21:16 | Ananya Krishnan -> Rajeev, Shalini, cc Marijke, drishti-core | `Project Drishti - revised plan date` |
| EM-072 | `EM-072_feb_duplicate_load_chain.eml` | Fri 21-Aug-2026 12:03 | Farida Contractor -> Neha, cc Ishaan | `FW: FW: RE: FW: Feb sales figures - not matching` (5 levels of quoted history back to 06-Mar-2026) |
| EM-075 | `EM-075_updated_tracker.eml` | Wed 26-Aug-2026 17:29 | Sneha Pillai -> drishti-core, Shalini | `Updated variance tracker` (**refers to an attachment that is not there**) |
| EM-078 | `EM-078_gst_rate_restatement.eml` | Thu 27-Aug-2026 10:05 | Neha Gokhale -> Shalini, cc Farida, Meghna | `RE: Chandanaa GST rate - Oct 25 restatement` |
| EM-081 | `EM-081_unknown_product_key.eml` | Wed 02-Sep-2026 15:37 | Ritwik Ghosh -> Ishaan, Meghna, cc Priya | `UNKNOWN product key - 2% of lines` |
| EM-084 | `EM-084_north_file_too_big.eml` | Fri 25-Sep-2026 13:21 | Vikram Sethi -> Priya, cc Meghna | `RE: North stockist file - too big for mail` (**PII-2**) |
| EM-089 | `EM-089_uat_slots.eml` | Mon 28-Sep-2026 09:50 | Sneha Pillai -> Shalini, Priya, Vikram, Meghna, cc drishti-core | `UAT slots 12 Oct - 6 Nov` |
| EM-092 | `EM-092_var003_night_reply.eml` | Thu 08-Oct-2026 23:51 | Aniruddh Deshpande -> Karthik, cc Farida, Ananya | `RE: VAR-003 - what is updating the invoice lines` |

Email conventions:
- Headers to include: `From`, `To`, `Cc` (where used), `Subject`, `Date` (RFC 5322 with the correct
  offset: `+0530` for IST, `+0200` for CEST, `+0100` for CET, `+0800` for SGT), `Message-ID`,
  `In-Reply-To` and `References` on replies, `MIME-Version`, `Content-Type: text/plain; charset="UTF-8"`,
  `X-Mailer` occasionally, `Thread-Topic` on Klarissen mails.
- Message-ID form for BCPL and Northlane Analytics:
  `<AM9PR07MB6212F3A1C9D4E7B2A5C8D91E0@AM9PR07MB6212.eurprd07.prod.outlook.example>` — vary the hex
  block per message, never reuse an ID, and keep the same mailbox stem within one thread.
- Klarissen mails use `<VI1PR04MB5109 ... @VI1PR04MB5109.eurprd04.prod.outlook.example>`.
- Quoted history uses `> ` prefixes and Outlook-style separators:
  `From: ... Sent: 16 April 2026 20:31 To: ... Subject: ...`
- Signature blocks: BCPL staff have a four-line signature with the Andheri East address and a
  confidentiality footer that is longer than most of their emails. Northlane Analytics staff have a
  two-line signature. Marijke has none.
- At least four threads must contain a top-post reply above untouched quoted history, and at least
  one must contain a mangled forward where the indentation has collapsed.

### 15.4 Documents — `_sources/docs/`

| ID | Filename | Date | Author | Length | Load-bearing content |
|---|---|---|---|---|---|
| DOC-01 | `DOC-01_orion_oltp_schema_notes.docx` | 09-Mar-2026 | Aniruddh Deshpande, edited by Ishaan Bhatt | approx. 14 pages | **`F-DELFLAG` (exclusive)**, ORION history, Sahyadri Softech, missing ER diagram, **PII-5** in Appendix B |
| DOC-02 | `DOC-02_odi_job_inventory.docx` | 20-Mar-2026 | Farida Contractor | approx. 11 pages | **`F-MANUAL` (exclusive)**, load plan and mapping inventory, window statistics, `MAP_STG_CREDIT_NOTE` disabled note |
| DOC-03 | `DOC-03_stored_procedure_walkthrough.docx` | 28-Apr-2026 | Karthik Subramanian, reviewed by Aniruddh Deshpande | approx. 9 pages | **`F-TIMING` and `F-ADDITIVE` (exclusive)** — the only place the VAR-003 mechanism exists |
| DOC-04 | `DOC-04_dimension_strategy.docx` | 11-May-2026 | Karthik Subramanian | approx. 12 pages | SCD2 rationale, the ADR register ADR-001 to ADR-005 |
| DOC-05 | `DOC-05_edw_target_model_notes.docx` | 08-Apr-2026 | Karthik Subramanian and Ishaan Bhatt | approx. 16 pages | target star schema, and **`F-CNGAP` as a single parenthetical aside (exclusive)** |

Document conventions: Word docs carry a version history table on page 2 with two or three rows and at
least one row whose "changes" cell says something unhelpful like "minor updates". Headers and footers
carry `Project Drishti | Confidential`. Track-changes are not present but at least two docs contain a
leftover highlighted `TBC` or a comment-style `[Ani to confirm]` in the body text. Document properties:
Author as above, Company `Northlane Analytics` except DOC-01 and DOC-02 where Company is
`Bharadwaj Consumer Products Ltd`.

### 15.5 Trackers — `_sources/trackers/`

| ID | Filename | Last saved | Owner | Sheets |
|---|---|---|---|---|
| XL-01 | `XL-01_variance_tracker_v7.xlsx` | 18-Sep-2026 | Sneha Pillai | `Summary`, `Variance Log`, `VAR-005_detail`, `Closed`, `Change Log` |
| XL-02 | `XL-02_dq_profiling_results.xlsx` | 12-Jun-2026 | Meghna Rao with Neha Gokhale | `Profiling Summary`, `Column Profile`, `DQ Rules`, `Failures by Table`, `Sample Failures` |
| XL-03 | `XL-03_scd2_load_impact.xlsx` | 22-Apr-2026 | Karthik Subramanian | `Assumptions`, `Load Window Model`, `Scenarios`, `Recommendation` |
| XL-04 | `XL-04_source_to_target_mapping.xlsx` | 10-Jun-2026 | Ishaan Bhatt | `FACT_INVOICE_LINE`, `DIM_CUSTOMER`, `DIM_PRODUCT`, `DIM_GEOGRAPHY`, `DIM_SCHEME`, `DIM_DATE`, `Notes` |

Tracker conventions: at least one sheet in XL-01 and XL-02 has a frozen top row, a filter, and a
column of dates stored as text. XL-01 carries **PII-3** as a cell comment. XL-01's `Variance Log`
shows **`F. Contractor` as the owner of VAR-004** — the tracker was never updated after the July
handover, and that staleness is deliberate. XL-04 documents the `DOC_TYPE <> 'SMP'` filter and does
**not** know about the `DOC_TYPE = 'INV'` change (it was saved on 10-Jun, fifteen days before that
decision was taken).

### 15.6 Technical — `_sources/technical/`

| ID | Filename | Content |
|---|---|---|
| TECH-SQL-OLTP | `schema_oltp.sql` | `OMS_PROD` and `FIN_PROD` DDL as it exists in ORION, including `CREDIT_NOTE` and `CREDIT_NOTE_LINE`, the `DELETE_FLAG` columns, and the 2019 `ALTER TABLE` left in as a commented-out historical statement. Extracted from the DB, so it has generated-DDL formatting and inconsistent comment style. |
| TECH-SQL-EDW | `schema_edw.sql` | `BCPL_EDW` DDL: all dimensions, `FACT_INVOICE_LINE`, `FACT_SECONDARY_SALES`, `FACT_ORDER_LINE`, `TAX_RATE_MASTER`, control tables, and the `STG_ORION` landing tables including the dormant `STG_CREDIT_NOTE`. **Contains no `FACT_CREDIT_NOTE`.** The absence is the evidence. |
| TECH-PKG | `pkg_month_end.pkb` | `FIN_PROD.PKG_MONTH_END` package body. The additive `UPDATE`, no idempotency guard, stale 2011 header comment and a 2014 modification note. No schedule time. |
| TECH-ODI-XML | `odi_mapping_export_MAP_FACT_INVOICE_LINE.xml` | ODI 12c mapping export, **exported 20-May-2026**, as-was state (no `DELETE_FLAG` filter, `CREATED_TS` date key, `IKM Oracle Control Append`). |
| TECH-CSV | `sample_extract_invoice_line.csv` | 60 to 120 rows of `STG_INVOICE_LINE`-shaped sample data using the canonical SKUs, distributors and depots. Must include at least three rows with `DELETE_FLAG` empty, at least two with `DELETE_FLAG=Y`, one invoice with `DOC_TYPE='STN'`, and one invoice line appearing twice with different `LOAD_DT` values. |
| TECH-CTLM | `control_m_schedule.txt` | Control-M folder listing per §10.3. No `FIN_PROD` job. No 02:10-02:20 time. |
| TECH-PROPS | `db_config_snippet.properties` | ODI/JDBC connection properties fragment. Carries **PII-4**, a hardcoded password. |

### 15.7 Chat — `_sources/chat/`

| ID | Filename | Span | Participants |
|---|---|---|---|
| CH-01 | `CH-01_teams_data_workstream.txt` | 04-Mar-2026 to 30-Sep-2026, exported as a flat log | Karthik, Ishaan, Farida, Ani, Neha, Ritwik, Sneha, Priya |
| CH-02 | `CH-02_whatsapp_uat_group.txt` | 09-Oct-2026 to 16-Oct-2026 | Priya, Vikram, Ritwik, Sneha, Meghna |

CH-01 is a Teams channel export: lines of the form
`[04/03/2026 14:12] Karthik Subramanian: ...`, with occasional `<edited>` markers, reactions rendered
as `(1 like)`, and a few messages that are just a link or a file name. **CH-01 carries `F-CHATDEC`.**
CH-02 is a WhatsApp export: `[09/10/2026, 21:14:03] Priya Nair: ...`, with
`‎<Media omitted>` lines, a `Messages and calls are end-to-end encrypted...` header line, and
**PII-1**. Date format in both is `DD/MM/YYYY`.

### 15.8 Recordings — `_sources/recordings/`

Eight `.txt` link stubs, no media, one per meeting. Filenames mirror the meeting slugs:

| ID | Filename | Meeting |
|---|---|---|
| REC-01 | `REC-2026-02-11_kickoff_scope.txt` | T-01 |
| REC-02 | `REC-2026-03-03_oltp_discovery.txt` | T-02 |
| REC-03 | `REC-2026-03-24_variance_findings.txt` | T-03 |
| REC-04 | `REC-2026-04-14_architecture_review.txt` | T-04 |
| REC-05 | `REC-2026-05-06_design_signoff.txt` | T-05 |
| REC-06 | `REC-2026-06-18_dq_readout.txt` | T-06 |
| REC-07 | `REC-2026-08-05_dashboard_scope_workshop.txt` | T-07 |
| REC-08 | `REC-2026-09-22_steerco.txt` | T-08 |

Each stub contains: meeting title, date and time, organiser, duration `hh:mm:ss`, a
`https://bharadwajcp.sharepoint.example/sites/drishti/Recordings/<slug>.mp4` link, a file size in MB,
an expiry date 90 days after the meeting, a line saying the transcript was auto-generated, and a
sentence noting that the recording is not attached. Stubs carry no substantive project facts. Two of
the eight should note that the recording failed or is partial (REC-03 "recording started 6 minutes
late", REC-07 "audio only for the first 22 minutes").

---

## 16. PHANTOM FILENAMES

These filenames are **referenced inside artifacts but must never be created on disk**. They are part
of the realistic mess. Do not generate them; do not "fix" a reference to point at a real file.

| Phantom filename | Referenced in | Why |
|---|---|---|
| `XL-01_variance_tracker_v6.xlsx` | EM-075, CH-01 | Sneha says she is attaching it; the attachment is missing and v7 is what actually exists |
| `DK-01_kickoff_v2_FINAL_revised.pptx` | EM-012, T-01 | an earlier circulated version |
| `Drishti_status_wk28.pptx` | EM-068, CH-01 | the weekly status pack, never in scope |
| `BCPL_reco_Aug26_vikram_v3 (1).xlsx` | EM-084, CH-02 | Vikram's own shadow workbook |
| `ORION_functional_spec_2009.doc` | DOC-01, T-02 | the Sahyadri Softech spec nobody can find |
| `scheme_calc_logic_2014.xls` | T-02, EM-092, CH-01 | Ani's own notes from the 2014 change |
| `UAT_defect_log.xlsx` | EM-089, CH-02 | lives on someone's laptop |
| `dq_rules_master_v2.xlsx` | DK-04, T-06 | superseded by XL-02 |

Note also: there is **no UAT deck** in this corpus. `contradiction_ledger.csv` records that the
nine-dashboard figure is sometimes attributed to "the UAT deck" in conversation. It is not there.
The figure lives in DK-06 and T-08. Do not create a UAT deck to satisfy the reference.

---

## 17. STYLE, MESS AND FORMAT RULES

### 17.1 Mess is mandatory

Polished, uniform, evenly-structured output is a **bug**. Every artifact must show at least three of:

- a typo that is never corrected (`recieved`, `seperate`, `teh`, `figuers`, `pls`, `Ntoe`)
- inconsistent capitalisation of the same term in the same document (`Scheme Discount`, `scheme
  discount`, `SCHEME DISCOUNT`)
- a half-finished sentence or a sentence that changes direction halfway
- a stale figure that was true two weeks earlier
- a filler phrase (`basically`, `as such`, `only`, `itself`, `kindly`, `do the needful`, `revert`)
- a date written in a different format from the rest of the document (`14/02/26`, `14-Feb-26`,
  `Feb 14th`, `14.02.2026`)
- a reference to a meeting or mail that the reader is assumed to remember
- an unresolved `TBC`, `[?]`, `<check this>`
- a bullet list where the last bullet is one word

Prose rules:
- **Vary sentence length hard.** Three words. Then thirty. Humans do not write balanced prose at 11pm.
- **Avoid em-dashes.** Use commas, full stops, brackets, or just start a new sentence. The only
  permitted em-dash in `_sources/` is inside the SYNTHETIC marker itself.
- Avoid tidy tricolons ("faster, cheaper, better"). Avoid "It's not just X, it's Y".
- Avoid headings that are perfectly parallel. Avoid a summary paragraph that restates what was said.
- Nobody in this corpus writes like a language model. If a paragraph could be a blog post, rewrite it.
- Indian English register where it is natural: "revert" for reply, "do the needful", "prepone",
  "kindly", "the same" as a pronoun ("please share the same"), "intimate" for inform, lakh/crore,
  "Sir" from Vikram to Rajeev, "ji" never (not this office).

### 17.2 Numbers and currency

- Indian digit grouping in artifacts written by BCPL and Northlane Analytics people:
  `INR 4,21,63,910`. Klarissen people use `EUR 336,796` with Western grouping.
- Crore and lakh: `4.2 Cr`, `90 L` or `90 lakh`, `INR 1,842 Cr`. Vikram writes `41.7 cr` lowercase.
  Shalini writes `INR 4.20 Cr` with two decimals. Marijke writes `EUR 0.34m`.
- The meeting platform transcribes "crore" as **"core"** and "lakh" as **"lac"**. See the ASR rules.
- Percentages to one decimal where they come from profiling (`8.7%`, `14.9%`, `2.0%`).

### 17.3 Transcript formats

**`.vtt` files** are the raw auto-transcript from the meeting platform. Format:

```
WEBVTT

NOTE Auto-generated transcript. Accuracy may vary.

1
00:00:03.480 --> 00:00:08.120
<v Ananya Krishnan>okay I think we are all here, let me just start the recording

2
00:00:08.400 --> 00:00:14.960
<v Ananya Krishnan>so, uh, thanks everyone for making the time, this is the first of the
```

Rules for `.vtt`:
- Cue numbers are sequential integers starting at 1.
- Timestamps advance realistically and the last cue ends within 90 seconds of the meeting's stated
  length. A 60 minute meeting ends near `00:59:xx`, a 90 minute meeting near `01:29:xx`.
- Cue length 4 to 20 seconds. Aim for 150 to 260 cues per hour of meeting, i.e. a condensed but
  continuous transcript rather than a summary. Never leave a gap of more than four minutes.
- Speaker tags use `<v Full Name>`. The platform sometimes gets the speaker wrong; do this two or
  three times per transcript, and once attribute a line to `<v Unknown Speaker>`.
- Lowercase, no punctuation beyond commas, filler words (`uh`, `um`, `so`, `yeah`, `no no`, `sorry
  go ahead`, `you are on mute`, `can you hear me`), overlapping speech, and false starts.
- **All ASR errors from `terminology_map.csv` (kind=asr) live here.** Use them freely and
  inconsistently: the same word may be right in one cue and wrong in the next.
- Two or three `[inaudible]` markers, one `[crosstalk]`, and at least one dropout for the meetings
  held in the 4th floor board room.

**`.txt` files** are the notes Sneha Pillai circulates afterwards. Format:

```
Bharadwaj Consumer Products Ltd / Northlane Analytics
Project Drishti - <Meeting title>
Date: <Weekday> <dd Month yyyy>, <hh:mm>-<hh:mm> IST
Venue: <location>
Notes by: Sneha Pillai
Attendees: <names, comma separated>
Apologies: <names or "none">

<notes, in past tense, speaker-attributed, 700 to 1,800 words>

Actions
AI-nn | <description> | <Owner> | <due dd-Mmm>
...

SYNTHETIC — generated for internal demo. No real entity depicted.
```

Rules for `.txt`:
- Sneha's voice throughout (see §7.2). Past tense, third person, short sentences.
- Action IDs are continuous across the whole corpus: T-01 starts at `AI-01`, and each meeting picks
  up where the last one stopped. Allocation: T-01 `AI-01`-`AI-07`, T-02 `AI-08`-`AI-13`,
  T-03 `AI-14`-`AI-21`, T-04 `AI-22`-`AI-29`, T-05 `AI-30`-`AI-36`, T-06 `AI-37`-`AI-45`,
  T-07 `AI-46`-`AI-55`, T-08 `AI-56`-`AI-61`.
- **Two to four uncorrected ASR errors survive into each `.txt`.** Sneha did not catch them. Put them
  where she would not have known better: a system name, a place name, a number word.
- One `[inaudible]` or `[name not captured]` per set of notes.
- The notes are not a transcript. They lose things the `.vtt` contains, and they occasionally record
  something that is not in the `.vtt` at all because it was said while the recording was stopped.
  That asymmetry is desirable.

### 17.4 Where the SYNTHETIC marker goes

Every generated file in `_sources/` carries this string **verbatim**, once:

```
SYNTHETIC — generated for internal demo. No real entity depicted.
```

(Note the em-dash. It is required here and only here.)

| File type | Placement |
|---|---|
| `.vtt` | a trailing `NOTE SYNTHETIC — generated for internal demo. No real entity depicted.` after the last cue |
| `.txt` (meetings, chat, recordings, Control-M) | final line |
| `.eml` | last line of the message body, below the signature |
| `.docx` | final paragraph of the document, and also in the document `comments` property |
| `.pptx` | a final slide containing only the marker, and in the presentation `comments` property |
| `.xlsx` | cell `A1` of the last sheet, or a dedicated last row, whichever is less obtrusive |
| `.sql`, `.pkb`, `.properties` | a comment on the final line using that language's comment syntax |
| `.xml` | an XML comment on the final line |
| `.csv` | a final line prefixed with `#` |

### 17.5 ASR rules

- ASR errors appear in `.vtt` files, and survive into meeting `.txt` files two to four times each.
- ASR errors **never** appear in email, documents, decks, trackers, technical files or chat.
- The same speaker's proper nouns get mangled consistently within a meeting but not across meetings.
- Numbers are the most dangerous: "four point two crore" comes out as "4.2 core" or "four point two
  core" and once as "42 core". Let one number be transcribed wrongly in a way that matters, in T-03.

### 17.6 Chat rules

- CH-01 (Teams) is where work actually gets decided. It is terse, technical, and out of order.
  People answer a question three messages later. There are two long silences (the Klarissen audit
  week in July, and the last two weeks of August).
- CH-02 (WhatsApp) is logistics and mild complaining. Emoji are permitted here and nowhere else, used
  sparingly, and never by Karthik or Marijke (who is not in the group).
- Neither chat may be tidied into a narrative. Interleave three or four threads of conversation.

---

## 18. NUMBERS APPENDIX — every frozen figure in one place

Do not recompute. Do not re-round. If a number you need is not here, do not use a number.

### 18.1 Variance amounts

| ID | Display value | Exact INR | EUR at 92.40 |
|---|---|---|---|
| VAR-001 | 4.2 Cr | 4,21,63,910 | 456,319 |
| VAR-002 | 90 L | 89,74,200 | 97,123 |
| VAR-003 | 1.7 Cr | 1,68,90,000 | 182,792 |
| VAR-004 | 65 L | 64,80,500 | 70,135 |
| VAR-005 (validated) | 3.1 Cr | 3,11,20,000 | 336,797 |
| VAR-005 (early, wrong) | 2.4 Cr | 2,40,00,000 | 259,740 |
| VAR-006 | 40 L | 39,60,000 | 42,857 |
| VAR-007 | 2.0% of invoiced volume | no INR value assigned | n/a |
| VAR-008 | 2.9 Cr | 2,94,10,000 | 318,290 |
| Total quantified | 13.85 Cr | | 1,498,918 |
| Closed | 8.40 Cr | | |
| Open | 5.45 Cr (see §12 on the rounding) | | |

### 18.2 Load window and SCD2 impact (XL-03, EM-041, EM-047)

| Item | Value |
|---|---|
| `MAP_DIM_CUSTOMER` current runtime | 4 min 12 sec |
| `MAP_DIM_CUSTOMER` with SCD2, measured on DEV 21-Apr-2026 | 11 min 40 sec |
| Delta | **+7 min 28 sec** |
| Farida's estimate in EM-041 | "12 to 15 minutes" (wrong, and she says so is an estimate) |
| `LP_DAILY_SALES` average elapsed | 58 min |
| `LP_DAILY_SALES` P95 elapsed | 71 min |
| Worst month-end night in sample | 3 h 12 min, finishing 04:12 IST |
| Worst night with SCD2 added | finishes **04:20 IST** |
| SLA | 05:30 IST. Head-room at worst case: **70 minutes** |
| `DIM_CUSTOMER` rows today | 2,140 |
| `DIM_CUSTOMER` rows projected Mar-2027 with SCD2 | approx. 6,900 |
| Average changed customer rows per night | 23 |
| Peak changed rows (territory realignment days) | 310, four such days a year |
| Extra storage per year | 38 MB |
| Sample window used for the model | 01-Feb-2026 to 17-Apr-2026, 76 nights |

### 18.3 DBLINK evidence (T-04, ruling out the T-03 hypothesis)

From the AWR report for `edw-db-prd-01`, 23-Mar-2026 01:00 to 03:00:

| Item | Value |
|---|---|
| `SQL*Net message from dblink` total wait | 4.1 minutes across the whole load |
| Average round trip | 38 ms |
| Round trips | 6,412 |
| Share of load elapsed attributable to the link | 1.2% |
| Intra-DC network latency, Mumbai | 0.4 ms |
| Conclusion | the link is not material; it cannot produce a 1.7 Cr value error, only elapsed time |

Two corroborating observations recorded against the same investigation, and these are the
only two; do not invent a third experiment:

1. Nights where the link was fast and the plan closed early produced the same variance as
   nights where it closed at 04:12. Latency and variance do not correlate.
2. Latency changes *when* the extract finishes. It does not change *what the source rows
   contained at the moment they were read*, and it does not change what happens to those
   rows afterwards.

Karthik's line in T-04, in substance: a latency problem makes the load slow, it does not make the
numbers wrong, and the duplicated amounts are exact duplicates rather than partial rows.

`odi_canon.md` §4.1 and `procs_canon.md` §4a carry the same figures. They agree with this
table exactly. If any of the three ever disagree, this table wins.

### 18.4 Data quality (XL-02, DK-04, T-06)

Overall DQ score at the June assessment: **71 / 100**.
By dimension: completeness 68, validity 74, consistency 66, uniqueness 79, timeliness 91.
Tables profiled: 14 (7 in ORION, 7 in `BCPL_EDW`). Profiling run date: **31-May-2026**.
Rules defined: **24** (`DQ-R-01` to `DQ-R-24`). Rules failing: **9**.

Named rules (use these IDs consistently):

| Rule | Dimension | Statement | Threshold | Actual | Result |
|---|---|---|---|---|---|
| `DQ-R-01` | completeness | mandatory columns on `FACT_INVOICE_LINE` are not null | 99.9% | 99.97% | pass |
| `DQ-R-04` | completeness | every invoiced SKU resolves to a known `DIM_PRODUCT` member | 99.5% | **98.0%** | fail (VAR-007) |
| `DQ-R-07` | uniqueness | exactly one `CURRENT_FLG='Y'` row per `CUSTOMER_ID` | 100% | **99.16%** (18 of 2,140) | fail (VAR-004) |
| `DQ-R-09` | consistency | one fact row per source invoice line | 100% | **99.94%** | fail (VAR-003, VAR-008) |
| `DQ-R-12` | validity | `SRC_DELETE_FLAG` in ('Y','N') | 100% | **85.1%** | fail (nulls, VAR-001 family) |
| `DQ-R-15` | validity | GST rate matches the rate effective on the invoice date | 99.9% | **96.3%** | fail (VAR-006) |
| `DQ-R-18` | timeliness | facts available by 05:30 IST | 98.0% | **97.3%** | fail, marginal |
| `DQ-R-21` | consistency | `DATE_KEY` month equals `INVOICE_DT` month | 100% | **99.87%** | fail (VAR-002) |
| `DQ-R-23` | consistency | every fact row resolves to a current `DIM_CUSTOMER` row | 100% | **99.71%** | fail (VAR-004) |

Row counts as of the 31-May-2026 run:

| Object | Rows |
|---|---|
| `OMS_PROD.INVOICE_LINE` | 61,847,220 |
| `OMS_PROD.INVOICE_HEADER` | 8,902,144 |
| `OMS_PROD.CUSTOMER` | 2,140 |
| `OMS_PROD.SKU_MASTER` | 1,246 |
| `OMS_PROD.CREDIT_NOTE` (FY26 only) | 9,318 |
| `OMS_PROD.CREDIT_NOTE_LINE` (FY26 only) | 31,204 |
| `BCPL_EDW.FACT_INVOICE_LINE` | 34,182,556 |
| `BCPL_EDW.FACT_SECONDARY_SALES` | 9,940,180 |
| `BCPL_EDW.FACT_ORDER_LINE` | 12,604,881 |
| `BCPL_EDW.DIM_CUSTOMER` | 2,140 |
| `BCPL_EDW.DIM_PRODUCT` | 1,246 |
| `BCPL_EDW.TAX_RATE_MASTER` | 214 |
| `DELETE_FLAG` distribution on `INVOICE_LINE` | Y 5,380,708 (8.7%) / N 47,251,124 (76.4%) / null 9,215,388 (14.9%) |
| Customers with overlapping effective dates | 61 |
| Customers with two `CURRENT_FLG='Y'` rows | 18 |
| SKUs with null `CATEGORY_CD` | 37 |
| Lines landing on `PRODUCT_KEY = -1` per month | 8,140 average, 11,902 peak (Jan-2026) |
| Secondary sales distributor coverage | 74% |
| Secondary sales feed lag | 5 days |

### 18.5 Credit notes (VAR-005, Q5)

| Item | Value |
|---|---|
| FY26 credit notes, all types | 9,318 documents, INR 46.81 Cr |
| Of which revenue-affecting types (`RATE_DIFF`, `OFF_INV_ADJ`) | **1,206 documents, INR 3,11,20,000 (3.11 Cr)** |
| Other types (`DAMAGE`, `RETURN`, `SCHEME`) | 8,112 documents, INR 43.70 Cr, settled against provisions or through the scheme accrual route inside ORION, so they do not hit the reported revenue line |
| Early estimate stated in DK-03 | INR 2,40,00,000 (2.4 Cr) |
| Why the early estimate was wrong (**EXCLUSIVE to EM-063**) | it covered Apr-2025 to Dec-2025 only, and it excluded the `OFF_INV_ADJ` type entirely |
| Validated by | Shalini Iyer, 21-Jul-2026, against the FY26 trial balance |
| Escalated by | Marijke van der Berg, 14-Jul-2026, EM-061 |

### 18.6 Power BI and UAT

| Item | Value |
|---|---|
| Reports at go-live | 9 |
| Dataset | `DRISHTI_SALES`, import mode, 1.9 GB compressed |
| Refresh | 06:00 and 14:00 IST |
| Named users at go-live | 128 (of which 41 are Sales Ops) |
| RLS roles | 4, by `REGION_CODE` |
| UAT scripts | 14 (`UAT-01` to `UAT-14`) |
| UAT testers | 9 |
| UAT window | 12-Oct-2026 to 06-Nov-2026 |
| Defects raised in the first UAT week | 23 (17 cosmetic, 4 data, 2 access) |

---

## 19. HARD PROHIBITIONS

Violating any of these fails the run.

1. **No sixteenth name.** Fifteen people, four organisations, nothing else. Exactly two non-Indian names.
2. **No fact that is not in the Canon.** No invented tables, columns, jobs, dates, amounts, systems,
   ticket numbers, room names, or cities.
3. **`fact_ownership.csv` is binding.** If your artifact ID is in a fact's `must_not_appear_in`, that
   fact is forbidden to you in every form, including paraphrase, hint, allusion and rounding.
4. **`F-TIMING` never leaves DOC-03.** No `02:15`, no "after the load", no ordering claim.
5. **`FACT_CREDIT_NOTE` is never created**, never designed, never listed in a schema, never put on a
   roadmap slide with a date. `schema_edw.sql` shows the absence by containing no such table.
6. **The Q6 decision does not exist anywhere.** No artifact may say that credit notes will be netted
   in Power BI, that `FACT_CREDIT_NOTE` is deferred to Phase 2, or that D11 will source credit notes
   from a Finance file. If your artifact needs to talk about D11's data, talk about receivables ageing
   from `AR_OPEN_ITEM` and stop there.
7. **No artifact references `_canon/`** or any file in it, or the existence of a canon at all.
8. **Every file carries the SYNTHETIC marker verbatim**, once, in the place §17.4 specifies.
9. **Generator scripts live in `_build/gen/`**, never in `_sources/`.
10. **Seed 20260822** for every random choice. No network calls.
11. **No em-dashes in artifact prose.** The marker is the only exception.
12. **Never write `Northlane` alone.** Always `Northlane Analytics` in full.
13. **No real company, person, product endorsement, or dataset.** Product names permitted by §6.2 only.
14. Do not create, modify or delete anything outside your assigned output paths and `_build/gen/`.

---

## 20. CANON FILE SET AND PRECEDENCE

`_canon/` was written by more than one Phase A agent and the halves were **reconciled at
the Phase A exit gate on 22 August 2026**. The narrative half (this file and the CSVs) and
the technical half (`schema_canon.sql`, `procs_canon.sql`, `odi_canon.md`,
`procs_canon.md`) now name the same objects, the same times and the same people. This
section records the precedence order, the closed object universe, and the collisions that
were resolved, so that no downstream agent has to guess and so that nobody reintroduces a
dead name from an earlier draft.

### 20.1 Precedence order

1. **`CANON.md`** (this file). The master fact sheet. **Binding, and it wins over everything
   else in `_canon/` on any point where they differ**, including object names, column
   names, datatypes, times, figures and people.
2. **`fact_ownership.csv`**. Co-binding with this file, and controlling on *where a fact may
   appear*. Where CANON.md states a fact and `fact_ownership.csv` restricts it, the
   restriction governs.
3. **`demo_answer_map.md`**, **`contradiction_ledger.csv`**, **`variance_register_canon.csv`**,
   **`timeline.csv`**, **`terminology_map.csv`**, **`pii_plant_register.csv`**. Binding within
   their subject.
4. **Technical companions**: `schema_canon.sql`, `procs_canon.sql`, `procs_canon.md`,
   `odi_canon.md`. Detailed elaboration, **now consistent with this file**. They carry
   column-level DDL, knowledge-module options, mapping defects and the batch clock. Use
   them freely for that detail. On the rare point where one still differs from §9, §10 or
   §11, this file wins.

**There are no known open conflicts between the four companions and this file.** Each
companion carries a short "dead names" register at its head listing the names an earlier
draft used. Those names appear nowhere else in the companion and must appear nowhere in
`_sources/`.

### 20.2 Closed object universe

**If an object is not in CANON.md §9, §10 or §11, it does not exist.** The following names
were used by superseded drafts of the technical companions. They are **dead**. They must
not appear in any artifact in `_sources/`, in any comment, in any mapping document, in any
sample data column heading, or in any conversation transcript:

`CUSTOMER_MASTER`, `ITEM_MASTER`, `ORD_HEADER`, `ORD_LINE`, `ORD_STATUS_HIST`,
`CUST_SHIP_TO`, `DISTRIBUTOR_MASTER`, `ITEM_UOM_CONV`, `PRICE_LIST`, `PRICE_LIST_LINE`,
`SCHEME_APPLIED`, `RETURN_HEADER`, `RETURN_LINE`, `CREDIT_NOTE_HEADER`, `GST_TAX_LINE`,
`FIN_PROD.INVOICE_HEADER`, `FIN_PROD.INVOICE_LINE`, `WH_LOAD_AUDIT`, `WH_ERROR_LOG`,
`DIM_DISTRIBUTOR`, `FACT_SALES_ORDER`, `FACT_RETURNS`, `AGG_MONTHLY_SALES`,
`MAP_AGG_MONTHLY_SALES`, `MAP_STG_ORD_HEADER`, `MAP_DIM_CUSTOMER_SCD2`,
`MAP_DIM_PRODUCT_SCD2`, `ODI_AGENT_PROD01`, `P_PURGE_CANCELLED_ORDERS`,
`P_LOAD_AUDIT_CLOSE`, `P_REBUILD_PRICE_CACHE`.

Use these instead:

| Dead name | Use |
|---|---|
| `CUSTOMER_MASTER` | `OMS_PROD.CUSTOMER` |
| `ITEM_MASTER` | `OMS_PROD.SKU_MASTER` |
| `ORD_HEADER` / `ORD_LINE` | `OMS_PROD.ORDER_HEADER` / `OMS_PROD.ORDER_LINE` |
| `FIN_PROD.INVOICE_HEADER` / `FIN_PROD.INVOICE_LINE` | `OMS_PROD.INVOICE_HEADER` / `OMS_PROD.INVOICE_LINE` |
| `CREDIT_NOTE_HEADER` | `OMS_PROD.CREDIT_NOTE` |
| `WH_LOAD_AUDIT` / `WH_ERROR_LOG` | `BCPL_EDW.ETL_BATCH_CONTROL` / `BCPL_EDW.ETL_ERROR_LOG` |
| `DIM_DISTRIBUTOR` | no equivalent. Distributors are `CUST_TYPE = 'DISTRIBUTOR'` rows in `DIM_CUSTOMER`. |
| `FACT_SALES_ORDER` | `BCPL_EDW.FACT_ORDER_LINE` |
| `FACT_RETURNS`, `AGG_MONTHLY_SALES` | no equivalent. There is no returns fact and no monthly aggregate. |
| `MAP_STG_ORD_HEADER` | `MAP_STG_ORDER_HEADER` (and `MAP_STG_ORDER_LINE`) |
| `MAP_DIM_CUSTOMER_SCD2` / `MAP_DIM_PRODUCT_SCD2` | `MAP_DIM_CUSTOMER` / `MAP_DIM_PRODUCT` |
| `ODI_AGENT_PROD01` | `OracleDIAgent1` |
| `P_LOAD_AUDIT_CLOSE` | `P_ETL_BATCH_CLOSE` (§11) |
| `P_PURGE_CANCELLED_ORDERS`, `P_REBUILD_PRICE_CACHE` | no equivalent. ORION housekeeping is referenced only as unnamed jobs in Control-M folder `BCPL_ORION_OPS`. |

Invoicing lives in `OMS_PROD`, not in `FIN_PROD`. The ODI agent is `OracleDIAgent1`. The
batch control tables are `ETL_BATCH_CONTROL` and `ETL_ERROR_LOG`. The order fact is
`FACT_ORDER_LINE`. There is no monthly aggregate table, no returns fact and no
`DIM_DISTRIBUTOR`.

### 20.3 Resolved: the audit column convention

This was the one collision the companions did not originally flag, and it is resolved as
follows. **Every table in `OMS_PROD` and `FIN_PROD` carries the same six audit columns, in
this order, at the end of the column list, spelled exactly like this:**

| # | Column | Type |
|---|---|---|
| 1 | `CREATED_BY` | `VARCHAR2(30)` |
| 2 | `CREATED_DT` | `DATE` — but see the exception |
| 3 | `LAST_UPD_BY` | `VARCHAR2(30)` |
| 4 | `LAST_UPD_DT` | `DATE` |
| 5 | `ACTIVE_FLG` | `CHAR(1)` |
| 6 | `DELETE_FLAG` | `CHAR(1)` |

**Dead spellings.** `CREATED_DATE`, `LAST_UPDATED_DATE`, `LAST_UPDATED_BY` and
`ACTIVE_FLAG` came from a superseded draft of `schema_canon.sql`. Do not use any of them
anywhere.

**The exception, and it is load-bearing.** On the transaction tables the created column is
a `TIMESTAMP(6)` written by the application server **in UTC**, and it is named `CREATED_TS`,
not `CREATED_DT`. Those tables are `OMS_PROD.INVOICE_HEADER`, `OMS_PROD.INVOICE_LINE`,
`OMS_PROD.INVOICE_LINE_ARCHIVE`, `OMS_PROD.ORDER_HEADER`, `OMS_PROD.CREDIT_NOTE` and
`FIN_PROD.SCHEME_ACCRUAL`. `INVOICE_HEADER.CREATED_TS` being UTC while `INVOICE_DT` is a
`DATE` in IST **is** VAR-002. Renaming it or making it a `DATE` destroys the variance.

**The second exception.** `OMS_PROD.INVOICE_LINE_ARCHIVE` is "the same shape minus
`DELETE_FLAG`" (§9.1) and carries five of the six. The column never existed on it, because
the table was closed off in 2016, three years before the soft delete programme.

**Business columns are separate from audit columns.** `OMS_PROD.CUSTOMER.STATUS_FLG`
('A' active / 'I' inactive) is a business column listed in §9.1 and it is **not** a synonym
for `ACTIVE_FLG`. `SKU_MASTER.ACTIVE_FLG` is the audit-convention column and it is also the
column that says 862 of the 1,246 SKUs are sellable. Both readings are true and people
conflate them, which is in character.

`LAST_UPD_DT` in particular is load-bearing: it is the column the incremental extract
predicate keys off (`STG_INVOICE_LINE.LAST_UPD_DT >= TRUNC(SYSDATE) - 1`). If an artifact
calls it `LAST_UPDATED_DATE`, the VAR-003 evidence chain stops making sense.

`DELETE_FLAG` keeps its §9.1 semantics: `'Y'` deleted, `'N'` live, `NULL` for rows that
predate the column. The reason the nulls exist is `F-DELFLAG` and belongs to DOC-01 alone.

### 20.4 Warehouse column convention

`BCPL_EDW` tables do **not** carry the six OLTP audit columns. They carry `LOAD_DT`, plus
`UPD_DT` on the SCD2 dimensions that update in place, plus `BATCH_ID` on the facts. There
is no `DW_LOAD_ID`, no `DW_INSERT_TS`, no `DW_UPDATE_TS` and no `SRC_SYS_CD`; those came
from the superseded draft. The SCD2 current-row flag is **`CURRENT_FLG`**, never
`CURRENT_FLAG`. Every `DIM_*` carries a reserved `-1` UNKNOWN member, and the high value on
`EFF_END_DT` is `31-DEC-4712`, not `31-DEC-9999`.

### 20.5 Companion elaboration that IS blessed

1. **Batch service accounts** appearing in `CREATED_BY` and `LAST_UPD_BY`: `ODI_LOAD`,
   `BATCH_OMS`, `SVC_FINBATCH`, `DMS_IFACE`, `SFA_IFACE`, and the old `APPS` on pre-2018
   migrated rows. Use these in sample data and in schema commentary.
2. **There is no change data capture anywhere.** No GoldenGate, no journalising, no CDC.
   Every incremental load in this landscape is a timestamp comparison on `LAST_UPD_DT`.
   This single architectural fact explains most of what goes wrong and may be stated freely.
3. **The knowledge-module roster in §10.2.** Four KMs, and only four.
4. **The batch clock in `procs_canon.md` §2**, subject to the §11 exclusivity banner. The
   EDW half of it (01:00 start, ~02:05 completion) is shared. The ORION half of it
   (02:15, ~02:40, ~02:55) is `F-TIMING` and belongs to DOC-03.

Nothing else from the companions is blessed. When in doubt, use CANON.md and say less.

---

SYNTHETIC — generated for internal demo. No real entity depicted.
