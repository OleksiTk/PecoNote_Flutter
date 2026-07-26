import '../entities/category.dart';

abstract interface class CategoriesRepository {
  Future<List<Category>> getCategories();

  Future<Category> create(Category category);

  Future<void> softDelete(String id);
}
