/// A Rizal municipality, used by the feed filter (FR-02).
class Municipality {
  const Municipality({required this.id, required this.name});

  final String id;
  final String name;

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? 'Unknown',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Municipality && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}
