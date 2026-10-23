# RZL — Annotated Structure

Starting point for the Phase 1 restructure. Current state: a single `lib/main.dart` with
the default counter app plus a Supabase connectivity check.

## Target tree

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
├── core/
│   ├── config/
│   │   └── env.dart
│   ├── supabase/
│   │   └── supabase_client.dart
│   ├── error/
│   │   ├── failure.dart
│   │   └── error_mapper.dart
│   ├── extensions/
│   │   └── datetime_ext.dart
│   └── widgets/
│       ├── empty_state.dart
│       ├── error_view.dart
│       ├── loading_skeleton.dart
│       └── app_button.dart
└── features/
    ├── auth/
    │   ├── data/auth_repository_impl.dart
    │   ├── domain/auth_repository.dart
    │   └── presentation/
    │       ├── screens/login_screen.dart
    │       ├── screens/register_screen.dart
    │       └── providers/auth_providers.dart
    ├── events/
    │   ├── data/
    │   │   ├── event_dto.dart
    │   │   └── event_repository_impl.dart
    │   ├── domain/
    │   │   ├── event.dart
    │   │   ├── event_filter.dart
    │   │   └── event_repository.dart
    │   └── presentation/
    │       ├── screens/event_feed_screen.dart
    │       ├── screens/event_detail_screen.dart
    │       ├── widgets/event_card.dart
    │       ├── widgets/event_filter_bar.dart
    │       └── providers/event_feed_provider.dart
    ├── engagement/
    │   ├── data/engagement_repository_impl.dart
    │   ├── domain/engagement_repository.dart
    │   └── presentation/providers/engagement_providers.dart
    ├── discovery/
    │   ├── data/discovery_repository_impl.dart
    │   ├── domain/discovery_repository.dart
    │   └── presentation/screens/recommendations_screen.dart
    ├── places/
    │   ├── data/place_repository_impl.dart
    │   └── presentation/widgets/nearby_places_section.dart
    ├── notifications/
    │   └── presentation/screens/notifications_screen.dart
    ├── profile/
    │   └── presentation/screens/profile_screen.dart
    └── admin/
        ├── data/admin_repository_impl.dart
        └── presentation/
            ├── screens/admin_dashboard_screen.dart
            ├── screens/event_editor_screen.dart
            ├── screens/announcement_editor_screen.dart
            ├── screens/engagement_report_screen.dart
            └── providers/admin_providers.dart
```

## `lib/main.dart` — bootstrap only

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/env.dart';
import 'core/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const ProviderScope(child: RzlApp()));
}
```

`Env` values are asserted non-empty at startup with a clear message, because a missing
`--dart-define` at build time is the most common "works on my machine" failure.

## `lib/core/config/env.dart`

```dart
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const embeddingFnUrl = String.fromEnvironment('EMBEDDING_FN_URL');

  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing --dart-define values: ${missing.join(', ')}. '
        'See docs/setup.md.',
      );
    }
  }
}
```

Run with:

```bash
flutter run --dart-define-from-file=env.json
```

`env.json` is gitignored. `env.example.json` is committed with empty values.

## `lib/core/error/failure.dart`

```dart
sealed class Failure implements Exception {
  const Failure(this.userMessage, {this.cause, this.stackTrace});
  final String userMessage;
  final Object? cause;
  final StackTrace? stackTrace;
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.cause, super.stackTrace})
      : super('No connection. Check your network and try again.');
}

final class AuthFailure extends Failure {
  const AuthFailure(super.userMessage, {super.cause, super.stackTrace});
}

final class PermissionFailure extends Failure {
  const PermissionFailure({super.cause, super.stackTrace})
      : super('You do not have permission to do that.');
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.cause, super.stackTrace})
      : super('That item is no longer available.');
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.cause, super.stackTrace})
      : super('Something went wrong. Please try again.');
}
```

Everything thrown from `data/` is mapped to a `Failure` with a **user-facing** message.
Never surface a raw `PostgrestException` string in the UI (TC-082).

## Migration order for Phase 1

Do this in one branch (`chore/phase-1-scaffold`), in this order:

1. Add dependencies: `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`,
   `go_router`, `freezed`, `json_serializable`, `build_runner`,
   `flutter_local_notifications`, `add_2_calendar`, `url_launcher`,
   `shared_preferences`, `intl`. Run `flutter pub get`.
2. Create `core/config/env.dart` and move the Supabase URL/key out of `main.dart`.
3. Create `core/supabase/supabase_client.dart` with `initSupabase()`.
4. Create `app/theme/` with light + dark `ColorScheme.fromSeed`.
5. Create `app/router.dart` with the guest routes only, then add the auth guard.
6. Rewrite `main.dart` to bootstrap only.
7. Delete the counter widget. Keep the Supabase query, but move it into
   `features/events/data/` and drive the feed with it.
8. `flutter analyze` and `dart format .`
9. Commit `env.example.json` and `docs/setup.md`.

**Keep the app runnable after every step.** A scaffolding branch that leaves `main` broken
for two days costs the team more than it saves.

## Testing layout

```
test/
├── unit/
│   ├── event_filter_test.dart
│   └── engagement_rules_test.dart
├── widget/
│   ├── event_feed_screen_test.dart
│   └── event_card_test.dart
└── helpers/
    ├── fake_event_repository.dart
    └── pump_app.dart
```

Widget tests use `FakeEventRepository` — no network in tests, so they run in CI and on any
laptop.
