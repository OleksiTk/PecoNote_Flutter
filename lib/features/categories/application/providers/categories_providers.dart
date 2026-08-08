import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/remote/categories_remote_data_source.dart';
import '../../data/repositories/api_categories_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/categories_repository.dart';

final categoriesRemoteDataSourceProvider = Provider<CategoriesRemoteDataSource>(
  (ref) => CategoriesRemoteDataSource(ref.watch(dioProvider)),
);

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return ApiCategoriesRepository(ref.watch(categoriesRemoteDataSourceProvider));
});

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() {
    return ref.watch(categoriesRepositoryProvider).getCategories();
  }

  Future<Category> createCategory({
    required String name,
    String? description,
    int? parentId,
    String? emoji,
  }) async {
    final created = await ref
        .read(categoriesRepositoryProvider)
        .create(
          name: name,
          description: description,
          parentId: parentId,
          emoji: emoji,
        );
    state = AsyncData([...?state.value, created]);
    return created;
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
      CategoriesNotifier.new,
    );
