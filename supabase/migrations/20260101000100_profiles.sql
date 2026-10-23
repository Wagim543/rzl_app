-- 0002 — Profiles
--
-- One row per authenticated user, created automatically on signup.
-- `role` is never writable from the client: promotion to admin/lgu happens with
-- a service-role script. See docs/design/rls-policies.md Shape D.

create type public.user_role as enum ('resident', 'tourist', 'admin', 'lgu');

create table public.profiles (
  id               uuid primary key references auth.users(id) on delete cascade,
  full_name        text,
  role             public.user_role not null default 'resident',
  municipality_id  uuid references public.municipalities(id) on delete set null,
  barangay_id      uuid references public.barangays(id) on delete set null,
  interests        text[] not null default '{}',
  avatar_url       text,
  dark_mode        boolean,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- Shared updated_at trigger, reused by every table that has the column.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- Create the profile row on signup. security definer so the insert succeeds
-- before the user has any session-scoped privileges of their own.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    nullif(new.raw_user_meta_data->>'full_name', ''),
    'resident'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
