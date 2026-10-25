# 0009 — One Supabase project until launch; it becomes prod
Status: Accepted (2026-10-25) · Amends: 0008

**Context:** Maintaining separate staging and prod projects doubles setup work before there is any real data. The user prefers one project now and a cleanup at launch.
**Decision:**
- Create a single free Supabase project (`RoktoSetu`, Singapore). Until launch it plays the role of "staging": the CLI is linked to it and Claude may push to it after asking (ADR 0008 rules unchanged).
- No `prod` project and no `.env.prod` now. Only `.env.staging` is used.
- Before launch the user runs the wipe checklist in `docs/launch-checklist.md`: delete test auth users and rows, remove test cron jobs, rotate secrets/keys; keep schema, migrations and seed data (districts, upazilas, hospitals, `app_config`).
- At launch the user creates a second free project as the new staging and relinks the CLI to it. From then on the original project is prod: Claude never pushes or links to it.
**Consequences:** Simpler setup now. Dev data must be wiped by hand; a missed item (test users, secrets) could leak into real use. A second project is still needed after launch, so the free-tier limit of 2 projects applies then.
