import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // тут нічого показувати не треба — система сама покаже notification
}

class PushService {
  static Future<String?> init({required Dio dio}) async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    final messaging = FirebaseMessaging.instance;

    // Android 13+ і iOS вимагають явного дозволу
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return null;
    }

    // FCM-токен цього пристрою — його треба відправити на бекенд
    final token = await messaging.getToken();
    if (token != null) {
      await _registerDeviceToken(dio, token);
    }

    // токен може оновитись — слухаємо
    messaging.onTokenRefresh.listen((newToken) async {
      await _registerDeviceToken(dio, newToken);
    });

    // повідомлення, коли застосунок відкритий
    FirebaseMessaging.onMessage.listen((message) {
      // показати через flutter_local_notifications
    });

    // тап по сповіщенню, коли застосунок у фоні
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // навігація: message.data['screen'] → context.goNamed(...)
    });

    return token;
  }

  static Future<void> _registerDeviceToken(Dio dio, String token) async {
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => throw UnsupportedError(
        'Push token registration is only supported on Android and iOS.',
      ),
    };

    await dio.post<void>(
      '/notifications/devices/',
      data: {'token': token, 'platform': platform},
    );
  }
}
