import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/notifications/push_service.dart';
import '../data/remote/notifications_remote_data_source.dart';

/// Keeps this device's FCM token registered with the backend for as long as the
/// user is signed in, and removes it on logout.
///
/// Everything here is best-effort: a push failure must never block login or
/// logout.
class DeviceTokenSync {
  DeviceTokenSync({
    required PushService pushService,
    required NotificationsRemoteDataSource remoteDataSource,
    required FlutterSecureStorage storage,
  })  : _push = pushService,
        _remote = remoteDataSource,
        _storage = storage;

  static const _lastTokenKey = 'notifications.deviceToken';

  final PushService _push;
  final NotificationsRemoteDataSource _remote;
  final FlutterSecureStorage _storage;

  StreamSubscription<String>? _refreshSub;
  String? _registeredToken;
  bool _registering = false;

  /// Call after a successful login and on every authenticated app launch.
  Future<void> register() async {
    if (_registering) return;
    _registering = true;
    try {
      final token = await _push.requestPermissionAndToken();
      if (token == null || token == _registeredToken) return;
      await _sendToken(token);
      _refreshSub ??= _push.tokenRefreshes.listen(_sendToken);
    } on Object catch (error, stack) {
      debugPrint('DeviceTokenSync.register failed: $error\n$stack');
    } finally {
      _registering = false;
    }
  }

  /// Call during logout, before the auth tokens are cleared, so the DELETE is
  /// still authenticated.
  Future<void> unregister() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    try {
      final token = _registeredToken ??
          await _storage.read(key: _lastTokenKey) ??
          await _push.currentTokenOrNull();
      if (token != null) {
        await _remote.unregisterDevice(token);
      }
      // Force a fresh token for the next account signed in on this device.
      await _push.deleteToken();
    } on Object catch (error, stack) {
      debugPrint('DeviceTokenSync.unregister failed: $error\n$stack');
    } finally {
      _registeredToken = null;
      await _storage.delete(key: _lastTokenKey);
    }
  }

  Future<void> _sendToken(String token) async {
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => null,
    };
    if (platform == null) return;

    if (kDebugMode) {
      // Masked so a debug/QA log dump can't be replayed to push-notify this
      // device; grab the full token from a debugger/breakpoint if you need
      // it for a curl test.
      debugPrint(
        'FCM device token registered ($platform): ${_maskToken(token)}',
      );
    }
    await _remote.registerDevice(token: token, platform: platform);
    _registeredToken = token;
    await _storage.write(key: _lastTokenKey, value: token);
  }

  static String _maskToken(String token) {
    if (token.length <= 10) return '***';
    return '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
  }
}
