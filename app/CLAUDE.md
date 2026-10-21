# Flutter app rules

- Target: Android 7.0+ (API 24), low-end phones (2 GB RAM), slow 3G. Keep APK < 30 MB; avoid heavy packages.
- Structure: feature-first `lib/features/<feature>/{data,domain,presentation}`. Shared code in `lib/core/`. Scaffold with `/new-feature`.
- State: Riverpod (code-gen providers). Routing: go_router. Models: freezed + json_serializable.
- Data access: only through repositories in `data/`. Call Supabase RPCs (`supabase.rpc(...)`); never `.from(table).insert/update` on sensitive tables (see root rules).
- Never handle raw phone numbers or coordinates beyond what the RPC returns. Show distance as returned (rounded).
- Strings: add keys to both `lib/l10n/app_bn.arb` and `app_en.arb`, then `flutter gen-l10n`. Bangla is default locale.
- UI: touch targets ≥ 48dp, must not break at large font scale. Request creation ≤ 3 screens.
- Flavors: `staging`, `prod` via `main_staging.dart` / `main_prod.dart` and `--dart-define-from-file`. Secrets never committed.
- Do not read generated files (`*.g.dart`, `*.freezed.dart`); regenerate with `dart run build_runner build -d`.
- Tests: unit tests for notifiers/repositories with `mocktail`; widget tests for forms. Put them under `test/` mirroring `lib/`.
