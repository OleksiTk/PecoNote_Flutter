import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../categories/application/providers/categories_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/domain/entities/category_tree.dart';
import '../../../settings/application/providers/settings_providers.dart';
import '../../application/providers/transactions_providers.dart';
import '../../domain/entities/transaction.dart' show TransactionType;
import '../models/transaction_draft.dart';

class _TransferAccount {
  const _TransferAccount({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.name,
    required this.balance,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String name;
  final double balance;
}

const _monoBlack = _TransferAccount(
  icon: Icons.credit_card,
  iconBg: AppColors.iconBgMintLight,
  iconFg: AppColors.iconFgGreen,
  name: 'Mono Black •4421',
  balance: 24850.70,
);

const _savingsJar = _TransferAccount(
  icon: Icons.savings_outlined,
  iconBg: AppColors.iconBgOrangeSoft,
  iconFg: AppColors.iconFgOrangeSoft,
  name: 'Savings jar',
  balance: 1000,
);

class TransactionDetailsScreen extends ConsumerStatefulWidget {
  const TransactionDetailsScreen({super.key, required this.draft});

  final TransactionDraft draft;

  @override
  ConsumerState<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState
    extends ConsumerState<TransactionDetailsScreen> {
  int? _selectedCategoryId;
  DateTime _date = DateTime.now();
  String? _note;
  bool _repeatsMonthly = false;
  bool _accountsSwapped = false;
  bool _saving = false;
  String? _categoryError;
  String? _error;

  _TransferAccount get _fromAccount =>
      _accountsSwapped ? _savingsJar : _monoBlack;
  _TransferAccount get _toAccount =>
      _accountsSwapped ? _monoBlack : _savingsJar;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.home.name);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 5),
      lastDate: DateTime(_date.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _editNote() async {
    final controller = TextEditingController(text: _note);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Add a note…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => _note = result.isEmpty ? null : result);
  }

  Future<void> _save() async {
    final draft = widget.draft;
    // Перекази поки не зберігаються: тут потрібен другий реальний рахунок,
    // а UI для "From/To" ще працює на статичних тестових акаунтах.
    if (draft.kind == TransactionKind.transfer || draft.accountId == null) {
      context.goNamed(AppRoute.home.name);
      return;
    }

    setState(() {
      _saving = true;
      _categoryError = null;
      _error = null;
    });
    try {
      final currencies = await ref.read(userCurrenciesProvider.future);
      if (currencies.isEmpty) {
        throw const NetworkFailure(
          'Set a default currency in Settings before saving.',
        );
      }
      await ref
          .read(transactionsProvider.notifier)
          .create(
            type: draft.kind == TransactionKind.income
                ? TransactionType.income
                : TransactionType.expense,
            accountId: draft.accountId!,
            amount: draft.amount,
            currencyId: currencies.first.id,
            counterpartyName: _note ?? '',
            occurredAt: _date,
            description: _note,
            tagIds: _selectedCategoryId == null
                ? const []
                : [_selectedCategoryId!],
          );
      if (mounted) context.goNamed(AppRoute.home.name);
    } on ValidationFailure catch (failure) {
      if (mounted) {
        final hasNonCategoryErrors = failure.fieldErrors.keys.any(
          (field) => field != 'tag',
        );
        setState(() {
          _categoryError = failure.fieldErrors['tag']?.join('\n');
          _error = hasNonCategoryErrors ? failure.message : null;
        });
      }
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String get _dateLabel {
    final now = DateTime.now();
    final isToday =
        _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
    final formatted = DateFormat('d MMM').format(_date);
    return isToday ? 'Today, $formatted' : formatted;
  }

  Future<void> _openCategoryPicker(List<Category> categories) async {
    final result = await showModalBottomSheet<_CategoryPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => _CategoryPickerSheet(
        categories: categories,
        selectedCategoryId: _selectedCategoryId,
      ),
    );
    if (result == null || !mounted) return;

    if (result.createNew) {
      final created = await showDialog<Category>(
        context: context,
        builder: (context) => _CreateCategoryDialog(categories: categories),
      );
      if (created == null || !mounted) return;
      setState(() {
        _selectedCategoryId = created.id;
        _categoryError = null;
      });
      return;
    }

    setState(() {
      _selectedCategoryId = result.categoryId;
      _categoryError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final isTransfer = draft.kind == TransactionKind.transfer;
    final categoriesAsync = isTransfer
        ? const AsyncData<List<Category>>([])
        : ref.watch(categoriesProvider);

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    GlassBackButton(onPressed: _goBack),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        isTransfer ? 'Transfer' : 'Details',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      child: const Text(
                        'Step 2 of 2',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                  child: LinearProgressIndicator(
                    value: 1,
                    minHeight: 4,
                    backgroundColor: AppColors.dotInactive,
                    valueColor: AlwaysStoppedAnimation(AppColors.accentBlue),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Text(
                      '${draft.kind.sign}₴ ${draft.wholeAmount}.${draft.decimalAmount}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _goBack,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        child: const Text(
                          'edit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isTransfer) ...[
                const _SectionLabel('FROM ACCOUNT'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AccountCard(
                    icon: _fromAccount.icon,
                    iconBg: _fromAccount.iconBg,
                    iconFg: _fromAccount.iconFg,
                    name: _fromAccount.name,
                    subtitle:
                        '₴${formatCurrencyAmount(_fromAccount.balance)} available',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 44, 6),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _SwapButton(
                      onTap: () =>
                          setState(() => _accountsSwapped = !_accountsSwapped),
                    ),
                  ),
                ),
                const _SectionLabel('TO ACCOUNT'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _AccountCard(
                    icon: _toAccount.icon,
                    iconBg: _toAccount.iconBg,
                    iconFg: _toAccount.iconFg,
                    name: _toAccount.name,
                    subtitle:
                        '₴${formatCurrencyAmount(_toAccount.balance)} · '
                        'after: ₴${formatCurrencyAmount(_toAccount.balance + draft.amount)}',
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.calendar_today,
                          iconBg: AppColors.accentBlueBg,
                          iconFg: AppColors.accentBlue,
                          label: 'Date',
                          value: _dateLabel,
                          onTap: _pickDate,
                        ),
                        const _DetailDivider(),
                        _DetailRow(
                          icon: Icons.description_outlined,
                          iconBg: AppColors.iconBgRed,
                          iconFg: AppColors.iconFgRed,
                          label: 'Note',
                          value: _note ?? 'optional',
                          isPlaceholder: _note == null,
                          onTap: _editNote,
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    'Transfers stay out of Statistics — they move money, '
                    'they do not spend it.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.grayText),
                  ),
                ),
              ] else ...[
                const _SectionLabel('CATEGORY'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _CategorySelector(
                    categoriesAsync: categoriesAsync,
                    selectedCategoryId: _selectedCategoryId,
                    errorText: _categoryError,
                    onSelected: (categoryId) => setState(() {
                      _selectedCategoryId = categoryId;
                      _categoryError = null;
                    }),
                    onShowAll: _openCategoryPicker,
                    onRetry: () => ref.invalidate(categoriesProvider),
                  ),
                ),
                const _SectionLabel('WHERE IT COMES FROM'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.credit_card,
                          iconBg: AppColors.iconBgMintLight,
                          iconFg: AppColors.iconFgGreen,
                          label: 'Account',
                          value: draft.accountLabel,
                        ),
                        const _DetailDivider(),
                        _DetailRow(
                          icon: Icons.calendar_today,
                          iconBg: AppColors.accentBlueBg,
                          iconFg: AppColors.accentBlue,
                          label: 'Date',
                          value: _dateLabel,
                          onTap: _pickDate,
                        ),
                        const _DetailDivider(),
                        _DetailRow(
                          icon: Icons.description_outlined,
                          iconBg: AppColors.iconBgRed,
                          iconFg: AppColors.iconFgRed,
                          label: 'Note',
                          value: _note ?? 'optional',
                          isPlaceholder: _note == null,
                          onTap: _editNote,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _repeatsMonthly = !_repeatsMonthly),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _repeatsMonthly
                                ? AppColors.accentBlue
                                : AppColors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _repeatsMonthly
                                  ? AppColors.accentBlue
                                  : AppColors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          child: _repeatsMonthly
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Repeats monthly',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: PillButton(
                  label: _saving ? 'Saving…' : draft.kind.saveLabel,
                  onPressed: _saving ? null : () => unawaited(_save()),
                  backgroundColor: AppColors.accentBlueMuted,
                  foregroundColor: AppColors.white,
                  borderColor: AppColors.accentBlueMuted,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.labelGray,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.name,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.75)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.grayTextLight,
          ),
        ],
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlue.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.swap_vert,
            size: 18,
            color: AppColors.accentBlue,
          ),
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categoriesAsync,
    required this.selectedCategoryId,
    required this.errorText,
    required this.onSelected,
    required this.onShowAll,
    required this.onRetry,
  });

  final AsyncValue<List<Category>> categoriesAsync;
  final int? selectedCategoryId;
  final String? errorText;
  final ValueChanged<int?> onSelected;
  final ValueChanged<List<Category>> onShowAll;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        categoriesAsync.when(
          data: (categories) {
            final quickCategories = _quickCategories(
              categories,
              selectedCategoryId,
            );
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CategoryChip(
                  icon: Icons.not_interested_outlined,
                  label: 'No category',
                  selected: selectedCategoryId == null,
                  onTap: () => onSelected(null),
                ),
                for (final category in quickCategories)
                  _CategoryChip(
                    icon: Icons.sell_outlined,
                    label: category.name,
                    selected: selectedCategoryId == category.id,
                    onTap: () => onSelected(category.id),
                  ),
                _AllCategoriesChip(onTap: () => onShowAll(categories)),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 42,
            child: Align(
              alignment: Alignment.centerLeft,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.accentBlue,
              ),
            ),
          ),
          error: (_, _) => Row(
            children: [
              const Expanded(
                child: Text(
                  'Could not load categories.',
                  style: TextStyle(fontSize: 13, color: AppColors.error),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 12.5, color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

List<Category> _quickCategories(
  List<Category> categories,
  int? selectedCategoryId,
) {
  final children = categories
      .where((category) => category.parentId != null)
      .toList();
  final candidates = children.isEmpty ? categories : children;
  final quick = candidates.take(4).toList();
  if (selectedCategoryId == null ||
      quick.any((category) => category.id == selectedCategoryId)) {
    return quick;
  }

  final selected = categories
      .where((category) => category.id == selectedCategoryId)
      .firstOrNull;
  if (selected == null) return quick;
  if (quick.length < 4) return [...quick, selected];
  return [...quick.take(3), selected];
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width - 40,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.textDark
              : AppColors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected
                ? AppColors.textDark
                : AppColors.white.withValues(alpha: 0.9),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? AppColors.white : AppColors.grayText,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.white : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllCategoriesChip extends StatelessWidget {
  const _AllCategoriesChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: AppColors.accentBlue.withValues(alpha: 0.5),
          ),
        ),
        child: const Text(
          'All categories',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.accentBlue,
          ),
        ),
      ),
    );
  }
}

class _CategoryPickerResult {
  const _CategoryPickerResult.selection(this.categoryId) : createNew = false;
  const _CategoryPickerResult.create() : categoryId = null, createNew = true;

  final int? categoryId;
  final bool createNew;
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedCategoryId,
  });

  final List<Category> categories;
  final int? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final rows = _flattenCategoryTree(categories);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F5F8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayTextLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'All categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              _CategoryPickerRow(
                icon: Icons.not_interested_outlined,
                label: 'No category',
                selected: selectedCategoryId == null,
                depth: 0,
                onTap: () => Navigator.of(
                  context,
                ).pop(const _CategoryPickerResult.selection(null)),
              ),
              for (final row in rows)
                _CategoryPickerRow(
                  icon: row.depth == 0
                      ? Icons.folder_outlined
                      : Icons.sell_outlined,
                  label: row.category.name,
                  selected: selectedCategoryId == row.category.id,
                  depth: row.depth,
                  onTap: () => Navigator.of(
                    context,
                  ).pop(_CategoryPickerResult.selection(row.category.id)),
                ),
              const Divider(height: 24),
              _CategoryPickerRow(
                icon: Icons.add,
                label: 'Create category',
                selected: false,
                depth: 0,
                accent: true,
                onTap: () => Navigator.of(
                  context,
                ).pop(const _CategoryPickerResult.create()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTreeRow {
  const _CategoryTreeRow(this.category, this.depth);

  final Category category;
  final int depth;
}

List<_CategoryTreeRow> _flattenCategoryTree(List<Category> categories) {
  final rows = <_CategoryTreeRow>[];
  final includedIds = <int>{};

  void addItem(CategoryTreeItem item, int depth) {
    if (!includedIds.add(item.category.id)) return;
    rows.add(_CategoryTreeRow(item.category, depth));
    for (final child in item.children) {
      addItem(child, depth + 1);
    }
  }

  for (final root in buildCategoryTree(categories)) {
    addItem(root, 0);
  }
  for (final category in categories) {
    if (includedIds.add(category.id)) {
      rows.add(_CategoryTreeRow(category, 0));
    }
  }
  return rows;
}

class _CategoryPickerRow extends StatelessWidget {
  const _CategoryPickerRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.depth,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final int depth;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.accentBlue : AppColors.textDark;
    return Material(
      color: selected
          ? AppColors.accentBlueBg.withValues(alpha: 0.7)
          : AppColors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14 + depth * 20, 12, 14, 12),
          child: Row(
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: depth == 0 || accent
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check, size: 19, color: AppColors.accentBlue),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateCategoryDialog extends ConsumerStatefulWidget {
  const _CreateCategoryDialog({required this.categories});

  final List<Category> categories;

  @override
  ConsumerState<_CreateCategoryDialog> createState() =>
      _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends ConsumerState<_CreateCategoryDialog> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  int? _parentId;
  bool _saving = false;
  Map<String, List<String>> _fieldErrors = const {};
  String? _error;

  String? _fieldError(String field) => _fieldErrors[field]?.join('\n');

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _saving) {
      if (name.isEmpty) {
        setState(() {
          _fieldErrors = const {
            'name': ['Enter a category name.'],
          };
        });
      }
      return;
    }

    setState(() {
      _saving = true;
      _fieldErrors = const {};
      _error = null;
    });
    try {
      final description = _description.text.trim();
      final created = await ref
          .read(categoriesProvider.notifier)
          .createCategory(
            name: name,
            description: description.isEmpty ? null : description,
            parentId: _parentId,
          );
      if (mounted) Navigator.of(context).pop(created);
    } on ValidationFailure catch (failure) {
      if (mounted) {
        setState(() {
          _fieldErrors = failure.fieldErrors;
          _error =
              failure.fieldErrors.keys.any(
                (field) => field != 'name' && field != 'description',
              )
              ? failure.message
              : null;
        });
      }
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentCategories = widget.categories;
    return AlertDialog(
      title: const Text('Create category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              enabled: !_saving,
              autofocus: true,
              maxLength: 64,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (_fieldErrors.containsKey('name')) {
                  setState(() {
                    _fieldErrors = Map.of(_fieldErrors)..remove('name');
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: _fieldError('name'),
              ),
            ),
            TextField(
              controller: _description,
              enabled: !_saving,
              maxLength: 256,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                errorText: _fieldError('description'),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _parentId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Parent category',
                errorText: _fieldError('parent'),
              ),
              hint: const Text('No parent'),
              items: [
                const DropdownMenuItem(value: -1, child: Text('No parent')),
                for (final category in parentCategories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() {
                      _parentId = value == -1 ? null : value;
                      _fieldErrors = Map.of(_fieldErrors)..remove('parent');
                    }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(fontSize: 12.5, color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saving ? null : () => unawaited(_save()),
          child: Text(_saving ? 'Creating…' : 'Create'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final String value;
  final bool isPlaceholder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPlaceholder
                      ? AppColors.placeholderGray
                      : AppColors.grayText,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.grayTextLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.white.withValues(alpha: 0.8),
    );
  }
}
