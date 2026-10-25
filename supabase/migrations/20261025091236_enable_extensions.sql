-- Extensions needed by the matching engine (MVP §৪, §৫). pg_cron and pg_net
-- are managed by Supabase and live in their own schemas.
create extension if not exists postgis with schema extensions;
create extension if not exists pg_cron with schema pg_catalog;
create extension if not exists pg_net with schema extensions;
create extension if not exists pgtap with schema extensions;
