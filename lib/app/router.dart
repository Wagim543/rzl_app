import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/empty_state.dart';
import '../features/events/presentation/screens/event_detail_screen.dart';
import '../features/events/presentation/screens/event_feed_screen.dart';

/// Route paths, referenced by name so a typo cannot silently create a 404.
abstract final class AppRoutes {
  const AppRoutes._();

  static const String eventFeed = '/';
  static const String eventDetailName = 'eventDetail';

  static String eventDetail(String id) => '/events/$id';
}

/// Prefixes that require a signed-in user.
///
/// Intentionally empty in Milestone 1: every route is guest-accessible, which is
/// a hard product requirement (FR-01, FR-06). Milestone 2 adds `/saved`,
/// `/profile` and `/admin`.
const List<String> _protectedPrefixes = <String>[];

/// Router for the guest-browsing slice.
///
/// The redirect is written now, and activated in Milestone 2 when
/// `authStateProvider` exists. Keeping the hook in place means adding auth later
/// is a one-line change rather than a refactor.
GoRouter createRouter({String? Function()? currentUserId}) {
  return GoRouter(
    initialLocation: AppRoutes.eventFeed,
    redirect: (context, state) {
      if (_protectedPrefixes.isEmpty) return null;

      final isProtected = _protectedPrefixes.any(
        (prefix) => state.matchedLocation.startsWith(prefix),
      );
      if (!isProtected) return null;

      final signedIn = currentUserId?.call() != null;
      if (signedIn) return null;

      return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: EmptyState(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: state.uri.toString(),
        actionLabel: 'Back to events',
        onAction: () => context.go(AppRoutes.eventFeed),
      ),
    ),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.eventFeed,
        builder: (context, state) => const EventFeedScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        name: AppRoutes.eventDetailName,
        builder: (context, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
    ],
  );
}
