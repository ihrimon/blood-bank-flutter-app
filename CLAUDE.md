# Blood donor matching app (Bangladesh) — working rules

Android app (Flutter) + Supabase backend that pushes emergency blood requests to nearby, eligible, verified donors, in waves. Launch district: Rangamati. **Budget is zero**: everything must run on free tiers.

## Start of every session
1. `docs/STATUS.md` is injected by a SessionStart hook (current sprint, last done, next task). Don't Read it again; nothing else by default.
2. Read only the current task in `docs/sprints/sprint-N.md`, then only the doc sections that task references (see Doc map).
3. Never read `docs/learning/` or `docs/ai-workflow.md` (the user's own notes) unless the user asks to work on them. A hook asks the user first.
4. Never read `docs/PRD.md` or `docs/MVP.md` in full (a hook blocks Read without `limit`). Grep the heading with `-n` (e.g. `^### ৫.৬`), then Read that range.

## Doc map (docs are in Bangla; headings use Bangla numerals)
| Topic | Where |
|---|---|
| Product decisions D1–D10 (why things are the way they are) | PRD §৫, plus `docs/decisions/` |
| User stories + acceptance criteria (A1…E4) | PRD §৬ |
| NFRs, KPIs | PRD §৭, §৮ |
| Architecture, principles | MVP §২ |
| Project layout, packages | MVP §৩ |
| Schema (enums, tables, app_config) | MVP §৪.১–৪.৩ |
| Blood compatibility, eligibility, matching query, waves | MVP §৫.১–৫.৪ |
| Edge Functions: dispatch / phone verification / gateway | MVP §৫.৫–৫.৬.১ |
| Contact reveal, state machines, RPC list, RLS matrix | MVP §৫.৭–৫.১০ |
| Screens | MVP §৬ |
| Sprint plan (source for sprint files) | MVP §৭ |
| Testing, security checklist, cost | MVP §৯–১১ |

## Commands
- App (run from `app/`): `flutter pub get` · `flutter analyze` · `flutter test` · `dart run build_runner build -d` · `flutter gen-l10n`
- DB (repo root; CLI is linked to **staging**, no local stack — ADR 0008): `supabase migration new <name>` · `supabase db push` (staging, asks first) · `supabase test db --linked` · `supabase migration list`
- Never run `supabase start`, `supabase db reset`, or `supabase functions serve` on this machine. Clean-DB tests run in CI.
- Edge Functions: `deno check index.ts` · `deno test` · deploy to staging with `supabase functions deploy <name>` (asks first)
- Full check: `/verify`

## Non-negotiable rules
- **Zero budget.** Never add a paid service, SDK, or API (no Twilio, paid SMS, Maps billing, Supabase Pro features). If something seems to need one, stop and ask.
- **RLS on every table.** Default deny. Client never writes sensitive tables directly. Business logic lives in RPCs (`security definer`, `set search_path = public`, check `auth.uid()` first) or Edge Functions.
- **Phone numbers and coordinates never reach the client**, except a phone via `get_request_contact` / `get_accepted_donors` after donor consent (PRD D1, D2). Clients see rounded distance only. Never log phone numbers.
- **No donor browsing/search API.** Matching is push-only (D1).
- **Never edit a committed or already-pushed migration.** Create a new one (`/new-migration`). A hook enforces the committed case; check `supabase migration list` for the pushed case.
- **All UI strings via l10n** (`app_bn.arb` primary, `app_en.arb`). No hardcoded user-facing text.
- **Tunable numbers live in `app_config`**, not in code (intervals, radii, caps, limits).
- Prod is touched only by the user. Claude may push only to the linked project (staging role; one shared project until launch, ADR 0009), after asking. Never use `--db-url`, never relink. After launch the old project is prod and off limits.

## Conventions
- Code, comments, identifiers, commit messages: English. Docs and chat with the user: Bangla.
- One task per session. Finish with `/verify`, commit, then `/sprint-done`.
- Commits: `<type>(<scope>): <summary>` with task ID, e.g. `feat(db): add phone_verifications (S1-T3)`.
- New product/technical decision → `/adr`. Don't silently change a decision recorded in PRD §৫ or `docs/decisions/`.
- Keep diffs small and focused on the task. No speculative features beyond the current task.

## Layout
`app/` Flutter app (has its own CLAUDE.md) · `supabase/` migrations, seed, functions, tests (has its own CLAUDE.md) · `docs/` PRD, MVP, STATUS, sprints, decisions · `.claude/` settings, hooks, skills, agents
