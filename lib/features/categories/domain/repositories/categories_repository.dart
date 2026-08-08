import '../entities/category.dart';

abstract interface class CategoriesRepository {
  Future<List<Category>> getCategories();

  Future<Category> create({
    required String name,
    String? description,
    int? parentId,
  });
}
