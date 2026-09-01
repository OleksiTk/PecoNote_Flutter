import 'package:flutter/foundation.dart';

/// Where a tapped push notification should take the user, derived from the FCM
/// message `data` map.
///
/// The backend can send either an explicit `path` (a go_router location such as
/// `/inbox`) or a short `screen` key that is mapped here. Anything else in the
/// payload is kept in [params] for the destination screen to read.
@immutable
class NotificationRoute {
  const NotificationRoute({required this.location, this.params});

  final String location;
  final Map<String, String>? params;

  /// Short keys the backend may send instead of a full path.
  static const _knownScreens = <String, String>{
    'inbox': '/inbox',
    'home': '/home',
    'operations': '/operations',
    'stats': '/stats',
    'settings': '/settings',
    'rules': '/settings/rules',
  };

  static NotificationRoute? fromData(Map<String, dynamic> data) {
    if (data.isEmpty) return null;

    final rawPath =
        (data['path'] ?? data['route'] ?? data['click_action'])?.toString();
    if (rawPath != null && rawPath.startsWith('/')) {
      return NotificationRoute(location: rawPath, params: _stringMap(data));
    }

    final screen = data['screen']?.toString();
    final mapped = screen == null ? null : _knownScreens[screen];
    if (mapped != null) {
      return NotificationRoute(location: mapped, params: _stringMap(data));
    }
    return null;
  }

  /// Round-trips through the `flutter_local_notifications` payload string, which
  /// is where foreground notifications stash their route.
  static NotificationRoute? tryDecode(String? payload) {
    if (payload == null || !payload.startsWith('/')) return null;
    return NotificationRoute(location: payload);
  }

  String encode() => location;

  static Map<String, String>? _stringMap(Map<String, dynamic> data) {
    final map = <String, String>{
      for (final entry in data.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
    return map.isEmpty ? null : map;
  }

  @override
  bool operator ==(Object other) =>
      other is NotificationRoute && other.location == location;

  @override
  int get hashCode => location.hashCode;

  @override
  String toString() => 'NotificationRoute($location)';
}
