# RZL — Row Level Security Policies

RLS is enabled on **every** table. A table without RLS is a bug, not an oversight.

The pattern below is the only approved pattern. Copy it; do not improvise, because a wrong
policy is invisible in development (the app runs as the owner) and a blank screen or a
silent data leak in production.

---

## 0. The helper function

Every policy that checks a role uses this. `security definer` avoids infinite recursion when
the policy on `profiles` itself needs to read `profiles`.

```sql
create or replace function public.current_role_name()
returns public.user_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select role in ('admin','lgu') from public.profiles where id = auth.uid()),
    false
  );
$$;
```

## 1. The four policy shapes

Every table uses one of these. Learn them once.

### Shape A — public read, staff write (reference + content)

Used by `categories`, `municipalities`, `barangays`, `places`, `events`, `announcements`.

```sql
alter table events enable row level security;

-- Guests and everyone else read published, non-archived events.
create policy "events read published"
on events for select
to anon, authenticated
using (
  (status = 'published' and (ends_at is null or ends_at > now() - interval '30 days'))
  or is_staff()
);

-- Only staff insert.
create policy "events insert staff"
on events for insert
to authenticated
with check (is_staff() and created_by = auth.uid());

-- Only staff update, and only staff-owned or any (staff can edit any event).
create policy "events update staff"
on events for update
to authenticated
using (is_staff())
with check (is_staff());

-- Only staff delete. Prefer archiving (FR-28) over this.
create policy "events delete staff"
on events for delete
to authenticated
using (is_staff());
```

> **Why `to anon` matters.** If you forget `anon`, guests get zero rows and the app looks
> broken to the panel while working perfectly on your logged-in phone. This is the single
> most common RLS failure in this project.

### Shape B — own rows only (user content)

Used by `bookmarks`, `attendance`, `likes`, `notifications`.

```sql
alter table bookmarks enable row level security;

create policy "bookmarks read own"
on bookmarks for select to authenticated
using (user_id = auth.uid());

create policy "bookmarks insert own"
on bookmarks for insert to authenticated
with check (user_id = auth.uid());

create policy "bookmarks delete own"
on bookmarks for delete to authenticated
using (user_id = auth.uid());
```

Note there is **no `update` policy** — a bookmark is a toggle (insert/delete), so update is
denied by default. That is intentional.

### Shape C — public read, own write, staff moderate

Used by `comments`, `reviews`.

```sql
alter table comments enable row level security;

-- Anyone can read visible comments (guests included).
create policy "comments read visible"
on comments for select to anon, authenticated
using (not is_hidden or is_staff() or user_id = auth.uid());

create policy "comments insert own"
on comments for insert to authenticated
with check (user_id = auth.uid() and not is_hidden);

create policy "comments update own or staff"
on comments for update to authenticated
using (user_id = auth.uid() or is_staff())
with check (user_id = auth.uid() or is_staff());
-- staff use this path to set is_hidden = true (soft moderation, AD-10)

create policy "comments delete own or staff"
on comments for delete to authenticated
using (user_id = auth.uid() or is_staff());
```

### Shape D — own profile only

```sql
alter table profiles enable row level security;

create policy "profiles read own or staff"
on profiles for select to authenticated
using (id = auth.uid() or is_staff());

create policy "profiles update own"
on profiles for update to authenticated
using (id = auth.uid())
with check (
  id = auth.uid()
  -- role is intentionally NOT writable from the client:
  and role = (select role from profiles p where p.id = auth.uid())
);

create policy "profiles insert self"
on profiles for insert to authenticated
with check (id = auth.uid() and role = 'resident');
```

## 2. Statistical tables

```sql
alter table event_views enable row level security;

-- Anyone (including guests) may log a view.
create policy "views insert anyone"
on event_views for insert to anon, authenticated
with check (true);

-- Only staff read the log.
create policy "views read staff"
on event_views for select to authenticated
using (is_staff());
```

## 3. Storage policies

```sql
-- bucket: event-images
insert into storage.buckets (id, name, public)
values ('event-images', 'event-images', true)
on conflict do nothing;

create policy "event images public read"
on storage.objects for select
using (bucket_id = 'event-images');

create policy "event images staff write"
on storage.objects for insert to authenticated
with check (bucket_id = 'event-images' and is_staff());
```

## 4. Verification checklist

Run this after **every** migration. It takes two minutes and prevents the worst demo failure.

```sql
-- 1. Is RLS on everywhere?
select tablename, rowsecurity
from pg_tables
where schemaname = 'public' and rowsecurity = false;
-- Expected: zero rows.

-- 2. Does every table have at least one policy?
select t.tablename, count(p.policyname) as policies
from pg_tables t
left join pg_policies p on p.tablename = t.tablename
where t.schemaname = 'public'
group by t.tablename
having count(p.policyname) = 0;
-- Expected: zero rows.
```

Then verify **as the anon role**, not as the owner:

```sql
set role anon;
select count(*) from events;                 -- must be > 0 when published events exist
select count(*) from comments where not is_hidden;  -- must be readable
insert into events (title) values ('nope');  -- must FAIL
reset role;
```

If step 4 succeeds, your policies are wrong. This is the test that catches privilege bugs.

## 5. Anti-patterns

| Don't | Why |
|---|---|
| `using (true)` on a write policy | Any authenticated user can write anything |
| Checking `is_staff()` in the client only | The client is attacker-controlled; RLS is the security boundary |
| Letting the client set `profiles.role` | Privilege escalation to admin |
| Deleting moderated comments | Breaks FR-31 report integrity (AD-10) |
| `security invoker` views without thought | Views inherit base-table RLS only with `security_invoker = true` |
| Forgetting `to anon` on public reads | Guests see an empty app — the classic capstone demo failure |
