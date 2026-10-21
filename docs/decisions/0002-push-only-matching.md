# 0002 — Push-only matching in waves; no donor browsing
Status: Accepted (2026-10-13)

**Context:** Validated problems P3 (brokers/fake donors) and P4 (harassment, esp. female donors). Public donor lists get scraped.
**Decision:** No API lists or searches donors. A request triggers waves (MVP §৫.৪): same group within 5 km → compatible within 15 km → whole district → (rare only) neighbor districts. Weekly per-donor cap and quiet hours, except rare groups / `now` urgency.
**Consequences:** Requesters never see who wasn't interested. Donor supply must be seeded before launch, since nobody can "look around".
