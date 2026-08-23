# Bharadwaj Consulting Corpus — Project Drishti

## What is this folder?

This is the **raw inbox** of consulting artifacts from a fictional engagement between Bharadwaj Consumer Products Ltd (BCPL), Klarissen Group N.V., and Northlane Analytics. The artifacts you see here represent the messy, overlapping, sometimes contradictory documentation that accumulates during a real data warehouse transformation project.

**This is NOT a knowledge repository or final deliverable.** It is the INPUT to a knowledge transformation pipeline. Think of it as your source material.

## Directory Layout

```
_sources/
├── chat/                 Meeting channels and group chats (Teams, WhatsApp)
├── decks/                PowerPoint presentations
├── docs/                 Word documents and detailed write-ups
├── email/                Email messages (.eml format)
├── meetings/             Meeting transcripts (.vtt ASR and .txt notes)
├── recordings/           Recording stubs linking to external media
├── technical/            SQL scripts, XML mappings, properties files
└── trackers/             Excel workbooks (project tracker, DQ profiling, etc.)
```

## Artifact ID Scheme

Every file in this corpus has a unique artifact ID that appears in its filename or is listed in MANIFEST.csv:

- **T-01 through T-08**: Meetings (steering committee, architecture review, etc.)
- **REC-01 through REC-08**: Recording stubs (one per meeting)
- **DK-01 through DK-06**: Presentation decks
- **EM-012, EM-023, ..., EM-092**: Email messages (spaced IDs for realism)
- **DOC-01 through DOC-05**: Documents
- **XL-01 through XL-04**: Excel trackers
- **CH-01, CH-02**: Chat exports
- **TECH-SQL-OLTP, TECH-CSV, ...**: Technical artifacts (code, DDL, mappings)

Artifact IDs are frozen. They map to exact dates and logical roles in the project.

## Understanding the Corpus

### The Canon
This folder lives alongside a `_canon/` directory (NOT included here) that contains the generation-time source of truth:

- **BRIEF.md** — authoritative cast, systems, terminology, and rules
- **timeline.csv** — when each artifact was created and its canonical metadata
- **fact_ownership.csv** — which critical facts appear where (and only where)
- Other canonical files: contradiction ledger, variance register, schema DDL, etc.

The `_canon/` files are used only during generation. They do not represent artifacts a real user would see.

### How to Read MANIFEST.csv

Each row describes one file in this folder:

| Column | Meaning |
|--------|---------|
| artifact_id | Unique identifier (T-01, EM-023, etc.) |
| path | File path relative to _sources/ |
| type | presentation, document, spreadsheet, transcript, technical, email, other |
| date | ISO date when created (YYYY-MM-DD) |
| author | Person/role that created or authored it |
| title | Short description from the artifact or event |
| canon_facts_owned | Semicolon-separated IDs of facts this artifact EXCLUSIVELY contains |
| size_bytes | File size in bytes |
| sha256 | SHA256 hash for integrity verification |

### Plain-Text Extractions

Binary artifacts (.pptx, .docx, .xlsx) have been pre-extracted to plain text at:

```
_build/corpus_text/
```

The directory mirrors this tree. Text files are for searching (grep is fast); open the original binary file when you need structure, formatting, or formulas.

### Example: Finding a fact

If you need to know when the dashboard count changed from 12 to 7:
1. Look in fact_ownership.csv for fact ID `F-DASH7-REASON`
2. See it is owned by `EM-023` only
3. In MANIFEST.csv, find the row with artifact_id = EM-023
4. Open the file at the path listed: `email/EM-023_dashboard_scope_cut.eml`

### Variance and Contradiction

The corpus deliberately contains contradictions (three different go-live dates, three different dashboard counts). These are marked in the canon as `CON-1`, `CON-3`, `CON-5`. Contradictions exist because:

- Real projects change dates and scope
- Different people remember or quote different versions
- Documents become stale and are not always updated

**Do not "fix" contradictions.** They are data about how projects actually work.

## Generation and Reproducibility

This entire corpus was generated deterministically from a seed (2026-08-22) using canonical source files. Every file, every name, every figure, every contradiction is reproducible and intentional.

**Synthetic marker present in all 63 files** — look for the string "SYNTHETIC — generated for internal demo" at the end of each artifact.

## Key Files

- **MANIFEST.csv** — index of all 63 artifacts with hashes and metadata
- **DISCLAIMER.md** — explicit statement that all names and entities are fictional
- **TREE.txt** — full directory tree with file sizes
- **_build/corpus_text/** — plain-text extractions of binary files for fast searching

## Size and Scope

- **63 artifacts** across 7 categories
- **~2 MB** total size (mostly transcripts and spreadsheets)
- **4 distinct contradictions** embedded and marked
- **5 PII strings** deliberately planted for testing
- **6 exclusive facts** (each appearing in one artifact only)
- **8 variance scenarios** (data quality and data modeling issues)

## What NOT to Do

- Do **not** create a Git repo in this folder — it is a synthetic snapshot, not source code
- Do **not** edit artifacts — they are a fixed corpus; if you find an error, note it in your analysis
- Do **not** add new files — artifact IDs and counts are frozen at 63
- Do **not** "fix" typos, mess, or contradictions — they are intentional test data

## For More Information

- See **DISCLAIMER.md** for the full fictional entity statement
- See **TREE.txt** for the complete directory tree with sizes
- See the top of MANIFEST.csv for field descriptions
- Search **_build/corpus_text/** for any text fragment across all binary artifacts

---

**Generated**: 2026-08-23  
**Seed**: 20260822  
**Status**: Synthetic demo corpus. No real company, person, customer, or data is depicted.

---

_SYNTHETIC — generated for internal demo. No real entity depicted._
