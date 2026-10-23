/// A published event as shown to guests and residents.
///
/// Plain immutable class: no code generation, so `dart run build_runner` is not
/// part of the build loop. `copyWith` is written only where it is used.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.startsAt,
    required this.endsAt,
    required this.categoryName,
    required this.categorySlug,
    required this.municipalityName,
    this.summary,
    this.address,
    this.barangayName,
    this.coverImageUrl,
    this.isFree = true,
  });

  final String id;
  final String title;
  final String description;

  /// Machine-generated summary (FR-21). Falls back to [description] in the UI
  /// when null, so a missing summary never leaves a blank card.
  final String? summary;

  final String venue;
  final String? address;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? coverImageUrl;
  final String municipalityName;
  final String? barangayName;
  final String categoryName;
  final String categorySlug;
  final bool isFree;

  /// The one-line blurb shown on cards and at the top of the detail screen.
  String get blurb => (summary != null && summary!.trim().isNotEmpty)
      ? summary!.trim()
      : description.trim();

  bool get hasEnded => endsAt.isBefore(DateTime.now());

  bool get isOngoing {
    final now = DateTime.now();
    return !startsAt.isAfter(now) && endsAt.isAfter(now);
  }

  String get locationLabel {
    final parts = <String>[
      if (barangayName != null && barangayName!.isNotEmpty) barangayName!,
      municipalityName,
    ];
    return parts.join(', ');
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: (json['title'] as String?)?.trim() ?? 'Untitled event',
      description: (json['description'] as String?)?.trim() ?? '',
      summary: json['summary'] as String?,
      venue: (json['venue'] as String?)?.trim() ?? '',
      address: json['address'] as String?,
      startsAt: _parseDate(json['starts_at'])!,
      endsAt: _parseDate(json['ends_at'])!,
      coverImageUrl: json['cover_image_url'] as String?,
      isFree: json['is_free'] as bool? ?? true,
      municipalityName: _embedded(json, 'municipalities', 'name') ?? 'Rizal',
      barangayName: _embedded(json, 'barangays', 'name'),
      categoryName: _embedded(json, 'categories', 'name') ?? 'Event',
      categorySlug: _embedded(json, 'categories', 'slug') ?? 'event',
    );
  }

  /// PostgREST returns a to-one embedded resource as an object, but a to-many
  /// relation as a list. Accept both so an ambiguous foreign key cannot crash
  /// the feed.
  static String? _embedded(
    Map<String, dynamic> json,
    String relation,
    String field,
  ) {
    final value = json[relation];
    if (value is Map) return value[field]?.toString();
    if (value is List && value.isNotEmpty && value.first is Map) {
      return (value.first as Map)[field]?.toString();
    }
    return null;
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}
