# ADR 0003: Request-to-Confirm Inventory Model and Payment Escrow Guardrails

## Status
Accepted

## Context
Sri Lankan independent boutique accommodations, chauffeur drivers, and certified guides typically do not operate real-time two-way PMS/GDS API synchronizations. Attempting to claim "instant booking" without automated feeds causes immediate double bookings, cancellations, and broken traveler promises. Furthermore, accepting merchant payments requires adherence to SLTDA and Central Bank of Sri Lanka (CBSL) regulations.

## Decision
1. **Request-to-Confirm Primary Inventory Model:**
   - Provider availability is declared manually or on-demand.
   - Quotations are snapshot with an immutable price, terms, and strict `expires_at` timestamp (e.g. 12 to 24 hours).
   - Component status moves: `REQUEST_SUBMITTED -> PROVIDER_ACCEPTED -> CONFIRMED`.
   - An expired quote cannot be accepted or booked without re-quoting.
2. **Payment Escrow & Financial Guardrails:**
   - No live credit card checkout will be enabled until Merchant of Record, legal liability, gateway contract, and bank guarantees are officially settled.
   - Double-entry accounting journal (`LedgerAccount`, `LedgerEntry`) will track all funds. No direct balance editing is permitted anywhere in the system.
   - Webhook processing requires HMAC SHA-256 signature verification and database deduplication using unique `gateway_event_id` keys.

## Consequences
- The traveler UI must clearly depict "Partial Confirmation" states and never mislead users that an itinerary is fully secured while components are pending.
- Automatic cancellation triggers when a provider fails to respond within the deadline.
