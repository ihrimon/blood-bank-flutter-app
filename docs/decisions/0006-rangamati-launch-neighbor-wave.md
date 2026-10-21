# 0006 — Launch in Rangamati; Wave 4 to neighbor districts for rare groups
Status: Accepted (2026-10-13)

**Context:** Rangamati is large, hilly, lake-divided and sparsely populated; Rh-negative donors will be very few. Complex cases are referred to Chattogram.
**Decision:** Only Rangamati is `is_active` (requests originate there). `districts.neighbor_ids` = Chattogram, Khagrachhari, Bandarban; rare-group requests get Wave 4 to registered donors there. Hospital list includes Chattogram referral hospitals. Radii (5/15 km) stay configurable; revisit after beta — possibly switch to upazila-based waves.
**Consequences:** Seed must cover upazilas of 4 districts. Rh-negative KPI target lowered (PRD §৮).
