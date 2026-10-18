# ADR 0002: Authentication, Session Management, and Tenant Isolation

## Status
Accepted

## Context
TRAVERZA operates multiple surfaces: public travellers (mobile & web), multi-staff provider businesses (stays, transport operators, excursion hosts), and internal operations/finance/compliance staff. A cross-tenant data leak (e.g. Provider A accessing Provider B's bookings, payout history, or passport uploads) represents a fatal trust and regulatory violation.

## Decision
1. **Password Hashing:** Argon2id with OWASP recommended memory, iteration, and parallelism parameters.
2. **Session Model:**
   - **Web (Next.js):** HttpOnly, Secure, SameSite=Lax cookies containing short-lived JWT access tokens and rotating refresh tokens in Redis. No JWT in browser `localStorage`.
   - **Mobile (Flutter):** Tokens stored in platform secure hardware (Keychain on iOS, EncryptedSharedPreferences on Android).
3. **Staff Privileged Security:**
   - Mandatory TOTP MFA (RFC 6238) for all Admin and Support roles.
   - Distinct permission-based RBAC (Super Admin, Provider Verification, Trip Ops, Finance, Support, Auditor) instead of a binary `is_admin` boolean flag.
4. **Tenant Isolation Architecture:**
   - Every provider resource belongs strictly to an `organization_id`.
   - Backend API dependencies verify the authenticated user's active `OrganizationMembership` and role permissions prior to executing any service layer operation.
   - Automated tests in CI explicitly test for IDOR (Insecure Direct Object Reference) across tenant IDs.

## Consequences
- Requires an organization-membership resolver on every provider-scoped route.
- Provider staff can belong to multiple organizations or switch roles without account duplication.
