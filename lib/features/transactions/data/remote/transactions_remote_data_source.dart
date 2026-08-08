import 'package:dio/dio.dart';

/// GET/POST /transactions/ і PATCH /transactions/{id}/trash/ на бекенді
/// PecoNote (Django + DRF ModelViewSet, IsAuthenticated; сторінкування
/// PageNumberPagination — список приходить у {count, next, previous, results}).
/// Транзакція вимагає counterparty (FK, не nullable у моделі) — тому тут же
/// living get-or-create по /counterparts/, бо окремого UI для контрагентів
/// у застосунку ще немає.
class TransactionsRemoteDataSource {
  const TransactionsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<dynamic>> getTransactions() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/transactions/',
      queryParameters: const {'page_size': 100},
    );
    final results = response.data?['results'];
    return results is List ? results : const [];
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/transactions/',
      data: data,
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> updateTags(String id, List<int> tagIds) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/transactions/$id/',
      data: {'tag': tagIds},
    );
    return response.data ?? const {};
  }

  Future<void> trash(String id) {
    return _dio.patch<void>('/transactions/$id/trash/');
  }

  Future<List<dynamic>> getCounterparties() async {
    final response = await _dio.get<List<dynamic>>('/counterparts/');
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> createCounterparty(String name) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/counterparts/',
      data: {'name': name},
    );
    return response.data ?? const {};
  }
}
