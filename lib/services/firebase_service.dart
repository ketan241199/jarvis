import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firestore_paths.dart';
import '../core/constants/app_constants.dart';
import '../firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  // Background message handling is done here.
  // For now, the notification itself is displayed by the system.
}

/// Service responsible for Firebase initialization and FCM token management.
class FirebaseService {
  static const _uuid = Uuid();

  /// Initializes Firebase and registers the FCM token.
  static Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// Gets or creates a unique device ID for this installation.
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(AppConstants.deviceIdKey);
    if (deviceId == null) {
      deviceId = _uuid.v4();
      await prefs.setString(AppConstants.deviceIdKey, deviceId);
    }
    return deviceId;
  }

  /// Requests notification permission and registers FCM token.
  static Future<void> setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get FCM token
      final token = await messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen(_saveToken);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Foreground messages will be handled by NotificationService
      // to show local notifications.
    });
  }

  /// Saves the FCM token to Firestore under the device settings.
  static Future<void> _saveToken(String token) async {
    final deviceId = await getDeviceId();
    await FirebaseFirestore.instance
        .collection(FirestorePaths.settings)
        .doc(deviceId)
        .set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

}
