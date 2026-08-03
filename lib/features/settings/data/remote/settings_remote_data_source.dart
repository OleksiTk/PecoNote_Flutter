import 'package:dio/dio.dart';

/// Профіль і валюти користувача — GET /profile/ і GET /currencies/ на бекенді
/// PecoNote (Django + DRF, IsAuthenticated; токен додає AuthTokenInterceptor).
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
}
