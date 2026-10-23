/// Query filters for the event feed (FR-02, FR-04, FR-05).
///
/// Value equality matters: this object is the argument to a Riverpod `family`,
/// so two equal filters must map to the same cached provider instance.
class EventFilter {
  const EventFilter({this.municipalityId, this.categorySlug});

  /// Null means "all municipalities".
  final String? municipalityId;

  /// Null means "all categories".
  final String? categorySlug;

  bool get isActive => municipalityId != null || categorySlug != null;

  EventFilter copyWith({
    String? municipalityId,
    String? categorySlug,
    bool clearMunicipality = false,
    bool clearCategory = false,
  }) {
    return EventFilter(
      municipalityId: clearMunicipality
          ? null
          : (municipalityId ?? this.municipalityId),
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EventFilter &&
      other.municipalityId == municipalityId &&
      other.categorySlug == categorySlug;

  @override
  int get hashCode => Object.hash(municipalityId, categorySlug);

  @override
  String toString() =>
      'EventFilter(municipalityId: $municipalityId, categorySlug: $categorySlug)';
}
