# Launch checklist (single-project plan, ADR 0009)

Done by the user, not Claude. Run before real users arrive.

## Wipe dev data
- [ ] Delete all test users (Dashboard → Authentication → Users)
- [ ] Truncate test rows in app tables (requests, responses, donors, verifications, notifications, logs)
- [ ] Keep seed data: districts, upazilas, hospitals, `app_config` (re-check values are production values)
- [ ] Remove test pg_cron jobs; keep keep-alive/wave jobs
- [ ] Storage buckets: delete test files

## Secrets and keys
- [ ] Rotate DB password, service_role key, webhook/gateway secrets
- [ ] Replace test Google OAuth / FCM credentials with release ones
- [ ] Re-check `supabase secrets list`

## Switch roles
- [ ] Create a new free project as staging; `supabase link` to it
- [ ] Apply all migrations + seed there; run `supabase test db --linked`
- [ ] Note the old project ref as PROD in a private place; Claude must not link it
