import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:zenslam/core/const/app_colors.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("📬 Handling background message: ${message.messageId}");

  // For data-only messages, show a local notification
  if (message.notification == null && message.data.isNotEmpty) {
    await _showBackgroundNotification(message);
  }
  // Messages with notification payload are auto-displayed by Firebase
}

/// Show a local notification for data-only background messages
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  final localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize for background context
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
  await localNotifications.initialize(initSettings);

  const androidDetail = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
    priority: Priority.high,
    color: AppColors.primaryColor,
  );

  const noticeDetail = NotificationDetails(
    android: androidDetail,
    iOS: DarwinNotificationDetails(),
  );

  final title = message.data['title'] ?? 'Zenslam';
  final body = message.data['body'] ?? message.data['message'] ?? '';

  if (body.isNotEmpty) {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await localNotifications.show(id, title, body, noticeDetail);
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  static Future<void> initialize() async {
    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize Local Notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // Use app icon
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Request permission
    await requestPermission();

    // Get FCM token
    await getFcmToken();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        _showLocalNotification(message);
      }
    });
  }

  /// Show Local Notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetail = AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
      color: AppColors.primaryColor,
    );

    const iosDetail = DarwinNotificationDetails();
    const noticeDetail = NotificationDetails(
      android: androidDetail,
      iOS: iosDetail,
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _localNotifications.show(
      id,
      message.notification!.title,
      message.notification!.body,
      noticeDetail,
    );
  }

  /// Request notification permission
  static Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  /// Get and print FCM Token
  static Future<String?> getFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      debugPrint("❌ Error getting FCM token: $e");
      return null;
    }
  }
}
