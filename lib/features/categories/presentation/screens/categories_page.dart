import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../application/providers/categories_providers.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/category_tree.dart';
import 'new_category_page.dart';

/// Result of the [CategoriesPage] picker: either a selected category
/// (or "no category" via a null [categoryId]) or the page was dismissed.
class CategoryPickResult {
  const CategoryPickResult(this.categoryId);

  final int? categoryId;
}

const _fallbackEmojis = [
  '🏷️',
  '🍔',
  '🛒',
  '🚗',
  '🏠',
  '💊',
  '🎁',
  '📦',
  '🎮',
  '📚',
  '✈️',
  '💡',
];

/// The emoji to show for [category]: its own emoji if set, otherwise a
/// deterministic fallback so every category still gets an icon.
String categoryEmoji(Category category) {
  final emoji = category.emoji?.trim();
  if (emoji != null && emoji.isNotEmpty) return emoji;
  final index = category.name.isEmpty
      ? category.id
      : category.name.codeUnitAt(0) + category.id;
  return _fallbackEmojis[index % _fallbackEmojis.length];
}

class _CategorySection {
  const _CategorySection(this.title, this.categories);

  final String title;
  final List<Category> categories;
}

List<_CategorySection> _buildSections(List<Category> categories) {
  final roots = buildCategoryTree(categories);
  final sections = <_CategorySection>[];
  final ungrouped = <Category>[];

  for (final root in roots) {
    if (root.children.isEmpty) {
      ungrouped.add(root.category);
    } else {
      sections.add(
        _CategorySection(
          root.category.name.toUpperCase(),
          [for (final child in root.children) child.category],
        ),
      );
    }
  }

  if (ungrouped.isNotEmpty) {
    sections.add(
      _CategorySection(
        sections.isEmpty ? 'CATEGORIES' : 'OTHER',
        ungrouped,
      ),
    );
  }

  return sections;
}

/// Full-screen category picker, grouped into sections, with search and a
/// shortcut to create a new category.
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key, required this.selectedCategoryId});

  final int? selectedCategoryId;

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() => _query = _search.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final created = await Navigator.of(context).push<Category>(
      MaterialPageRoute(builder: (context) => const NewCategoryPage()),
    );
    if (created != null && mounted) {
      Navigator.of(context).pop(CategoryPickResult(created.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  GlassBackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _createCategory,
                    behavior: HitTestBehavior.opaque,
                    child: const Text(
                      '+ New',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.75),
                  ),
                ),
                child: TextField(
                  controller: _search,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textDark,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.grayTextLight,
                    ),
                    hintText: 'Search categories…',
                    hintStyle: TextStyle(color: AppColors.placeholderGray),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
                data: (categories) {
                  final sections = _buildSections(categories);
                  final filtered = _query.isEmpty
                      ? sections
                      : [
                          for (final section in sections)
                            _CategorySection(
                              section.title,
                              section.categories
                                  .where(
                                    (category) => category.name
                                        .toLowerCase()
                                        .contains(_query),
                                  )
                                  .toList(),
                            ),
                        ].where((section) => section.categories.isNotEmpty).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No categories found.',
                        style: TextStyle(color: AppColors.grayText),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      for (final section in filtered) ...[
                        _SectionLabel(section.title),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: section.categories.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.8,
                              ),
                          itemBuilder: (context, index) {
                            final category = section.categories[index];
                            return _CategoryTile(
                              emoji: categoryEmoji(category),
                              label: category.name,
                              selected:
                                  widget.selectedCategoryId == category.id,
                              onTap: () => Navigator.of(context).pop(
                                CategoryPickResult(category.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.accentBlue,
                  ),
                ),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Could not load categories.',
                        style: TextStyle(color: AppColors.error),
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(categoriesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.labelGray,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentBlue
              : AppColors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.accentBlue
                : AppColors.white.withValues(alpha: 0.8),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
