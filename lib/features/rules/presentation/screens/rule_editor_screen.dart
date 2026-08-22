import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../../accounts/application/providers/accounts_providers.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../categories/application/providers/categories_providers.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/screens/categories_page.dart';
import '../../../settings/presentation/widgets/settings_sheet_shell.dart';
import '../../application/providers/rules_providers.dart';
import '../../domain/entities/rule.dart';
import '../../domain/entities/rule_condition.dart';
import '../widgets/rule_texts.dart';

class RuleEditorScreen extends ConsumerStatefulWidget {
  const RuleEditorScreen({super.key, this.rule});

  final Rule? rule;

  @override
  ConsumerState<RuleEditorScreen> createState() => _RuleEditorScreenState();
}

class _RuleEditorScreenState extends ConsumerState<RuleEditorScreen> {
  late CategoryRuleConditionType _conditionType;
  final _textValue = TextEditingController();
  final _mccValue = TextEditingController();
  final _amountMin = TextEditingController();
  final _amountMax = TextEditingController();
  String? _accountId;
  int? _categoryId;
  bool _excludeFromAnalytics = false;
  RuleOutcomeKind _outcomeKind = RuleOutcomeKind.none;
  bool _applyToExisting = false;

  bool _saving = false;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  Timer? _debounce;
  int? _previewCount;
  bool _previewLoading = false;

  bool get _isEditing => widget.rule != null;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _conditionType =
        rule?.condition.type ?? CategoryRuleConditionType.merchantContains;
    _textValue.text = rule?.condition.textValue ?? '';
    _mccValue.text = rule?.condition.mcc?.toString() ?? '';
    _accountId = rule?.condition.accountId;
    _amountMin.text = rule?.condition.amountMin?.toString() ?? '';
    _amountMax.text = rule?.condition.amountMax?.toString() ?? '';
    _categoryId = rule?.categoryId;
    _excludeFromAnalytics = rule?.excludeFromAnalytics ?? false;
    _outcomeKind = rule?.outcomeKind ?? RuleOutcomeKind.none;
    _applyToExisting = rule?.applyToExisting ?? false;

    for (final controller in [_textValue, _mccValue, _amountMin, _amountMax]) {
      controller.addListener(_scheduleLivePreview);
    }
    _scheduleLivePreview();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textValue.dispose();
    _mccValue.dispose();
    _amountMin.dispose();
    _amountMax.dispose();
    super.dispose();
  }

  RuleCondition _buildCondition() {
    return switch (_conditionType) {
      CategoryRuleConditionType.merchantContains ||
      CategoryRuleConditionType.descriptionContains ||
      CategoryRuleConditionType.counterpartyEquals => RuleCondition(
        type: _conditionType,
        textValue: _textValue.text.trim(),
      ),
      CategoryRuleConditionType.mccEquals => RuleCondition(
        type: _conditionType,
        mcc: int.tryParse(_mccValue.text.trim()),
      ),
      CategoryRuleConditionType.accountEquals => RuleCondition(
        type: _conditionType,
        accountId: _accountId,
      ),
      CategoryRuleConditionType.amountRange => RuleCondition(
        type: _conditionType,
        amountMin: double.tryParse(_amountMin.text.trim()),
        amountMax: double.tryParse(_amountMax.text.trim()),
      ),
    };
  }

  void _scheduleLivePreview() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetchPreview);
  }

  Future<void> _fetchPreview() async {
    final condition = _buildCondition();
    if (!condition.isFilled) {
      if (mounted) {
        setState(() {
          _previewCount = null;
          _previewLoading = false;
        });
      }
      return;
    }
    setState(() => _previewLoading = true);
    try {
      final preview = await ref
          .read(rulesRepositoryProvider)
          .previewMatches(condition);
      if (mounted) {
        setState(() {
          _previewCount = preview.count;
          _previewLoading = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _previewCount = null;
          _previewLoading = false;
        });
      }
    }
  }

  void _selectConditionType(CategoryRuleConditionType type) {
    setState(() => _conditionType = type);
    _scheduleLivePreview();
  }

  Future<void> _pickConditionType() async {
    final selected = await showModalBottomSheet<CategoryRuleConditionType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => _ConditionTypePickerSheet(current: _conditionType),
    );
    if (selected != null) _selectConditionType(selected);
  }

  Future<void> _pickAccount() async {
    final accounts = ref.read(accountsProvider).value ?? const <Account>[];
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) =>
          _AccountPickerSheet(accounts: accounts, currentId: _accountId),
    );
    if (selected != null) {
      setState(() => _accountId = selected);
      _scheduleLivePreview();
    }
  }

  Future<void> _pickCategory() async {
    final result = await Navigator.of(context).push<CategoryPickResult>(
      MaterialPageRoute(
        builder: (context) => CategoriesPage(selectedCategoryId: _categoryId),
      ),
    );
    if (result != null && mounted) {
      setState(() => _categoryId = result.categoryId);
    }
  }

  String? get _conditionFieldError {
    return switch (_conditionType) {
      CategoryRuleConditionType.merchantContains =>
        _fieldErrors['merchant_contains']?.join('\n'),
      CategoryRuleConditionType.descriptionContains =>
        _fieldErrors['description_contains']?.join('\n'),
      CategoryRuleConditionType.counterpartyEquals =>
        _fieldErrors['counterparty_equals']?.join('\n'),
      CategoryRuleConditionType.mccEquals => _fieldErrors['mcc']?.join('\n'),
      CategoryRuleConditionType.accountEquals =>
        _fieldErrors['account']?.join('\n'),
      CategoryRuleConditionType.amountRange =>
        (_fieldErrors['min_amount'] ?? _fieldErrors['max_amount'])?.join('\n'),
    };
  }

  Future<void> _save() async {
    if (_saving) return;
    final condition = _buildCondition();
    if (!condition.isFilled) {
      setState(() => _error = 'Fill in the condition value.');
      return;
    }
    if (_categoryId == null && _outcomeKind != RuleOutcomeKind.transfer) {
      setState(
        () => _error = 'Choose a category, or mark this rule as a transfer.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
      _fieldErrors = const {};
    });

    final categories = ref.read(categoriesProvider).value ?? const <Category>[];
    final category = categories.where((c) => c.id == _categoryId).firstOrNull;
    final accounts = ref.read(accountsProvider).value ?? const <Account>[];
    final account = _accountId == null
        ? null
        : accounts.where((a) => a.id == _accountId).firstOrNull;
    final name = ruleFallbackTitle(
      condition,
      categoryName: category?.name,
      accountName: account?.name,
    );

    try {
      final notifier = ref.read(rulesProvider.notifier);
      final saved = _isEditing
          ? await notifier.updateRule(
              id: widget.rule!.id,
              name: name,
              condition: condition,
              categoryId: _categoryId,
              excludeFromAnalytics: _excludeFromAnalytics,
              outcomeKind: _outcomeKind,
              applyToExisting: _applyToExisting,
            )
          : await notifier.create(
              name: name,
              condition: condition,
              categoryId: _categoryId,
              excludeFromAnalytics: _excludeFromAnalytics,
              outcomeKind: _outcomeKind,
              applyToExisting: _applyToExisting,
            );

      if (!mounted) return;
      if (_applyToExisting) {
        context.pushReplacementNamed(AppRoute.rulePreview.name, extra: saved);
      } else {
        context.pop();
      }
    } on ValidationFailure catch (failure) {
      if (mounted) {
        setState(() {
          _fieldErrors = failure.fieldErrors;
          _error = failure.fieldErrors.containsKey('non_field_errors')
              ? failure.fieldErrors['non_field_errors']!.join('\n')
              : failure.message;
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
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final category = categories.where((c) => c.id == _categoryId).firstOrNull;
    final account = _accountId == null
        ? null
        : accounts.where((a) => a.id == _accountId).firstOrNull;

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlassBackButton(onPressed: () => context.pop()),
                        const SizedBox(width: 14),
                        Text(
                          _isEditing ? 'Edit rule' : 'New rule',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    const _SectionLabel('IF'),
                    const SizedBox(height: 8),
                    _GlassBlock(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabeledField(
                            label: 'CONDITION',
                            child: GestureDetector(
                              onTap: _pickConditionType,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      conditionTypeLabel(_conditionType),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.expand_more,
                                    size: 20,
                                    color: AppColors.grayText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ConditionValueInput(
                            type: _conditionType,
                            textController: _textValue,
                            mccController: _mccValue,
                            amountMinController: _amountMin,
                            amountMaxController: _amountMax,
                            accountName: account?.name,
                            onPickAccount: _pickAccount,
                          ),
                          if (_conditionFieldError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _conditionFieldError!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          _PreviewLine(
                            loading: _previewLoading,
                            count: _previewCount,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    const _SectionLabel('THEN'),
                    const SizedBox(height: 8),
                    _GlassBlock(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabeledField(
                            label: 'CATEGORY',
                            child: GestureDetector(
                              onTap: _pickCategory,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                children: [
                                  if (category != null) ...[
                                    Text(
                                      categoryEmoji(category),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      category?.name ??
                                          (_outcomeKind ==
                                                  RuleOutcomeKind.transfer
                                              ? 'None (transfer)'
                                              : 'Select category'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: category != null
                                            ? AppColors.textDark
                                            : AppColors.placeholderGray,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: AppColors.placeholderGray,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_fieldErrors['set_tag'] != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _fieldErrors['set_tag']!.join('\n'),
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          _CheckRow(
                            label: 'Exclude from analytics',
                            value: _excludeFromAnalytics,
                            onChanged: (value) =>
                                setState(() => _excludeFromAnalytics = value),
                          ),
                          const SizedBox(height: 12),
                          _OutcomeSelector(
                            value: _outcomeKind,
                            onChanged: (value) =>
                                setState(() => _outcomeKind = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    const _SectionLabel('APPLY'),
                    const SizedBox(height: 8),
                    _GlassBlock(
                      child: _CheckRow(
                        label: 'Apply to already imported transactions',
                        value: _applyToExisting,
                        onChanged: (value) =>
                            setState(() => _applyToExisting = value),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
              child: PillButton(
                label: _saving ? 'Saving…' : 'Save rule',
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
                onPressed: _saving ? null : _save,
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
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.grayText,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _GlassBlock extends StatelessWidget {
  const _GlassBlock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.75)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ConditionValueInput extends StatelessWidget {
  const _ConditionValueInput({
    required this.type,
    required this.textController,
    required this.mccController,
    required this.amountMinController,
    required this.amountMaxController,
    required this.onPickAccount,
    this.accountName,
  });

  final CategoryRuleConditionType type;
  final TextEditingController textController;
  final TextEditingController mccController;
  final TextEditingController amountMinController;
  final TextEditingController amountMaxController;
  final VoidCallback onPickAccount;
  final String? accountName;

  static const _hints = {
    CategoryRuleConditionType.merchantContains: 'e.g. SILPO',
    CategoryRuleConditionType.descriptionContains: 'e.g. subscription',
    CategoryRuleConditionType.counterpartyEquals: 'e.g. John Doe',
  };

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CategoryRuleConditionType.merchantContains:
      case CategoryRuleConditionType.descriptionContains:
      case CategoryRuleConditionType.counterpartyEquals:
        return LabeledField(
          label: 'VALUE',
          child: TextField(
            controller: textController,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: _hints[type],
              hintStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark.withValues(alpha: 0.35),
              ),
            ),
          ),
        );
      case CategoryRuleConditionType.mccEquals:
        return LabeledField(
          label: 'MCC CODE',
          child: TextField(
            controller: mccController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: 'e.g. 5411',
              hintStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark.withValues(alpha: 0.35),
              ),
            ),
          ),
        );
      case CategoryRuleConditionType.accountEquals:
        return LabeledField(
          label: 'ACCOUNT',
          child: GestureDetector(
            onTap: onPickAccount,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    accountName ?? 'Select account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: accountName != null
                          ? AppColors.textDark
                          : AppColors.placeholderGray,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.placeholderGray,
                ),
              ],
            ),
          ),
        );
      case CategoryRuleConditionType.amountRange:
        return Row(
          children: [
            Expanded(
              child: LabeledField(
                label: 'MIN',
                child: TextField(
                  controller: amountMinController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LabeledField(
                label: 'MAX',
                child: TextField(
                  controller: amountMaxController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: '∞',
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.loading, required this.count});

  final bool loading;
  final int? count;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentBlue,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Checking matches…',
            style: TextStyle(fontSize: 12.5, color: AppColors.grayText),
          ),
        ],
      );
    }
    if (count == null) {
      return const Text(
        'Fill in a value to preview matches.',
        style: TextStyle(fontSize: 12.5, color: AppColors.grayTextLight),
      );
    }
    return Text(
      'Matches $count transaction${count == 1 ? '' : 's'}',
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.accentBlue,
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.accentBlue
                  : AppColors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: value
                    ? AppColors.accentBlue
                    : AppColors.white.withValues(alpha: 0.9),
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 15, color: AppColors.white)
                : null,
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
        ],
      ),
    );
  }
}

class _OutcomeSelector extends StatelessWidget {
  const _OutcomeSelector({required this.value, required this.onChanged});

  final RuleOutcomeKind value;
  final ValueChanged<RuleOutcomeKind> onChanged;

  static const _options = [
    (RuleOutcomeKind.none, 'None'),
    (RuleOutcomeKind.transfer, 'Transfer'),
    (RuleOutcomeKind.refund, 'Refund'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in _options)
          GestureDetector(
            onTap: () => onChanged(option.$1),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: value == option.$1
                    ? AppColors.accentBlue
                    : AppColors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: value == option.$1
                      ? AppColors.accentBlue
                      : AppColors.white.withValues(alpha: 0.8),
                ),
              ),
              child: Text(
                option.$2,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: value == option.$1
                      ? AppColors.white
                      : AppColors.textDark,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConditionTypePickerSheet extends StatelessWidget {
  const _ConditionTypePickerSheet({required this.current});

  final CategoryRuleConditionType current;

  @override
  Widget build(BuildContext context) {
    const types = CategoryRuleConditionType.values;
    return SettingsBottomSheetShell(
      title: 'Condition',
      children: [
        SettingsOptionsCard(
          children: [
            for (var i = 0; i < types.length; i++) ...[
              Material(
                color: AppColors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(types[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            conditionTypeLabel(types[i]),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: types[i] == current
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        SettingsRadioDot(selected: types[i] == current),
                      ],
                    ),
                  ),
                ),
              ),
              if (i != types.length - 1) const SettingsOptionDivider(),
            ],
          ],
        ),
      ],
    );
  }
}

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({required this.accounts, required this.currentId});

  final List<Account> accounts;
  final String? currentId;

  @override
  Widget build(BuildContext context) {
    return SettingsBottomSheetShell(
      title: 'Account',
      children: [
        if (accounts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No accounts yet.',
                style: TextStyle(color: AppColors.grayText),
              ),
            ),
          )
        else
          SettingsOptionsCard(
            children: [
              for (var i = 0; i < accounts.length; i++) ...[
                Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(accounts[i].id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              accounts[i].name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: accounts[i].id == currentId
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          SettingsRadioDot(
                            selected: accounts[i].id == currentId,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (i != accounts.length - 1) const SettingsOptionDivider(),
              ],
            ],
          ),
      ],
    );
  }
}
