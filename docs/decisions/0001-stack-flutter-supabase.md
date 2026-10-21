# 0001 — Flutter (Android first) + Supabase + FCM
Status: Accepted (2026-10-13)

**Context:** Solo developer, zero budget, users on low-end Android phones; matching needs geo queries.
**Decision:** Flutter app, Android only for MVP. Supabase (Postgres + PostGIS, Auth, Edge Functions, pg_cron, pg_net) as backend. FCM for push.
**Consequences:** PostGIS makes radius matching a single SQL query. Business logic lives in SQL/RPC, so pgTAP is the main test layer. iOS later from the same codebase.
