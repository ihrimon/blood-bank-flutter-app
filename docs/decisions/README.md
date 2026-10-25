# Architecture / product decision records

One file per decision: `NNNN-short-title.md`, created with `/adr`. Status: Accepted | Superseded by NNNN.
Read only the ADR relevant to your task. Do not reverse an Accepted ADR without a new ADR approved by the user.

| # | Decision | PRD ref |
|---|---|---|
| [0001](0001-stack-flutter-supabase.md) | Flutter (Android first) + Supabase + FCM | — |
| [0002](0002-push-only-matching.md) | Push-only matching in waves; no donor browsing | D1, D3 |
| [0003](0003-consent-based-contact.md) | Phone revealed only after donor accepts | D2 |
| [0004](0004-zero-budget-free-tier.md) | Entire MVP on free tiers | D10 |
| [0005](0005-google-signin-reverse-sms.md) | Google Sign-In + reverse-SMS phone verification | D5 |
| [0006](0006-rangamati-launch-neighbor-wave.md) | Launch in Rangamati; Wave 4 to neighbor districts for rare groups | D9, §৫.১ |
| [0007](0007-config-driven-rules.md) | Tunable rules in `app_config` | D4 |
| [0008](0008-cloud-staging-no-local-supabase.md) | Cloud staging is the dev DB; no local Supabase; pgTAP in CI + `--linked` | — |
| [0009](0009-single-project-until-launch.md) | One Supabase project until launch (acts as staging), then becomes prod; wipe checklist | D10 |
