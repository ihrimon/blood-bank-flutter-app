---
name: verify
description: Run the project's checks (flutter analyze, flutter test, supabase test db --linked) and report only failures. Use before marking any task done or committing.
---

Run only the parts affected by the current changes (check `git status --short`; if git isn't initialised, run all available):

| Changed | Run |
|---|---|
| `app/**` | in `app/`: `flutter analyze` then `flutter test` |
| `app/**/*.arb` | also `flutter gen-l10n` first |
| freezed/riverpod annotated files | `dart run build_runner build -d` first |
| `supabase/migrations/**`, `supabase/tests/**`, `seed.sql` | repo root: `supabase migration list` (unpushed local migrations? ask the user before `supabase db push`), then `supabase test db --linked`. No local stack (ADR 0008); CI is the clean-DB check — after pushing to GitHub, report the CI result if available (`gh run list -L 1`) |
| `supabase/functions/**` | `deno test` in that function dir if tests exist; `deno check index.ts` |

Output rules (save tokens):
- Pipe long output through `tail -n 40` or filter to error lines; never paste full logs.
- Report: ✅ per passing step in one line; for failures give file:line + message, max ~10 items.
- If a tool is missing (flutter/supabase/deno not installed), say so and which step was skipped — never report it as passing.
- Do not fix unrelated pre-existing failures; list them separately.
