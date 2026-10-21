# 0008 — Cloud staging as dev database; no local Supabase stack
Status: Accepted (2026-10-21) · Amends: 0001

**Context:** Developer machine has little free space on C:. Local Supabase (`supabase start`) needs Docker + several GB of images.
**Decision:**
- Install only the Supabase CLI (via Scoop). Never run `supabase start` / `db reset` / `functions serve` on the dev machine.
- The CLI is linked (by the user, once) to the **staging** project. Linked project is always staging, never prod.
- Dev loop: write migration → `supabase db push` (staging) → `supabase test db --linked` (pgTAP; tests run inside a transaction and roll back).
- CI (GitHub Actions) runs the full local stack (`supabase start` + `supabase test db`) on GitHub's runners — that is the authoritative clean-DB test.
- Edge Functions: `deno check`/`deno test` locally; manual testing by `supabase functions deploy` to staging.
- Prod deploys are done only by the user (`supabase db push --db-url <prod>` or a manual workflow), never by Claude.
- A migration already pushed to staging is treated as immutable even if not yet committed; fix forward.
**Consequences:** Needs internet for DB work; slightly slower loop. Staging can't be wiped casually (user-only `db reset --linked`). Docker Desktop is optional on the dev machine.
