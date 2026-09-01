import 'package:dio/dio.dart';

/// `/notifications/devices/` on the PecoNote backend (Django + DRF,
/// IsAuthenticated; the bearer token is added by `AuthTokenInterceptor`).
///
/// Expected contract:
///   POST   /notifications/devices/          {token, platform}  -> upsert by token
///   DELETE /notifications/devices/{token}/                     -> 204 on removal
class NotificationsRemoteDataSource {
  const NotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    await _dio.post<void>(
      '/notifications/devices/',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<void> unregisterDevice(String token) async {
    try {
      await _dio.delete<void>('/notifications/devices/$token/');
    } on DioException catch (error) {
      // The token may already be gone server-side — that is still success.
      if (error.response?.statusCode != 404) rethrow;
    }
  }
}
