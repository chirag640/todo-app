import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../api/api_client.dart';
import '../utils/logger.dart';
import '../../features/auth/data/services/user_service.dart';

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.info('Background message: ${message.messageId}', 'FCM');

  // You can process the message here if needed
  if (message.notification != null) {
    AppLogger.info(
      'Background notification: ${message.notification!.title}',
      'FCM',
    );
  }
}

/// Singleton service to handle all notification logic
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _fcmToken;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> init() async {
    if (_initialized) {
      AppLogger.warning(
          'NotificationService already initialized', 'NotificationService');
      return;
    }

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set your timezone

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initLocalNotifications();

      // Initialize FCM
      await _initFCM();

      _initialized = true;
      AppLogger.success(
          'NotificationService initialized', 'NotificationService');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize NotificationService', e, stackTrace,
          'NotificationService');
      rethrow;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ requires notification permission
      final status = await Permission.notification.request();
      if (status.isDenied) {
        AppLogger.warning(
            'Notification permission denied', 'NotificationService');
      }
    }

    // Request FCM permissions (iOS)
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppLogger.info(
      'FCM permission status: ${settings.authorizationStatus}',
      'NotificationService',
    );
  }

  /// Initialize local notifications
  Future<void> _initLocalNotifications() async {
    // Android initialization settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback for notification tap
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _createNotificationChannel();

    AppLogger.debug('Local notifications initialized', 'NotificationService');
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'task_reminders', // Channel ID
        'Task Reminders', // Channel name
        description: 'Notifications for task reminders and due dates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      AppLogger.debug('Notification channel created', 'NotificationService');
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initFCM() async {
    // Get FCM token
    _fcmToken = await _fcm.getToken();
    AppLogger.info('FCM Token: $_fcmToken', 'NotificationService');

    // Send token to backend
    if (_fcmToken != null) {
      await sendTokenToBackend();
    }

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      AppLogger.info('FCM Token refreshed: $newToken', 'NotificationService');
      // Send updated token to backend
      sendTokenToBackend();
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated messages - use the top-level function
    // Note: Background handler is registered in main.dart initialization
    // FirebaseMessaging.onBackgroundMessage is called there

    // Handle when user taps notification while app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state via notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    AppLogger.debug('FCM initialized', 'NotificationService');
  }

  /// Handle foreground messages (when app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground message received: ${message.messageId}', 'FCM');

    if (message.notification != null) {
      // Show local notification for foreground messages
      _showLocalNotification(
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle when user taps notification (background/terminated state)
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.info('Message opened app: ${message.messageId}', 'FCM');

    // TODO: Navigate to specific screen based on message data
    if (message.data.isNotEmpty) {
      debugPrint('Notification data: ${message.data}');
      // Example: Navigate to task details if task_id is present
      // final taskId = message.data['task_id'];
      // navigatorKey.currentState?.pushNamed('/task-details', arguments: taskId);
    }
  }

  /// Handle notification tap (local notifications)
  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info(
        'Notification tapped: ${response.payload}', 'NotificationService');

    // TODO: Handle notification tap - navigate to relevant screen
    if (response.payload != null && response.payload!.isNotEmpty) {
      debugPrint('Notification payload: ${response.payload}');
      // Parse payload and navigate
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders and due dates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
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
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );

    AppLogger.debug('Local notification shown: $title', 'NotificationService');
  }

  /// Schedule a notification for a specific date/time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_initialized) {
      throw StateError('NotificationService not initialized');
    }

    // Don't schedule if time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      AppLogger.warning(
        'Cannot schedule notification in the past: $scheduledTime',
        'NotificationService',
      );
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders and due dates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
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

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    AppLogger.info(
      'Notification scheduled: $title at $scheduledTime',
      'NotificationService',
    );
  }

  /// Schedule task reminder notifications
  Future<void> scheduleTaskReminders({
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    if (!_initialized) {
      throw StateError('NotificationService not initialized');
    }

    final now = DateTime.now();

    // Schedule notification 1 day before (if not passed)
    final oneDayBefore = dueDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(now)) {
      await scheduleNotification(
        id: '${taskId}_1day'.hashCode,
        title: 'Task Due Tomorrow',
        body: 'Reminder: "$taskTitle" is due tomorrow',
        scheduledTime: oneDayBefore,
        payload: taskId,
      );
    }

    // Schedule notification 1 hour before (if not passed)
    final oneHourBefore = dueDate.subtract(const Duration(hours: 1));
    if (oneHourBefore.isAfter(now)) {
      await scheduleNotification(
        id: '${taskId}_1hour'.hashCode,
        title: 'Task Due Soon',
        body: 'Reminder: "$taskTitle" is due in 1 hour',
        scheduledTime: oneHourBefore,
        payload: taskId,
      );
    }

    // Schedule notification at due time (if not passed)
    if (dueDate.isAfter(now)) {
      await scheduleNotification(
        id: '${taskId}_due'.hashCode,
        title: 'Task Due Now',
        body: '"$taskTitle" is due now!',
        scheduledTime: dueDate,
        payload: taskId,
      );
    }

    AppLogger.success(
      'Task reminders scheduled for: $taskTitle',
      'NotificationService',
    );
  }

  /// Cancel all notifications for a specific task
  Future<void> cancelTaskReminders(String taskId) async {
    if (!_initialized) {
      throw StateError('NotificationService not initialized');
    }

    try {
      // Cancel all 3 possible notifications for this task
      await _localNotifications.cancel('${taskId}_1day'.hashCode);
      await _localNotifications.cancel('${taskId}_1hour'.hashCode);
      await _localNotifications.cancel('${taskId}_due'.hashCode);

      AppLogger.info(
          'Task reminders cancelled for: $taskId', 'NotificationService');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to cancel task reminders',
        e,
        stackTrace,
        'NotificationService',
      );
    }
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    if (!_initialized) {
      throw StateError('NotificationService not initialized');
    }

    await _localNotifications.cancel(id);
    AppLogger.debug('Notification cancelled: $id', 'NotificationService');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) {
      throw StateError('NotificationService not initialized');
    }

    await _localNotifications.cancelAll();
    AppLogger.info('All notifications cancelled', 'NotificationService');
  }

  /// Get list of pending notifications (Android only)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) {
      throw StateError('NotificationService not initialized');
    }

    return await _localNotifications.pendingNotificationRequests();
  }

  /// Show immediate notification (for testing or instant alerts)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// Send FCM token to backend (for push notifications from server)
  Future<void> sendTokenToBackend() async {
    if (_fcmToken == null) {
      AppLogger.warning('No FCM token available', 'NotificationService');
      return;
    }

    try {
      // Note: Sending token to backend requires authenticated API client
      // This should be called after user login when API client is available
      // For now, just log the token
      AppLogger.info('FCM token ready to send to backend: $_fcmToken',
          'NotificationService');

      // TODO: Uncomment when authentication is set up
      // final userService = UserService(ApiClient());
      // await userService.updateFcmToken(_fcmToken!);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to send FCM token to backend',
        e,
        stackTrace,
        'NotificationService',
      );
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final settings = await _fcm.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    }
    return false;
  }

  /// Open app settings for notification permissions
  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }
}
