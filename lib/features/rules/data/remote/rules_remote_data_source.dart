import 'package:dio/dio.dart';

/// CRUD /rules/ on the PecoNote backend (Django + DRF ModelViewSet,
/// IsAuthenticated; token added by AuthTokenInterceptor), plus two custom
/// actions: /rules/preview/ (ad-hoc condition match count + sample) and
/// /rules/{id}/apply/ (retroactive tagging of already-imported transactions).
class RulesRemoteDataSource {
  const RulesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<dynamic>> getRules() async {
    final response = await _dio.get<List<dynamic>>('/rules/');
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>('/rules/', data: body);
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> body) async {
    final response = await _dio.put<Map<String, dynamic>>('/rules/$id/', data: body);
    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Expected 200 OK when updating a rule.',
      );
    }
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> setActive(String id, bool isActive) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/rules/$id/',
      data: {'is_active': isActive},
    );
    return response.data ?? const {};
  }

  Future<void> delete(String id) async {
    final response = await _dio.delete<void>('/rules/$id/');
    if (response.statusCode != 204) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Expected 204 No Content when deleting a rule.',
      );
    }
  }

  Future<Map<String, dynamic>> preview(Map<String, dynamic> conditionBody) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/rules/preview/',
      data: conditionBody,
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> apply(String ruleId, List<String> transactionIds) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/rules/$ruleId/apply/',
      data: {'transaction_ids': transactionIds},
    );
    return response.data ?? const {};
  }
}
