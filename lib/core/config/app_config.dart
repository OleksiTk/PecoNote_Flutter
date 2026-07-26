import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static const _fallbackApiUrl = 'http://localhost:8006/v1.0';
  static const _fallbackAppTitle = 'PecoNote';

  static String get apiUrl {
    return _read('API_URL', _fallbackApiUrl).replaceFirst(RegExp(r'/$'), '');
  }

  static String get appTitle => _read('APP_TITLE', _fallbackAppTitle);

  static String _read(String key, String fallback) {
    if (!dotenv.isInitialized) return fallback;

    final value = dotenv.maybeGet(key)?.trim();
    return value == null || value.isEmpty ? fallback : value;
  }
}
