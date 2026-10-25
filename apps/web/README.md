# TRAVERZA Web — Master Operations Console (Admin Dashboard)

This web application is the dedicated internal **Admin Operations Dashboard** for **TRAVERZA Sri Lanka**.

The traveler-facing product is delivered via the mobile application (`apps/mobile`), while this web portal serves solely as the administrative command center across all 12 operational domains.

## Operational Domains Managed
1. **Overview**: Executive telemetry, system health, active bookings, gross booking volume (GBV).
2. **Users**: Super Admin, Operator, Guide, and Traveler role management and account verification.
3. **Providers**: Verification, SLTDA licenses, business registration, and credential audits.
4. **Island Atlas**: Destinations, cultural/nature places, GPS coordinates, entrance fees, and visit durations.
5. **Catalogue**: Boutique stays, certified guides, licensed chauffeur transfers, and excursions.
6. **Packages**: Operator curated packages, multi-stop corridor templates, and approval workflows.
7. **Bookings & Escrow**: Truthful partial confirmations, dispute resolution, and state overrides.
8. **Finance & Escrow Ledger**: Double-entry ledger invariant monitoring, 90/10 split releases, and payouts.
9. **Autopilot Disruption Engine**: Real-time corridor disruption monitoring and backup resource dispatching.
10. **Community Moderation**: Travel story moderation, geo-tagged photo review, and safety compliance.
11. **Broadcast Center**: Safety, weather, and corridor alerts dispatched to active travelers.
12. **Audit Vault**: Immutable cryptographic audit logging for compliance (PDPA 2027 & ISO/IEC 27001).

## Getting Started

Run the development server:

```powershell
# In PowerShell:
npm.cmd run dev
# Or after enabling scripts:
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) or [http://localhost:3000/admin](http://localhost:3000/admin) to view the Admin Console.
