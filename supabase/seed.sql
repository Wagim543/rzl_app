-- RZL seed data
-- Applied by `supabase db reset` or `supabase db push --include-seed`.
-- Development data only. Never run against production.

-- ─── Municipalities ─────────────────────────────────────────────────────────
insert into public.municipalities (name, psgc_code) values
  ('Angono',               '0405801000'),
  ('Antipolo',             '0405804000'),
  ('Baras',                '0405802000'),
  ('Binangonan',           '0405803000'),
  ('Cainta',               '0405805000'),
  ('Cardona',              '0405806000'),
  ('Jala-jala',            '0405807000'),
  ('Morong',               '0405808000'),
  ('Pililla',              '0405809000'),
  ('Rodriguez',            '0405810000'),
  ('San Mateo',            '0405811000'),
  ('Tanay',                '0405812000'),
  ('Taytay',               '0405813000'),
  ('Teresa',               '0405814000')
on conflict (name) do nothing;

-- ─── Binangonan barangays ───────────────────────────────────────────────────
insert into public.barangays (municipality_id, name)
select m.id, b.name
from public.municipalities m
cross join (values
  ('Batingan'), ('Bilibiran'), ('Buhangin'), ('Calumpang'),
  ('Darangan'), ('Kalayaan'), ('Layunan'), ('Libid'),
  ('Mahabang Parang'), ('Malakaban'), ('Pag-asa'), ('Palangoy'),
  ('Pantok'), ('Pila-pila'), ('Poblacion'), ('Sapang'),
  ('Tagpos'), ('Tatala'), ('Wawa')
) as b(name)
where m.name = 'Binangonan'
on conflict (municipality_id, name) do nothing;

-- ─── Categories ─────────────────────────────────────────────────────────────
insert into public.categories (name, slug, icon, sort_order) values
  ('Festival',    'festival',    'celebration',        1),
  ('Cultural',    'cultural',    'theater_comedy',     2),
  ('Sports',      'sports',      'sports_basketball',  3),
  ('Health',      'health',      'local_hospital',     4),
  ('Livelihood',  'livelihood',  'storefront',         5),
  ('Environment', 'environment', 'eco',                6),
  ('Education',   'education',   'school',             7),
  ('Government',  'government',  'account_balance',    8),
  ('Religious',   'religious',   'church',             9),
  ('Music',       'music',       'music_note',        10)
on conflict (slug) do nothing;

-- ─── Demo events ────────────────────────────────────────────────────────────
-- Dates are relative to `now()` so the feed is never stale during a demo.
-- `where not exists` keeps the seed re-runnable without a unique constraint.
insert into public.events (
  title, description, summary,
  category_id, municipality_id, barangay_id,
  venue, address, latitude, longitude,
  starts_at, ends_at, is_free, cover_image_url, status, published_at
)
select
  v.title,
  v.description,
  v.summary,
  c.id,
  m.id,
  b.id,
  v.venue,
  v.address,
  v.latitude::double precision,
  v.longitude::double precision,
  now() + v.start_offset,
  now() + v.end_offset,
  true,
  v.cover_image_url,
  'published'::public.event_status,
  now()
from (values
  (
    'Binangonan Fiesta 2027',
    'festival',
    'Poblacion',
    'The annual town fiesta brings street dancing, a food fair, and evening programmes to the municipal grounds. Barangay contingents parade in traditional costume, and local vendors operate stalls throughout the week.',
    'A week-long town fiesta with street dancing, a food fair, and evening shows at the municipal grounds.',
    'Binangonan Municipal Grounds',
    'Poblacion, Binangonan, Rizal',
    14.4611, 121.1925,
    interval '7 days', interval '9 days',
    'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=1200&q=80'
  ),
  (
    'Laguna de Bay Coastal Cleanup',
    'environment',
    'Bilibiran',
    'Volunteers from barangay and youth organisations gather along the Bilibiran shoreline to collect plastic waste. Gloves, sacks, and refreshments are provided. Participants are asked to bring their own reusable water containers.',
    'A community coastal cleanup along the Bilibiran shoreline of Laguna de Bay.',
    'Bilibiran Shoreline',
    'Bilibiran, Binangonan, Rizal',
    14.4741, 121.1802,
    interval '3 days', interval '3 days 4 hours',
    'https://images.unsplash.com/photo-1618477388954-7852f32655ec?w=1200&q=80'
  ),
  (
    'Barangay Health Drive',
    'health',
    'Kalayaan',
    'Free medical check-up, blood pressure and blood sugar screening, and medicine giveaways for residents. Senior citizens and children are prioritised. Bring a valid ID and your barangay certificate.',
    'Free check-up, health screening, and medicine giveaways for Kalayaan residents.',
    'Kalayaan Covered Court',
    'Kalayaan, Binangonan, Rizal',
    14.4585, 121.1901,
    interval '5 days', interval '5 days 6 hours',
    'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=1200&q=80'
  ),
  (
    'Rizal Youth Basketball League',
    'sports',
    'Tagpos',
    'Opening day of the inter-barangay youth basketball tournament. Twelve teams compete across a three-week schedule. Free admission; spectators are encouraged to bring their own seating.',
    'Inter-barangay youth basketball tournament opening day at the Tagpos Sports Complex.',
    'Tagpos Sports Complex',
    'Tagpos, Binangonan, Rizal',
    14.4702, 121.1853,
    interval '12 days', interval '12 days 3 hours',
    'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200&q=80'
  ),
  (
    'Livelihood Skills Workshop',
    'livelihood',
    'Batingan',
    'A free one-day workshop on food processing and small business bookkeeping, run with the municipal livelihood office. Limited to 40 participants; registration is on a first-come basis at the barangay hall.',
    'Free training on food processing and small business bookkeeping, limited to 40 participants.',
    'Batingan Barangay Hall',
    'Batingan, Binangonan, Rizal',
    14.4651, 121.1880,
    interval '20 days', interval '20 days 5 hours',
    'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1200&q=80'
  ),
  (
    'Cultural Night at the Plaza',
    'cultural',
    'Poblacion',
    'An open-air evening of folk dance, rondalla music, and performances by local artists. The programme runs from sunset until late and is free to the public.',
    'Folk dance, rondalla, and local artists in an open-air programme at Binangonan Plaza.',
    'Binangonan Plaza',
    'Poblacion, Binangonan, Rizal',
    14.4600, 121.1929,
    interval '15 days', interval '15 days 4 hours',
    'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=1200&q=80'
  )
) as v(
  title, category_slug, barangay_name,
  description, summary,
  venue, address, latitude, longitude,
  start_offset, end_offset, cover_image_url
)
join public.categories c on c.slug = v.category_slug
join public.municipalities m on m.name = 'Binangonan'
left join public.barangays b
  on b.municipality_id = m.id and b.name = v.barangay_name
where not exists (
  select 1 from public.events e where e.title = v.title
);
