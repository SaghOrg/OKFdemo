---
type: oltp-table
title: GL_JOURNAL_LINE (FIN_PROD)
description: General ledger journal entry detail lines; one or more debit/credit lines
  per journal header.
resource: FIN_PROD.GL_JOURNAL_LINE
tags:
- general ledger
- journal lines
- GL posting
- debit credit
- GL accounts
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

Detail lines for GL journal entries. Each row represents a single debit or credit posting to a GL account, linked to its parent journal header. Implements the double-entry bookkeeping model where debits and credits are balanced at the header level.

## Grain

One row per account that is debited or credited in a journal entry.

## Key Columns

- **JOURNAL_LINE_ID** (NUMBER(12), PK): Unique identifier for the journal line
- **JOURNAL_ID** (NUMBER(12), NOT NULL, FK): Reference to parent GL_JOURNAL_HDR
- **GL_ACCOUNT_CD** (VARCHAR2(10)): The GL account code being debited or credited, links to GL_ACCOUNT_MASTER
- **DR_AMT** (NUMBER(16,2)): Debit amount in INR, two decimal places (NULL if only credited)
- **CR_AMT** (NUMBER(16,2)): Credit amount in INR, two decimal places (NULL if only debited)

## Keys and Constraints

- Primary Key: JOURNAL_LINE_ID
- Foreign Key: FK_GLJL_HDR on JOURNAL_ID references GL_JOURNAL_HDR.JOURNAL_ID
- Standard OLTP audit columns: CREATED_BY, CREATED_DT, LAST_UPD_BY, LAST_UPD_DT
- Delete flag: DELETE_FLAG (CHAR(1))
- Activity flag: ACTIVE_FLG (CHAR(1))

## Relationships

- Child table to GL_JOURNAL_HDR via JOURNAL_ID
- Links to GL_ACCOUNT_MASTER via GL_ACCOUNT_CD
- Collectively with all lines under a header, maintains double-entry integrity

## Notes

- Either DR_AMT or CR_AMT is populated; normally one is NULL
- Multiple lines per journal header are normal; a journal entry typically affects several accounts
- DR_AMT and CR_AMT must sum to match at the header level to maintain GL integrity
- Always NVL the delete flag: `NVL(DELETE_FLAG,'N') = 'N'`
## Referenced by

- [VAR-003 — Scheme discount double-count](/concepts/variances/var-003-scheme-discount-double-count.md)
- [Data Architecture](/context/data-architecture.md)

