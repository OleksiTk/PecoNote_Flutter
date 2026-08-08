import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';
import '../remote/categories_remote_data_source.dart';

class ApiCategoriesRepository implements CategoriesRepository {
  const ApiCategoriesRepository(this._remoteDataSource);

  final CategoriesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final json = await _remoteDataSource.getCategories();
      return json.whereType<Map<String, dynamic>>().map(_fromJson).toList();
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<Category> create({
    required String name,
    String? description,
    int? parentId,
    String? emoji,
  }) async {
    try {
      final json = await _remoteDataSource.create(
        name: name,
        description: description,
        parentId: parentId,
        emoji: emoji,
      );
      return _fromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  Category _fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      parentId: json['parent'] as int?,
      emoji: json['icon'] as String?,
    );
  }

  AppFailure _failureFrom(DioException error) {
    final data = error.response?.data;
    final fieldErrors = <String, List<String>>{};
    if (error.response?.statusCode == 400 && data is Map) {
      for (final entry in data.entries) {
        if (entry.key == 'detail') continue;
        final value = entry.value;
        fieldErrors[entry.key.toString()] = value is List
            ? value.map((message) => message.toString()).toList()
            : [value.toString()];
      }
      if (fieldErrors.isNotEmpty) {
        return ValidationFailure(
          'Please check the highlighted fields.',
          fieldErrors,
        );
      }
    }
    if (error.response?.statusCode == 401) {
      return const AuthenticationFailure(
        'Your session has expired. Please sign in again.',
      );
    }
    return const NetworkFailure('Could not load categories. Please try again.');
  }
}
