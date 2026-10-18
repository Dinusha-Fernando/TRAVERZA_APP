# ADR 0005: TripGraph Deterministic Engine & AI Planner Boundaries

## Status
Accepted

## Context
Generative AI models are capable of synthesizing natural language recommendations, but are prone to hallucinations regarding operational realities (such as driving speeds through winding Sri Lankan mountain roads, seasonal monsoon closures, venue opening windows, and arithmetic totals). Allowing an AI to directly write booking states, reserve dates, or claim inventory introduces severe operational risk.

## Decision
1. **Separation of Concerns:**
   - **AI Planner Role:** Acts exclusively as an ideation and natural language interface. Given user preferences, it returns candidate JSON structures proposing destinations, themes, and pacing.
   - **TripGraph Engine Role:** Authoritative, deterministic backend Python/PostGIS service that evaluates all candidate plans and modifications against hard constraints.
2. **Deterministic Rules Enforced by TripGraph:**
   - Temporal sequence & no-overlap rule on scheduled items.
   - Geographic transit buffers based on verified Sri Lanka road terrain speeds (e.g., Kandy to Ella travel time with buffer).
   - Provider availability windows and verified business operating hours.
   - Strict integer-minor currency arithmetic (no floating point calculations).
3. **Classification of Discrepancies:**
   - **Hard Errors:** Physical impossibilities (e.g. flight arrival at 14:00 with a 13:00 Sigiriya climb) that block quote snapshot creation until resolved.
   - **Warnings:** Weather seasonality notices, advisory traffic delays, or manual availability flags that inform the traveler without blocking planning.
4. **AI Guardrails:**
   - The LLM has zero direct write access to database tables, booking states, or payment handlers.
   - All LLM tool calls are strictly typed and read-only.
   - A non-AI fallback rule engine operates seamlessly if AI services are unreachable.

## Consequences
- Trip feasibility is mathematically guaranteed by the backend before a traveler requests quotes or commits funds.
- System remains operable even during third-party LLM outages.
