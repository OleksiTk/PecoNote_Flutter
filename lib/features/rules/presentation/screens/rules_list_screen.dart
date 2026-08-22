import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../accounts/application/providers/accounts_providers.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../categories/application/providers/categories_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/screens/categories_page.dart'
    show categoryEmoji;
import '../../application/providers/rules_providers.dart';
import '../../domain/entities/rule.dart';
import '../../domain/entities/rule_condition.dart';
import '../widgets/rule_texts.dart';

class RulesListScreen extends ConsumerWidget {
  const RulesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(rulesProvider);
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
              child: Row(
                children: [
                  GlassBackButton(onPressed: () => context.pop()),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Rules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pushNamed(AppRoute.ruleEditor.name),
                    behavior: HitTestBehavior.opaque,
                    child: const Text(
                      '+ New Rule',
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
            const SizedBox(height: 16),
            Expanded(
              child: rulesAsync.when(
                data: (rules) {
                  if (rules.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Center(
                        child: EmptyState(
                          emoji: '🧩',
                          title: 'No rules yet',
                          subtitle:
                              'Create a rule to automatically categorize '
                              'matching payments.',
                          actionLabel: '+ New Rule',
                          onAction: () =>
                              context.pushNamed(AppRoute.ruleEditor.name),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    itemCount: rules.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      final category = categories
                          .where((c) => c.id == rule.categoryId)
                          .firstOrNull;
                      final account =
                          rule.condition.type ==
                              CategoryRuleConditionType.accountEquals
                          ? accounts
                                .where((a) => a.id == rule.condition.accountId)
                                .firstOrNull
                          : null;
                      return _RuleRow(
                        rule: rule,
                        categoryName: category?.name,
                        categoryEmojiText: category != null
                            ? categoryEmoji(category)
                            : null,
                        accountName: account?.name,
                        onTap: () => context.pushNamed(
                          AppRoute.ruleEditor.name,
                          extra: rule,
                        ),
                        onToggle: (value) => ref
                            .read(rulesProvider.notifier)
                            .setActive(rule.id, value),
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
                        'Could not load rules.',
                        style: TextStyle(color: AppColors.grayText),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => ref.invalidate(rulesProvider),
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
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatefulWidget {
  const _RuleRow({
    required this.rule,
    required this.onTap,
    required this.onToggle,
    this.categoryName,
    this.categoryEmojiText,
    this.accountName,
  });

  final Rule rule;
  final VoidCallback onTap;
  final Future<void> Function(bool isActive) onToggle;
  final String? categoryName;
  final String? categoryEmojiText;
  final String? accountName;

  @override
  State<_RuleRow> createState() => _RuleRowState();
}

class _RuleRowState extends State<_RuleRow> {
  bool _toggling = false;

  Future<void> _handleToggle(bool value) async {
    if (_toggling) return;
    setState(() => _toggling = true);
    try {
      await widget.onToggle(value);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not update rule: $error')));
      }
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rule = widget.rule;
    final title = ruleDisplayTitle(
      rule,
      categoryName: widget.categoryName,
      accountName: widget.accountName,
    );
    final summary = conditionSummaryText(
      rule.condition,
      accountName: widget.accountName,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.75),
                ),
              ),
              child: Row(
                children: [
                  if (widget.categoryEmojiText != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      child: Text(
                        widget.categoryEmojiText!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
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
                        const SizedBox(height: 3),
                        Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grayText,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'matched ${rule.matchedCount} payments',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grayTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ActiveSwitch(
                    value: rule.isActive,
                    enabled: !_toggling,
                    onChanged: _handleToggle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveSwitch extends StatelessWidget {
  const _ActiveSwitch({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value
              ? AppColors.success.withValues(alpha: 0.55)
              : AppColors.placeholderGray.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
        ),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlue.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
