-- 0001 — Reference tables
--
-- Municipalities, barangays, and categories. Read by every role, written only
-- by migrations and seeds. See docs/design/schema.md §1.

create table public.municipalities (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  psgc_code   text unique,
  created_at  timestamptz not null default now()
);

create table public.barangays (
  id               uuid primary key default gen_random_uuid(),
  municipality_id  uuid not null references public.municipalities(id) on delete cascade,
  name             text not null,
  created_at       timestamptz not null default now(),
  unique (municipality_id, name)
);

create table public.categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null unique,
  slug        text not null unique,
  icon        text,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);

create index barangays_municipality_idx on public.barangays (municipality_id);
