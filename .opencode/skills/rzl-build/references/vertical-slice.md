# RZL — Vertical Slice 1: Guest Event Browsing

The first thing that must work. Everything else is repetition of this pattern.

**Definition of done:** a person who has never logged in opens the app, sees real events from
Supabase, filters by municipality, opens an event, and reads it. No login wall at any point.

**Proves:** auth-free RLS (`to anon`), the repository pattern, all four UI states, routing.

---

## Files

```
lib/core/config/env.dart
lib/core/supabase/supabase_client.dart
lib/core/error/failure.dart
lib/core/error/error_mapper.dart
lib/core/widgets/empty_state.dart
lib/core/widgets/error_view.dart
lib/core/widgets/loading_skeleton.dart

lib/app/app.dart
lib/app/router.dart
lib/app/theme/app_theme.dart

lib/features/events/domain/event.dart
lib/features/events/domain/event_filter.dart
lib/features/events/domain/event_repository.dart
lib/features/events/domain/municipality.dart

lib/features/events/data/event_repository_impl.dart
lib/features/events/data/providers.dart

lib/features/events/presentation/screens/event_feed_screen.dart
lib/features/events/presentation/screens/event_detail_screen.dart
lib/features/events/presentation/widgets/event_card.dart
lib/features/events/presentation/widgets/municipality_filter_bar.dart

lib/main.dart                              (rewritten)

supabase/migrations/20260101000000_reference_tables.sql
supabase/migrations/20260101000100_profiles.sql
supabase/migrations/20260101000200_events.sql
supabase/migrations/20260101000300_rls_core.sql
supabase/seed.sql

test/helpers/fake_event_repository.dart
test/widget/event_feed_screen_test.dart
```

## Data flow

```
EventFeedScreen
   └─ watch(eventFeedProvider(filter))
        └─ eventRepositoryProvider
             └─ SupabaseEventRepository
                  └─ supabase.from('events').select(...).eq('status','published')
                       └─ RLS: events read published (to anon, authenticated)
```

Four layers, each testable in isolation. The screen never touches Supabase; the repository
never touches widgets.

## The query

```dart
client
  .from('events')
  .select(
    'id, title, description, summary, venue, address, '
    'starts_at, ends_at, cover_image_url, status, capacity, is_free, '
    'categories(name, slug), '
    'municipalities(id, name), '
    'barangays(name)',
  )
  .eq('status', 'published')
  .gte('ends_at', DateTime.now().toUtc().toIso8601String())
  .order('starts_at', ascending: true)
  .limit(50);
```

Notes:
- **Never `select('*')`** — a later migration adds `embedding vector(1536)`, and `*` would
  pull 6 KB of floats per row into every list response.
- `.gte('ends_at', now)` hides past events. `ends_at` not `starts_at`, so an event happening
  right now stays visible.
- Embedded resources (`categories(name)`) return nested maps — the `fromJson` must read
  `json['categories']?['name']`, not a flat column.
- `limit(50)` for the slice; pagination is FR-01 follow-up work.

## The four states

```dart
ref.watch(eventFeedProvider(filter)).when(
  loading: () => const EventFeedSkeleton(),          // not a bare spinner
  error: (e, _) => ErrorView(
    message: (e as Failure).userMessage,
    onRetry: () => ref.invalidate(eventFeedProvider(filter)),
  ),
  data: (events) => events.isEmpty
      ? const EmptyState(
          icon: Icons.event_busy,
          title: 'No events found',
          message: 'Try a different municipality or date.',
        )
      : EventList(events: events),
);
```

`empty` is a **success** with zero rows, not an error. Do not merge them.

## Schema this slice needs

Minimum tables: `municipalities`, `barangays`, `categories`, `profiles`, `events`.
Everything else (`bookmarks`, `comments`, `reviews`, `places`, `notifications`) belongs to
later milestones — adding them now means untested tables with no policies, which is how
security holes ship.

## Migration order

```
20260101000000_reference_tables.sql    municipalities, barangays, categories
20260101000100_profiles.sql            profiles + handle_new_user trigger
20260101000200_events.sql              events + indexes
20260101000300_rls_core.sql            enable RLS + policies for all of the above
```

`20260101000300_rls_core.sql` is a separate file on purpose: it is the one file a reviewer
should read to understand access control. Do not bury policies inside table definitions.

## Verifying the guest path

The whole slice can appear to work while being broken for guests, because a logged-in
developer session bypasses some mistakes. Verify as `anon`:

```sql
set role anon;
select id, title from events limit 5;      -- must return rows
insert into events (title) values ('x');   -- must fail
reset role;
```

If the `select` returns zero rows but the table is populated, the policy is missing `to anon`.

## Tests

| Test | Asserts |
|---|---|
| feed renders events | 3 events in, 3 `EventCard`s out |
| feed shows empty state | empty list → "No events found", no spinner |
| feed shows error + retry | throwing repo → `ErrorView`, retry re-invokes |
| card shows municipality | filter data flows to the chip label |

Use `FakeEventRepository` with `ProviderScope(overrides: [...])`. No network in tests.

## Common mistakes in this slice

| Mistake | Symptom |
|---|---|
| Forgot `to anon` | Guests see an empty feed; developers see it fine |
| `select('*')` | Feed slow once embeddings exist |
| Filtering past events on `starts_at` | An ongoing event disappears mid-way |
| Screen calls `Supabase.instance` | Untestable, and breaks the moment auth is added |
| Merging empty and error | Panel sees "error" on a valid empty result |
| Building the detail screen before the list | Nothing to navigate to; wasted work |
