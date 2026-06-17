import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/overdue_checker_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await FirebaseService.initialize();

  // 2. Set up dependency injection
  setupDependencies();

  // 3. Initialize notifications
  await NotificationService.initialize();

  // 4. Set up FCM
  await FirebaseService.setupFCM();

  // 5. Check for overdue tasks on startup
  final overdueChecker = sl<OverdueCheckerService>();
  await overdueChecker.check();

  // 6. Run the app
  runApp(const JarvisApp());
}
