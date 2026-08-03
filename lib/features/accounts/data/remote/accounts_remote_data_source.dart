import 'package:dio/dio.dart';

/// GET/POST/DELETE /accounts/ на бекенді PecoNote (Django + DRF ModelViewSet,
/// IsAuthenticated; токен додає AuthTokenInterceptor).
class AccountsRemoteDataSource {
  const AccountsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<dynamic>> getAccounts() async {
    final response = await _dio.get<List<dynamic>>('/accounts/');
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> create({
    required String name,
    String? description,
    required int currencyId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/accounts/',
      data: {
        'name': name,
        'description': ?description,
        'currency': currencyId,
      },
    );
    return response.data ?? const {};
  }

  Future<void> delete(String id) {
    return _dio.delete<void>('/accounts/$id/');
  }
}
