# Supabase rules (DB, RLS, Edge Functions)

## Migrations
- One concern per migration. Create with `supabase migration new <snake_name>` or `/new-migration`.
- Committed **or already pushed to staging** migrations are immutable (hook enforces committed; check `supabase migration list` for pushed). Fix forward with a new migration.
- No local stack (ADR 0008): apply with `supabase db push` to the linked staging project (ask the user first). Seed changes: `supabase db push --include-seed`.
- Every new table in the same migration: `enable row level security` + explicit policies (or none = deny all). Match the RLS matrix in MVP §৫.১০.
- Enums, table and column names must match MVP §৪. If you must deviate, record it with `/adr` and update MVP §৪.
- Geography: `geography(Point,4326)` + GiST index. Distances in metres.
- Seed data goes in `seed.sql` (districts, upazilas, hospitals, app_config), never in migrations.

## Functions (RPC)
- Scaffold with `/new-rpc`. Pattern: `security definer`, `set search_path = public`, first statement checks `auth.uid()` and caller status/role, then `revoke all ... from public; grant execute ... to authenticated;`.
- Read tunables from `app_config`; never hardcode intervals, radii, caps.
- Return only what the client needs. Never return phone/location columns except in the contact RPCs (MVP §৫.৭).
- Wave processing must be idempotent and lock rows with `for update skip locked`.

## Tests
- Every migration with logic gets a pgTAP file in `tests/`. Run with `supabase test db --linked` (staging; each file must `begin; … rollback;` so nothing persists). CI runs the same tests on a clean local stack. Cover: happy path, RLS denial for other users, permission checks, edge cases listed in MVP §৯.
- Use helper to impersonate users: `set local role authenticated; set local request.jwt.claims = '{"sub":"<uuid>"}';`

## Edge Functions (Deno, `functions/<name>/index.ts`)
- Verify caller: shared secret header (from pg_net) or webhook secret/signature. Reject otherwise.
- Secrets via `Deno.env` / `supabase secrets set`; never in code.
- Idempotent: only process `pending` rows; record `sent`/`failed` + error.
- Never log phone numbers or message bodies containing them.

## Free tier
- Avoid anything that burns quota: no per-second cron, no polling loops in functions. pg_cron at 1-minute granularity is the floor.
