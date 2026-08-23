---
type: oltp-table
title: GL_JOURNAL_HDR (FIN_PROD)
description: General ledger journal entry headers; one row per journal posting, parent
  record for GL_JOURNAL_LINE.
resource: FIN_PROD.GL_JOURNAL_HDR
tags:
- general ledger
- journal
- GL posting
- financial posting
- OLTP
generated:
  by: process:claude-haiku/tables
  at: 2026-08-23 10:37:09+00:00
sources:
- resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
  id: DOC-01
  author: Aniruddh Deshpande
  last_modified: 2026-03-08
---


## Purpose

Parent table for all GL journal entries in ORION. Each header row represents a single journal posting event that may debit or credit multiple accounts (detail in GL_JOURNAL_LINE).

## Grain

One row per journal entry posted to the general ledger.

## Key Columns

- **JOURNAL_ID** (NUMBER(12), PK): Unique identifier for the journal entry
- **PERIOD_YYYYMM** (VARCHAR2(6)): Fiscal period in YYYYMM format (e.g. `202603` for March 2026)
- **SOURCE_CD** (VARCHAR2(20)): Source system or module code indicating where the posting originated
- **POSTED_TS** (TIMESTAMP(6)): Timestamp when the journal was posted to the GL

## Keys and Constraints

- Primary Key: JOURNAL_ID
- Standard OLTP audit columns: CREATED_BY, CREATED_DT, LAST_UPD_BY, LAST_UPD_DT
- Delete flag: DELETE_FLAG (CHAR(1)), must always be filtered as `NVL(DELETE_FLAG,'N') = 'N'`
- Activity flag: ACTIVE_FLG (CHAR(1))

## Relationships

- Parent to GL_JOURNAL_LINE via JOURNAL_ID (FK_GLJL_HDR)
- Links to GL_ACCOUNT_MASTER (indirectly via GL_JOURNAL_LINE) using account codes
- Period reference: PERIOD_YYYYMM typically matches PERIOD_CONTROL period status

## Notes

- Each journal header may have one or more detail lines in GL_JOURNAL_LINE
- Journal entries are fundamental to month-end close activities in FIN_PROD
- Source code identifies the origin (e.g., OMS interface, manual entry, accrual posting)
## Referenced by

- [VAR-003 — Scheme discount double-count](/concepts/variances/var-003-scheme-discount-double-count.md)
- [Data Architecture](/context/data-architecture.md)

