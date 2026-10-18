# ADR 0004: SLTDA Tourism-App Guidelines and Sri Lanka PDPA (2027) Compliance

## Status
Accepted

## Context
1. **SLTDA Requirements:** The Sri Lanka Tourism Development Authority publishes guidelines for Tourism-App Operating Companies mandating local incorporation, LKR bank accounts, verified licensed merchants, audit logs, software copyright protection, ISO/IEC 27001 readiness, insurance, and bank guarantee documentation.
2. **Sri Lanka PDPA (Act No. 9 of 2022 / Amendment 2025):** Extraordinary Gazette No. 2498/16 sets **1 January 2027** as the commencement date for personal data processing and controller/processor obligations.

## Decision
1. **Immutable Audit Trail:**
   - Every provider status modification, administrative approval, financial adjustment, and traveler cancellation is recorded in an append-only `audit_events` table with actor ID, IP address, timestamp, prior state, and justification.
2. **Private Document Storage:**
   - Provider compliance documents (SLTDA licences, insurance certificates, vehicle registrations) are stored in an S3-compatible private bucket with zero public access. Downloads use signed, short-lived URLs (max 15 minutes validity).
3. **Privacy by Design & Data Minimization:**
   - No continuous background GPS tracking in mobile apps; location queries are contextual and user-initiated.
   - PII (passports, contact numbers, email addresses) is redacted from general debug logs and prohibited from third-party LLM prompt context.
   - Self-service endpoints for data export (`/api/v1/users/me/export`) and deletion (`/api/v1/users/me/delete`) designed into the core identity module from Day 1.

## Consequences
- Compliance verification is integrated into CI/CD security quality gates.
- Requires strict reviewer logs on all provider approvals.
