---
name: new-rpc
description: Scaffold a secure Postgres RPC (security definer) plus pgTAP tests for permissions and behaviour. Use for any function the Flutter app calls via supabase.rpc.
---

Argument: function name from MVP §৫.৯ (Grep it there and in §৫.৭/§৫.৮ for its contract).

1. Add it in a new migration via `/new-migration add_<fn_name>` (or the migration of the current task if not yet committed).
2. Template:

```sql
create or replace function public.<fn_name>(<args>)
returns <type>
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  -- caller must be active (and have role / verified phone if the story requires it)
  if not exists (select 1 from profiles where id = v_uid and status = 'active') then
    raise exception 'not_allowed' using errcode = '42501';
  end if;

  -- read tunables from app_config, never hardcode
  -- business logic ...
end;
$$;

revoke all on function public.<fn_name>(<arg types>) from public, anon;
grant execute on function public.<fn_name>(<arg types>) to authenticated;
```

3. Rules: return only fields the client needs; never phone/location except contact RPCs (MVP §৫.৭); raise short snake_case error codes the app maps to l10n strings; use `for update skip locked` when claiming rows.
4. pgTAP tests (minimum): anon denied · inactive/suspended user denied · wrong owner denied · happy path result · each acceptance-criterion edge case from the PRD story.
5. Add the Dart side: a repository method in the feature's `data/` calling `supabase.rpc('<fn_name>', params: {...})`, mapping error codes to typed failures.
6. Run `/verify`.
