---
name: RZL Flutter
description: Load when creating or modifying any screen, widget, provider, repository, model, route, or theme in the RZL Flutter app. Defines the locked stack, feature-first folder structure, the four-state screen pattern, naming rules, and error handling.
---

# RZL — Flutter Conventions

Locked stack: **Riverpod + go_router**, plain immutable models, no code generation.
Do not introduce a second state management or routing solution. Changing the stack
requires a new `AD-` row in `docs/spec/decisions.md`.

## Folder structure

```
lib/
├── main.dart                       # bootstrap only: init Supabase, runApp
├── app/
│   ├── app.dart                    # MaterialApp.router, themes
│   ├── router.dart                 # go_router config + auth redirect guard
│   └── theme/
│       ├── app_theme.dart          # light + dark ThemeData
│       └── app_colors.dart
├── core/
│   ├── config/env.dart             # String.fromEnvironment values
│   ├── supabase/supabase_client.dart
│   ├── error/failure.dart          # sealed Failure types
│   ├── error/error_mapper.dart     # PostgrestException -> Failure
│   ├── error/message_of.dart       # Failure -> user-facing string
│   ├── format/date_formats.dart    # schedule + relative-day formatting
│   └── widgets/                    # shared: empty_state, error_view, loading_skeleton
└── features/
    └── events/
        ├── data/
        │   └── event_repository_impl.dart   # the only file that talks to Supabase
        ├── domain/
        │   ├── event.dart           # immutable entity + fromJson
        │   ├── event_filter.dart    # provider argument; needs == / hashCode
        │   └── event_repository.dart # abstract contract
        └── presentation/
            ├── screens/event_feed_screen.dart
            ├── widgets/event_card.dart
            └── providers/events_providers.dart
```

Rules:
- **One feature = one folder.** If a file is used by two features, it belongs in `core/`.
- `domain/` imports nothing from the app. No Flutter, no Supabase.
- `data/` imports `domain/` + `package:supabase_flutter`.
- `presentation/providers/` may import `data/` — it is the one place that constructs the
  concrete repository and injects it.
- `presentation/screens/` and `presentation/widgets/` import `domain/` + `providers/` only.
  They must never import `data/` or touch `Supabase.instance`.
- `main.dart` stays under 40 lines. Bootstrap only.

## The four-state rule

Every screen that reads remote data renders exactly four states. No hand-rolled
`isLoading` booleans.

```dart
class EventFeedScreen extends ConsumerWidget {
  const EventFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventFeedProvider);
    return events.when(
      loading: () => const EventFeedSkeleton(),
      error: (err, _) => ErrorView(
        message: (err as Failure).userMessage,
        onRetry: () => ref.invalidate(eventFeedProvider),
      ),
      data: (items) => items.isEmpty
          ? const EmptyState(
              title: 'No events found',
              message: 'Try a different municipality or date range.',
              icon: Icons.event_busy,
            )
          : EventList(events: items),
    );
  }
}
```

- `empty` is not `error`. An empty list is a success with zero rows.
- `error` always has a retry. Never a dead end.
- Never show a bare `CircularProgressIndicator` that can hang forever — pair it with a
  timeout or a skeleton.

## Providers

```dart
// presentation/providers/event_feed_provider.dart
@riverpod
Future<List<Event>> eventFeed(Ref ref, {EventFilter? filter}) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.fetchPublished(filter: filter ?? const EventFilter());
}
```

- Providers return `Future<...>`; screens consume `AsyncValue`. Do not cache alongside the
  provider.
- Filtering is **provider arguments**, not local widget state. Filters therefore survive
  navigation.
- Invalidate after a mutation: `ref.invalidate(eventFeedProvider)` — do not manually
  splice lists.

## Repository contract

```dart
// domain/event_repository.dart
abstract interface class EventRepository {
  Future<List<Event>> fetchPublished({EventFilter filter = const EventFilter()});
  Future<Event> fetchById(String id);
  Future<List<Event>> searchSemantic(String query);
  Future<void> create(EventDraft draft);
  Future<void> update(String id, EventDraft draft);
  Future<void> archive(String id);
}
```

Two implementations worth naming up front:
`SupabaseEventRepository` and `FakeEventRepository` (for widget tests and for demoing
without network). The fake is not decoration — it is your defense-day fallback.

## Models

Entities are **plain immutable classes** — no `freezed`, no `build_runner` (AD-13).

Why: a five-person team shipping weekly cannot afford a codegen step that silently goes
stale, and generated `.g.dart` files are a steady source of "it compiles on my machine".
The boilerplate we give up is one hand-written `copyWith`; the build-loop cost we avoid is
larger.

Rules:
- `const` constructor, `final` fields, no setters.
- Write `fromJson` by hand, in the entity, next to the constructor. Read the snake_case
  keys explicitly (`json['starts_at']`). Never rename a Postgres column for Dart's benefit.
- Write `copyWith` only when something needs it. Do not add it speculatively.
- Add `==` / `hashCode` only to objects used as provider arguments (`EventFilter`) — that
  equality is what makes Riverpod family caching work.
- Enums map with an explicit `switch` plus a fallback, so an unexpected database value
  degrades instead of crashing the screen.
- **Never** put Flutter widgets or `BuildContext` in a model.
- Dates: parse `timestamptz` to `DateTime`, and convert to local time at the display
  boundary only.

## Providers

- One file per feature: `presentation/providers/events_providers.dart`.
- Use `Notifier` / `NotifierProvider`. `StateProvider` and `StateNotifierProvider` are
  legacy in Riverpod 3 and live behind a separate import — do not use them in new code.
- **Disable Riverpod 3's automatic retry.** Version 3 retries a failed provider with
  exponential backoff for as long as it has a listener. That fights the "Try again" button,
  makes the error state flicker, and makes widget tests non-deterministic (one widget test
  counted 11 fetch attempts before the user tapped anything). Every UI-facing
  `FutureProvider` passes `retry: (count, error) => null`.

## Routing

`go_router` with a single `redirect` guard:

```dart
redirect: (context, state) {
  final loggedIn = ref.read(authStateProvider).valueOrNull != null;
  final isProtected = state.matchedLocation.startsWith('/saved') ||
      state.matchedLocation.startsWith('/profile') ||
      state.matchedLocation.startsWith('/admin');
  if (isProtected && !loggedIn) return '/login?from=${state.uri}';
  return null;
}
```

- The event feed, event detail, and search routes are **public**. Never add them to
  `isProtected`.
- Admin routes check the role, but the router guard is convenience — **RLS is the security
  boundary**. Both must deny.
- Deep link format: `/events/:id` so an event can be shared as a URL.

## Naming

| Kind | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `event_feed_screen.dart` |
| Classes | `PascalCase` | `EventFeedScreen` |
| Providers | `camelCase`, no `Provider` suffix | `eventFeed`, `authState` |
| Screens | `*Screen` | `EventDetailScreen` |
| Reusable widgets | `*Card`, `*Tile`, `*Sheet`, `EmptyState`, `ErrorView` | `EventCard` |
| Booleans | `is*` / `has*` | `isBookmarked`, `hasEnded` |

## Theme

- One `AppTheme.light` and one `AppTheme.dark` built from the same `ColorScheme.fromSeed`.
- Colours and text styles come from `Theme.of(context)`. **No hardcoded `Color(0xFF…)` in a
  widget.**
- Dark mode follows the OS via `themeMode`, with an explicit user override persisted on
  `profiles.dark_mode` (null = follow OS).
- Body text must meet 4.5:1 contrast in both themes (TC-048).

## Accessibility and small screens

- Every icon-only button has a `tooltip` and a `semanticLabel`.
- Minimum tap target 48×48.
- Test at 360×640 logical pixels. Use `SingleChildScrollView` or `ListView` — never a
  fixed-height `Column` that can overflow (TC-084).
- Respect `MediaQuery.textScaler` — do not hardcode font sizes smaller than 12.

## Before reporting done

```bash
flutter analyze          # must be clean
dart format .            # must be applied
```

Then confirm in the response: which `FR-` this implements, which `TC-` covers it, and that
all four states are handled. See `AGENTS.md` §5.
