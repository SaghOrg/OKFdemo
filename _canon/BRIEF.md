# CANON BRIEF — Project Bharadwaj

> Condensed working canon for artifact-generation agents. This is AUTHORITATIVE and sufficient
> for most tasks. Full detail lives in _canon/CANON.md (schema/ODI/procs detail in their own files).
> Do NOT cat the whole _canon/ directory — it is ~99k tokens. Read this, plus only what you need.

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


## APPENDIX A — variance register (verbatim)
```csv
"id","title","root_cause","impact_inr","owner","status","opened","closed","detected_in"
"VAR-001","FY26 Q1 revenue overstated","MAP_FACT_INVOICE_LINE applied no DELETE_FLAG filter at all, so logically deleted and cancelled invoice lines were loaded into FACT_INVOICE_LINE and counted as revenue. Apr-Jun 2025 overstated. Correct predicate is NVL(DELETE_FLAG,'N')='N'; a plain DELETE_FLAG='N' would have dropped 9.2 million historic rows.","4.2 Cr (INR 4,21,63,910)","Farida Contractor","Closed","2026-03-24","2026-06-12","T-03"
"VAR-002","Month-end boundary drift","DIM_DATE key derived in MAP_FACT_INVOICE_LINE from INVOICE_HEADER.CREATED_TS, which the application server writes in UTC, instead of INVOICE_DT which is a DATE in IST. Invoices raised after 18:30 IST on the last day of a month were keyed into the following month. Fixed under ADR-005 and CHG0021207.","90 L (INR 89,74,200)","Karthik Subramanian","Closed","2026-03-24","2026-06-12","T-03"
"VAR-003","Scheme discount double-count","P_RECALC_SCHEME_DISCOUNT runs post-load. CANON-INTERNAL TRUTH: the FIN_PROD.PKG_MONTH_END driver P_ADJUST_REVENUE is scheduled inside ORION by DBMS_SCHEDULER job FIN_MTHEND_ADJ_NIGHTLY at 02:15 IST, after the 01:00 IST nightly load has already extracted the lines. It additively updates OMS_PROD.INVOICE_LINE.SCHEME_DISC_AMT and bumps LAST_UPD_DT, so the same lines are re-extracted the next night and appended by IKM Oracle Control Append. THIS TEXT MAY NOT BE REPRODUCED IN ANY ARTIFACT EXCEPT AS PERMITTED BY fact_ownership.csv (F-TIMING, F-ADDITIVE: DOC-03 only).","1.7 Cr (INR 1,68,90,000)","Aniruddh Deshpande","Open","2026-03-24","","T-03"
"VAR-004","Duplicate facts on distributor reassignment","DIM_CUSTOMER SCD2 effective-dating bug. On a territory reassignment the closing row's EFF_END_DT is set to the same timestamp as the new row's EFF_START_DT and CURRENT_FLG is left 'Y' on both rows, so a fact row joins to two dimension rows. 61 customers have overlapping effective dates, 18 carry two current rows. Worked example DIST-W-0241 Mahalaxmi Distributors, reassigned 17-Apr-2026 from TER-W-014 to TER-W-011.","65 L (INR 64,80,500)","Ishaan Bhatt","Open","2026-05-19","","CH-01"
"VAR-005","Credit notes absent from warehouse","No credit note fact table was ever built in BCPL_EDW. OMS_PROD.CREDIT_NOTE and CREDIT_NOTE_LINE exist in ORION and the STG_CREDIT_NOTE landing table exists but its mapping was disabled on 14-Nov-2022. Finance nets the revenue-affecting credit notes by hand in Excel each month, so the warehouse revenue line is gross of them. FY26 revenue-affecting value INR 3,11,20,000 across 1,206 documents of type RATE_DIFF and OFF_INV_ADJ.","3.1 Cr (INR 3,11,20,000)","Shalini Iyer","Open","2026-04-24","","DOC-05"
"VAR-006","GST rate change mishandled","BCPL_EDW.TAX_RATE_MASTER is a truncate-and-reload snapshot of FIN_PROD.TAX_RATE_MASTER holding current rates only, with no effective dating, although the source table is effective-dated. The Chandanaa HSN 3401 change from 18 percent to 12 percent effective 01-Oct-2025 was therefore applied retrospectively to Apr-Sep 2025. Replaced by DIM_TAX_RATE under CHG0021339.","40 L (INR 39,60,000)","Neha Gokhale","Closed","2026-06-18","2026-08-28","XL-02"
"VAR-007","Late-arriving SKUs to UNKNOWN member","No late-arriving dimension handling in MAP_FACT_INVOICE_LINE. A SKU invoiced before MAP_DIM_PRODUCT has seen it is routed to the UNKNOWN member at PRODUCT_KEY = -1 and is never re-pointed once the dimension row arrives. Average 8,140 lines a month, peak 11,902 in Jan-2026, 2.0 percent of invoiced volume. Fails DQ-R-04 at 98.0 percent against a 99.5 percent threshold.","2% of invoiced volume (no INR value assigned)","Ritwik Ghosh","Open","2026-06-18","","XL-02"
"VAR-008","Feb duplicate load","LP_DAILY_SALES re-run is not idempotent. After a first failure on Saturday 14-Feb-2026 the load plan was resubmitted manually as session SESS_884012 and IKM Oracle Control Append appended the entire night's invoice lines a second time. The duplicated sales sat in the February figures for three weeks. Batch-id guard added in R2026.07.","2.9 Cr (INR 2,94,10,000)","Farida Contractor","Closed","2026-03-06","2026-04-02","EM-072"
# root_cause values in this file are CANON-INTERNAL TRUTH. An artifact may state a root cause only to the extent fact_ownership.csv permits.
# VAR-004 owner is Ishaan Bhatt from 09-Jul-2026 (EM-055). XL-01_variance_tracker_v7.xlsx still shows 'F. Contractor' and that staleness is deliberate.
# SYNTHETIC — generated for internal demo. No real entity depicted.
```

## APPENDIX B — contradiction ledger (verbatim)
```csv
"id","fact","early_value","early_artifact","corrected_value","correcting_artifact","resolution_date","notes"
"CON-1","Go-live date","15-Sep-2026","DK-01; T-01","12-Nov-2026","DK-06; T-08","2026-09-22","THREE VALUES, TWO MOVES. 15-Sep-2026 stated at kickoff in DK-01 slide 4 and in T-01. Slips to 30-Oct-2026 in EM-068 on 19-Aug-2026, which is the ONLY artifact carrying the 30-Oct value and the ONLY artifact carrying the reason for the first slip. Settles at 12-Nov-2026 at the steering committee of 22-Sep-2026, stated in T-08 and DK-06. Neither T-08 nor DK-06 may state the 30-Oct value; they refer to the current plan date without repeating it. This is demo question Q1 and the stale trap is DK-01."
"CON-2","Root cause of VAR-003, the scheme discount double-count","DBLINK latency on the ORION_PRD link","T-03","Source-side stored procedure timing in FIN_PROD.PKG_MONTH_END","T-05; DOC-04 (ADR-004)","2026-05-06","Hypothesis raised in T-03 on 24-Mar-2026 and echoed as an open line of enquiry in DK-02. Ruled out in T-04 on 14-Apr-2026 with AWR evidence: 4.1 minutes of link wait across the whole load, 38 ms average round trip, 1.2 percent of elapsed, which explains slowness and not a value error. The mechanism itself is written down only in DOC-03 and is fact F-TIMING. T-05 and ADR-004 record the decision without restating the mechanism. This is demo question Q3."
"CON-3","Number of dashboards in scope for go-live","12","DK-01","9","DK-06; T-08","2026-09-22","THREE VALUES, TWO MOVES. 12 in DK-01 slide 9. Cut to 7 by Shalini Iyer in EM-023 on 30-Mar-2026, which is the only artifact stating 7 as a change and the only artifact carrying her reason. T-07 on 05-Aug-2026 ends at seven committed plus two candidates and does not reach a number. DK-05 shows seven wireframes plus two marked CANDIDATE - not funded. Settles at 9 in DK-06 and T-08. NOTE: in conversation the nine-dashboard figure is sometimes attributed to a UAT deck. NO UAT DECK EXISTS IN THIS CORPUS and none is to be created. The figure lives in DK-06 and T-08 only. This is demo question Q4 and the stale trap is DK-01."
"CON-4","Owner of VAR-004","Farida Contractor","XL-01; DK-04; T-06","Ishaan Bhatt","EM-055","2026-07-09","Reassigned on 09-Jul-2026 and recorded in EM-055 and NOWHERE ELSE. XL-01_variance_tracker_v7.xlsx, saved 18-Sep-2026, still shows F. Contractor in the owner cell for VAR-004 because nobody updated it; that staleness is deliberate and must be preserved. Artifacts dated after 09-Jul may show Ishaan Bhatt doing the VAR-004 work but must never state, imply or contrast that the ownership changed, and must never name Farida Contractor as the former owner."
"CON-5","FY26 impact of missing credit notes (VAR-005)","INR 2.4 Cr","DK-03; T-06","INR 3.11 Cr","EM-063; XL-01","2026-07-21","2.4 Cr was a working estimate presented in DK-03 on 05-May-2026 and repeated once in T-06. Shalini Iyer validated 3.11 Cr against the FY26 trial balance and reported it in EM-063 on 21-Jul-2026. The REASON the early estimate was wrong (it covered Apr-2025 to Dec-2025 only and excluded the OFF_INV_ADJ credit note type) appears in EM-063 and nowhere else. XL-01 carries only the validated figure; its Change Log notes an update without repeating the old number. This is demo question Q5."
"CON-6","SCD strategy for DIM_PRODUCT","SCD1","T-04","SCD2","T-05; DOC-04 (ADR-003)","2026-05-06","Karthik Subramanian proposed SCD1 for DIM_PRODUCT at the architecture review on 14-Apr-2026 on the grounds that SKU attributes rarely change. Reversed at design sign-off on 06-May-2026 after the pack-size and MRP change history turned out to matter for the Product Mix and Contribution dashboard. ADR-003 in DOC-04 records the reversal and explicitly supersedes the 14-Apr position. DIM_CUSTOMER was never proposed as anything other than SCD2, so do not conflate the two."
"CON-7","UAT window","10-Aug-2026 to 28-Aug-2026","DK-01","12-Oct-2026 to 06-Nov-2026","EM-089","2026-09-28","Consequence of CON-1. The original window in DK-01 was built around a 15-Sep go-live. EM-068 states only that UAT cannot start before 05-Oct; it does not give a window. The actual dates appear first in EM-089 on 28-Sep-2026 and are echoed in CH-02. T-08 refers to UAT finishing before the cutover weekend without giving dates."
"CON-8","FY26 Q1 reported net revenue","INR 438.6 Cr","DK-02","INR 434.4 Cr restated","XL-01; DK-06","2026-06-12","438.6 Cr is what the warehouse reported before the VAR-001 fix and is the figure Shalini Iyer was refusing to sign. The 4.2 Cr of cancelled invoice lines came out with CHG0021184 on 03-Jun-2026 and the restated figure is 434.4 Cr. DK-03 in May still shows 438.6 because the fix was not yet deployed; that is correct behaviour for a May artifact, not a contradiction to fix."
# THE UAT DECK DOES NOT EXIST. CON-3 records that the nine-dashboard figure is sometimes attributed in conversation to 'the UAT deck'. There is no UAT deck in this corpus and none may be generated. The figure lands in DK-06_steerco_sep2026.pptx and in T-08.
# A contradiction is only a contradiction if BOTH values are actually written somewhere. Every early_value listed here MUST appear in its early_artifact, unmarked and uncorrected, exactly as a stale document would carry it.
# SYNTHETIC — generated for internal demo. No real entity depicted.
```

## APPENDIX C — terminology map (verbatim)
```csv
"canonical_term","variant","used_by","kind"
"distributor","distributor","Ananya Krishnan; Karthik Subramanian; Ishaan Bhatt; Neha Gokhale; Ritwik Ghosh; Sneha Pillai; Shalini Iyer; Priya Nair; Meghna Rao; Rajeev Menon; Farida Contractor; Aniruddh Deshpande","canonical"
"distributor","channel partner","Marijke van der Berg; Wei Lin Tan","synonym"
"distributor","stockist","Vikram Sethi","synonym"
"distributor","party","Aniruddh Deshpande","legacy"
"distributor","the trade","Vikram Sethi; Rajeev Menon","register"
"distributor","DIST code / party code","Aniruddh Deshpande; Ishaan Bhatt","jargon"
"scheme discount","scheme discount","Karthik Subramanian; Ishaan Bhatt; Aniruddh Deshpande; Ananya Krishnan; Priya Nair; Meghna Rao; Ritwik Ghosh; Sneha Pillai","canonical"
"scheme discount","trade promotion accrual","Shalini Iyer","finance"
"scheme discount","promo accrual","Marijke van der Berg; Wei Lin Tan","finance"
"scheme discount","TPR","Vikram Sethi","misuse"
"scheme discount","secondary scheme","Vikram Sethi; Farida Contractor","misuse"
"scheme discount","the scheme amount","Farida Contractor","synonym"
"scheme discount","scheme accrual","Shalini Iyer; Karthik Subramanian","finance"
"scheme discount","discount","Rajeev Menon","register"
"variance","variance","Ananya Krishnan; Karthik Subramanian; Rajeev Menon; Sneha Pillai; Neha Gokhale; Ishaan Bhatt","canonical"
"variance","reconciliation gap","Shalini Iyer","synonym"
"variance","delta","Aniruddh Deshpande; Ishaan Bhatt","jargon"
"variance","mismatch","Vikram Sethi","synonym"
"variance","not matching","Vikram Sethi; Priya Nair","register"
"variance","the walk","Marijke van der Berg","finance"
"variance","bridge","Wei Lin Tan","finance"
"variance","reconciliation","Farida Contractor; Shalini Iyer","synonym"
"primary sales","primary sales","Karthik Subramanian; Ananya Krishnan; Shalini Iyer; Ishaan Bhatt; Neha Gokhale; Sneha Pillai; Ritwik Ghosh","canonical"
"primary sales","sell-in","Wei Lin Tan; Marijke van der Berg","finance"
"primary sales","billing","Vikram Sethi","misuse"
"primary sales","primary","Vikram Sethi; Priya Nair","abbreviation"
"primary sales","despatch sales","Farida Contractor; Aniruddh Deshpande","legacy"
"primary sales","invoiced sales","Shalini Iyer","finance"
"secondary sales","secondary sales","Karthik Subramanian; Ananya Krishnan; Ishaan Bhatt; Neha Gokhale; Sneha Pillai; Ritwik Ghosh; Meghna Rao","canonical"
"secondary sales","sell-out","Marijke van der Berg; Wei Lin Tan","finance"
"secondary sales","off-take","Vikram Sethi","synonym"
"secondary sales","retail off-take","Vikram Sethi","synonym"
"secondary sales","secondary","Vikram Sethi; Priya Nair","abbreviation"
"primary sales vs secondary sales","THEY ARE NOT THE SAME THING. Primary sales is BCPL to distributor and is revenue. Secondary sales is distributor to retailer and is not revenue. Vikram Sethi routinely quotes secondary while everyone else is quoting primary, which is one of the reasons his numbers never match.","Vikram Sethi (the confusion); Karthik Subramanian and Neha Gokhale (the correction)","false_friend"
"ODI mapping","mapping","Karthik Subramanian; Ishaan Bhatt; Neha Gokhale; Sneha Pillai","canonical"
"ODI mapping","interface","Farida Contractor","legacy"
"ODI mapping","the ETL","Shalini Iyer; Vikram Sethi; Rajeev Menon","register"
"ODI mapping","the code","Aniruddh Deshpande","register"
"dashboard","dashboard","Rajeev Menon; Shalini Iyer; Ananya Krishnan; Vikram Sethi; Marijke van der Berg; Sneha Pillai","canonical"
"dashboard","report","Priya Nair","legacy"
"dashboard","page","Ritwik Ghosh","jargon"
"dashboard","dashboard page","Priya Nair","legacy"
"dashboard","analysis","Priya Nair","legacy"
"filter control","slicer","Ritwik Ghosh; Ishaan Bhatt","canonical"
"filter control","prompt","Priya Nair","legacy"
"visual","visual","Ritwik Ghosh","canonical"
"visual","tile","Ritwik Ghosh; Rajeev Menon","synonym"
"visual","card","Ritwik Ghosh","jargon"
"visual","chart","Priya Nair; Shalini Iyer","register"
"agent","agent means an OBIEE scheduled delivery to Priya Nair and the ODI standalone agent OracleDIAgent1 to Farida Contractor. Both usages appear and nobody disambiguates.","Priya Nair (OBIEE sense); Farida Contractor (ODI sense)","false_friend"
"SCD2","SCD2","Karthik Subramanian; Ishaan Bhatt","canonical"
"SCD2","type 2","Neha Gokhale","synonym"
"SCD2","history tracking","Shalini Iyer; Rajeev Menon","register"
"SCD2","effective dating","Karthik Subramanian; Neha Gokhale","jargon"
"SCD2","versioned dimension","Ishaan Bhatt","jargon"
"nightly load","nightly load","Karthik Subramanian; Ananya Krishnan; Neha Gokhale; Sneha Pillai; Ishaan Bhatt","canonical"
"nightly load","the run","Farida Contractor; Aniruddh Deshpande","jargon"
"nightly load","the batch","Rajeev Menon; Shalini Iyer; Vikram Sethi","register"
"nightly load","load plan","Farida Contractor; Karthik Subramanian","jargon"
"nightly load","the job","Priya Nair; Vikram Sethi","register"
"credit note","credit note","Shalini Iyer; Karthik Subramanian; Ananya Krishnan; Marijke van der Berg; Ishaan Bhatt; Sneha Pillai","canonical"
"credit note","CN","Shalini Iyer; Farida Contractor","abbreviation"
"credit note","claim","Vikram Sethi","misuse"
"credit note","rate difference","Shalini Iyer","finance"
"secondary sales feed","DMS feed","Ishaan Bhatt; Karthik Subramanian","canonical"
"secondary sales feed","SFA upload","Farida Contractor; Priya Nair","legacy"
"secondary sales feed","the secondary file","Vikram Sethi","register"
"warehouse","warehouse","Karthik Subramanian; Ananya Krishnan; Shalini Iyer; Neha Gokhale","canonical"
"warehouse","EDW","Farida Contractor; Ishaan Bhatt; Aniruddh Deshpande","abbreviation"
"warehouse","the DW","Priya Nair; Meghna Rao","abbreviation"
"warehouse","the cube","Priya Nair","legacy"
"crore","Cr","Shalini Iyer; Ananya Krishnan; Karthik Subramanian; Sneha Pillai","abbreviation"
"crore","cr (lowercase)","Vikram Sethi","register"
"lakh","L","Ananya Krishnan; Sneha Pillai; Karthik Subramanian","abbreviation"
"lakh","lacs","Vikram Sethi; Aniruddh Deshpande","register"
"stored procedure","proc","Aniruddh Deshpande; Ishaan Bhatt","jargon"
"stored procedure","stored procedure","Karthik Subramanian; Neha Gokhale; Sneha Pillai","canonical"
"stored procedure","the package","Karthik Subramanian; Aniruddh Deshpande","jargon"
"server","the box","Aniruddh Deshpande","jargon"
"server","host","Karthik Subramanian; Farida Contractor","canonical"
"reply","revert","Vikram Sethi; Priya Nair","register"
"please do it","do the needful","Vikram Sethi","register"
"bring forward","prepone","Vikram Sethi; Priya Nair","register"
"Klarissen Group N.V.","Group","Shalini Iyer; Rajeev Menon; Ananya Krishnan","register"
"Klarissen Group N.V.","Amsterdam","Rajeev Menon","register"
"Bharadwaj Consumer Products Ltd","India","Marijke van der Berg; Wei Lin Tan","register"
"Bharadwaj Consumer Products Ltd","BCPL","everyone","abbreviation"
"Baddi","Buddy","ASR of Aniruddh Deshpande; Farida Contractor; Vikram Sethi","asr"
"Baddi","Bady","ASR of Priya Nair","asr"
"ODI","Odie","ASR of Farida Contractor; Karthik Subramanian","asr"
"ODI","OD I","ASR of Ishaan Bhatt; Neha Gokhale","asr"
"SCD2","SED 2","ASR of Karthik Subramanian","asr"
"SCD2","SCD too","ASR of Ishaan Bhatt","asr"
"Nashik","Nashville","ASR of Vikram Sethi; Ananya Krishnan","asr"
"ORION","Oreo","ASR of Vikram Sethi; Shalini Iyer","asr"
"ORION","O'Ryan","ASR of Ananya Krishnan","asr"
"OBIEE","Obi E","ASR of Priya Nair","asr"
"OBIEE","OB I double E","ASR of Ritwik Ghosh","asr"
"crore","core","ASR of everyone who says a rupee figure","asr"
"lakh","lac","ASR of Shalini Iyer; Vikram Sethi","asr"
"Ani","Annie","ASR of Farida Contractor; Karthik Subramanian; Ishaan Bhatt","asr"
"Aniruddh","Anirood","ASR of Ananya Krishnan","asr"
"Farida","Frida","ASR of Karthik Subramanian; Ananya Krishnan","asr"
"Meghna","Megna","ASR of Neha Gokhale","asr"
"Iyer","Ayer","ASR of Marijke van der Berg; Wei Lin Tan","asr"
"Klarissen","Clarissen","ASR of Rajeev Menon; Shalini Iyer","asr"
"Bharadwaj","Bhardwaj","ASR of everyone","asr"
"Drishti","Drishty","ASR of Ananya Krishnan","asr"
"Sahyadri","Sai Adri","ASR of Aniruddh Deshpande","asr"
"stockist","stock list","ASR of Vikram Sethi","asr"
"SKU","skew","ASR of Ritwik Ghosh; Meghna Rao","asr"
"Control-M","control em","ASR of Farida Contractor","asr"
"DELETE_FLAG","delete flack","ASR of Ishaan Bhatt; Aniruddh Deshpande","asr"
"primary sales","primary cells","ASR of Vikram Sethi","asr"
"secondary sales","secondary cells","ASR of Vikram Sethi; Priya Nair","asr"
"Andheri","Andaree","ASR of Sneha Pillai","asr"
"Suvarn","Sovereign","ASR of Vikram Sethi","asr"
"Rakshak","rickshaw","ASR of Ritwik Ghosh","asr"
"Chandanaa","Chandan A","ASR of Meghna Rao","asr"
"Nimbua","Nimbu ah","ASR of Priya Nair","asr"
"Tarang","Ta rang","ASR of Vikram Sethi","asr"
"DBLINK","the be link","ASR of Karthik Subramanian","asr"
"hypercare","hyper care","ASR of Ananya Krishnan","asr"
"UAT","you A T","ASR of Priya Nair","asr"
"idempotent","I dem potent","ASR of Karthik Subramanian","asr"
"Vikram","Vikrant","ASR of Wei Lin Tan","asr"
# used_by is BINDING. A speaker uses their assigned variant consistently across the entire corpus.
# Vikram Sethi says 'stockist' always and never 'distributor' or 'channel partner'. Marijke van der Berg says 'channel partner' always. Karthik Subramanian says 'SCD2' always.
# kind=asr rows appear ONLY in _sources/meetings/*.vtt, and survive 2 to 4 times into each meeting .txt. Never in email, docs, decks, trackers, technical files or chat.
# SYNTHETIC — generated for internal demo. No real entity depicted.
```

## APPENDIX D — PII plant register (verbatim)
```csv
"plant_id","type","value","location_artifact_id","location_hint","verified"
"PII-1","mobile number","+91 90000 00012","CH-02","_sources/chat/CH-02_whatsapp_uat_group.txt. Priya Nair posts it on the first UAT morning so testers can reach her when the VPN drops. Roughly one third of the way into the log, on 12/10/2026. Written inline in a normal sentence, e.g. 'if anything breaks just call me on +91 90000 00012 i am not on teams today'. Do not label it, do not repeat it, do not put it in a signature block.","pending"
"PII-2","personal email address","vikram.sethi.personal@gmail.example","EM-084","_sources/email/EM-084_north_file_too_big.eml. In the message body, not in a header. Vikram Sethi asks Priya Nair to send the North file to his personal address because BCPL mail bounces anything over 20 MB. The address must appear only in the body text of Vikram's message; the From, To and Cc headers stay on bharadwajcp.example throughout.","pending"
"PII-3","masked bank account fragment","A/c XXXXXXXX4417, IFSC XXXX0000000","XL-01","_sources/trackers/XL-01_variance_tracker_v7.xlsx. An Excel CELL COMMENT, not a cell value, on the VAR-005_detail sheet, cell E22, comment author 'Shalini Iyer'. Comment text along the lines of 'refund went to the distributor a/c XXXXXXXX4417, IFSC XXXX0000000 - do not circulate outside finance'. It must be a comment so that it is discoverable only by a tool that reads comments.","pending"
"PII-4","hardcoded database password","odi.stg.password=Bcpl@Str0ng!2026 and edw.jdbc.password=Wint3r#2026","TECH-PROPS","_sources/technical/db_config_snippet.properties. Two plaintext password lines in a JDBC and ODI connection properties fragment, around lines 9 to 14, sitting between ordinary url, driver and user properties. No warning comment, no placeholder marker. One nearby commented-out line should show an older password, e.g. '#odi.stg.password=Bcpl@Str0ng!2024'.","pending"
"PII-5","Aadhaar-format identity number","9999 8888 7777","DOC-01","_sources/docs/DOC-01_orion_oltp_schema_notes.docx. Appendix B, 'Sample rows', in a small table of example rows from the distributor KYC columns, third data row, in a column headed AADHAAR_NO. It is there because Ani pasted a real-looking sample row out of a query window while writing the appendix and nobody reviewed it. No commentary in the document draws attention to it.","pending"
# Exactly five plants. Values are unmistakably fake by construction: a +91 90000 xxxxx number, a gmail.example address, XXXX-masked bank fields, obviously synthetic passwords and a 9999 8888 7777 Aadhaar-format string.
# NO OTHER PII MAY BE PLANTED ANYWHERE IN THE CORPUS. No other phone numbers, no other personal addresses, no other account or identity numbers, in any artifact.
# verified stays 'pending' until the QA phase confirms each plant is present exactly once and nowhere else.
# SYNTHETIC — generated for internal demo. No real entity depicted.
```
