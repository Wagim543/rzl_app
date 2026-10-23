import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rzl_app/core/error/failure.dart';
import 'package:rzl_app/core/widgets/empty_state.dart';
import 'package:rzl_app/core/widgets/error_view.dart';
import 'package:rzl_app/features/events/presentation/providers/events_providers.dart';
import 'package:rzl_app/features/events/domain/event.dart';
import 'package:rzl_app/features/events/domain/municipality.dart';
import 'package:rzl_app/features/events/presentation/screens/event_feed_screen.dart';
import 'package:rzl_app/features/events/presentation/widgets/event_card.dart';

import '../helpers/fake_event_repository.dart';

Widget _harness(FakeEventRepository repository) {
  return ProviderScope(
    overrides: [eventRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: EventFeedScreen()),
  );
}

void main() {
  group('EventFeedScreen - the four states', () {
    testWidgets('renders a card per event', (tester) async {
      final repository = FakeEventRepository(
        events: <Event>[
          buildEvent(id: 'evt-1', title: 'Fiesta'),
          buildEvent(id: 'evt-2', title: 'Cleanup Drive'),
          buildEvent(id: 'evt-3', title: 'Health Drive'),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(find.byType(EventCard), findsNWidgets(3));
      expect(find.text('Fiesta'), findsOneWidget);
      expect(find.text('Cleanup Drive'), findsOneWidget);
    });

    testWidgets('shows the empty state, not an error, for zero rows', (
      tester,
    ) async {
      final repository = FakeEventRepository();

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No events yet'), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('shows the error state with a retry affordance', (
      tester,
    ) async {
      final repository = FakeEventRepository(error: const NetworkFailure());

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text(NetworkFailure().userMessage), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('retry re-invokes the repository', (tester) async {
      final repository = FakeEventRepository(error: const NetworkFailure());

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();
      expect(repository.fetchPublishedCalls, 1);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(repository.fetchPublishedCalls, 2);
    });
  });

  group('EventFeedScreen - filtering (FR-02)', () {
    testWidgets('selecting a municipality refetches with that filter', (
      tester,
    ) async {
      final repository = FakeEventRepository(
        events: <Event>[buildEvent()],
        municipalities: const <Municipality>[
          Municipality(id: 'muni-binangonan', name: 'Binangonan'),
          Municipality(id: 'muni-tanay', name: 'Tanay'),
        ],
      );

      await tester.pumpWidget(_harness(repository));
      await tester.pumpAndSettle();

      expect(repository.lastFilter?.municipalityId, isNull);

      await tester.tap(find.text('Binangonan'));
      await tester.pumpAndSettle();

      expect(repository.lastFilter?.municipalityId, 'muni-binangonan');
    });
  });
}
