import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/entities/category_tree.dart';
import '../../../categories/presentation/screens/categories_page.dart'
    show categoryEmoji;

class _CategoryFilterSection {
  const _CategoryFilterSection(this.title, this.categories);

  final String title;
  final List<Category> categories;
}

List<_CategoryFilterSection> _buildSections(List<Category> categories) {
  final roots = buildCategoryTree(categories);
  final sections = <_CategoryFilterSection>[];
  final ungrouped = <Category>[];

  for (final root in roots) {
    if (root.children.isEmpty) {
      ungrouped.add(root.category);
    } else {
      sections.add(
        _CategoryFilterSection(
          root.category.name.toUpperCase(),
          [for (final child in root.children) child.category],
        ),
      );
    }
  }

  if (ungrouped.isNotEmpty) {
    sections.add(
      _CategoryFilterSection(sections.isEmpty ? 'CATEGORIES' : 'OTHER', ungrouped),
    );
  }

  return sections;
}

/// Opens the category filter bottom sheet and resolves with the newly
/// selected category ids, or null if the sheet was dismissed without
/// applying.
Future<Set<int>?> showCategoryFilterSheet(
  BuildContext context, {
  required List<Category> categories,
  required Set<int> selected,
}) {
  return showModalBottomSheet<Set<int>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => _CategoryFilterSheet(
      categories: categories,
      initialSelected: selected,
    ),
  );
}

class _CategoryFilterSheet extends StatefulWidget {
  const _CategoryFilterSheet({
    required this.categories,
    required this.initialSelected,
  });

  final List<Category> categories;
  final Set<int> initialSelected;

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet> {
  late final Set<int> _selected = {...widget.initialSelected};

  String get _subtitle {
    if (_selected.isEmpty) return 'All categories';
    final names = [
      for (final category in widget.categories)
        if (_selected.contains(category.id)) category.name,
    ];
    return '${_selected.length} selected · ${names.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(widget.categories);
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.scaffoldVivid,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: _DragHandle(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category filter',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(_selected.clear),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 12, top: 2),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentBlueMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final section in sections) ...[
                        _SectionLabel(section.title),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final category in section.categories)
                              _CategoryChip(
                                emoji: categoryEmoji(category),
                                label: category.name,
                                selected: _selected.contains(category.id),
                                onTap: () => setState(() {
                                  if (!_selected.remove(category.id)) {
                                    _selected.add(category.id);
                                  }
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
                child: PillButton(
                  label: 'Apply',
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: AppColors.white,
                  borderColor: AppColors.accentBlue,
                  onPressed: () => Navigator.of(context).pop(_selected),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.dotInactive,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.labelGray,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBlue : AppColors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? AppColors.accentBlue : AppColors.subChipBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
