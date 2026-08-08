import 'package:dio/dio.dart';

/// CRUD /accounts/ на бекенді PecoNote (Django + DRF ModelViewSet,
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
      data: {'name': name, 'description': ?description, 'currency': currencyId},
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> update({
    required String id,
    required String name,
    String? description,
    required int currencyId,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/accounts/$id/',
      data: {'name': name, 'description': description, 'currency': currencyId},
    );
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Expected 200 OK when updating an account.',
      );
    }
    return response.data ?? const {};
  }

  Future<void> delete(String id) async {
    final response = await _dio.delete<void>('/accounts/$id/');
    if (response.statusCode != 204) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Expected 204 No Content when deleting an account.',
      );
    }
  }
}
