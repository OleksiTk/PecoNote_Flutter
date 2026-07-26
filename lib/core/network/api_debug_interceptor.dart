import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiDebugInterceptor extends Interceptor {
  static const _startedAtKey = 'api_debug_started_at';
  static const _sensitiveKeys = {
    'access',
    'access_token',
    'authorization',
    'confirm_password',
    'email',
    'password',
    'refresh',
    'refresh_token',
    'token',
  };
  static const _sensitiveResponseKeys = {
    'access',
    'access_token',
    'authorization',
    'refresh',
    'refresh_token',
    'token',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now();
    debugPrint('[API] → ${options.method} ${_safeUri(options.uri)}');
    debugPrint('[API] curl: ${_toCurl(options)}');
    if (options.data != null) {
      debugPrint(
        '[API] request: ${_format(options.data, sensitiveKeys: _sensitiveKeys)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    debugPrint(
      '[API] ← ${response.statusCode} ${request.method} ${_safeUri(request.uri)} '
      '(${_elapsed(request)})',
    );
    if (response.data != null) {
      debugPrint(
        '[API] response: ${_format(response.data, sensitiveKeys: _sensitiveResponseKeys)}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    debugPrint(
      '[API] ✕ ${err.response?.statusCode ?? 'NETWORK'} '
      '${request.method} ${_safeUri(request.uri)} (${_elapsed(request)})',
    );
    if (err.response?.data != null) {
      debugPrint(
        '[API] error: ${_format(err.response!.data, sensitiveKeys: _sensitiveResponseKeys)}',
      );
    } else {
      debugPrint('[API] error: ${err.type.name} — ${err.message}');
    }
    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];
    if (startedAt is! DateTime) return 'unknown duration';
    return '${DateTime.now().difference(startedAt).inMilliseconds} ms';
  }

  String _toCurl(RequestOptions options) {
    final parts = <String>[
      'curl',
      '-X',
      _shellQuote(options.method),
      _shellQuote(_safeUri(options.uri)),
    ];

    for (final header in options.headers.entries) {
      final normalizedKey = header.key.toLowerCase();
      final value = _sensitiveKeys.contains(normalizedKey)
          ? '<redacted>'
          : header.value.toString();
      parts
        ..add('-H')
        ..add(_shellQuote('${header.key}: $value'));
    }

    if (options.data != null) {
      parts
        ..add('--data-raw')
        ..add(
          _shellQuote(_format(options.data, sensitiveKeys: _sensitiveKeys)),
        );
    }

    return parts.join(' ');
  }

  String _shellQuote(String value) => "'${value.replaceAll("'", "'\\''")}'";

  String _safeUri(Uri uri) {
    return uri.toString().replaceFirst(
      RegExp(r'(/auth/password-reset-confirm/)[^/]+/[^/]+/'),
      r'$1<redacted>/<redacted>/',
    );
  }

  String _format(dynamic value, {Set<String>? sensitiveKeys}) {
    final formattedValue = sensitiveKeys == null
        ? value
        : _sanitize(value, sensitiveKeys);
    try {
      return jsonEncode(formattedValue);
    } on Object {
      return formattedValue.toString();
    }
  }

  dynamic _sanitize(dynamic value, Set<String> sensitiveKeys) {
    if (value is Map) {
      return value.map((key, dynamic nestedValue) {
        final normalizedKey = key.toString().toLowerCase();
        return MapEntry(
          key.toString(),
          sensitiveKeys.contains(normalizedKey)
              ? '<redacted>'
              : _sanitize(nestedValue, sensitiveKeys),
        );
      });
    }
    if (value is Iterable) {
      return value.map((item) => _sanitize(item, sensitiveKeys)).toList();
    }
    if (value is FormData) return '<multipart form data>';
    return value;
  }
}
