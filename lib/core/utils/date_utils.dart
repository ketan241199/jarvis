import 'package:intl/intl.dart';

/// Utility functions for date/time operations used across the app.
///
/// Centralizes all date logic to satisfy DRY — overdue checks,
/// formatting, and day boundary calculations live here.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dayMonthYear = DateFormat('dd MMM yyyy');
  static final DateFormat _dayMonthYearTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');
  static final DateFormat _dayName = DateFormat('EEEE');

  /// Whether the given [dueDate] is in the past (task is overdue).
  static bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  /// Whether the given [date] is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Whether the given [date] is tomorrow.
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Whether the given [date] is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Returns a human-friendly due date string.
  ///
  /// Examples: "Today", "Tomorrow", "Yesterday", "12 Jun 2026"
  static String formatDueDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isTomorrow(date)) return 'Tomorrow';
    if (isYesterday(date)) return 'Yesterday';
    return _dayMonthYear.format(date);
  }

  /// Returns the full date with time.
  ///
  /// Example: "12 Jun 2026, 03:30 PM"
  static String formatDateTime(DateTime date) {
    return _dayMonthYearTime.format(date);
  }

  /// Returns just the time portion.
  ///
  /// Example: "03:30 PM"
  static String formatTime(DateTime date) {
    return _timeOnly.format(date);
  }

  /// Returns the day name.
  ///
  /// Example: "Monday"
  static String formatDayName(DateTime date) {
    return _dayName.format(date);
  }

  /// Returns the start of today (midnight 00:00:00).
  static DateTime get todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns the start of tomorrow (next midnight).
  static DateTime get tomorrowStart {
    return todayStart.add(const Duration(days: 1));
  }

  /// Returns the end of today (23:59:59.999).
  static DateTime get todayEnd {
    return tomorrowStart.subtract(const Duration(milliseconds: 1));
  }

  /// Returns how long ago or until a date, as a human-readable string.
  ///
  /// Examples: "2 hours ago", "in 3 days", "just now"
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.isNegative) {
      // Future date
      final absDiff = diff.abs();
      if (absDiff.inDays > 0) return 'in ${absDiff.inDays} day${absDiff.inDays == 1 ? '' : 's'}';
      if (absDiff.inHours > 0) return 'in ${absDiff.inHours} hour${absDiff.inHours == 1 ? '' : 's'}';
      if (absDiff.inMinutes > 0) return 'in ${absDiff.inMinutes} min';
      return 'just now';
    }

    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
    return 'just now';
  }
}
