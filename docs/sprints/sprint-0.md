# Sprint 0 — Setup (week 1)

Source: MVP §৭ "Sprint 0". Goal: an empty but fully wired project — app builds, local Supabase runs, CI is green, nothing paid.
Legend: `[ ]` todo · `[~]` in progress · `[x]` done · **(U)** = needs the user (accounts, devices, consoles); Claude prepares files/instructions only.

### S0-T1 — Git repo + hygiene
- [x] `git init`, default branch `main`; `.gitignore` (Flutter, Dart, Supabase `.branches/.temp`, `.env*`, `*.key`, `*.jks`, `google-services.json`, backups)
- [x] `.gitattributes` (LF for `*.sql`, `*.dart`, `*.ts`, `*.md`)
- [x] `README.md` (short, Bangla, points to docs/)
- Done when: first commit contains docs + `.claude/` + CLAUDE.md files.

### S0-T2 — Flutter project
- [ ] `flutter create --org <org> --project-name <name> --platforms android app` (keep existing `app/CLAUDE.md`)
- [ ] minSdk 24; flavors `staging`/`prod` (Gradle productFlavors + `main_staging.dart`/`main_prod.dart`)
- [ ] Packages from MVP §৩; lint `very_good_analysis`; folder skeleton `lib/{app,core,l10n,features}`
- Done when: `flutter analyze` clean, `flutter build apk --flavor staging -t lib/main_staging.dart` succeeds.

### S0-T3 — l10n, theme, router scaffold
- [ ] `l10n.yaml`, `app_bn.arb` (default) + `app_en.arb`, `flutter gen-l10n`
- [ ] Theme (large touch targets, Bangla-capable font), go_router with placeholder Splash/Home
- Done when: app launches on emulator in Bangla, language toggle works.

### S0-T4 — Supabase CLI + cloud projects **(U)** — no local stack (ADR 0008)
- [x] (U) Supabase CLI installed via Scoop (`supabase --version` → 2.121.0)
- [ ] (U) Create free projects `staging` and `prod`; store refs/keys in local `.env` files (never committed)
- [ ] `supabase init` (creates `supabase/config.toml`; keep existing `supabase/CLAUDE.md`)
- [ ] (U) `supabase login` then `supabase link --project-ref <staging-ref>` — staging only, never prod
- [ ] Extensions migration: `postgis`, `pg_cron`, `pg_net`, `pgtap`; push to staging
- [ ] Re-check free tier limits on the official pricing page; note any change in MVP §১১
- Done when: `supabase migration list` shows the migration applied on staging and `supabase test db --linked` passes one smoke test.

### S0-T5 — Google Sign-In setup **(U)**
- [ ] (U) Google Cloud project, OAuth consent screen, Android client (SHA-1 of debug + release keys) and Web client ID
- [ ] Enable Google provider in Supabase (local `config.toml` + staging)
- [ ] Write step-by-step instructions in `docs/setup/google-oauth.md`
- Done when: a throwaway test button signs in on staging.

### S0-T6 — Firebase (FCM + Crashlytics) **(U)**
- [ ] (U) Firebase projects for staging/prod (Spark plan), add Android apps per flavor
- [ ] `firebase_core`, `firebase_messaging`, `firebase_crashlytics` wired; token printed in debug
- Done when: a test push from the Firebase console reaches the staging app.

### S0-T7 — Gateway phone proof-of-concept **(U for device)**
- [ ] (U) Old Android phone + separate SIM, install SMS Gateway for Android (capcom6)
- [ ] Verify: does it support webhook signing? What does Cloud mode require (terms, privacy)? Record findings → `/adr` if it changes MVP §৫.৬
- [ ] Minimal Edge Function receiving `sms:received` and logging (no phone numbers in logs)
- Done when: an SMS sent to the gateway SIM reaches the local/staging function.

### S0-T8 — Seed data
- [ ] `seed.sql`: all 64 districts (Rangamati `is_active=true`, `neighbor_ids` = Chattogram, Khagrachhari, Bandarban)
- [ ] Upazilas with centroids for those 4 districts (cite the open dataset used in a comment)
- [ ] Hospitals: Rangamati govt + private, upazila health complexes, Chattogram referral hospitals — mark `-- TODO verify locally` where uncertain
- [ ] `app_config` defaults from MVP §৪.৩
- Done when: `supabase db push --include-seed` loads seed into staging without errors, and CI's clean `supabase start` also loads it. (Tables come from S0-T8a.)
- S0-T8a: minimal migration for `districts`, `upazilas`, `hospitals`, `clubs`, `app_config` (+RLS read-only for authenticated) so the seed has somewhere to go.

### S0-T9 — GitHub Actions
- [ ] `ci.yml`: flutter analyze + test; `supabase start` + `supabase test db` on the GitHub runner (this is the only clean-DB test — ADR 0008; Docker runs on GitHub, not locally)
- [ ] `keep-alive.yml`: every 2 days call `health()` RPC on staging and prod (anon key via secrets)
- [ ] `backup.yml`: weekly `pg_dump` → encrypt with `age` (public key in repo, private key only with user) → upload artifact
- [ ] `health()` RPC migration (returns true, anon-executable)
- Done when: CI green on main; keep-alive manual run succeeds.

## Sprint 0 exit criteria
App builds per flavor · local Supabase + tests green · CI green · Google sign-in and FCM proven on staging · gateway PoC result recorded · seed loads.
