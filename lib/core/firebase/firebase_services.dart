import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:talevra/core/logger/app_logger.dart';
import 'package:talevra/core/storage/local_storage.dart';

/// Firebase Analytics and FCM bootstrap shared by every brand entry point.
class FirebaseServices {
  FirebaseServices._();

  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'default_notifications',
        'Notifications',
        description: 'General Talevra notifications',
        importance: Importance.high,
      );

  static Future<void> init() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _initLocalNotifications();
      await analytics.setAnalyticsCollectionEnabled(true);

      final settings = await messaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          )
          .timeout(const Duration(seconds: 3));
      AppLogger.i(
        'FCM permission: ${settings.authorizationStatus.name}',
        tag: 'Firebase',
      );

      final token = await messaging
          .getToken()
          .timeout(const Duration(seconds: 4));
      await _storeToken(token);
      messaging.onTokenRefresh.listen(_storeToken);

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleOpenedMessage(initialMessage);
      }
    } catch (error, stack) {
      AppLogger.e(
        'Firebase notification setup skipped',
        error: error,
        stack: stack,
        tag: 'Firebase',
      );
    }
  }

  static Future<void> _storeToken(String? token) async {
    if (token == null || token.isEmpty || !LocalStorage.isInitialized) return;
    await LocalStorage.I.setString('firebase.fcmToken', token);
    AppLogger.i('FCM token refreshed', tag: 'Firebase');
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      localNotifications.show(
        id: message.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_notifications',
            'Notifications',
            channelDescription: 'General Talevra notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.isEmpty ? null : message.data.toString(),
      );
    }
    AppLogger.i(
      'FCM foreground message: ${message.messageId ?? 'unknown'}',
      tag: 'Firebase',
    );
  }

  static Future<void> _initLocalNotifications() async {
    const settings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await localNotifications.initialize(
      settings: const InitializationSettings(android: settings),
      onDidReceiveNotificationResponse: (response) {
        AppLogger.i(
          'Local notification opened: ${response.payload ?? ''}',
          tag: 'Firebase',
        );
      },
    );

    final android = localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_defaultChannel);
    await android?.requestNotificationsPermission();
  }

  static void _handleOpenedMessage(RemoteMessage message) {
    AppLogger.i(
      'FCM notification opened: ${message.messageId ?? 'unknown'}',
      tag: 'Firebase',
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.i(
    'FCM background message: ${message.messageId ?? 'unknown'}',
    tag: 'Firebase',
  );
}
