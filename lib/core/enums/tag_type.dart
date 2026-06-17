/// Classification type for tags.
enum TagType {
  home('Home'),
  work('Work'),
  personal('Personal'),
  custom('Custom');

  const TagType(this.label);

  /// Human-readable label for display.
  final String label;

  /// Creates a [TagType] from its string name.
  /// Returns [TagType.custom] if the name is unrecognized.
  static TagType fromName(String name) {
    return TagType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TagType.custom,
    );
  }
}
