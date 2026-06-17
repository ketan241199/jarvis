/// Reusable form validation helpers.
///
/// Centralizes validation logic so it's not duplicated across
/// screens and forms.
class Validators {
  Validators._();

  /// Validates that the input is not null or empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that the input does not exceed [maxLength].
  static String? maxLength(String? value, int maxLength,
      [String fieldName = 'This field']) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    return null;
  }

  /// Validates a task title: required and max 200 characters.
  static String? taskTitle(String? value) {
    return required(value, 'Task title') ??
        maxLength(value, 200, 'Task title');
  }

  /// Validates a task description: optional but max 1000 characters.
  static String? taskDescription(String? value) {
    if (value == null || value.isEmpty) return null;
    return maxLength(value, 1000, 'Description');
  }

  /// Validates that a due date is not in the past (for new tasks).
  static String? futureDueDate(DateTime? date) {
    if (date == null) {
      return 'Due date is required';
    }
    // Allow today but not past days
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    if (date.isBefore(todayStart)) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  /// Validates that a tag name is not empty and within bounds.
  static String? tagName(String? value) {
    return required(value, 'Tag name') ??
        maxLength(value, 50, 'Tag name');
  }
}
