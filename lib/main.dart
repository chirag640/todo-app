import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/app.dart';
import 'core/config/env_loader.dart';
import 'core/database/hive_database.dart';
import 'core/services/notification_service.dart';
import 'features/auth/data/services/secure_storage_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables (optional)
    await EnvLoader.load();
  } catch (e) {
    debugPrint('Environment file not found, using defaults: $e');
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Register background message handler (must be done before other FCM setup)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }

  try {
    // Initialize Hive database (must be first)
    await HiveDatabase.instance.init();
  } catch (e) {
    debugPrint('Failed to initialize database: $e');
  }

  try {
    // Initialize secure storage for auth tokens
    await SecureStorageService().init();
  } catch (e) {
    debugPrint('Failed to initialize secure storage: $e');
  }

  try {
    // Initialize notification service (depends on Firebase)
    await NotificationService.instance.init();
    debugPrint('✅ NotificationService initialized');
  } catch (e) {
    debugPrint('Failed to initialize notification service: $e');
  }

  runApp(const App());
}
