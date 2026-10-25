# RoktoSetu (Blood Donor) Matching App (Bangladesh)

An Android app that pushes emergency blood requests, in waves, to nearby, eligible, verified donors. Launch district: **Rangamati**. The whole system runs on **free tiers** with no paid services.

> The final app name is not decided yet. The current package id is `bd.placeholder.roktosetu`.

## How it works

1. A patient's relative submits a request with blood group, quantity, hospital and urgency.
2. The system picks **eligible, phone-verified** donors based on blood group compatibility, the minimum gap since the last donation, and distance.
3. The nearest donors get a push notification first. If nobody responds, the next wave widens the radius and notifies more donors.
4. The requester sees a donor's phone number only after that donor consents.

## Core principles

- **Push-only matching:** there is no API or screen for searching or browsing donors.
- **Privacy:** phone numbers and exact locations never reach the client. A phone number is revealed only through a dedicated RPC after donor consent, and clients see rounded distance only.
- **Default deny:** Row Level Security is enabled on every table. Sensitive writes go through `security definer` RPCs or Edge Functions.
- **Config-driven rules:** intervals, radii, caps and limits live in the `app_config` table, not in code.
- **Zero budget:** Supabase free tier, Firebase Spark, and our own Android gateway phone for SMS.

## Tech stack

| Layer | Technology |
|---|---|
| App | Flutter (Android), Riverpod, go_router, l10n (Bangla primary, English) |
| Backend | Supabase: Postgres + PostGIS, Auth (Google), RLS, RPC, Edge Functions (Deno) |
| Push | Firebase Cloud Messaging |
| Phone verification | Reverse SMS via an Android SMS gateway phone |
| Crash reporting | Firebase Crashlytics |

## Repository layout

```
app/        Flutter app (lib/, test/, l10n)
supabase/   migrations, seed, Edge Functions, pgTAP tests
```

## Getting started

Requirements: Flutter SDK, Android Studio (emulator or a real phone), Supabase CLI, Deno.

### App

From `app/`:

```bash
flutter pub get
flutter gen-l10n                          # generate l10n code
dart run build_runner build -d           # generate Riverpod/freezed code
flutter analyze
flutter test
flutter run
```

Google Sign-In needs a Google Cloud OAuth client that includes the SHA-1 of your debug keystore, and a Google account signed in on the device. On an emulator, use a **Google Play** system image.

### Database and Edge Functions

The Supabase CLI is linked to a **staging** project. No local Docker stack is used.

```bash
supabase migration new <name>       # new migration
supabase migration list
supabase db push                    # apply to staging
supabase test db --linked           # pgTAP tests

deno check index.ts                 # inside supabase/functions/<name>/
deno test
supabase functions deploy <name>
```

Committed or already-pushed migrations are never edited. Any change is a new migration.

## Configuration and secrets

`.env` files, `google-services.json`, keystores, service-role keys and similar are never committed (excluded by `.gitignore`). The client holds only the Supabase URL and anon key. The service-role key exists only in the Edge Function environment.

## Status

Sprint 0 (setup) is in progress. Done: Flutter scaffold, l10n and theme, Supabase project link, Google Sign-In. Remaining: Firebase (FCM, Crashlytics), SMS gateway proof of concept, CI.
