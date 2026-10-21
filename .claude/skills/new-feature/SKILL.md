---
name: new-feature
description: Scaffold a Flutter feature folder (data/domain/presentation) with Riverpod provider, repository, route and l10n keys. Use when starting a new screen or feature in app/.
---

Argument: feature name (snake_case) and screen(s), e.g. `donor_inbox incoming_request`.

Create under `app/lib/features/<feature>/`:

```
data/<feature>_repository.dart        # only place that talks to Supabase (rpc calls)
domain/<model>.dart                   # freezed models + failure types
presentation/<screen>_screen.dart     # widgets only, no Supabase imports
presentation/<screen>_controller.dart # @riverpod notifier / AsyncNotifier
```

Rules:
- Repository is exposed via a `@riverpod` provider; controllers depend on it; screens watch controllers.
- Screens use `AppLocalizations.of(context)`; add every new key to both `app_bn.arb` (Bangla, primary) and `app_en.arb`, then `flutter gen-l10n`.
- Register the route in `lib/app/router.dart` (go_router); deep-link paths must match MVP §৬ (e.g. `/incoming/:requestId`).
- Add `test/features/<feature>/` with a controller unit test (mocktail repository) and one widget test for the main form/state.
- Run `dart run build_runner build -d`, then `/verify`.
