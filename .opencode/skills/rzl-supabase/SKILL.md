---
name: RZL Supabase
description: Load when designing or changing tables, writing migrations, authoring RLS policies, wiring auth, storage buckets, realtime, or Edge Functions for the RZL Supabase backend. Encodes the public-browse/authenticated-engage/admin-write permission model and the verification steps that catch privilege bugs.
---

# RZL — Supabase Backend

Schema: `docs/design/schema.md`. Policies: `docs/design/rls-policies.md`. Permission model:
`docs/spec/roles.md`.

## Non-negotiables

1. **RLS enabled on every table.** A table without RLS is a bug.
2. **Guests read events.** `to anon` on every public-read policy. This is the #1 cause of
   "blank app on the panel's phone".
3. **`profiles.role` is never writable from the client.** Privilege escalation otherwise.
4. **Moderation is soft** (`is_hidden`), never `DELETE`. Engagement reports must stay
   intact (AD-10).
5. **No paid API at runtime.** Embeddings and summaries are generated on write, never on
   read (`docs/spec/cost-model.md`).

## Migration workflow

Migrations are ordered SQL files in `supabase/migrations/`. Never edit the schema through
the dashboard — it will not be reproducible in the defense, and a panel may ask you to
rebuild the database.

```
supabase/migrations/
├── 20260101000000_reference_tables.sql
├── 20260101000100_profiles.sql
├── 20260101000200_events.sql
├── 20260101000300_engagement.sql
├── 20260101000400_announcements_notifications.sql
├── 20260101000500_places.sql
├── 20260101000600_analytics.sql
├── 20260101000700_views_functions.sql
└── 20260101000800_rls_policies.sql
```

Rules:
- One concern per file. `reference_tables` and `rls_policies` never share a file.
- Every `create table` is followed in the **same file** by `alter table … enable row level
  security`.
- Every policy file is idempotent-friendly: `drop policy if exists x on t;` before
  `create policy x`.
- No `seed` data in a migration. Seeds go in `supabase/seed.sql` and are applied manually.

Local loop:

```bash
supabase start
supabase db reset          # applies all migrations + seed
supabase gen types dart --local > lib/core/supabase/database.dart
```

Generate Dart types. Do not hand-write table shapes — hand-written row classes drift from
the schema and the drift shows up as a null crash during the demo.

## Auth

- **Email + password**, with email confirmation for the study. Handle the "check your
  email" state explicitly — it is a common dead end (TC-020).
- A trigger creates the `profiles` row on `auth.users` insert, defaulting `role` to
  `'resident'`:

```sql
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, new.raw_user_meta_data->>'full_name', 'resident')
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
```

- Promotion to `admin` / `lgu` happens via a service-role script or the dashboard, never
  through the app.
- Session persistence is handled by `supabase_flutter`. Do not build a custom token store.
- Logging out must return the app to **guest mode with a working feed** (TC-023), not to a
  blank screen.

## Storage

- Bucket `event-images`, public read, staff-only write.
- Validate **client-side before upload**: max 5 MB, `image/jpeg|png|webp` only (TC-071,
  TC-072). A rejected 12 MB upload should never reach the network.
- Store the public URL on `events.cover_image_url`; do not store the file path only.

## Realtime

- Use realtime for `comments` and `likes` on an open event detail screen only.
- **Always** pair a realtime subscription with a polling fallback (AD-11). Venue Wi-Fi at
  the defense is the actual constraint.
- Unsubscribe on dispose. A leaked channel is a slow memory leak and a source of duplicate
  rows in the UI.

## Queries

- The feed reads the `event_stats` view, not seven round trips.
- Filter server-side: `.eq('municipality_id', id)`, `.gte('starts_at', ...)`,
  `.eq('status', 'published')`. Do not fetch everything and filter in Dart — it is slower
  and it breaks as the dataset grows.
- Paginate: `.range(from, to)` with 20 per page.
- Never `select('*')` in a screen. Name the columns; `select('*')` on `events` pulls the
  1536-dimension embedding vector into every list response.

## Semantic search query

```sql
create or replace function public.match_events(
  query_embedding vector(1536),
  match_threshold float default 0.5,
  match_count int default 20
)
returns table (
  id uuid, title text, summary text, starts_at timestamptz, similarity float
)
language sql stable
as $$
  select e.id, e.title, e.summary, e.starts_at,
         1 - (e.embedding <=> query_embedding) as similarity
  from public.events e
  where e.status = 'published'
    and e.embedding is not null
    and 1 - (e.embedding <=> query_embedding) > match_threshold
  order by e.embedding <=> query_embedding
  limit match_count;
$$;
```

`<=>` is cosine distance, so similarity is `1 - distance`. Call it via `.rpc()`.

## Verification — run after every migration

```sql
-- tables missing RLS
select tablename from pg_tables
where schemaname = 'public' and rowsecurity = false;

-- tables with no policies
select t.tablename from pg_tables t
left join pg_policies p on p.tablename = t.tablename
where t.schemaname = 'public'
group by t.tablename having count(p.policyname) = 0;
```

Both must return zero rows. Then verify **as `anon`**, because the owner bypasses RLS and
will happily show you a working app that is broken for guests:

```sql
set role anon;
select count(*) from events;               -- must be > 0 when published events exist
insert into events (title) values ('x');   -- must FAIL
reset role;
```

## Anti-patterns

| Don't | Why |
|---|---|
| `using (true)` on insert/update | Any authenticated user writes anything |
| Enforcing roles only in the client | The client is attacker-controlled |
| Editing schema in the dashboard | Not reproducible for the defense |
| `select('*')` on `events` | Ships the embedding vector on every list call |
| Fetching all rows then filtering in Dart | Slow and breaks at scale |
| Hard delete of moderated content | Breaks FR-31 reports |
| Storing keys in `lib/` | Use `--dart-define`; see `rzl-flutter` |
| Skipping the `to anon` clause | Guests see an empty app |
