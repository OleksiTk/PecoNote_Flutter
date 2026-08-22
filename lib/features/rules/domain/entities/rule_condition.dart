/// Mirrors the backend's per-field match condition on a Rule: exactly one
/// of these is meant to be set at a time (amount_range uses both min/max).
enum CategoryRuleConditionType {
  merchantContains,
  descriptionContains,
  counterpartyEquals,
  mccEquals,
  accountEquals,
  amountRange,
}

class RuleCondition {
  const RuleCondition({
    required this.type,
    this.textValue,
    this.mcc,
    this.accountId,
    this.amountMin,
    this.amountMax,
  });

  final CategoryRuleConditionType type;

  /// merchant_contains / description_contains / counterparty_equals.
  final String? textValue;

  /// mcc_equals.
  final int? mcc;

  /// account_equals.
  final String? accountId;

  /// amount_range.
  final double? amountMin;
  final double? amountMax;

  bool get isFilled => switch (type) {
    CategoryRuleConditionType.merchantContains ||
    CategoryRuleConditionType.descriptionContains ||
    CategoryRuleConditionType.counterpartyEquals =>
      textValue?.trim().isNotEmpty ?? false,
    CategoryRuleConditionType.mccEquals => mcc != null,
    CategoryRuleConditionType.accountEquals => accountId != null,
    CategoryRuleConditionType.amountRange => amountMin != null || amountMax != null,
  };
}
