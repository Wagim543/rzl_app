-- RZL — seed data
-- Applied by `supabase db reset`. Never run in production.
-- Contents: all Rizal municipalities, Binangonan barangays, categories,
-- and a small realistic Binangonan event set for development and UAT.

-- ─── Municipalities (13 municipalities + Antipolo) ───────────────────────────
insert into municipalities (name, psgc_code) values
  ('Antipolo',            '0405804000'),
  ('Angono',              '0405801000'),
  ('Baras',               '0405802000'),
  ('Binangonan',          '0405803000'),
  ('Cainta',              '0405805000'),
  ('Cardona',             '0405806000'),
  ('Jala-jala',           '0405807000'),
  ('Morong',              '0405808000'),
  ('Pililla',             '0405809000'),
  ('Rodriguez (Montalban)','0405810000'),
  ('San Mateo',           '0405811000'),
  ('Tanay',               '0405812000'),
  ('Taytay',              '0405813000'),
  ('Teresa',              '0405814000')
on conflict (name) do nothing;

-- ─── Binangonan barangays (subset used in the study) ────────────────────────
insert into barangays (municipality_id, name)
select m.id, b.name
from municipalities m
cross join (values
  ('Poblacion'), ('Kalayaan'), ('Batingan'), ('Bilibiran'),
  ('Buhangin'), ('Darangan'), ('Layunan'), ('Libid'),
  ('Mahabang Parang'), ('Malakaban'), ('Pag-asa'), ('Palangoy'),
  ('Pantok'), ('Pila-pila'), ('Pinugay'), ('Sapang'),
  ('Tagpos'), ('Tatala'), ('Wawa')
) as b(name)
where m.name = 'Binangonan'
on conflict (municipality_id, name) do nothing;

-- ─── Categories ─────────────────────────────────────────────────────────────
insert into categories (name, slug, icon, sort_order) values
  ('Festival',    'festival',    'celebration',      1),
  ('Cultural',    'cultural',    'theater_comedy',   2),
  ('Sports',      'sports',      'sports_basketball',3),
  ('Health',      'health',      'local_hospital',   4),
  ('Livelihood',  'livelihood',  'storefront',       5),
  ('Environment', 'environment', 'eco',              6),
  ('Education',   'education',   'school',           7),
  ('Government',  'government',  'account_balance',  8),
  ('Religious',   'religious',   'church',           9),
  ('Music',       'music',       'music_note',      10)
on conflict (slug) do nothing;

-- ─── Places (nearby attractions / restaurants / hotels) ─────────────────────
-- Seeded deliberately: no live Places API at runtime (AD-08, NG-B1).
insert into places (name, type, municipality_id, address, latitude, longitude, description)
select p.name, p.type::place_type, m.id, p.address, p.lat, p.lng, p.descr
from municipalities m
cross join (values
  ('Binangonan Municipal Hall', 'attraction', 'Poblacion, Binangonan', 14.4611, 121.1925, 'Seat of the municipal government.'),
  ('Binangonan Church (Santa Ursula)', 'attraction', 'Poblacion, Binangonan', 14.4598, 121.1936, 'Historic parish church and pilgrimage site.'),
  ('Layunan Viewing Deck', 'attraction', 'Layunan, Binangonan', 14.4487, 121.2041, 'Overlook of the eastern shore of Laguna de Bay.'),
  ('Talim Island Pier', 'attraction', 'Layunan, Binangonan', 14.4429, 121.1887, 'Jump-off to Talim Island barangays.'),
  ('Bonifacio Ave Eateries', 'restaurant', 'Poblacion, Binangonan', 14.4606, 121.1918, 'Cluster of local eateries along the main road.'),
  ('Kainan sa Bilibiran', 'restaurant', 'Bilibiran, Binangonan', 14.4741, 121.1802, 'Local seafood and home-style cooking.'),
  ('Batingan Coffee Corner', 'restaurant', 'Batingan, Binangonan', 14.4651, 121.1880, 'Small cafe near the barangay hall.'),
  ('Binangonan Lakeside Hotel', 'hotel', 'Poblacion, Binangonan', 14.4604, 121.1931, 'Mid-range hotel walking distance to the pier.'),
  ('Sapang Garden Inn', 'hotel', 'Sapang, Binangonan', 14.4528, 121.1987, 'Quiet inn with parking.'),
  ('Talim Island Guest House', 'hotel', 'Layunan, Binangonan', 14.4440, 121.1879, 'Budget lodging near the boat landing.')
) as p(name, type, address, lat, lng, descr)
where m.name = 'Binangonan';

-- ─── Demo events ────────────────────────────────────────────────────────────
-- created_by uses the first admin profile if one exists; skip when none.
insert into events (
  title, description, category_id, municipality_id, barangay_id,
  venue, address, latitude, longitude, starts_at, ends_at,
  is_free, cover_image_url, status, published_at, created_by
)
select
  e.title, e.descr,
  (select id from categories where slug = e.cat),
  m.id,
  (select b.id from barangays b where b.municipality_id = m.id and b.name = e.brgy),
  e.venue, e.addr, e.lat, e.lng,
  now() :: timestamptz + e.start_offset, now() :: timestamptz + e.end_offset,
  true, e.img, 'published', now(), p.id
from municipalities m
cross join (values
  ('Binangonan Fiesta 2027', 'festival', 'Poblacion', 'Binangonan Municipal Grounds', 'Poblacion, Binangonan', 14.4611, 121.1925, interval '7 days', interval '9 days', 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=1200', 'Annual town fiesta with street dancing, a food fair, and evening shows.'),
  ('Laguna de Bay Coastal Cleanup', 'environment', 'Bilibiran', 'Bilibiran Shoreline', 'Bilibiran, Binangonan', 14.4741, 121.1802, interval '3 days', interval '3 days 4 hours', 'https://images.unsplash.com/photo-1618477388954-7852f32655ec?w=1200', 'Coastal cleanup with volunteers from barangay and youth organisations.'),
  ('Barangay Health Drive', 'health', 'Kalayaan', 'Kalayaan Covered Court', 'Kalayaan, Binangonan', 14.4585, 121.1901, interval '5 days', interval '5 days 6 hours', 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=1200', 'Free check-up, blood pressure screening, and medicine giveaways.'),
  ('Rizal Youth Basketball League', 'sports', 'Tagpos', 'Tagpos Sports Complex', 'Tagpos, Binangonan', 14.4702, 121.1853, interval '12 days', interval '12 days 3 hours', 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=1200', 'Inter-barangay basketball tournament opening day.'),
  ('Livelihood Skills Workshop', 'livelihood', 'Batingan', 'Batingan Barangay Hall', 'Batingan, Binangonan', 14.4651, 121.1880, interval '20 days', interval '20 days 5 hours', 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=1200', 'Free training on food processing and small business bookkeeping.'),
  ('Cultural Night at the Plaza', 'cultural', 'Poblacion', 'Binangonan Plaza', 'Poblacion, Binangonan', 14.4600, 121.1929, interval '15 days', interval '15 days 4 hours', 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=1200', 'Folk dance, rondalla, and local artists in an open-air programme.')
) as e(title, cat, brgy, venue, addr, lat, lng, start_offset, end_offset, img, descr)
where m.name = 'Binangonan'
  and exists (select 1 from profiles p2 where p2.role in ('admin', 'lgu'));
