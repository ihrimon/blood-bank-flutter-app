# AI Workflow: blood-bank (কম token, নির্দিষ্ট model)

> এই ফাইল শুধু তোমার জন্য। Claude এটা পড়ে না (hook আগে তোমাকে জিজ্ঞেস করে)।

## ১. রোজকার লুপ
```
/clear → /sprint-next → বানাও → /verify → /sprint-done → "commit koro"
```
- `/clear` দিলেই `STATUS.md` নিজে context-এ আসে (SessionStart hook)। আলাদা করে পড়তে বলতে হবে না।
- এক সেশনে একটাই টাস্ক।
- RLS, contact RPC, matching, dispatch, phone verification বা ADR-এর কাজ হলে আগে `/model opus`, শেষে `/model sonnet`।

## ২. Model routing
| কাজ | Model |
|---|---|
| Flutter স্ক্রিন, l10n, seed, CI, সাধারণ migration | sonnet (ডিফল্ট) |
| RLS, `get_request_contact`, matching query, dispatch Edge Function, phone verification, ADR | opus |
| কোড খোঁজা (অনেক ফাইল) | `Explore` agent |
| ১–২ ফাইলের কাজ | মূল সেশনেই করো, agent নয় |

## ৩. Skills (কমান্ড)
| কমান্ড | কাজ |
|---|---|
| `/sprint-next [SN-Tk]` | টাস্ক ও দরকারি ডক-অংশ লোড, প্ল্যান |
| `/verify` | analyze, test, `supabase test db` (শুধু ব্যর্থতা দেখায়) |
| `/sprint-done` | sprint ফাইল ও STATUS আপডেট, commit প্রস্তাব |
| `/new-migration` `/new-rpc` `/new-feature` | রেসিপি (RLS ও pgTAP সহ) |
| `/adr <title>` | নতুন সিদ্ধান্ত লেখা |

## ৪. Hooks (token খরচ ছাড়া, harness জোর করে চালায়)
| Hook | কাজ |
|---|---|
| SessionStart | `docs/STATUS.md` context-এ দেয় |
| PreToolUse `guard-reads.ps1` | `PRD.md`/`MVP.md` limit ছাড়া Read করলে block করে; `docs/learning/` আর এই ফাইল পড়ার আগে তোমাকে জিজ্ঞেস করে |
| PreToolUse `protect-migrations.ps1` | commit করা migration edit করলে block করে |
| PostToolUse `format-dart.ps1` | `.dart` ফাইলে `dart format` চালায় |

## ৫. Permission
- **জিজ্ঞেস করে না:** flutter/dart/deno কমান্ড, `supabase test/migration`, `git status/diff/log/add`।
- **সবসময় জিজ্ঞেস করবে (ইচ্ছা করে):** `git push`, `gh pr`, `gh repo`, `supabase db push`, `functions deploy`।
- **নিষেধ:** `supabase start/db reset/link`, `--db-url`, force push, `.env` বা key পড়া।

## ৬. Context হালকা রাখো
- অপ্রাসঙ্গিক claude.ai connector (Gmail, Notion, Apollo …) এই প্রজেক্টে বন্ধ রাখো।
- `/context` দিয়ে মাঝে মাঝে দেখো কোন জিনিস কতটা জায়গা নিচ্ছে।
- বড় ফাইল পেস্ট না করে পাথ দাও। টেস্ট আউটপুট লম্বা হলে শুধু শেষটুকু।
- `CLAUDE.md` ৬০ লাইনের নিচে রাখো। নতুন নিয়ম যোগ করার আগে পুরোনো কিছু মুছো বা skill-এ সরাও।

## ৭. Roadmap (বাকি ধাপ)
- [x] **Phase 0:** SessionStart hook, read-guard, এই গাইড
- [ ] **Phase 1 (S0-T9):** টাস্ক-প্রতি branch, PR, CI সবুজ হলে merge, `main` protection, `sprint-N-start/done` tag
- [ ] **Phase 2 (Sprint 1-এর আগে):** `security-reviewer` opus-এ; নতুন agent `qa-reviewer`, `bangla-copy-editor`, `ux-reviewer` (haiku), `tutor` (sonnet); `/review-as`, `/bugfix`; migration hook (RLS ছাড়া table, `search_path` ছাড়া security definer হলে সতর্ক করবে)
- [ ] **Phase 3 (sprint শেষে):** `/sprint-review N`, সব agent parallel, একটাই রিপোর্ট, ফলাফল পরের sprint-এ টাস্ক
- [ ] **Phase 4:** ডোমেইন skill ইংরেজিতে (`blood-matching`, `supabase-security-patterns`), যাতে বাংলা MVP বারবার পড়তে না হয়

## ৮. শেখার ফাঁদ এড়াও
শুধু "বানিয়ে দাও" বললে কোড পাবে, জ্ঞান পাবে না। মাঝে মাঝে বলো: "এই RPC লাইন ধরে ব্যাখ্যা করো", "আমি policy লিখি, তুমি রিভিউ করো", "ভুলটা রেখে দাও, আমি খুঁজি।"
