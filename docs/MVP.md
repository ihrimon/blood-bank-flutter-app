# MVP টেকনিক্যাল স্পেসিফিকেশন: [অ্যাপের নাম]

| | |
|---|---|
| **ভিত্তি** | [PRD.md](PRD.md) v1.0 |
| **Stack** | Flutter (Android), Supabase (Postgres + PostGIS, Auth, Edge Functions, pg_cron), Firebase Cloud Messaging, নিজস্ব Android ফোনে SMS গেটওয়ে ([capcom6/android-sms-gateway](https://github.com/capcom6/android-sms-gateway)), GitHub Actions |
| **বাজেট** | **শূন্য।** সব সার্ভিস free tier-এ চলবে। একমাত্র অনিবার্য খরচ Play Console-এর একবারের $২৫ (১১ নম্বর অংশ দেখুন) |
| **টিম** | ১ জন (full-stack) |
| **আনুমানিক সময়** | ১১ সপ্তাহ (setup ১ + ৪টা স্প্রিন্ট × ২ + বেটা ২) |

এই ডকুমেন্টে লেখা আছে PRD-র P0 ফিচারগুলো **কীভাবে** বানানো হবে। স্কোপ বাড়াতে হলে আগে PRD আপডেট করতে হবে।

---

## ১. MVP স্কোপ: এক নজরে

| থাকবে (P0) | থাকবে না |
|---|---|
| Google Sign-In, উল্টো SMS দিয়ে ফোন নম্বর যাচাই, প্রোফাইল, ডোনার প্রোফাইল | iOS, ওয়েব অ্যাপ |
| উপযুক্ততার স্বয়ংক্রিয় হিসাব (১২০ দিন), সাময়িক বিরতি | ম্যাপে পিন বসানো (GPS বা এলাকা বাছাই দিয়েই যথেষ্ট) |
| রিকোয়েস্ট তৈরি, অবস্থা দেখা, বন্ধ করা, নিজে থেকে expire | প্লেটলেট বা প্লাজমা, থ্যালাসেমিয়ার নিয়মিত ডোনার গ্রুপ |
| ৩ ধাপের ম্যাচিং (দূরত্ব আর গ্রুপের compatibility দিয়ে), বিরল গ্রুপে পাশের জেলায় Wave 4 | অ্যাপের ভেতরে চ্যাট বা কল |
| Push (FCM), নোটিফিকেশনের সীমা আর রাতের নিয়ম, বিরল গ্রুপে গেটওয়ে ফোন থেকে SMS (ঐচ্ছিক, ডিফল্টে বন্ধ) | ব্যাজ, লিডারবোর্ড, ক্লাবের ড্যাশবোর্ড |
| GitHub Actions দিয়ে keep-alive আর encrypted backup | যেকোনো paid সার্ভিস (OTP SMS, bulk SMS, Supabase Pro) |
| সম্মতি দিলে নম্বর দেখানো | হাসপাতালের মজুদ |
| রক্তদান নিশ্চিত করা, ইতিহাস, বিশ্বাসযোগ্যতার স্কোর | একাধিক জেলা চালু (schema প্রস্তুত থাকবে) |
| রিপোর্ট, ব্লক, auto-suspend, মডারেটর স্ক্রিন, audit log | |
| বাংলা ও ইংরেজি, Crashlytics, KPI views | |

---

## ২. সিস্টেম আর্কিটেকচার

```
┌────────────────────────┐   HTTPS (supabase_flutter)    ┌───────────────────────────────────┐
│  Flutter Android App   │ ────────────────────────────► │ Supabase (Free)                   │
│  Google Sign-In        │                               │  Auth (Google OAuth)              │
│  FCM receiver          │ ◄── push ── FCM ◄─────────┐   │  Postgres + PostGIS               │
└──────────┬─────────────┘                           │   │   ├─ tables + RLS                 │
           │ ব্যবহারকারী নিজে SMS পাঠান               │   │   ├─ RPC (security definer)       │
           │ "RB 4821" (নম্বর যাচাই)                  │   │   └─ pg_cron (প্রতি মিনিটে)        │
           ▼                                         │   │        └─ process_due_waves()     │
┌────────────────────────┐  webhook (sms:received)   │   │             └─ pg_net ──┐         │
│  গেটওয়ে Android ফোন    │ ────────────────────────► │   │  Edge Functions         │         │
│  (SIM + SMS Gateway    │       Edge Fn: sms-verify-webhook                       ▼         │
│   for Android অ্যাপ)    │ ◄─ (ঐচ্ছিক) বিরল alert ── │──── Edge Fn: dispatch-notifications   │
└────────────────────────┘     SMS পাঠানো            └───┴───────────────────────────────────┘
                                                                 ▲
                         GitHub Actions (Free) ──────────────────┘
                           ├─ keep-alive ping (প্রতি ২ দিনে)
                           └─ সাপ্তাহিক pg_dump → encrypted backup
```

**মূল নীতি:**
1. **Client "বোকা" থাকবে।** ম্যাচিং, নম্বর দেখানো, স্ট্যাটাস বদলানোর মতো সব ব্যবসায়িক নিয়ম চলবে Postgres function (RPC) বা Edge Function-এ। Client সরাসরি sensitive table-এ লিখতে পারবে না।
2. **RLS সবখানে চালু।** ডিফল্টে কিছুই অনুমোদিত না। শুধু দরকারি পলিসি খোলা হবে।
3. **ফোন নম্বর** থাকবে শুধু `user_phones` আর `request_contacts`-এ। এই দুই table-এ client-এর কোনো select policy নেই। Client নম্বর পাবে শুধু `get_*_contact` RPC দিয়ে, আর শুধু শর্ত পূরণ হলে।
4. **লোকেশন** `geography(Point, 4326)` হিসেবে server-এ থাকবে। Client-এর কাছে কখনো coordinate যাবে না, যাবে শুধু গোল করা দূরত্ব।
5. **কোনো paid সার্ভিসের উপর নির্ভরতা থাকবে না।** গেটওয়ে ফোন বন্ধ থাকলেও অ্যাপের মূল কাজ (রিকোয়েস্ট, push, সাড়া দেওয়া) চলবে। শুধু নতুন নম্বর যাচাই আর ঐচ্ছিক SMS alert সাময়িক বন্ধ থাকবে।

---

## ৩. Flutter প্রজেক্টের কাঠামো

```
app/
├── lib/
│   ├── main_staging.dart / main_prod.dart      # flavor entrypoints
│   ├── app/                                    # router, theme, l10n setup
│   ├── core/                                   # supabase client, errors, utils, constants
│   ├── l10n/                                   # app_bn.arb, app_en.arb
│   └── features/
│       ├── auth/            # google sign-in, phone verification (reverse SMS)
│       ├── profile/         # profile setup, donor settings, pause, delete account
│       ├── requests/        # create, my requests, request detail (requester view)
│       ├── donor_inbox/     # incoming request detail (donor view), accept/decline
│       ├── donations/       # confirm, history
│       ├── safety/          # report, block
│       ├── moderation/      # moderator screens
│       └── notifications/   # FCM token sync, deep link handling
│           └── (প্রতিটা feature-এ: data/ domain/ presentation/)
└── test/
supabase/
├── migrations/              # *.sql — schema, RLS, functions
├── seed.sql                 # districts, upazilas, hospitals, app_config
├── functions/
│   ├── dispatch-notifications/
│   └── sms-verify-webhook/
└── tests/                   # pgTAP tests
.github/workflows/
├── ci.yml                   # analyze, test, supabase test db
├── keep-alive.yml           # প্রতি ২ দিনে health RPC কল (free project pause ঠেকাতে)
└── backup.yml               # সাপ্তাহিক pg_dump → age/gpg দিয়ে encrypt → private artifact
```

**প্যাকেজ:** `supabase_flutter`, `flutter_riverpod`, `go_router`, `freezed` + `json_serializable`, `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `firebase_crashlytics`, `google_sign_in`, `geolocator`, `url_launcher` (কল করা আর SMS লেখার স্ক্রিন খোলার জন্য), `intl` / `flutter_localizations`।

**Environment:** দুটো Supabase project (`staging`, `prod`) আর দুটো Firebase project। Flutter flavor দিয়ে আলাদা করা হবে। Secret থাকবে `--dart-define-from-file`-এ, git-এ commit হবে না।

---

## ৪. ডেটা মডেল

### ৪.১ Enum

```sql
create type blood_group     as enum ('A+','A-','B+','B-','AB+','AB-','O+','O-');
create type user_role       as enum ('user','moderator','super_admin');
create type user_status     as enum ('active','suspended','banned');
create type request_urgency as enum ('now','today','scheduled');
create type request_reason  as enum ('surgery','delivery','accident','thalassemia','dengue','other');
create type request_status  as enum ('open','fulfilled','closed','expired','removed');
create type response_status as enum ('accepted','declined','withdrawn');
create type notif_channel   as enum ('push','sms');
create type notif_status    as enum ('pending','sent','failed','skipped');
create type donation_status as enum ('pending','confirmed','disputed','no_show');
create type report_reason   as enum ('asked_money','fake_request','harassment','no_show','other');
create type report_status   as enum ('open','dismissed','actioned');
```

### ৪.২ Table

```sql
-- ভৌগোলিক তথ্য (seed করা হবে)
create table districts (
  id smallint primary key, name_bn text not null, name_en text not null,
  is_active boolean not null default false,         -- MVP: শুধু রাঙ্গামাটি true (রিকোয়েস্ট শুধু এখান থেকে)
  neighbor_ids smallint[] not null default '{}'     -- Wave 4 fallback; রাঙ্গামাটি = {চট্টগ্রাম, খাগড়াছড়ি, বান্দরবান}
);
create table upazilas (
  id int primary key, district_id smallint not null references districts,
  name_bn text not null, name_en text not null,
  centroid geography(Point,4326) not null           -- GPS না দিলে এটাই লোকেশন
);
create table hospitals (
  id uuid primary key default gen_random_uuid(),
  district_id smallint not null references districts,
  name_bn text not null, name_en text,
  location geography(Point,4326) not null,
  is_active boolean not null default true
);
create table clubs (
  id uuid primary key default gen_random_uuid(),
  name text not null, district_id smallint not null references districts
);

-- ব্যবহারকারী
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  full_name text not null,
  blood_group blood_group,                          -- null = "জানি না"
  gender text check (gender in ('male','female','other')),
  birth_year smallint,
  district_id smallint not null references districts,
  upazila_id int not null references upazilas,
  role user_role not null default 'user',
  status user_status not null default 'active',
  locale text not null default 'bn',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table club_moderators (
  club_id uuid references clubs, user_id uuid references profiles,
  primary key (club_id, user_id)
);
create table donor_profiles (
  user_id uuid primary key references profiles on delete cascade,
  is_active boolean not null default true,           -- ডোনার মোড চালু/বন্ধ
  location geography(Point,4326) not null,
  last_donated_at date,
  paused_until timestamptz,                          -- null = বিরতিতে নেই; 'infinity' = নিজে চালু না করা পর্যন্ত
  eligibility_confirmed_at timestamptz not null,     -- বয়স/ওজনের self-declaration
  verified_club_id uuid references clubs,
  verified_by uuid references profiles,
  verified_at timestamptz,
  reliability_score real not null default 0.5,
  updated_at timestamptz not null default now()
);
create index donor_profiles_location_gix on donor_profiles using gist (location);

-- ফোন নম্বর (Google লগইনে নম্বর থাকে না, তাই আলাদা table; client select policy নেই)
create table user_phones (
  user_id uuid primary key references profiles on delete cascade,
  phone text not null unique,                       -- E.164: +8801XXXXXXXXX
  verified_at timestamptz,                          -- null = যাচাই হয়নি
  verified_method text check (verified_method in ('reverse_sms','moderator'))
);
create table phone_verifications (                  -- উল্টো SMS-এর চলমান চেষ্টা
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles on delete cascade,
  phone text not null,
  code text not null,                               -- যেমন '4821' (SMS body: 'RB 4821')
  expires_at timestamptz not null,                  -- তৈরির ১৫ মিনিট পর
  consumed_at timestamptz,
  created_at timestamptz not null default now()
);
create index phone_verifications_lookup_idx on phone_verifications (phone, code) where consumed_at is null;

create table device_tokens (
  user_id uuid references profiles on delete cascade,
  fcm_token text not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, fcm_token)
);

-- রিকোয়েস্ট
create table blood_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references profiles,
  patient_blood_group blood_group not null,
  bags_needed smallint not null check (bags_needed between 1 and 5),
  hospital_id uuid references hospitals,
  hospital_name_other text,
  district_id smallint not null references districts,
  location geography(Point,4326) not null,          -- হাসপাতাল থেকে কপি
  urgency request_urgency not null,
  needed_by timestamptz not null,
  reason request_reason,
  note text check (char_length(note) <= 200),
  status request_status not null default 'open',
  current_wave smallint not null default 0,
  next_wave_at timestamptz,                         -- null = আর কোনো wave বাকি নেই
  created_at timestamptz not null default now(),
  closed_at timestamptz,
  check (hospital_id is not null or hospital_name_other is not null)
);
create index blood_requests_due_idx on blood_requests (next_wave_at) where status = 'open';

create table request_contacts (                     -- কোনো client select policy নেই
  request_id uuid primary key references blood_requests on delete cascade,
  phone text not null
);

create table request_notifications (
  id bigint generated always as identity primary key,
  request_id uuid not null references blood_requests on delete cascade,
  donor_id uuid not null references profiles,
  wave smallint not null,
  channel notif_channel not null,
  status notif_status not null default 'pending',
  error text,
  created_at timestamptz not null default now(),
  sent_at timestamptz,
  unique (request_id, donor_id, channel)
);
create index request_notifications_donor_recent_idx on request_notifications (donor_id, created_at);

create table request_responses (
  request_id uuid references blood_requests on delete cascade,
  donor_id uuid references profiles,
  status response_status not null,
  responded_at timestamptz not null default now(),
  primary key (request_id, donor_id)
);

-- রক্তদান
create table donations (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references blood_requests,
  donor_id uuid not null references profiles,
  donated_on date not null default current_date,
  requester_confirmed boolean,                      -- null = এখনো চিহ্ন দেননি
  donor_confirmed boolean,
  status donation_status not null default 'pending',
  created_at timestamptz not null default now(),
  unique (request_id, donor_id)
);

-- নিরাপত্তা
create table reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references profiles,
  reported_user_id uuid not null references profiles,
  request_id uuid references blood_requests,
  reason report_reason not null,
  details text check (char_length(details) <= 500),
  status report_status not null default 'open',
  handled_by uuid references profiles,
  handled_at timestamptz,
  created_at timestamptz not null default now(),
  unique (reporter_id, reported_user_id, request_id)
);
create table blocks (
  blocker_id uuid references profiles, blocked_id uuid references profiles,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id)
);
create table moderation_audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid not null references profiles,
  action text not null,                             -- 'verify','unverify','suspend','ban','dismiss_report',...
  target_user_id uuid, target_request_id uuid, details jsonb,
  created_at timestamptz not null default now()
);

-- কনফিগারেশন (কোড না বদলেই নিয়ম পাল্টানো যাবে)
create table app_config (key text primary key, value jsonb not null);
```

### ৪.৩ `app_config`-এর ডিফল্ট মান

| key | value | ব্যবহার |
|---|---|---|
| `donation_interval_days` | `120` | উপযুক্ততার হিসাব |
| `waves` | `[{"radius_m":5000,"delay_min":0,"compatible":false,"limit":20},{"radius_m":15000,"delay_min":10,"compatible":true,"limit":40},{"radius_m":null,"delay_min":20,"compatible":true,"limit":80},{"scope":"neighbors","delay_min":30,"compatible":true,"limit":80,"rare_only":true}]` | ম্যাচিংয়ের ধাপ (`radius_m: null` = পুরো জেলা, `scope: neighbors` = পাশের জেলা)। রাঙ্গামাটির পাহাড়ি দূরত্বের কারণে বেটার ডেটা দেখে ব্যাসার্ধ ঠিক করতে হবে |
| `donor_weekly_notif_cap` | `3` | C2 |
| `quiet_hours` | `{"start":"23:00","end":"07:00","tz":"Asia/Dhaka"}` | C2 |
| `rare_groups` | `["O-","A-","B-","AB-"]` | C3, সীমা প্রযোজ্য না |
| `gateway_sms_alerts_enabled` | `false` | বিরল গ্রুপের SMS alert চালু বা বন্ধ (গেটওয়ে SIM-এ বান্ডেল থাকলে তবেই `true`) |
| `gateway_sms_daily_cap` | `50` | গেটওয়ে ফোন থেকে দিনে সর্বোচ্চ SMS। অপারেটর যেন spam ভেবে SIM ব্লক না করে |
| `gateway_number` | `"+8801XXXXXXXXX"` | যে নম্বরে ব্যবহারকারী যাচাইয়ের SMS পাঠাবেন। অ্যাপ এখান থেকে পড়বে |
| `phone_verification_daily_limit` | `5` | একজন ব্যবহারকারী দিনে কতবার যাচাইয়ের কোড চাইতে পারবেন |
| `max_open_requests` / `max_requests_24h` | `2` / `3` | B1 |
| `auto_suspend_report_threshold` | `3` | E1 |
| `request_expiry_hours_after_needed_by` | `6` | B3 |

---

## ৫. ব্যবসায়িক লজিক

### ৫.১ রক্তের গ্রুপ compatibility (red cell / whole blood)

| রোগীর গ্রুপ | Wave 1 (একই গ্রুপ) | Wave 2+ (compatible ডোনার) |
|---|---|---|
| O− | O− | O− |
| O+ | O+ | O+, O− |
| A− | A− | A−, O− |
| A+ | A+ | A+, A−, O+, O− |
| B− | B− | B−, O− |
| B+ | B+ | B+, B−, O+, O− |
| AB− | AB− | AB−, A−, B−, O− |
| AB+ | AB+ | সব গ্রুপ |

```sql
create function compatible_donor_groups(recipient blood_group, include_compatible boolean)
returns blood_group[] language sql immutable as $$ ... $$;
```

> হাসপাতাল সাধারণত একই গ্রুপ পছন্দ করে, তাই Wave 1-এ শুধু একই গ্রুপ যাবে। চূড়ান্ত crossmatch সবসময় হাসপাতালে হবে (PRD D7)।

### ৫.২ ডোনার উপযুক্ত কিনা (single source of truth)

```sql
create function is_donor_eligible(d donor_profiles, p profiles) returns boolean language sql stable as $$
  select d.is_active
     and p.status = 'active'
     and (d.paused_until is null or d.paused_until < now())
     and (d.last_donated_at is null
          or d.last_donated_at <= current_date - (select (value)::int from app_config where key='donation_interval_days'))
     and (p.birth_year is null or extract(year from now()) - p.birth_year between 18 and 60)
$$;
```

UI-তে "পরের বার কবে দিতে পারবেন" দেখানোর জন্যও এই একই নিয়ম ব্যবহার হবে (`get_my_donor_status()` RPC দিয়ে)।

### ৫.৩ ম্যাচিং query (একটা wave-এর জন্য)

```sql
-- candidates for request r, wave w
select d.user_id, st_distance(d.location, r.location) as distance_m
from donor_profiles d
join profiles p on p.id = d.user_id
where is_donor_eligible(d, p)
  and p.blood_group = any(compatible_donor_groups(r.patient_blood_group, w.compatible))
  and case when w.scope = 'neighbors'                                            -- Wave 4 (শুধু বিরল গ্রুপে)
           then p.district_id = any((select neighbor_ids from districts where id = r.district_id))
           else p.district_id = r.district_id
               and (w.radius_m is null or st_dwithin(d.location, r.location, w.radius_m))
      end
  and d.user_id <> r.requester_id
  and not exists (select 1 from request_notifications n
                  where n.request_id = r.id and n.donor_id = d.user_id)          -- আগে জানানো হয়নি
  and not exists (select 1 from blocks b
                  where (b.blocker_id = d.user_id and b.blocked_id = r.requester_id)
                     or (b.blocker_id = r.requester_id and b.blocked_id = d.user_id))
  and (r.patient_blood_group = any(rare_groups)                                   -- বিরল হলে সীমা নেই
       or (select count(*) from request_notifications n
           where n.donor_id = d.user_id and n.channel = 'push'
             and n.created_at > now() - interval '7 days') < weekly_cap)
  and (r.urgency = 'now' or not in_quiet_hours(now()))
order by (d.verified_at is not null) desc, d.reliability_score desc, distance_m asc
limit w.limit;
```

### ৫.৪ Wave চালানোর প্রক্রিয়া

1. **`create_blood_request(...)` RPC:**
   - rate limit আর `profiles.status` যাচাই করবে
   - হাসপাতাল থেকে `location` আর `district_id` নেবে
   - `blood_requests` (current_wave=0, next_wave_at=now()) আর `request_contacts`-এ insert করবে
   - তারপর সঙ্গে সঙ্গে `process_request_wave(id)` চালাবে, যাতে Wave 1 কোনো দেরি ছাড়া যায়
2. **`process_request_wave(request_id)`** (`for update skip locked` দিয়ে row lock করে):
   - যদি `status <> 'open'` হয়, অথবা রাজি হওয়া ডোনারের সংখ্যা `bags_needed`-এর সমান বা বেশি হয়, তাহলে `next_wave_at = null` করে থেমে যাবে
   - পরের wave নির্ধারণ করে candidate query চালাবে, আর `request_notifications`-এ প্রতি candidate-এর জন্য `push` row insert করবে (বিরল গ্রুপ হলে, `gateway_sms_alerts_enabled = true` হলে আর আজকের `gateway_sms_daily_cap` পূরণ না হলে সাথে `sms` row-ও)
   - `current_wave++` করবে। আরো wave থাকলে `next_wave_at = created_at + delay_min`, না থাকলে `null`
   - তারপর `net.http_post` দিয়ে Edge Function `dispatch-notifications` ডাকবে, body: `{request_id, wave}`
3. **pg_cron, প্রতি মিনিটে:**
   - `process_due_waves()` চালাবে, অর্থাৎ যেসব রিকোয়েস্টের `status='open' and next_wave_at <= now()`, প্রতিটার জন্য `process_request_wave`
   - `expire_requests()`: `needed_by + 6h < now()` হলে `status='expired'`
   - যেসব `request_notifications` ৫ মিনিটের বেশি `pending` আছে সেগুলো আবার dispatch করবে (retry)
4. **রোজ একবার pg_cron:**
   - `finalize_donations()`: ৪৮ ঘণ্টা পার হওয়া এক-পক্ষের নিশ্চিতকরণকে `confirmed` করবে
   - `send_eligibility_reminders()`: যাদের ১২০ দিন পূর্ণ হয়েছে তাদের রিমাইন্ডার (P1)

### ৫.৫ Edge Function: `dispatch-notifications`

- Input `{request_id, wave}`। Auth: service role key, অথবা শুধু pg_net থেকে আসা shared secret header গ্রহণ করবে।
- সেই রিকোয়েস্টের `pending` row গুলো পড়বে, আর প্রতিটা `push` row-এর জন্য ডোনারের `device_tokens` থেকে **FCM HTTP v1**-এ data + notification message পাঠাবে।
  - payload: `{type:"blood_request", request_id}`। গ্রুপ আর হাসপাতালের নাম থাকবে notification-এর লেখায়, ফোন নম্বর কখনো না।
  - Android channel: `urgent_requests`, high priority।
- `sms` row (ঐচ্ছিক): গেটওয়ে ফোনের SMS Gateway অ্যাপের API-তে পাঠাবে। লেখা বাংলায় (Unicode), যেমন: `জরুরি O− রক্ত দরকার, [হাসপাতাল], [এলাকা]। সাড়া দিন: <app link>`। গেটওয়ে ফোনে পৌঁছানো না গেলে `failed` হবে, কিন্তু push আর wave স্বাভাবিকভাবে চলবে।
- সফল হলে `sent`, ব্যর্থ হলে `failed` আর `error` লিখে রাখবে। FCM থেকে `UNREGISTERED` এলে সেই token মুছে ফেলবে।
- Idempotent হবে: শুধু `pending` row-ই পাঠাবে, তাই দুবার চললেও এক নোটিফিকেশন দুবার যাবে না।

### ৫.৬ লগইন আর ফোন নম্বর যাচাই (শূন্য খরচে)

**লগইন:** Supabase Auth-এর Google provider (`signInWithIdToken`, Android-এ `google_sign_in` থেকে পাওয়া ID token দিয়ে)। কোনো SMS লাগে না। Google Cloud-এ OAuth client বানানো ফ্রি।

**ফোন নম্বর যাচাই, উল্টো SMS দিয়ে:** ব্যবহারকারী নিজে আমাদের গেটওয়ে নম্বরে SMS পাঠাবেন। SMS গ্রহণে আমাদের কোনো খরচ নেই।

1. App ডাকবে `start_phone_verification(phone)`:
   - নম্বর normalize করবে (`01XXXXXXXXX` থেকে `+8801XXXXXXXXX`), দৈনিক সীমা যাচাই করবে
   - নম্বরটা অন্য কোনো যাচাই করা অ্যাকাউন্টে থাকলে প্রত্যাখ্যান করবে
   - ৪ সংখ্যার একটা কোড তৈরি করে `phone_verifications`-এ রাখবে, মেয়াদ ১৫ মিনিট
   - ফেরত দেবে `{gateway_number, sms_body: "RB 4821"}`
2. App `url_launcher` দিয়ে `sms:<gateway_number>?body=RB%204821` খুলবে। ব্যবহারকারীর ফোনের SMS অ্যাপে লেখাটা তৈরি থাকবে, উনি শুধু Send চাপবেন। স্ক্রিনে লেখা থাকবে: "আপনার সাধারণ SMS খরচ প্রযোজ্য।"
3. গেটওয়ে ফোনের **SMS Gateway for Android** অ্যাপ `sms:received` webhook পাঠাবে Edge Function **`sms-verify-webhook`**-এ।
4. `sms-verify-webhook`-এর কাজ:
   - webhook আসল কিনা যাচাই করবে: অ্যাপের webhook signing থাকলে তার signature দিয়ে, নাহলে URL-এ একটা লম্বা secret token দিয়ে
   - পাঠানো নম্বর normalize করে body থেকে `RB (\d{4})` বের করবে
   - মেলে এমন, মেয়াদ না-পেরোনো আর আগে ব্যবহার না হওয়া `phone_verifications` row খুঁজবে
   - পেলে `user_phones`-এ upsert করবে (`verified_at = now()`, `verified_method = 'reverse_sms'`), আর row-টা `consumed` চিহ্নিত করবে
5. App যাচাই স্ক্রিনে প্রতি ৩ সেকেন্ডে `get_my_phone_status()` ডাকবে, সর্বোচ্চ ৩ মিনিট পর্যন্ত। যাচাই হয়ে গেলে পরের ধাপে যাবে। ৩ মিনিটে না হলে লেখা আসবে: "আবার চেষ্টা করুন, অথবা আপনার ক্লাবের মডারেটরকে বলুন।"

**বিকল্প পথ:** মডারেটর `mod_verify_phone(user_id)` দিয়ে হাতে হাতে নম্বর যাচাই করতে পারবেন (`verified_method = 'moderator'`)। গেটওয়ে ফোন বন্ধ থাকলে বা ব্যবহারকারীর SMS ব্যালেন্স না থাকলে এটাই সমাধান।

**কোন কাজে যাচাই করা নম্বর লাগবে:** ডোনার হওয়া, রিকোয়েস্ট পাঠানো, আর রিকোয়েস্টে সাড়া দেওয়া। Google দিয়ে লগইন করলেই প্রোফাইল বানানো যাবে, কিন্তু এই তিনটা কাজ নম্বর যাচাই না হলে করা যাবে না।

**নিরাপত্তার সীমা:**
- SMS-এর sender নম্বর নকল করা (spoofing) বাংলাদেশে বিরল, তবে অসম্ভব না। তাই বিশ্বাসের মূল ভিত্তি এখনো ক্লাবের Verified ব্যাজ (PRD D5)।
- গেটওয়ে ফোনের নম্বর অ্যাপে প্রকাশ্য থাকবে। এই নম্বরে আসা অন্য SMS webhook উপেক্ষা করবে।

### ৫.৬.১ গেটওয়ে ফোন চালানোর নিয়ম

- একটা পুরনো Android ফোন (Android 5 বা তার উপরে) আর একটা আলাদা SIM। ফোনটা সবসময় চার্জে, Wi-Fi বা মোবাইল ডেটায় থাকবে।
- ফোনে [SMS Gateway for Android](https://github.com/capcom6/android-sms-gateway) (Apache 2.0, ফ্রি) চলবে। `sms:received` webhook সেট করা থাকবে, আর battery optimization বন্ধ।
- **Heartbeat:** ফোন থেকে প্রতি ঘণ্টায় একটা টেস্ট SMS নিজের কাছে পাঠানো (অথবা অ্যাপের health ফিচার), আর `sms-verify-webhook` শেষ কখন webhook পেয়েছে তা লিখে রাখবে। ৩ ঘণ্টা কোনো সাড়া না এলে মডারেটরের স্ক্রিনে "গেটওয়ে বন্ধ" দেখাবে।
- বিরল গ্রুপের alert পাঠাতে হলে (ঐচ্ছিক) Cloud বা Private mode লাগবে, যাতে Edge Function থেকে ফোনে কমান্ড পাঠানো যায়। Cloud mode-এ প্রজেক্টের পাবলিক সার্ভার ব্যবহার হয়। ডেটা প্রাইভেসি আর ব্যবহারের শর্ত Sprint 4-এ যাচাই করতে হবে।

### ৫.৭ যোগাযোগের তথ্য দেখানোর RPC (PRD D2)

```sql
-- ডোনার: রিকোয়েস্টারের নম্বর পাবেন শুধু নিজে 'accepted' অবস্থায় থাকলে আর রিকোয়েস্ট 'open' থাকলে
create function get_request_contact(p_request_id uuid) returns text
language plpgsql security definer set search_path = public as $$ ... $$;

-- রিকোয়েস্টার: শুধু নিজের রিকোয়েস্টে যারা 'accepted' তাদের নাম, নম্বর, আনুমানিক দূরত্ব আর verified কিনা
create function get_accepted_donors(p_request_id uuid)
returns table (donor_id uuid, full_name text, phone text, distance_km_rounded int, is_verified boolean)
language plpgsql security definer set search_path = public as $$ ... $$;
```

### ৫.৮ State machine

**রিকোয়েস্ট:**
```
open ──(রিকোয়েস্টার: পাওয়া গেছে)──► fulfilled
open ──(রিকোয়েস্টার: আর লাগবে না)──► closed
open ──(needed_by + 6h)────────────► expired
open ──(মডারেটর)───────────────────► removed
```

**ডোনারের সাড়া:**
```
(notified) ──► accepted ──► withdrawn   (wave আবার চালু হবে)
           └─► declined
```

**রক্তদান:** কোনো ডোনার `accepted` হলে `donations` row তৈরি হবে (`pending`)।
```
pending ──(দুই পক্ষ নিশ্চিত, অথবা এক পক্ষ নিশ্চিত + ৪৮ ঘণ্টা)──► confirmed
         ──► last_donated_at আপডেট, reliability_score আবার হিসাব
pending ──(রিকোয়েস্টার: আসেননি)──► no_show  ──► reliability_score কমবে
(পরস্পরবিরোধী নিশ্চিতকরণ) ──► disputed  ──► মডারেটরের তালিকায় যাবে
```

**বিশ্বাসযোগ্যতার স্কোর:** `(confirmed + 1) / (accepted_total - withdrawn_early + 2)`, যেখানে মান ০ থেকে ১ এর মধ্যে থাকবে। কোনো ইতিহাস না থাকলে ০.৫।

### ৫.৯ RPC-এর তালিকা (client যা ডাকতে পারবে)

| RPC | কে ডাকবে | কাজ |
|---|---|---|
| `upsert_my_profile(...)` | নিজে | প্রোফাইল সেটআপ বা আপডেট |
| `start_phone_verification(phone)` / `get_my_phone_status()` | নিজে | ৫.৬: উল্টো SMS দিয়ে যাচাই |
| `health()` | anon | GitHub Actions-এর keep-alive ping। শুধু `true` ফেরত দেয় |
| `upsert_my_donor_profile(lat?, lng?, upazila_id, last_donated_at, ...)` | নিজে | GPS না দিলে upazila-র centroid ব্যবহার হবে |
| `set_donor_pause(until)` / `get_my_donor_status()` | নিজে | বিরতি দেওয়া, উপযুক্ততা আর পরের তারিখ দেখা |
| `register_device_token(token)` | নিজে | FCM token সংরক্ষণ |
| `create_blood_request(...)` | যেকোনো active ব্যবহারকারী | B1 |
| `close_blood_request(id, outcome)` | রিকোয়েস্টার | B3 |
| `get_request_for_donor(id)` | যাকে জানানো হয়েছে | নম্বর ছাড়া বিস্তারিত আর আনুমানিক দূরত্ব |
| `respond_to_request(id, accept bool)` / `withdraw_response(id)` | যাকে জানানো হয়েছে | C4 |
| `get_request_contact(id)` / `get_accepted_donors(id)` | শর্তসাপেক্ষে | ৫.৭ |
| `confirm_donation(donation_id, donated bool)` | দুই পক্ষ | D1 |
| `report_user(...)` / `block_user(id)` | যেকোনো | E1, E2 |
| `mod_search_user(phone)` / `mod_set_verified(user_id, bool)` / `mod_verify_phone(user_id)` / `mod_handle_report(id, action)` / `mod_list_unanswered_requests()` / `mod_gateway_status()` | মডারেটর (নিজের ক্লাবের জেলায়) | E3, audit log-এ লেখা হবে |
| `delete_my_account()` | নিজে | A4 |

### ৫.১০ RLS-এর সারসংক্ষেপ

| Table | Client select | Client insert / update / delete |
|---|---|---|
| `districts`, `upazilas`, `hospitals`, `clubs` | সবাই (authenticated) | না |
| `profiles` | শুধু নিজের row | update শুধু নিরাপদ column-এ (`role` আর `status` বাদে), trigger দিয়ে নিয়ন্ত্রিত |
| `donor_profiles` | শুধু নিজের row | না, শুধু RPC দিয়ে |
| `blood_requests` | নিজে যেগুলো তৈরি করেছেন | না, শুধু RPC দিয়ে |
| `request_contacts`, `user_phones`, `phone_verifications` | **কেউ না** | না, শুধু RPC বা Edge Function দিয়ে |
| `request_notifications`, `request_responses`, `donations` | নিজের সাথে সম্পর্কিত row | না, শুধু RPC দিয়ে |
| `reports`, `blocks` | নিজের তৈরি করা | না, শুধু RPC দিয়ে |
| `moderation_audit_log`, `app_config` | না | না |

---

## ৬. স্ক্রিনের তালিকা

| # | স্ক্রিন | Story |
|---|---|---|
| 1 | Splash, ভাষা বাছাই | – |
| 2 | Google দিয়ে লগইন | A1 |
| 2a | ফোন নম্বর দেওয়া, তারপর "SMS পাঠান" বাটন, তারপর অপেক্ষার স্ক্রিন (৩ মিনিট, polling) | A1b |
| 3 | প্রোফাইল সেটআপ (নাম, গ্রুপ, জেলা, উপজেলা) | A2 |
| 4 | ডোনার সেটআপ (উপযুক্ততার নিশ্চিতকরণ, শেষ দানের তারিখ, লোকেশন) | A2 |
| 5 | Notification permission ও battery optimization নির্দেশনা | ঝুঁকি |
| 6 | **Home:** বড় "রক্ত দরকার" বাটন, আমার চালু রিকোয়েস্ট, ডোনার স্ট্যাটাস কার্ড (উপযুক্ত কিনা, পরের তারিখ, বিরতি টগল) | – |
| 7 | রিকোয়েস্ট তৈরি (ধাপ ১: গ্রুপ, ব্যাগ; ধাপ ২: হাসপাতাল, সময়; ধাপ ৩: সারসংক্ষেপ ও সতর্কবার্তা) | B1 |
| 8 | আমার রিকোয়েস্ট: বিস্তারিত (কতজনকে জানানো হয়েছে, রাজি ডোনারদের তালিকা, কল বাটন, রক্তদান চিহ্নিত করা, বন্ধ করা) | B2, B3, D1 |
| 9 | ডোনারের কাছে আসা রিকোয়েস্ট (বিস্তারিত, রাজি বা অরাজি, রাজি হলে নম্বর আর কল বাটন, সরে আসা) | C4 |
| 10 | আমার রক্তদানের ইতিহাস | D2 |
| 11 | রিপোর্ট বা ব্লক (bottom sheet) | E1, E2 |
| 12 | সেটিংস (প্রোফাইল এডিট, ভাষা, প্রাইভেসি পলিসি, অ্যাকাউন্ট মুছে ফেলা) | A4 |
| 13 | মডারেটর: সদস্য যাচাই, রিপোর্টের তালিকা, সাড়া না পাওয়া রিকোয়েস্ট | E3 |

**Deep link:** notification-এ চাপলে `/incoming/:requestId` (স্ক্রিন ৯) খুলবে। অ্যাপ বন্ধ থাকলেও কাজ করতে হবে (`getInitialMessage`)।

---

## ৭. স্প্রিন্ট প্ল্যান

### Sprint 0: Setup (সপ্তাহ ১)
- [ ] Git repo, Flutter প্রজেক্ট, flavors, lint (`very_good_analysis` বা `flutter_lints`)
- [ ] Supabase staging ও prod, Supabase CLI (staging-এ link করা)। local Supabase চলবে না, staging-ই development-এর ডেটাবেস (ADR 0008)
- [ ] Firebase project, FCM, Crashlytics
- [ ] Google Cloud-এ OAuth client (Android + Web client ID), Supabase-এ Google provider চালু
- [ ] গেটওয়ে ফোন সেটআপ: আলাদা SIM, SMS Gateway for Android অ্যাপ, staging-এর webhook
- [ ] GitHub Actions: `keep-alive.yml` (প্রতি ২ দিনে) আর `backup.yml` (সাপ্তাহিক, encrypted)
- [ ] Seed: সব districts (রাঙ্গামাটি `is_active`, `neighbor_ids` সহ), রাঙ্গামাটি আর পাশের ৩ জেলার upazilas (centroid সহ), হাসপাতাল (রাঙ্গামাটির সরকারি আর প্রাইভেট, উপজেলা স্বাস্থ্য কমপ্লেক্স, চট্টগ্রামের রেফারেল হাসপাতাল)
- [ ] CI (GitHub Actions): `flutter analyze`, `flutter test`, `supabase test db`
- [ ] l10n scaffold (bn, en), থিম, router

### Sprint 1: পরিচয় ও ডোনার (সপ্তাহ ২–৩)
- [ ] Migration: enum, profiles, donor_profiles, device_tokens, RLS
- [ ] Google Sign-In (A1)
- [ ] `user_phones`, `phone_verifications`, `start_phone_verification`, `get_my_phone_status`, Edge Function `sms-verify-webhook` (A1b)
- [ ] প্রোফাইল ও ডোনার সেটআপ (A2), লোকেশন: GPS অথবা upazila centroid
- [ ] `is_donor_eligible`, `get_my_donor_status`, বিরতি (A3)
- [ ] Home স্ক্রিনের ডোনার স্ট্যাটাস কার্ড
- [ ] FCM token নিবন্ধন
- **Demo:** নতুন ব্যবহারকারী Google দিয়ে ঢুকবেন, উল্টো SMS দিয়ে নম্বর যাচাই করবেন, ডোনার হবেন আর নিজের উপযুক্ততা দেখবেন।

### Sprint 2: রিকোয়েস্ট ও ম্যাচিং (সপ্তাহ ৪–৫), *সবচেয়ে ঝুঁকিপূর্ণ, তাই আগে*
- [ ] Migration: blood_requests, request_contacts, request_notifications, app_config
- [ ] `compatible_donor_groups`, candidate query, `process_request_wave`, `create_blood_request`
- [ ] pg_cron: `process_due_waves`, `expire_requests`, pending retry
- [ ] Edge Function `dispatch-notifications` (FCM)
- [ ] রিকোয়েস্ট তৈরির flow (স্ক্রিন ৭)
- [ ] pgTAP: compatibility table, উপযুক্ততা, ব্যাসার্ধ, সীমা, রাতের নিয়ম, ব্লক, দ্বিতীয়বার না পাঠানো
- **Demo:** স্টেজিংয়ে ৩০ জন fake ডোনার seed করে রিকোয়েস্ট পাঠানো হবে। Wave 1 আর Wave 2 সঠিক মানুষের কাছে যাবে আর push পৌঁছাবে।

### Sprint 3: সাড়া, যোগাযোগ, রক্তদান (সপ্তাহ ৬–৭)
- [ ] Migration: request_responses, donations
- [ ] `respond_to_request`, `withdraw_response`, `get_request_for_donor`, `get_request_contact`, `get_accepted_donors`
- [ ] স্ক্রিন ৮ আর ৯, deep link, কল বাটন
- [ ] রিকোয়েস্টারের কাছে push যাবে "নতুন ডোনার রাজি হয়েছেন"
- [ ] `close_blood_request`, দরকারি সংখ্যক ডোনার রাজি হলে wave থামানো
- [ ] `confirm_donation`, `finalize_donations`, reliability score, ইতিহাস (স্ক্রিন ১০)
- **Demo:** দুটো ফোন দিয়ে পুরো end-to-end flow: রিকোয়েস্ট, push, রাজি, কল, রক্তদান নিশ্চিত, ইতিহাস।

### Sprint 4: নিরাপত্তা, মডারেশন, SMS, polish (সপ্তাহ ৮–৯)
- [ ] reports, blocks, auto-suspend trigger, স্ক্রিন ১১
- [ ] club_moderators, `mod_*` RPC, audit log, স্ক্রিন ১৩
- [ ] `mod_verify_phone`, গেটওয়ের heartbeat আর `mod_gateway_status`
- [ ] (ঐচ্ছিক) গেটওয়ে ফোন থেকে বিরল গ্রুপের SMS alert, দৈনিক সীমা। ডিফল্টে বন্ধ থাকবে
- [ ] অ্যাকাউন্ট মুছে ফেলা (A4), প্রাইভেসি পলিসি আর Terms স্ক্রিন
- [ ] KPI SQL views (৮ নম্বর অংশ দেখুন)
- [ ] কম দামের ফোনে (২ জিবি RAM) পারফরম্যান্স টেস্ট, Xiaomi, Oppo, Vivo-তে push টেস্ট
- [ ] বাংলা লেখা রিভিউ
- **Demo:** Release candidate।

### Beta (সপ্তাহ ১০–১১)
- [ ] **Play Console না থাকলে:** signed APK GitHub Releases-এ রেখে ক্লাবের মাধ্যমে লিংক দেওয়া (ফ্রি)। Sideload করার নির্দেশনা বাংলায় দিতে হবে
- [ ] **Play Console থাকলে ($২৫):** Closed testing track-এ পার্টনার ক্লাবের ১০০–২০০ জন। নতুন ব্যক্তিগত developer অ্যাকাউন্টে production-এ যাওয়ার আগে নির্দিষ্ট সংখ্যক টেস্টার নিয়ে ১৪ দিনের closed testing বাধ্যতামূলক। টেস্টারের সংখ্যা Play Console-এর এখনকার নিয়ম দেখে নিতে হবে
- [ ] মডারেটরদের অনবোর্ডিং (নম্বর হাতে হাতে যাচাই করা, গেটওয়ের অবস্থা দেখা)
- [ ] প্রতিদিন KPI আর crash রিভিউ, বাগ ঠিক করা
- [ ] Production-এ লঞ্চ

---

## ৮. KPI-এর SQL views

```sql
create view kpi_first_response as      -- median মিনিট, প্রতিদিন
  select date_trunc('day', r.created_at) as day,
         percentile_cont(0.5) within group (order by extract(epoch from (fr.first_at - r.created_at))/60) as median_min
  from blood_requests r
  join lateral (select min(responded_at) first_at from request_responses
                where request_id = r.id and status = 'accepted') fr on fr.first_at is not null
  group by 1;
-- kpi_fulfillment_rate, kpi_rare_fulfillment_rate, kpi_eligible_donors_by_group,
-- kpi_response_rate, kpi_no_show_rate, kpi_report_rate: একই ধরনে
```

এগুলো Supabase Dashboard থেকে, বা পরে কোনো ছোট অ্যাডমিন পেজ থেকে দেখা যাবে।

---

## ৯. টেস্টিং

| স্তর | টুল | কী টেস্ট হবে |
|---|---|---|
| Database | pgTAP (development-এ `supabase test db --linked` staging-এ; পরিষ্কার ডেটাবেসে পূর্ণ পরীক্ষা CI-তে, ADR 0008) | compatibility, উপযুক্ততা, ম্যাচিং query, wave-এর অবস্থা বদল, RLS (অন্যের row দেখা যায় না, `request_contacts` পড়া যায় না), RPC-এর অনুমতি, rate limit |
| Edge Function | Deno test | payload তৈরি, idempotency, FCM বা গেটওয়ের ভুলের সামাল; `sms-verify-webhook`: ভুল secret, ভুল কোড, মেয়াদ শেষ, একই কোড দুবার, নম্বরের বিভিন্ন ফরম্যাট (`01…`, `+8801…`, `8801…`) |
| Flutter unit / widget | `flutter_test`, `mocktail` | form validation, state notifier, বাংলা লেখা ঠিক দেখায় কিনা |
| End-to-end (ম্যানুয়াল) | চেকলিস্ট, ২–৩টা আসল ফোন | পুরো flow; অ্যাপ বন্ধ বা background অবস্থায় push; ধীর নেটওয়ার্ক |

**Done-এর সংজ্ঞা:** কোনো story শেষ হবে তখনই যখন acceptance criteria পূরণ হয়েছে, DB-এর লজিকে pgTAP টেস্ট আছে, RLS যাচাই করা হয়েছে, বাংলা আর ইংরেজি লেখা আছে, আর staging-এ demo হয়েছে।

---

## ১০. নিরাপত্তা চেকলিস্ট

- [ ] সব table-এ RLS চালু (`supabase db lint` দিয়ে যাচাই)
- [ ] প্রতিটা `security definer` function-এ `set search_path`, শুরুতেই `auth.uid()` যাচাই
- [ ] App-এ শুধু anon key থাকবে। Service role key শুধু Edge Function-এর secret-এ
- [ ] Edge Function-এ shared secret বা JWT যাচাই
- [ ] Rate limit: নম্বর যাচাইয়ের কোড (দিনে ৫টা), রিকোয়েস্ট (RPC), রিপোর্ট (দিনে ১০টা)
- [ ] `sms-verify-webhook`-এ secret বা signature যাচাই। Secret repo-তে থাকবে না
- [ ] Backup ফাইল সবসময় encrypt করা (age বা gpg)। Decrypt key থাকবে শুধু আপনার কাছে, GitHub-এ না
- [ ] কোনো log-এ ফোন নম্বর লেখা হবে না
- [ ] Play Store-এর Data Safety ফর্মে সঠিক তথ্য

---

## ১১. খরচ: শূন্য বাজেটের পরিকল্পনা

| খাত | খরচ | কীভাবে |
|---|---|---|
| Supabase | **০** | Free tier: ২টা project (staging আর prod), ৫০০ MB DB, ৫০k MAU, মাসে ৫ লাখ Edge Function call (সীমাগুলো Sprint 0-তে official pricing পেজে মিলিয়ে নিতে হবে) |
| Supabase-এর pause ঠেকানো | **০** | ৭ দিন activity না থাকলে free project pause হয়। GitHub Actions `keep-alive.yml` প্রতি ২ দিনে `health()` RPC ডাকবে |
| Backup | **০** | GitHub Actions `backup.yml`: সাপ্তাহিক `pg_dump`, encrypt করে private artifact-এ রাখা |
| লগইন | **০** | Google Sign-In |
| ফোন নম্বর যাচাই | **০** (আমাদের জন্য) | উল্টো SMS। ব্যবহারকারীর একটা সাধারণ SMS খরচ হয়, আর মডারেটর দিয়ে হাতে হাতে যাচাইয়ের বিকল্প আছে |
| Push | **০** | FCM |
| Crash রিপোর্ট | **০** | Crashlytics |
| প্রাইভেসি পলিসির পেজ | **০** | GitHub Pages |
| গেটওয়ে ফোন | **০** (নিজের পুরনো ফোন) | SIM চালু রাখার জন্য মাঝে মাঝে সামান্য রিচার্জ লাগতে পারে |
| বিরল গ্রুপের SMS alert | ঐচ্ছিক | ডিফল্টে বন্ধ। চালু করলে গেটওয়ে SIM-এ একটা সস্তা SMS বান্ডেল লাগবে |
| **Play Console** | **একবার $২৫, এটা এড়ানো যায় না** | বেটা চলবে APK দিয়ে। Play Store-এ যাওয়ার আগে টাকাটা জোগাড় করা, যেমন পার্টনার ক্লাবের স্পন্সরশিপে |

**কখন paid প্ল্যানে যাওয়া দরকার হবে:** DB ৪০০ MB ছাড়ালে, মাসিক সীমার ৮০% পেরোলে, অথবা অন্য জেলায় সম্প্রসারণের সময়। তখন Supabase Pro (মাসে প্রায় $২৫) আর একটা দেশি SMS গেটওয়ে নেওয়া। এই নিয়ম PRD D10-এর সাথে মিলিয়ে রাখা হয়েছে।

---

## ১২. খোলা টেকনিক্যাল প্রশ্ন

1. SMS Gateway for Android-এর webhook signing আছে কিনা, আর Cloud mode-এর ব্যবহারের শর্ত ও প্রাইভেসি কেমন, তা যাচাই করা। Sprint 0-তে গেটওয়ে ফোন দিয়ে একটা proof-of-concept বানাতে হবে।
2. রাঙ্গামাটি আর পাশের জেলার upazila centroid আর হাসপাতালের coordinate কোথা থেকে নেওয়া হবে (open dataset + স্থানীয়ভাবে হাতে যাচাই)।
3. রাঙ্গামাটিতে সরলরেখার দূরত্ব (`st_dwithin`) কতটা কাজের? বেটায় যদি দেখা যায় হ্রদ বা পাহাড়ের কারণে কাছের ডোনারও দেরিতে পৌঁছাচ্ছেন, তাহলে Wave 1-2 উপজেলাভিত্তিক করা হবে (একই উপজেলা, তারপর পাশের উপজেলা)।
4. Edge Function ডাকার জন্য pg_net-এর ভরসায় থাকা যথেষ্ট কিনা, নাকি Supabase Queues (pgmq) লাগবে। MVP-তে pg_net আর retry cron যথেষ্ট ধরে নেওয়া হয়েছে।
