import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import 'notification_route.dart';

/// Android channel that background FCM "notification" messages are posted to.
/// The id must match `com.google.firebase.messaging.default_notification_channel_id`
/// in `android/app/src/main/AndroidManifest.xml`.
const AndroidNotificationChannel kAndroidNotificationChannel =
    AndroidNotificationChannel(
  'peconote_high_importance',
  'PecoNote alerts',
  description:
      'Sync problems, uncategorised payments and other inbox tasks that need '
      'your decision.',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // A background isolate has its own memory, so Firebase must be initialised
  // here as well. The OS renders the tray notification itself — nothing else
  // to do until the user taps it.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Owns the Firebase Cloud Messaging lifecycle: initialisation, OS permission,
/// the device token, foreground display via local notifications, and routing
/// from notification taps.
///
/// Token registration with the backend lives in `DeviceTokenSync` so it can be
/// tied to the auth session.
class PushService {
  PushService._();

  static final PushService instance = PushService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<NotificationRoute> _routeRequests =
      StreamController<NotificationRoute>.broadcast();

  bool _initialised = false;
  NotificationRoute? _initialRoute;

  /// Routes produced by notification taps while the app is already running.
  Stream<NotificationRoute> get routeRequests => _routeRequests.stream;

  /// The route carried by the notification the user tapped to cold-start the
  /// app. Consumed once, after the router is ready.
  NotificationRoute? takeInitialRoute() {
    final route = _initialRoute;
    _initialRoute = null;
    return route;
  }

  /// Safe to call more than once; only the first call does the work. Throws if
  /// Firebase itself cannot start (e.g. on an unconfigured platform) — callers
  /// should treat push as unavailable in that case.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _initLocalNotifications();

    // iOS shows nothing for a foreground push unless we opt in here. On Android
    // we render it ourselves via flutter_local_notifications below.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = NotificationRoute.fromData(message.data);
      if (route != null) _routeRequests.add(route);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _initialRoute = NotificationRoute.fromData(initialMessage.data);
    }

    if (kDebugMode) {
      // Print the token on every debug launch so it can be used to send test
      // pushes with curl before the backend endpoint exists.
      final token = await currentTokenOrNull();
      debugPrint('FCM device token: $token');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Firebase Messaging already prompts for permission; don't ask twice.
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        final route = NotificationRoute.tryDecode(response.payload);
        if (route != null) _routeRequests.add(route);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(kAndroidNotificationChannel);
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return; // data-only message: nothing to display

    final route = NotificationRoute.fromData(message.data);
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          kAndroidNotificationChannel.id,
          kAndroidNotificationChannel.name,
          channelDescription: kAndroidNotificationChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: route?.encode(),
    );
  }

  /// Asks the OS for notification permission and returns the FCM token, or
  /// `null` when the user declined or the platform has no push support.
  Future<String?> requestPermissionAndToken() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }
    return messaging.getToken();
  }

  Future<String?> currentTokenOrNull() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } on Object {
      return null;
    }
  }

  Stream<String> get tokenRefreshes =>
      FirebaseMessaging.instance.onTokenRefresh;

  Future<void> deleteToken() => FirebaseMessaging.instance.deleteToken();
}
