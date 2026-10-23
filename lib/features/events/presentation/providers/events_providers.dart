import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/event_repository_impl.dart';
import '../../domain/event.dart';
import '../../domain/event_filter.dart';
import '../../domain/event_repository.dart';
import '../../domain/municipality.dart';

/// The single place the app touches `Supabase.instance`.
///
/// Tests override this provider, and nothing else in the app needs to know
/// Supabase exists.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return SupabaseEventRepository(ref.watch(supabaseClientProvider));
});

/// Riverpod 3 retries a failed provider automatically, with backoff, for as long
/// as something is listening. That is wrong for this app: the user cannot see
/// the retries, the error state flickers, and a repository that always throws
/// loops forever on a dead network.
///
/// Every screen already renders an explicit `ErrorView` with a "Try again"
/// button, so retries belong to the user, not the framework. Returning `null`
/// from this callback disables the automatic retry.
Duration? _noAutoRetry(int retryCount, Object error) => null;

/// Published upcoming events for the given filter (FR-01…FR-05).
final eventFeedProvider = FutureProvider.autoDispose
    .family<List<Event>, EventFilter>((ref, filter) {
      return ref.watch(eventRepositoryProvider).fetchPublished(filter: filter);
    }, retry: _noAutoRetry);

/// A single event for the detail screen (FR-06).
final eventDetailProvider = FutureProvider.autoDispose.family<Event, String>((
  ref,
  id,
) {
  return ref.watch(eventRepositoryProvider).fetchById(id);
}, retry: _noAutoRetry);

/// Municipalities for the filter bar (FR-02).
final municipalitiesProvider = FutureProvider.autoDispose<List<Municipality>>((
  ref,
) {
  return ref.watch(eventRepositoryProvider).fetchMunicipalities();
}, retry: _noAutoRetry);

/// Currently selected municipality. Null means "all".
///
/// Uses `Notifier` rather than `StateProvider`, which is legacy in Riverpod 3.
class SelectedMunicipality extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? municipalityId) => state = municipalityId;

  void clear() => state = null;
}

final selectedMunicipalityProvider =
    NotifierProvider<SelectedMunicipality, String?>(SelectedMunicipality.new);

/// The filter currently applied to the feed.
final currentEventFilterProvider = Provider<EventFilter>((ref) {
  return EventFilter(municipalityId: ref.watch(selectedMunicipalityProvider));
});
