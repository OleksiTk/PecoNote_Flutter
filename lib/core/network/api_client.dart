import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_session.dart';
import '../config/app_config.dart';
import '../security/secure_token_storage.dart';
import 'api_debug_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    AuthTokenInterceptor(
      dio: dio,
      tokenStorage: ref.watch(secureTokenStorageProvider),
      onUnauthorized: () async {
        await ref.read(authSessionProvider).clear();
      },
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(ApiDebugInterceptor());
  }

  return dio;
});

class AuthTokenInterceptor extends QueuedInterceptor {
  AuthTokenInterceptor({
    required Dio dio,
    required SecureTokenStorage tokenStorage,
    required Future<void> Function() onUnauthorized,
  }) : _dio = dio,
       _refreshDio = Dio(
         BaseOptions(
           baseUrl: AppConfig.apiUrl,
           connectTimeout: const Duration(seconds: 20),
           receiveTimeout: const Duration(seconds: 20),
           headers: const {
             'Accept': 'application/json',
             'Content-Type': 'application/json',
           },
         ),
       ),
       _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized;

  static const _retriedKey = 'auth.retried';
  static const _publicPaths = {
    '/auth/login/',
    '/auth/register/',
    '/auth/password-reset/',
    '/auth/token/refresh/',
  };

  bool _isPublicPath(String path) {
    return _publicPaths.contains(path) ||
        path.startsWith('/auth/password-reset-confirm/');
  }
  final Dio _dio;
  final Dio _refreshDio;
  final SecureTokenStorage _tokenStorage;
  final Future<void> Function() _onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicPath(options.path)) {
      handler.next(options);
      return;
    }
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        _isPublicPath(request.path) ||
        request.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    try {
      final currentAccessToken = await _tokenStorage.readAccessToken();
      final usedAuthorization = request.headers['Authorization'];
      final usedAccessToken = usedAuthorization is String
          ? usedAuthorization.replaceFirst('Bearer ', '')
          : null;

      var accessToken = currentAccessToken;
      if (accessToken == null || accessToken == usedAccessToken) {
        final refreshToken = await _tokenStorage.readRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          throw const FormatException('Refresh token is missing.');
        }
        final response = await _refreshDio.post<Map<String, dynamic>>(
          '/auth/token/refresh/',
          data: {'refresh': refreshToken},
        );
        final refreshedAccessToken = response.data?['access'];
        if (refreshedAccessToken is! String || refreshedAccessToken.isEmpty) {
          throw const FormatException('Refresh response has no access token.');
        }
        accessToken = refreshedAccessToken;
        await _tokenStorage.saveAccessToken(accessToken);
      }
      request.extra[_retriedKey] = true;
      request.headers['Authorization'] = 'Bearer $accessToken';
      final response = await _dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on Object {
      await _onUnauthorized();
      handler.next(err);
    }
  }
}
