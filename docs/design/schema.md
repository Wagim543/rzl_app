# RZL — Database Schema

Target: Supabase Postgres 15+ with `pgvector`. This is the ERD source for Chapter 3 —
if this file and the ERD disagree, **this file wins** and the ERD is redrawn.

Conventions:
- `id uuid primary key default gen_random_uuid()`
- `created_at timestamptz not null default now()`, `updated_at` maintained by trigger
- Enums are Postgres `enum` types, not `text` + check
- Soft-hide for user content (`is_hidden`), soft-archive for events (`status`)
- Every table has RLS **enabled**; no exceptions

---

## 1. Reference tables (public read, admin write)

```sql
create table municipalities (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,          -- 'Binangonan', 'Antipolo', ...
  psgc_code   text unique,                   -- PSA geographic code
  created_at  timestamptz not null default now()
);

create table barangays (
  id               uuid primary key default gen_random_uuid(),
  municipality_id  uuid not null references municipalities(id) on delete cascade,
  name             text not null,
  created_at       timestamptz not null default now(),
  unique (municipality_id, name)
);

create table categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,           -- 'Festival', 'Sports', 'Health', ...
  slug        text not null unique,
  icon        text,                           -- material icon name used by the client
  sort_order  int  not null default 0,
  created_at  timestamptz not null default now()
);
```

Seed with all 13 Rizal municipalities + Antipolo, and the Binangonan barangays that appear
in the study. See `scripts/seed.sql` in the `rzl-supabase` skill.

## 2. Profiles

```sql
create type user_role as enum ('resident', 'tourist', 'admin', 'lgu');

create table profiles (
  id                uuid primary key references auth.users(id) on delete cascade,
  full_name         text,
  role              user_role not null default 'resident',
  municipality_id   uuid references municipalities(id),
  barangay_id       uuid references barangays(id),
  interests         text[] not null default '{}',   -- category slugs
  avatar_url        text,
  dark_mode         boolean,                        -- null = follow OS
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);
```

`role` is written by a trigger on signup (`'resident'`) and promoted only by an admin, via
a service-role call. **It must never be settable from the client** — that is a privilege
escalation path.

## 3. Events (the core table)

```sql
create type event_status as enum ('draft', 'published', 'cancelled', 'archived');

create table events (
  id                     uuid primary key default gen_random_uuid(),
  title                  text not null,
  description            text not null,
  summary                text,                          -- FR-21, generated on publish
  summary_generated_at   timestamptz,
  embedding              vector(1536),                  -- FR-22/23, pgvector
  category_id            uuid not null references categories(id),
  municipality_id        uuid not null references municipalities(id),
  barangay_id            uuid references barangays(id),
  venue                  text not null,
  address                text,
  latitude               double precision,
  longitude              double precision,
  starts_at              timestamptz not null,
  ends_at                timestamptz not null,
  is_free                boolean not null default true,
  price                  numeric(10,2),
  capacity               int,
  cover_image_url        text,
  status                 event_status not null default 'draft',
  published_at           timestamptz,
  created_by             uuid references profiles(id) on delete set null,  -- null = seeded/system content (AD-15)
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  constraint events_time_order check (ends_at > starts_at)
);

create index events_status_starts_idx on events (status, starts_at desc);
create index events_municipality_idx on events (municipality_id, starts_at desc);
create index events_barangay_idx     on events (barangay_id, starts_at desc);
create index events_category_idx     on events (category_id, starts_at desc);
-- HNSW cosine index for semantic search
create index events_embedding_idx on events using hnsw (embedding vector_cosine_ops);
```

## 4. Engagement tables

```sql
create type attendance_status as enum ('going', 'interested', 'cancelled');

create table bookmarks (
  user_id    uuid not null references profiles(id) on delete cascade,
  event_id   uuid not null references events(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, event_id)
);

create table attendance (
  user_id    uuid not null references profiles(id) on delete cascade,
  event_id   uuid not null references events(id) on delete cascade,
  status     attendance_status not null default 'going',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, event_id)
);

create table likes (
  user_id    uuid not null references profiles(id) on delete cascade,
  event_id   uuid not null references events(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, event_id)
);

create table comments (
  id         uuid primary key default gen_random_uuid(),
  event_id   uuid not null references events(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  body       text not null check (char_length(btrim(body)) between 1 and 1000),
  parent_id  uuid references comments(id) on delete cascade,  -- reserved, v1 flat
  is_hidden  boolean not null default false,
  created_at timestamptz not null default now()
);

create table reviews (
  id         uuid primary key default gen_random_uuid(),
  event_id   uuid not null references events(id) on delete cascade,
  user_id    uuid not null references profiles(id) on delete cascade,
  rating     smallint not null check (rating between 1 and 5),
  body       text check (body is null or char_length(btrim(body)) <= 2000),
  is_hidden  boolean not null default false,
  created_at timestamptz not null default now(),
  unique (user_id, event_id)          -- one review per user per event (FR-18)
);
```

Composite primary keys on `bookmarks` / `attendance` / `likes` give you "one per user per
event" for free. Do not replace them with an `id` column plus a unique index.

## 5. Announcements and notifications

```sql
create table announcements (
  id               uuid primary key default gen_random_uuid(),
  title            text not null,
  body             text not null,
  municipality_id  uuid references municipalities(id),   -- null = province-wide
  published_at     timestamptz,
  created_by       uuid not null references profiles(id),
  created_at       timestamptz not null default now()
);

create table notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  title       text not null,
  body        text not null,
  type        text not null,      -- 'event_soon' | 'event_cancelled' | 'announcement'
  payload     jsonb not null default '{}'::jsonb,
  read_at     timestamptz,
  created_at  timestamptz not null default now()
);
create index notifications_user_unread_idx on notifications (user_id, read_at);
```

## 6. Places (seeded, no live API)

```sql
create type place_type as enum ('attraction', 'restaurant', 'hotel');

create table places (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  type             place_type not null,
  municipality_id  uuid not null references municipalities(id),
  address          text,
  latitude         double precision not null,
  longitude        double precision not null,
  description      text,
  image_url        text,
  created_at       timestamptz not null default now()
);
create index places_geo_idx on places (type, municipality_id);
```

Radius filtering happens client-side or via a `postgis`-free haversine query. For a fixed
study area, seed 15–30 real establishments in Binangonan.

## 7. Analytics

```sql
create table event_views (
  id          bigserial primary key,
  event_id    uuid not null references events(id) on delete cascade,
  user_id     uuid references profiles(id) on delete set null,  -- null = guest
  session_id  text,
  viewed_at   timestamptz not null default now()
);
create index event_views_event_idx on event_views (event_id, viewed_at desc);

-- materialised daily rollup for FR-31
create table event_metrics_daily (
  event_id      uuid not null references events(id) on delete cascade,
  day           date not null,
  views         int not null default 0,
  likes         int not null default 0,
  comments      int not null default 0,
  reviews       int not null default 0,
  going_count   int not null default 0,
  bookmarks     int not null default 0,
  primary key (event_id, day)
);
```

`event_views.user_id` being nullable is deliberate: guests browse, and FR-31 needs to count
them. Do not make it `not null`.

## 8. Aggregates used by the client

```sql
create view event_stats as
select
  e.id as event_id,
  (select count(*) from likes    l where l.event_id = e.id) as like_count,
  (select count(*) from comments c where c.event_id = e.id and not c.is_hidden) as comment_count,
  (select count(*) from reviews  r where r.event_id = e.id and not r.is_hidden) as review_count,
  (select round(avg(r.rating)::numeric, 1) from reviews r
     where r.event_id = e.id and not r.is_hidden) as avg_rating,
  (select count(*) from attendance a
     where a.event_id = e.id and a.status = 'going') as going_count,
  (select count(*) from bookmarks b where b.event_id = e.id) as bookmark_count
from events e;
```

Expose this as a read-only view so the feed needs one round trip instead of seven. Views
inherit RLS from their base tables when `security_invoker = true`:

```sql
alter view event_stats set (security_invoker = true);
```

## 9. Relationship summary (for the ERD)

```
municipalities 1─┬─* barangays
                 ├─* events
                 └─* places
categories     1──* events
profiles       1─┬─* events            (created_by)
                 ├─* bookmarks     *──1 events
                 ├─* attendance    *──1 events
                 ├─* likes         *──1 events
                 ├─* comments      *──1 events
                 ├─* reviews       *──1 events
                 └─* notifications
events         1─┬─* event_views
                 ├─* event_metrics_daily
                 └─* (all engagement tables)
announcements  *──1 municipalities
```

Draw this as the Chen or crow's-foot ERD for Chapter 3 **directly from this section**, so
the paper and the migrations cannot drift.
