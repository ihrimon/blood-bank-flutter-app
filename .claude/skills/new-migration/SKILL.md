---
name: new-migration
description: Create a new Supabase SQL migration with RLS and a matching pgTAP test file. Use whenever adding or changing tables, enums, indexes, policies, triggers or SQL functions.
---

Argument: snake_case name, e.g. `add_phone_verifications`.

1. Run `supabase migration new <name>` (repo root). Never edit an existing committed migration — fix forward.
2. Fill the file using this skeleton; keep one concern per migration and names exactly as in MVP §৪ (Grep the table name there for its definition):

```sql
-- <TASK-ID>: <one-line purpose>
-- Ref: MVP §<section>

create table if not exists public.<table> ( ... );
create index if not exists <table>_<col>_idx on public.<table> (...);

alter table public.<table> enable row level security;
-- Policies per MVP §৫.১০. No policy = deny all (preferred for sensitive tables).
create policy "<table>_select_own" on public.<table>
  for select to authenticated using (<owner_col> = auth.uid());

-- No direct client writes on sensitive tables; mutations go through RPCs.
revoke insert, update, delete on public.<table> from anon, authenticated;
```

3. Create `supabase/tests/<same-timestamp>_<name>.test.sql`:

```sql
begin;
select plan(<n>);
-- structure
select has_table('public', '<table>', '<table> exists');
select ok((select relrowsecurity from pg_class where oid = 'public.<table>'::regclass), 'RLS enabled');
-- RLS: user A cannot see user B's rows
-- set local role authenticated; set local request.jwt.claims = '{"sub":"<uuid-a>"}';
-- select is_empty($$ select * from public.<table> where <owner_col> = '<uuid-b>' $$, 'cannot read others');
select * from finish();
rollback;
```

4. Ask the user, then `supabase db push` (linked staging), then `supabase test db --linked`. Fix until green. Never `supabase start`/`db reset` (ADR 0008). Once pushed, the migration is immutable — fix forward with another migration.
5. If you deviated from MVP §৪, update that section and mention it to the user.
