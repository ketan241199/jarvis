import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../core/constants/app_constants.dart';

/// Service for local and push notification management.
///
/// Handles both scheduled local notifications (reminders, overdue alerts)
/// and incoming FCM push notifications displayed as local notifications.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initializes the notification service.
  static Future<void> initialize() async {
    if (_initialized) return;

    // Android init settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS init settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _createAndroidChannel();

    // Listen for foreground FCM messages and show as local notification
    FirebaseMessaging.onMessage.listen(_showFCMAsLocalNotification);

    _initialized = true;
  }

  /// Creates the Android notification channel for task reminders.
  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Shows a local notification immediately.
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Shows a notification for overdue tasks.
  static Future<void> showOverdueNotification({
    required int taskCount,
  }) async {
    if (taskCount == 0) return;

    final title = taskCount == 1
        ? '1 Overdue Task'
        : '$taskCount Overdue Tasks';
    const body = 'You have tasks that need attention!';

    await showNotification(
      id: 0, // Fixed ID for overdue summary
      title: title,
      body: body,
      payload: 'overdue',
    );
  }

  /// Shows a reminder notification for a specific task.
  static Future<void> showTaskReminder({
    required String taskId,
    required String taskTitle,
  }) async {
    await showNotification(
      id: taskId.hashCode,
      title: 'Reminder: $taskTitle',
      body: 'This task needs your attention.',
      payload: taskId,
    );
  }

  /// Converts an incoming FCM message to a local notification.
  static void _showFCMAsLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    showNotification(
      id: message.hashCode,
      title: notification.title ?? 'Jarvis',
      body: notification.body ?? '',
      payload: message.data['taskId'] as String?,
    );
  }

  /// Handles notification tap.
  static void _onNotificationTapped(NotificationResponse response) {
    // Navigation to specific task will be handled via GoRouter
    // The payload contains the task ID or 'overdue' for the overdue screen.
    // This will be connected to the router in a future update.
  }

  /// Cancels a specific notification.
  static Future<void> cancel(int id) async {
    await _localNotifications.cancel(id: id);
  }

  /// Cancels all notifications.
  static Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }
}
