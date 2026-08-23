# Project Bharadwaj — Engagement Knowledge Base

You are working in the knowledge base for Northlane Analytics'
OLTP→warehouse engagement with Bharadwaj Consumer Products Ltd (BCPL).

Everything here is synthetic demo data. No real entity is depicted.

## Read protocol — do this at the start of EVERY task

Read these before answering anything:

1. `/context/project-brief.md` — what the engagement is
2. `/context/active-context.md` — what is happening right now
3. `/context/glossary.md` — REQUIRED. The client, the consultants,
   and finance use different words for the same things.
4. `/index.md` — catalog of all concepts

Then grep the relevant subtree. Do not answer from `/context/` alone —
it is a map, not the territory.

## How this knowledge base is organised

- `/concepts/tables/` — one file per OLTP or warehouse table
- `/concepts/variances/` — one file per known discrepancy (VAR-NNN)
- `/concepts/metrics/` — metric and KPI definitions
- `/concepts/dashboards/` — dashboard specs
- `/decisions/` — decision records, `YYYYMMDD-slug.md`, MADR format
- `/meetings/` — meeting notes derived from transcripts
- `/context/` — the rehydration set above
- `/_sources/` — raw untransformed artifacts. Read-only. Cite, never edit.

Every concept file is markdown with YAML frontmatter. `type` is the
only required field. Links between concepts are bundle-relative
absolute paths, e.g. `/concepts/tables/fact-invoice-line.md`.

## Answering rules

- **Cite the file you got it from.** Every factual claim names its source file.
- **Prefer the most recent statement of a fact.** Dates and scope changed
  repeatedly during this engagement. Check `updated` frontmatter and
  `/log.md` before trusting an early document.
- **Translate vocabulary through the glossary.** "Scheme discount",
  "trade promotion accrual", and "TPR" are the same thing. "Stockist"
  and "channel partner" both mean distributor.
- **Say when you don't know.** A missing concept file is normal — this
  KB is incomplete by design. Do not fill gaps by inference.
- If two sources conflict and you cannot tell which is current, say so
  and show both.

## Write protocol

You may write to this repo. You must follow this exactly.

**Never commit to main.** Create a branch, make changes, open a PR.

When a decision is made:
1. Create `/decisions/YYYYMMDD-slug.md` from `/templates/decision.md`
2. Fill every frontmatter field
3. Link it from every concept it affects
4. Add a line to `/log.md`
5. Update `/context/active-context.md` if the current focus changed

When a fact changes:
- **Supersede, do not overwrite.** Set the old record's
  `status: deprecated`, add a link to the replacement, and create the
  new record. The history of a wrong belief is valuable here.

When adding a concept:
- Copy the closest existing file's frontmatter shape
- One concept per file
- Cross-link it in both directions

**Never:**
- Edit anything under `/_sources/`
- Delete a concept or decision file
- Commit media, credentials, or unredacted personal data
- Invent a table name, person, date, or figure not present in the repo

## Engagement quick facts

Client: BCPL (FMCG, Mumbai). Source: Oracle 19c "ORION" OLTP
(`OMS_PROD`, `FIN_PROD`). Target: `BCPL_EDW` star schema. ETL: ODI 12c.
BI: OBIEE 11g → Power BI. Scheduling: Control-M.

Workstreams: variance root-cause, data quality, dashboard build.
Eight tracked variances, VAR-001 to VAR-008.
