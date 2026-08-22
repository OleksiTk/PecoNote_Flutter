import 'package:dio/dio.dart';

/// Профіль і валюти користувача — /profile/, /profile/change-email/,
/// /profile/change-password/ і /currencies/ на бекенді PecoNote
/// (Django + DRF, IsAuthenticated; токен додає AuthTokenInterceptor).
class SettingsRemoteDataSource {
  const SettingsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get<Map<String, dynamic>>('/profile/');
    return response.data ?? const {};
  }

  Future<List<dynamic>> getCurrencies() async {
    final response = await _dio.get<List<dynamic>>('/currencies/all/');
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> updateProfile({required String username}) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/profile/',
      data: {'username': username},
    );
    return response.data ?? const {};
  }

  Future<void> changeEmail({
    required String email,
    required String currentPassword,
  }) {
    return _dio.post<void>(
      '/profile/change-email/',
      data: {'email': email, 'current_password': currentPassword},
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) {
    return _dio.post<void>(
      '/profile/change-password/',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_new_password': confirmNewPassword,
      },
    );
  }
}
