import 'event.dart';
import 'event_filter.dart';
import 'municipality.dart';

/// Contract for event reads.
///
/// The presentation layer depends on this interface, never on Supabase. That is
/// what makes `FakeEventRepository` possible in widget tests, and what will keep
/// the screens unchanged when caching or offline support is added (FR-33).
abstract interface class EventRepository {
  /// Published, not-yet-ended events matching [filter], soonest first.
  ///
  /// Callable by guests — no session required (FR-01).
  Future<List<Event>> fetchPublished({
    EventFilter filter = const EventFilter(),
  });

  /// A single event by id. Callable by guests (FR-06).
  ///
  /// Throws [NotFoundFailure] when the event does not exist or is not visible.
  Future<Event> fetchById(String id);

  /// Municipalities for the filter bar (FR-02).
  ///
  /// Lives here for the guest slice; it moves to a shared reference-data
  /// repository once the admin event editor needs the same list.
  Future<List<Municipality>> fetchMunicipalities();
}
