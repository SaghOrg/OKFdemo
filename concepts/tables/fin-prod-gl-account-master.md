---
type: oltp-table
title: GL_ACCOUNT_MASTER (FIN_PROD)
description: Chart of accounts; master data for GL account codes with types and names
  used in journal entries.
resource: FIN_PROD.GL_ACCOUNT_MASTER
tags:
- chart of accounts
- general ledger
- account code
- master data
- GL
- OLTP
generated:
  by: process:claude-haiku/tables
  at: "2026-08-23T10:37:09Z"
sources:
- resource: /_sources/docs/DOC-01_orion_oltp_schema_notes.docx
  id: DOC-01
  author: Aniruddh Deshpande
  last_modified: "2026-03-08"
---


## Purpose

Maintains the chart of accounts for BCPL. Every GL account that can appear in journal entries must be defined here. Finance team members (notably Shalini's team) work with account codes rather than account names.

## Grain

One row per account code in the chart of accounts.

## Key Columns

- **GL_ACCOUNT_CD** (VARCHAR2(10), PK): The account code, e.g. `410100`, `410900`, `411200`
- **GL_ACCOUNT_NM** (VARCHAR2(120)): Human-readable account name
- **ACCOUNT_TYPE** (VARCHAR2(20)): Classification of the account (e.g. Income, Expense, Asset, Liability)

## Keys and Constraints

- Primary Key: GL_ACCOUNT_CD
- Standard OLTP audit columns: CREATED_BY, CREATED_DT, LAST_UPD_BY, LAST_UPD_DT
- Delete flag: DELETE_FLAG (CHAR(1))
- Activity flag: ACTIVE_FLG (CHAR(1))

## Key Account Codes

From DOC-01, the three accounts Shalini's Finance Systems team uses most frequently:

- **410100**: Net Sales Domestic
- **410900**: Scheme discount contra (the offset account for scheme discounts)
- **411200**: Credit note account

## Relationships

- Referenced by GL_JOURNAL_LINE via GL_ACCOUNT_CD
- Referenced by GL_JOURNAL_HDR (indirectly via the line table)

## Notes

- Finance always refers to accounts by code, not by name, within the ORION system
- The account master is the single source of truth for valid GL codes
## Referenced by

- [Data Architecture](/context/data-architecture.md)

