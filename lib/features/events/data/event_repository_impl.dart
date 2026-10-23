import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/error_mapper.dart';
import '../../../core/error/failure.dart';
import '../domain/event.dart';
import '../domain/event_filter.dart';
import '../domain/event_repository.dart';
import '../domain/municipality.dart';

/// Supabase-backed implementation of [EventRepository].
///
/// Two rules hold everywhere in this file:
/// 1. Name the columns. Never `select('*')` — a later migration adds a
///    1536-dimension `embedding` column that would ship with every list row.
/// 2. Wrap every call so the caller only ever sees a [Failure].
class SupabaseEventRepository implements EventRepository {
  SupabaseEventRepository(this._client);

  final SupabaseClient _client;

  static const String _columns =
      'id, title, description, summary, venue, address, '
      'starts_at, ends_at, cover_image_url, is_free, status, '
      'categories(name, slug), '
      'municipalities(id, name), '
      'barangays(name)';

  @override
  Future<List<Event>> fetchPublished({
    EventFilter filter = const EventFilter(),
  }) async {
    try {
      final query = _client
          .from('events')
          .select(_columns)
          .eq('status', 'published')
          // `ends_at`, not `starts_at`: an event happening right now must stay
          // visible, and past events must not.
          .gte('ends_at', DateTime.now().toUtc().toIso8601String());

      final filtered = filter.municipalityId == null
          ? query
          : query.eq('municipality_id', filter.municipalityId!);

      final rows = await filtered.order('starts_at', ascending: true).limit(50);

      return rows.map(Event.fromJson).toList(growable: false);
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }

  @override
  Future<Event> fetchById(String id) async {
    try {
      final row = await _client
          .from('events')
          .select(_columns)
          .eq('id', id)
          .eq('status', 'published')
          .maybeSingle();

      if (row == null) {
        throw const NotFoundFailure();
      }

      return Event.fromJson(row);
    } catch (error, stackTrace) {
      if (error is Failure) rethrow;
      throw mapError(error, stackTrace);
    }
  }

  @override
  Future<List<Municipality>> fetchMunicipalities() async {
    try {
      final rows = await _client
          .from('municipalities')
          .select('id, name')
          .order('name', ascending: true);

      return rows.map(Municipality.fromJson).toList(growable: false);
    } catch (error, stackTrace) {
      throw mapError(error, stackTrace);
    }
  }
}
