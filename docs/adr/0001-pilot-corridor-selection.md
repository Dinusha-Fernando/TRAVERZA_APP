# ADR 0001: Pilot Corridor Selection for Initial Coordinated Trips

## Status
Accepted

## Context
TRAVERZA aims to prove multi-vendor trip coordination (stays, intercity chauffeur transit, licensed guides, and curated activities) before scaling across Sri Lanka. Attempting all-island coverage on Day 1 leads to thin provider density, unreliable travel time estimates, and fractured supplier response loops.

## Decision
We select the **Colombo – Sigiriya/Dambulla – Kandy – Nuwara Eliya** corridor as the pilot launch geography:
1. **Connectivity:** Bandaranaike International Airport (CMB) connects naturally into the Cultural Triangle via the Central Expressway/A1/A6 corridors.
2. **Provider Ecosystem:** Dense concentration of SLTDA-registered chauffeur guides, boutique heritage stays, and licensed cultural guides.
3. **Route Reality:** Combines flat expressway transit, rural cultural routes, and mountain highland driving, providing the optimal stress-test for the TripGraph transit buffer calculator.

## Consequences
- Listings outside this corridor will not be marketed for the initial pilot phase.
- Map and routing validation will focus on accurate speeds (e.g. factoring 30–45 km/h highland segments between Kandy and Nuwara Eliya).
- Initial founding provider cohort will be recruited exclusively within this geographic belt.
