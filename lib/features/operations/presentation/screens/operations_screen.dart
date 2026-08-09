import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../categories/application/providers/categories_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/screens/categories_page.dart'
    show categoryEmoji;
import '../../../transactions/application/providers/transactions_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/models/transaction_draft.dart'
    show formatCurrencyAmount;
import '../models/operations_filters.dart';
import '../widgets/category_filter_sheet.dart';
import '../widgets/date_filter_sheet.dart';

/// Екран операцій PecoNote: список транзакцій, згрупованих по днях,
/// з пошуком за назвою. Дані підʼєднані до [transactionsProvider].
class OperationsScreen extends ConsumerStatefulWidget {
  const OperationsScreen({super.key});

  @override
  ConsumerState<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends ConsumerState<OperationsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Set<int> _selectedCategoryIds = {};
  DateFilter _dateFilter = const DateFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount =>
      _selectedCategoryIds.length + (_dateFilter.isAllTime ? 0 : 1);

  Future<void> _openCategoryFilter() async {
    final categories = ref.read(categoriesProvider).value ?? const [];
    final result = await showCategoryFilterSheet(
      context,
      categories: categories,
      selected: _selectedCategoryIds,
    );
    if (result != null) setState(() => _selectedCategoryIds = result);
  }

  Future<void> _openDateFilter() async {
    final result = await showDateFilterSheet(context, initial: _dateFilter);
    if (result != null) setState(() => _dateFilter = result);
  }

  void _removeCategory(int id) {
    setState(() => _selectedCategoryIds = {..._selectedCategoryIds}..remove(id));
  }

  void _clearDateFilter() {
    setState(() => _dateFilter = const DateFilter());
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategoryIds = {};
      _dateFilter = const DateFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).value ?? const [];

    return GradientBackground(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: _OperationsHeader(
                    label: _dateFilter.label(),
                    onTap: _openDateFilter,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SearchRow(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    filterCount: _activeFilterCount,
                    onFilterTap: _openCategoryFilter,
                  ),
                ),
                if (_activeFilterCount > 0) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _FilterChipsRow(
                      categories: categories,
                      selectedCategoryIds: _selectedCategoryIds,
                      dateFilter: _dateFilter,
                      onRemoveCategory: _removeCategory,
                      onRemoveDate: _clearDateFilter,
                      onClearAll: _clearAllFilters,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    child: _OperationsSheet(
                      query: _query,
                      selectedCategoryIds: _selectedCategoryIds,
                      dateRange: _dateFilter.resolve(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: -10,
            child: SafeArea(
              top: false,
              child: AppBottomNavBar(activeTab: AppNavTab.ops),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsHeader extends StatelessWidget {
  const _OperationsHeader({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Operations',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentBlue,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.accentBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.filterCount,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int filterCount;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GlassField(
            height: 50,
            borderRadius: 18,
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.placeholderGray,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Search transactions…',
                      hintStyle: TextStyle(
                        color: AppColors.placeholderGray,
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _FilterButton(count: filterCount, onTap: onFilterTap),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const _GlassField(
              height: 50,
              borderRadius: 18,
              child: Center(
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
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

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.categories,
    required this.selectedCategoryIds,
    required this.dateFilter,
    required this.onRemoveCategory,
    required this.onRemoveDate,
    required this.onClearAll,
  });

  final List<Category> categories;
  final Set<int> selectedCategoryIds;
  final DateFilter dateFilter;
  final ValueChanged<int> onRemoveCategory;
  final VoidCallback onRemoveDate;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories)
            if (selectedCategoryIds.contains(category.id)) ...[
              _FilterChip(
                emoji: categoryEmoji(category),
                label: category.name,
                onRemove: () => onRemoveCategory(category.id),
              ),
              const SizedBox(width: 8),
            ],
          if (!dateFilter.isAllTime) ...[
            _FilterChip(label: dateFilter.label(), onRemove: onRemoveDate),
            const SizedBox(width: 8),
          ],
          _ClearAllChip(onTap: onClearAll),
        ],
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.height,
    required this.borderRadius,
    required this.child,
  });

  final double height;
  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      // Плоский колір замість BackdropFilter: пошук показаний одночасно
      // поверх постійно анімованого фону.
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
        ),
        child: child,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({this.emoji, required this.label, required this.onRemove});

  final String? emoji;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.close, size: 15, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }
}

class _ClearAllChip extends StatelessWidget {
  const _ClearAllChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: const Text(
          'Clear all',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.grayText,
          ),
        ),
      ),
    );
  }
}

class _OperationsSheet extends ConsumerWidget {
  const _OperationsSheet({
    required this.query,
    required this.selectedCategoryIds,
    required this.dateRange,
  });

  final String query;
  final Set<int> selectedCategoryIds;
  final DateTimeRange? dateRange;

  static String _titleOf(Transaction data) {
    if (data.description?.isNotEmpty == true) return data.description!;
    return switch (data.type) {
      TransactionType.income => 'Income',
      TransactionType.expense => 'Expense',
      TransactionType.transfer => 'Transfer',
    };
  }

  static String _dayKey(DateTime local) =>
      '${local.year}-${local.month}-${local.day}';

  static String _dayLabel(DateTime local) {
    final now = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final date = DateFormat('d MMM').format(local).toUpperCase();
    if (isSameDay(local, now)) return 'TODAY · $date';
    if (isSameDay(local, now.subtract(const Duration(days: 1)))) {
      return 'YESTERDAY · $date';
    }
    return date;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider).value;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        // Плоский колір замість BackdropFilter: цей лист одночасно з
        // навбаром і пошуком блюрив тло на кожен кадр анімації.
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
          ),
          child: transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'No transactions yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: AppColors.grayText),
                    ),
                  ),
                );
              }

              final trimmedQuery = query.trim().toLowerCase();
              final filtered = transactions.where((t) {
                if (trimmedQuery.isNotEmpty &&
                    !_titleOf(t).toLowerCase().contains(trimmedQuery)) {
                  return false;
                }
                if (selectedCategoryIds.isNotEmpty &&
                    !t.tagIds.any(selectedCategoryIds.contains)) {
                  return false;
                }
                if (dateRange != null) {
                  final local = t.occurredAt.toLocal();
                  if (local.isBefore(dateRange!.start) ||
                      local.isAfter(dateRange!.end)) {
                    return false;
                  }
                }
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'No transactions match your filters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: AppColors.grayText),
                    ),
                  ),
                );
              }

              final sorted = [...filtered]
                ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

              final orderedKeys = <String>[];
              final groups = <String, List<Transaction>>{};
              for (final tx in sorted) {
                final local = tx.occurredAt.toLocal();
                final key = _dayKey(local);
                if (!groups.containsKey(key)) {
                  orderedKeys.add(key);
                  groups[key] = [];
                }
                groups[key]!.add(tx);
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                children: [
                  for (final key in orderedKeys) ...[
                    _DayHeaderRow(
                      label: _dayLabel(groups[key]!.first.occurredAt.toLocal()),
                      total: _dayTotal(groups[key]!),
                    ),
                    const SizedBox(height: 4),
                    for (final tx in groups[key]!)
                      _TransactionTile(data: tx, category: _categoryFor(tx, categories)),
                    const SizedBox(height: 14),
                  ],
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.accentBlue,
              ),
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Failed to load transactions.\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: AppColors.grayText),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Category? _categoryFor(Transaction tx, List<Category>? categories) {
    if (categories == null || tx.tagIds.isEmpty) return null;
    for (final tagId in tx.tagIds) {
      for (final category in categories) {
        if (category.id == tagId) return category;
      }
    }
    return null;
  }

  static String _dayTotal(List<Transaction> transactions) {
    var total = 0.0;
    for (final tx in transactions) {
      switch (tx.type) {
        case TransactionType.income:
          total += tx.total;
        case TransactionType.expense:
          total -= tx.total;
        case TransactionType.transfer:
          break;
      }
    }
    final sign = total < 0 ? '−' : (total > 0 ? '+' : '');
    return '$sign₴ ${formatCurrencyAmount(total.abs())}';
  }
}

class _DayHeaderRow extends StatelessWidget {
  const _DayHeaderRow({required this.label, required this.total});

  final String label;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.grayText,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Text(
            total,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data, required this.category});

  final Transaction data;
  final Category? category;

  static const _emojiByType = {
    TransactionType.income: '💼',
    TransactionType.expense: '🧾',
    TransactionType.transfer: '🔁',
  };

  @override
  Widget build(BuildContext context) {
    final isIncome = data.type == TransactionType.income;
    final title = data.description?.isNotEmpty == true
        ? data.description!
        : switch (data.type) {
            TransactionType.income => 'Income',
            TransactionType.expense => 'Expense',
            TransactionType.transfer => 'Transfer',
          };
    final sign = switch (data.type) {
      TransactionType.expense => '−',
      TransactionType.income => '+',
      TransactionType.transfer => '',
    };
    final icon = category != null
        ? categoryEmoji(category!)
        : _emojiByType[data.type] ?? '🧾';
    final subtitle =
        '${category?.name ?? title} · '
        '${DateFormat('HH:mm').format(data.occurredAt.toLocal())}';

    return GestureDetector(
      onTap: () =>
          context.pushNamed(AppRoute.transactionView.name, extra: data),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$sign₴ ${formatCurrencyAmount(data.total)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.income : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
