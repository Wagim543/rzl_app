import 'package:rzl_app/features/events/domain/event.dart';
import 'package:rzl_app/features/events/domain/event_filter.dart';
import 'package:rzl_app/features/events/domain/event_repository.dart';
import 'package:rzl_app/features/events/domain/municipality.dart';

/// In-memory repository for widget tests.
///
/// No network, no Supabase, no async delay — so tests are fast and deterministic.
/// Also useful for demoing the UI when the venue Wi-Fi is gone.
class FakeEventRepository implements EventRepository {
  FakeEventRepository({
    this.events = const <Event>[],
    this.municipalities = const <Municipality>[],
    this.error,
  });

  final List<Event> events;
  final List<Municipality> municipalities;

  /// When set, every call throws this instead of returning data.
  final Object? error;

  /// The filter the screen actually sent — lets a test assert on behaviour
  /// rather than on rendered text alone.
  EventFilter? lastFilter;

  int fetchPublishedCalls = 0;

  @override
  Future<List<Event>> fetchPublished({
    EventFilter filter = const EventFilter(),
  }) async {
    fetchPublishedCalls++;
    lastFilter = filter;
    if (error != null) throw error!;
    if (filter.municipalityId == null) return events;
    return events
        .where((event) => event.municipalityName.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<Event> fetchById(String id) async {
    if (error != null) throw error!;
    return events.firstWhere((event) => event.id == id);
  }

  @override
  Future<List<Municipality>> fetchMunicipalities() async {
    if (error != null) throw error!;
    return municipalities;
  }
}

/// A valid event fixture. Dates default to the future so the card renders as
/// upcoming.
Event buildEvent({
  String id = 'evt-1',
  String title = 'Binangonan Fiesta',
  String venue = 'Municipal Grounds',
  String municipalityName = 'Binangonan',
  String categoryName = 'Festival',
  String categorySlug = 'festival',
  String? barangayName = 'Poblacion',
  String? coverImageUrl,
}) {
  final now = DateTime.now();
  return Event(
    id: id,
    title: title,
    description: 'A description of $title.',
    summary: 'A one-line summary of $title.',
    venue: venue,
    startsAt: now.add(const Duration(days: 3)),
    endsAt: now.add(const Duration(days: 3, hours: 6)),
    municipalityName: municipalityName,
    barangayName: barangayName,
    categoryName: categoryName,
    categorySlug: categorySlug,
    coverImageUrl: coverImageUrl,
  );
}
