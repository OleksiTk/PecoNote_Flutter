class Category {
  const Category({
    required this.id,
    required this.name,
    required this.isPublic,
    this.description,
    this.parentId,
    this.emoji,
  });

  final int id;
  final String name;
  final String? description;
  final bool isPublic;
  final int? parentId;
  final String? emoji;
}
