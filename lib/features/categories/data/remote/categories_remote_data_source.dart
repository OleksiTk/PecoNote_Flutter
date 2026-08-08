import 'package:dio/dio.dart';

class CategoriesRemoteDataSource {
  const CategoriesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<dynamic>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/tags/');
    return response.data ?? const [];
  }

  Future<Map<String, dynamic>> create({
    required String name,
    String? description,
    int? parentId,
    String? emoji,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/tags/',
      data: {
        'name': name,
        'description': description,
        'is_public': false,
        'parent': parentId,
        'icon': ?emoji,
      },
    );
    return response.data ?? const {};
  }
}
