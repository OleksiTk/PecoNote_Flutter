class RuleMatchTransaction {
  const RuleMatchTransaction({
    required this.id,
    required this.amount,
    required this.occurredAt,
    this.description,
    this.accountName,
  });

  final String id;
  final String? description;
  final double amount;
  final DateTime occurredAt;
  final String? accountName;
}

class RuleMatchPreview {
  const RuleMatchPreview({required this.count, required this.transactions});

  final int count;
  final List<RuleMatchTransaction> transactions;
}
