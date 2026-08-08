class Category {
  const Category({
    required this.id,
    required this.name,
    required this.isPublic,
    this.description,
    this.parentId,
  });

  final int id;
  final String name;
  final String? description;
  final bool isPublic;
  final int? parentId;
}
