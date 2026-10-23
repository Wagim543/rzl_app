-- 0004 — Row Level Security (core tables)
--
-- This is the file to read to understand access control. It is separate from
-- the table definitions on purpose: policies are a security surface, not a
-- schema detail.
--
-- Model: guests read published events; authenticated users read the same and
-- write their own rows; staff write events. See docs/spec/roles.md.

-- ─── Helper functions ────────────────────────────────────────────────────────
-- security definer so the function can read profiles without triggering the
-- profiles policy it is used inside (which would recurse).

create or replace function public.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select p.role in ('admin', 'lgu') from public.profiles p where p.id = auth.uid()),
    false
  );
$$;

-- ─── Reference tables: public read, staff write ─────────────────────────────

alter table public.municipalities enable row level security;
alter table public.barangays      enable row level security;
alter table public.categories      enable row level security;

create policy "municipalities read all"
  on public.municipalities for select
  to anon, authenticated
  using (true);

create policy "barangays read all"
  on public.barangays for select
  to anon, authenticated
  using (true);

create policy "categories read all"
  on public.categories for select
  to anon, authenticated
  using (true);

create policy "municipalities write staff"
  on public.municipalities for all
  to authenticated
  using (public.is_staff())
  with check (public.is_staff());

create policy "barangays write staff"
  on public.barangays for all
  to authenticated
  using (public.is_staff())
  with check (public.is_staff());

create policy "categories write staff"
  on public.categories for all
  to authenticated
  using (public.is_staff())
  with check (public.is_staff());

-- ─── Profiles: own row, or staff ────────────────────────────────────────────

alter table public.profiles enable row level security;

create policy "profiles read own or staff"
  on public.profiles for select
  to authenticated
  using (id = auth.uid() or public.is_staff());

create policy "profiles insert self as resident"
  on public.profiles for insert
  to authenticated
  with check (id = auth.uid() and role = 'resident');

-- Role is pinned to its current value: the client can update name, municipality,
-- and dark mode, but cannot promote itself. This is the privilege-escalation
-- check verified by TC-027.
create policy "profiles update own without role change"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (
    id = auth.uid()
    and role = (select p.role from public.profiles p where p.id = auth.uid())
  );

-- ─── Events: public read of published, staff write ──────────────────────────

alter table public.events enable row level security;

-- `to anon` is mandatory. Without it, guests see an empty feed while developers
-- signed in see everything — the classic capstone demo failure (TC-001).
create policy "events read published"
  on public.events for select
  to anon, authenticated
  using (
    (status = 'published' and ends_at > now() - interval '30 days')
    or public.is_staff()
  );

create policy "events insert staff"
  on public.events for insert
  to authenticated
  with check (public.is_staff() and created_by = auth.uid());

create policy "events update staff"
  on public.events for update
  to authenticated
  using (public.is_staff())
  with check (public.is_staff());

create policy "events delete staff"
  on public.events for delete
  to authenticated
  using (public.is_staff());
