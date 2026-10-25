# STATUS

**Current:** Sprint 0 — Setup (`docs/sprints/sprint-0.md`)
**Last done:** S0-T4 — Supabase project `RoktoSetu` (Mumbai, single project until launch, ADR 0009) linked; extensions migration pushed; free tier re-checked (df01f4c)
**Next:** S0-T5 — Google Sign-In setup **(U)**
**Blockers / waiting on user:**
- S0-T5: Google account for Google Cloud OAuth
- Gateway phone + separate SIM (needed for S0-T7)
- App name (placeholder `[অ্যাপের নাম]`; package id `bd.placeholder.blooddonor`; "RoktoSetu" is the Supabase project name only; avoid "BloodLink", an existing app)
- `supabase test db --linked` needs Docker (not run here); full pgTAP runs in CI (S0-T8). Smoke test checked via `supabase db query --linked`
- Before launch: follow `docs/launch-checklist.md` (ADR 0009)
- Dev machine: Avast Web Shield breaks Java TLS — Gradle builds need a truststore with the Avast root (see S0-T2 note)
- Dev machine: C: drive ~98% full — emulator needs free space (see S0-T3 note)

<!-- Keep this file under ~20 lines. Updated by /sprint-done. History lives in git and sprint files. -->
