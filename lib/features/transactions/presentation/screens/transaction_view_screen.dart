import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../accounts/application/providers/accounts_providers.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../categories/application/providers/categories_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/screens/categories_page.dart';
import '../../application/providers/transactions_providers.dart';
import '../../domain/entities/transaction.dart';
import '../models/transaction_draft.dart' show formatCurrencyAmount;

/// Read-only view of a single transaction, opened by tapping a transaction
/// row on the home page or the operations page. Category is the one field
/// that's actually editable end to end (via [TransactionsNotifier
/// .updateTransactionTags]) — the backend has no generic transaction-update
/// endpoint and no MCC / bank-import / "counted in stats" / rule-match data,
/// so this screen only shows and edits what the API actually provides.
class TransactionViewScreen extends ConsumerWidget {
  const TransactionViewScreen({super.key, required this.transaction});

  final Transaction transaction;

  static const _emojiByType = {
    TransactionType.income: '💼',
    TransactionType.expense: '🧾',
    TransactionType.transfer: '🔁',
  };

  Future<void> _editCategory(BuildContext context, WidgetRef ref, Transaction current) async {
    final currentCategoryId = current.tagIds.isEmpty ? null : current.tagIds.first;
    final result = await Navigator.of(context).push<CategoryPickResult>(
      MaterialPageRoute(
        builder: (context) =>
            CategoriesPage(selectedCategoryId: currentCategoryId),
      ),
    );
    if (result == null) return;
    try {
      await ref
          .read(transactionsProvider.notifier)
          .updateTransactionTags(
            id: current.id,
            tagIds: result.categoryId == null ? [] : [result.categoryId!],
          );
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Transaction current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this transaction?'),
        content: const Text(
          'It will be moved to trash and removed from your totals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(transactionsProvider.notifier).trash(current.id);
      if (context.mounted) context.pop();
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider).value;
    final current = transactions?.firstWhere(
          (t) => t.id == transaction.id,
          orElse: () => transaction,
        ) ??
        transaction;

    final categories = ref.watch(categoriesProvider).value;
    final category = _categoryFor(current, categories);
    final accounts = ref.watch(accountsProvider).value;
    final account = _accountFor(current, accounts);

    final isIncome = current.type == TransactionType.income;
    final title = current.description?.isNotEmpty == true
        ? current.description!
        : switch (current.type) {
            TransactionType.income => 'Income',
            TransactionType.expense => 'Expense',
            TransactionType.transfer => 'Transfer',
          };
    final sign = switch (current.type) {
      TransactionType.expense => '−',
      TransactionType.income => '+',
      TransactionType.transfer => '',
    };
    final icon = category != null
        ? categoryEmoji(category)
        : _emojiByType[current.type] ?? '🧾';

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  GlassBackButton(onPressed: () => context.pop()),
                  const Expanded(
                    child: Text(
                      'Transaction',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  _EditButton(onTap: () => _editCategory(context, ref, current)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 40),
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      '$sign₴${formatCurrencyAmount(current.total)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isIncome ? AppColors.income : AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grayText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _DetailCard(
                    rows: [
                      _DetailRow(
                        label: 'Category',
                        value: category != null
                            ? '${categoryEmoji(category)} ${category.name}'
                            : 'Uncategorized',
                        onTap: () => _editCategory(context, ref, current),
                      ),
                      _DetailRow(
                        label: 'Account',
                        value: account?.name ?? '—',
                      ),
                      _DetailRow(
                        label: 'Date & time',
                        value: DateFormat(
                          'd MMM, HH:mm',
                        ).format(current.occurredAt.toLocal()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _DetailCard(
                    tint: const Color(0xFFFFE0DA),
                    rows: [
                      _DetailRow(
                        label: 'Delete transaction',
                        labelColor: AppColors.notificationDot,
                        onTap: () => _delete(context, ref, current),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

  static Account? _accountFor(Transaction tx, List<Account>? accounts) {
    if (accounts == null) return null;
    for (final account in accounts) {
      if (account.id == tx.accountId) return account;
    }
    return null;
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.iconBgOrangeSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 17,
              color: AppColors.iconFgOrangeSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.rows, this.tint});

  final List<_DetailRow> rows;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: (tint ?? AppColors.white).withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.white.withValues(alpha: 0.55),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.value,
    this.labelColor,
    this.onTap,
  });

  final String label;
  final String? value;
  final Color? labelColor;
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? AppColors.grayText,
                ),
              ),
              const Spacer(),
              if (value != null)
                Text(
                  value!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: labelColor ?? AppColors.placeholderGray,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
