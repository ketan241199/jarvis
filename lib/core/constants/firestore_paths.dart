/// Firestore collection and document path constants.
///
/// Centralizes all Firestore paths to avoid magic strings scattered
/// throughout the codebase. Any path change only needs updating here.
class FirestorePaths {
  FirestorePaths._();

  static const String tasks = 'tasks';
  static const String tags = 'tags';
  static const String schedules = 'schedules';
  static const String settings = 'settings';

  /// Returns the document path for a specific task.
  static String taskDoc(String taskId) => '$tasks/$taskId';

  /// Returns the document path for a specific tag.
  static String tagDoc(String tagId) => '$tags/$tagId';

  /// Returns the document path for a specific schedule.
  static String scheduleDoc(String scheduleId) => '$schedules/$scheduleId';

  /// Returns the document path for device settings.
  static String settingsDoc(String deviceId) => '$settings/$deviceId';
}
