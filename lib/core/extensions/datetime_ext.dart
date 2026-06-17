/// Convenience extensions on [DateTime].
extension DateTimeExt on DateTime {
  /// Returns a new [DateTime] with only the date component (time zeroed out).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Whether this date is the same calendar day as [other].
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Whether this date is before today (past due).
  bool get isPast => isBefore(DateTime.now());

  /// Whether this date is today.
  bool get isToday => isSameDay(DateTime.now());

  /// Whether this date is tomorrow.
  bool get isTomorrow =>
      isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Returns the day of the week as 1=Monday .. 7=Sunday (ISO 8601).
  /// Dart's [weekday] already follows this convention.
  int get isoWeekday => weekday;

  /// Returns a copy of this DateTime with the time set to [hour] and [minute].
  DateTime withTime(int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }

  /// Returns the start of this day (midnight).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the end of this day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}
