-- 0003 — Events
--
-- The core table. See docs/design/schema.md §3.
--
-- Note: created_by is nullable on purpose. Seeded and migrated LGU content has
-- no natural author, and an event should survive the deletion of the admin who
-- entered it (engagement history references the event, not the admin).

create type public.event_status as enum ('draft', 'published', 'cancelled', 'archived');

create table public.events (
  id                uuid primary key default gen_random_uuid(),
  title             text not null,
  description       text not null,
  summary           text,
  summary_generated_at timestamptz,
  category_id       uuid not null references public.categories(id) on delete restrict,
  municipality_id   uuid not null references public.municipalities(id) on delete restrict,
  barangay_id       uuid references public.barangays(id) on delete set null,
  venue             text not null,
  address           text,
  latitude          double precision,
  longitude         double precision,
  starts_at         timestamptz not null,
  ends_at           timestamptz not null,
  is_free           boolean not null default true,
  price             numeric(10, 2),
  capacity          int,
  cover_image_url   text,
  status            public.event_status not null default 'draft',
  published_at      timestamptz,
  created_by        uuid references public.profiles(id) on delete set null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  constraint events_time_order check (ends_at > starts_at),
  constraint events_price_non_negative check (price is null or price >= 0),
  constraint events_capacity_positive check (capacity is null or capacity > 0)
);

create index events_status_starts_idx on public.events (status, starts_at desc);
create index events_municipality_idx on public.events (municipality_id, starts_at desc);
create index events_barangay_idx on public.events (barangay_id, starts_at desc);
create index events_category_idx on public.events (category_id, starts_at desc);

create trigger events_set_updated_at
before update on public.events
for each row execute function public.set_updated_at();
