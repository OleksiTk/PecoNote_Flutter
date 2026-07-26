import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login/',
      data: {'email': email, 'password': password, 'is_remember': true},
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register/',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      },
    );
    return response.data ?? const {};
  }

  Future<void> logout() {
    return _dio.post<void>('/auth/logout/', data: <String, dynamic>{});
  }

  Future<void> requestPasswordReset({required String email}) {
    return _dio.post<void>('/auth/password-reset/', data: {'email': email});
  }

  Future<void> resetPassword({
    required String uid,
    required String token,
    required String password,
    required String confirmPassword,
  }) {
    return _dio.post<void>(
      '/auth/password-reset-confirm/$uid/$token/',
      data: {'password': password, 'confirm_password': confirmPassword},
    );
  }
}
