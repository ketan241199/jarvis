/// Convenience extensions on [String].
extension StringExt on String {
  /// Capitalizes the first letter of this string.
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Returns this string truncated to [maxLength] with an ellipsis if longer.
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }

  /// Returns null if this string is empty, otherwise returns itself.
  /// Useful for converting empty strings to null for optional fields.
  String? get nullIfEmpty => isEmpty ? null : this;
}
