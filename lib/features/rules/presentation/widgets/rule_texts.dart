import '../../domain/entities/rule.dart';
import '../../domain/entities/rule_condition.dart';

String conditionTypeLabel(CategoryRuleConditionType type) => switch (type) {
  CategoryRuleConditionType.merchantContains => 'Merchant contains',
  CategoryRuleConditionType.descriptionContains => 'Description contains',
  CategoryRuleConditionType.counterpartyEquals => 'Counterparty is',
  CategoryRuleConditionType.mccEquals => 'MCC code is',
  CategoryRuleConditionType.accountEquals => 'Account is',
  CategoryRuleConditionType.amountRange => 'Amount range',
};

/// Just the matched value, e.g. "SILPO", "4829", an account name, or a
/// formatted amount range - used both standalone and inside
/// [conditionSummaryText].
String ruleConditionValueLabel(RuleCondition condition, {String? accountName}) {
  return switch (condition.type) {
    CategoryRuleConditionType.merchantContains ||
    CategoryRuleConditionType.descriptionContains ||
    CategoryRuleConditionType.counterpartyEquals =>
      condition.textValue?.trim() ?? '',
    CategoryRuleConditionType.mccEquals => condition.mcc?.toString() ?? '',
    CategoryRuleConditionType.accountEquals => accountName ?? 'account',
    CategoryRuleConditionType.amountRange => switch ((
      condition.amountMin,
      condition.amountMax,
    )) {
      (final min?, final max?) => '₴$min–₴$max',
      (final min?, null) => '≥ ₴$min',
      (null, final max?) => '≤ ₴$max',
      (null, null) => 'amount',
    },
  };
}

/// e.g. `merchant contains "SILPO"` - shown under a rule's name in the list
/// and as a live label while editing the IF block.
String conditionSummaryText(RuleCondition condition, {String? accountName}) {
  final value = ruleConditionValueLabel(condition, accountName: accountName);
  return switch (condition.type) {
    CategoryRuleConditionType.merchantContains => 'merchant contains "$value"',
    CategoryRuleConditionType.descriptionContains =>
      'description contains "$value"',
    CategoryRuleConditionType.counterpartyEquals => 'counterparty is "$value"',
    CategoryRuleConditionType.mccEquals => 'MCC is $value',
    CategoryRuleConditionType.accountEquals => 'account is $value',
    CategoryRuleConditionType.amountRange => 'amount is $value',
  };
}

/// e.g. "SILPO → Food" - built from a condition's value and a category
/// name. Used both as the list row's title fallback and, by the editor, to
/// generate the name it sends on save (the backend requires a non-blank
/// name and the editor has no separate name field).
String ruleFallbackTitle(RuleCondition condition, {String? categoryName, String? accountName}) {
  final value = ruleConditionValueLabel(condition, accountName: accountName);
  if (categoryName == null || categoryName.isEmpty) {
    return value.isEmpty ? 'Rule' : value;
  }
  return value.isEmpty ? categoryName : '$value → $categoryName';
}

/// The list row title, e.g. "SILPO → Food". Falls back to
/// [ruleFallbackTitle] when the rule has no explicit name, which shouldn't
/// normally happen since the editor always generates one on save.
String ruleDisplayTitle(Rule rule, {String? categoryName, String? accountName}) {
  if (rule.name.trim().isNotEmpty) return rule.name;
  return ruleFallbackTitle(
    rule.condition,
    categoryName: categoryName,
    accountName: accountName,
  );
}
