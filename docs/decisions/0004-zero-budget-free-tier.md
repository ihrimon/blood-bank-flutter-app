# 0004 — Entire MVP on free tiers
Status: Accepted (2026-10-14)

**Context:** No budget until the app earns users' trust.
**Decision:** Supabase Free (2 projects), FCM, Crashlytics, GitHub Actions, GitHub Pages. No paid SMS/OTP. Only unavoidable cost: Play Console one-time $25; until then beta ships as APK.
Mitigations: keep-alive workflow every 2 days (free projects pause after ~7 idle days); weekly encrypted `pg_dump` backup.
**Revisit when:** DB > 400 MB, any quota > 80%, or expanding beyond Rangamati → Supabase Pro + local SMS gateway.
