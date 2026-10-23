import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/message_of.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../providers/events_providers.dart';
import '../../domain/event.dart';
import '../../domain/event_filter.dart';
import '../widgets/event_card.dart';
import '../widgets/municipality_filter_bar.dart';

/// Guest-accessible event feed (FR-01).
///
/// This screen is the product's front door. It must render for a user who has
/// never signed in, so it never reads auth state.
class EventFeedScreen extends ConsumerWidget {
  const EventFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(currentEventFilterProvider);
    final feed = ref.watch(eventFeedProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('RZL'),
            Text(
              'Events in Rizal',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh events',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(eventFeedProvider(filter)),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const MunicipalityFilterBar(),
          Expanded(
            child: feed.when(
              loading: () => const LoadingSkeleton(),
              error: (error, _) => ErrorView(
                message: messageOf(error),
                onRetry: () => ref.invalidate(eventFeedProvider(filter)),
              ),
              data: (events) => events.isEmpty
                  ? EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: filter.municipalityId == null
                          ? 'No events yet'
                          : 'No events in this municipality',
                      message:
                          'Check back soon, or try a different municipality.',
                      actionLabel: 'Show all municipalities',
                      onAction: filter.municipalityId == null
                          ? null
                          : () => ref
                                .read(selectedMunicipalityProvider.notifier)
                                .clear(),
                    )
                  : _EventList(events: events, filter: filter),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventList extends ConsumerWidget {
  const _EventList({required this.events, required this.filter});

  final List<Event> events;
  final EventFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(eventFeedProvider(filter));
        try {
          await ref.read(eventFeedProvider(filter).future);
        } on Failure {
          // The error state is rendered by the AsyncValue below; swallowing
          // here only stops the pull-to-refresh indicator from hanging.
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => EventCard(event: events[index]),
      ),
    );
  }
}
