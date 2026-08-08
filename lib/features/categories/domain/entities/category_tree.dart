import 'category.dart';

class CategoryTreeItem {
  CategoryTreeItem({required this.category});

  final Category category;
  final List<CategoryTreeItem> children = [];
}

List<CategoryTreeItem> buildCategoryTree(List<Category> categories) {
  final items = {
    for (final category in categories)
      category.id: CategoryTreeItem(category: category),
  };
  final roots = <CategoryTreeItem>[];

  for (final item in items.values) {
    final parentId = item.category.parentId;
    final parent = parentId == null ? null : items[parentId];
    if (parent == null || identical(parent, item)) {
      roots.add(item);
    } else {
      parent.children.add(item);
    }
  }

  return roots;
}
