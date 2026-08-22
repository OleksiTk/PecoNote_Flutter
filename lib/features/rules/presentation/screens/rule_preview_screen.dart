import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../application/providers/rules_providers.dart';
import '../../domain/entities/rule.dart';
import '../../domain/entities/rule_match.dart';

class RulePreviewScreen extends ConsumerStatefulWidget {
  const RulePreviewScreen({super.key, required this.rule});

  final Rule rule;

  @override
  ConsumerState<RulePreviewScreen> createState() => _RulePreviewScreenState();
}

class _RulePreviewScreenState extends ConsumerState<RulePreviewScreen> {
  AsyncValue<RuleMatchPreview> _previewAsync = const AsyncValue.loading();
  final Set<String> _uncheckedIds = {};
  bool _applying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _previewAsync = const AsyncValue.loading());
    try {
      final preview = await ref
          .read(rulesRepositoryProvider)
          .previewMatches(widget.rule.condition);
      if (mounted) setState(() => _previewAsync = AsyncValue.data(preview));
    } on Object catch (error, stack) {
      if (mounted) setState(() => _previewAsync = AsyncValue.error(error, stack));
    }
  }

  void _toggle(String id) {
    setState(() {
      if (!_uncheckedIds.remove(id)) _uncheckedIds.add(id);
    });
  }

  Future<void> _apply(List<RuleMatchTransaction> transactions) async {
    if (_applying) return;
    final selectedIds = transactions
        .map((t) => t.id)
        .where((id) => !_uncheckedIds.contains(id))
        .toList();
    if (selectedIds.isEmpty) {
      _goToList();
      return;
    }
    setState(() {
      _applying = true;
      _error = null;
    });
    try {
      await ref
          .read(rulesRepositoryProvider)
          .applyRule(widget.rule.id, selectedIds);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Applied to ${selectedIds.length} '
            'transaction${selectedIds.length == 1 ? '' : 's'}.',
          ),
        ),
      );
      _goToList();
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  void _goToList() => context.goNamed(AppRoute.rules.name);

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                children: [
                  GlassBackButton(onPressed: _goToList),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Apply rule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Review the matching transactions before applying the '
                'category retroactively.',
                style: TextStyle(fontSize: 13, color: AppColors.grayText),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _previewAsync.when(
                data: (preview) {
                  if (preview.transactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Center(
                        child: EmptyState(
                          emoji: '🔍',
                          title: 'No matching transactions',
                          subtitle:
                              'This rule will still apply automatically to '
                              'future imports.',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                    itemCount: preview.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = preview.transactions[index];
                      return _MatchRow(
                        transaction: transaction,
                        checked: !_uncheckedIds.contains(transaction.id),
                        onToggle: () => _toggle(transaction.id),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.accentBlue,
                  ),
                ),
                error: (_, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Could not load matching transactions.',
                        style: TextStyle(color: AppColors.grayText),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _load,
                        behavior: HitTestBehavior.opaque,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
              child: Column(
                children: [
                  PillButton(
                    label: _applying ? 'Applying…' : 'Apply',
                    backgroundColor: AppColors.accentBlueMuted,
                    foregroundColor: AppColors.white,
                    borderColor: AppColors.accentBlueMuted,
                    onPressed: (_applying || !_previewAsync.hasValue)
                        ? null
                        : () => _apply(_previewAsync.value!.transactions),
                  ),
                  const SizedBox(height: 10),
                  PlainLinkText(
                    label: 'For future transactions only',
                    onTap: () {
                      if (!_applying) _goToList();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({
    required this.transaction,
    required this.checked,
    required this.onToggle,
  });

  final RuleMatchTransaction transaction;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.75)),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: checked ? AppColors.accentBlue : AppColors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: checked ? AppColors.accentBlue : AppColors.placeholderGray,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, size: 15, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description?.isNotEmpty == true
                        ? transaction.description!
                        : 'Transaction',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      DateFormat('d MMM').format(transaction.occurredAt.toLocal()),
                      if (transaction.accountName != null) transaction.accountName!,
                    ].join(' · '),
                    style: const TextStyle(fontSize: 12, color: AppColors.grayText),
                  ),
                ],
              ),
            ),
            Text(
              '₴${transaction.amount.abs().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
