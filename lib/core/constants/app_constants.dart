/// Application-wide constants.
class AppConstants {
  AppConstants._();

  /// App display name.
  static const String appName = 'Jarvis';

  /// Default notification channel ID for Android.
  static const String notificationChannelId = 'jarvis_reminders';

  /// Default notification channel name.
  static const String notificationChannelName = 'Task Reminders';

  /// Default notification channel description.
  static const String notificationChannelDescription =
      'Reminders for upcoming and overdue tasks';

  /// SharedPreferences key for device ID.
  static const String deviceIdKey = 'device_id';

  /// Default work schedule start time (hour).
  static const int defaultWorkStartHour = 9;

  /// Default work schedule end time (hour).
  static const int defaultWorkEndHour = 18;

  /// Days considered as workdays by default (1 = Monday .. 5 = Friday).
  static const List<int> defaultWorkDays = [1, 2, 3, 4, 5];

  /// Maximum task title length.
  static const int maxTitleLength = 200;

  /// Maximum task description length.
  static const int maxDescriptionLength = 1000;
}
