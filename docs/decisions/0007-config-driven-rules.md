# 0007 — Tunable rules in `app_config`
Status: Accepted (2026-10-13)

**Context:** Donation interval, radii, caps and limits are uncertain (national guideline check pending, Rangamati terrain) and will change after beta.
**Decision:** All such numbers live in the `app_config` table (MVP §৪.৩) and are read by SQL functions at runtime. Code never hardcodes them.
**Consequences:** Changing a rule = one row update, no release. Tests must set config explicitly rather than rely on defaults.
