import '../../../../core/sync/sync_metadata.dart';
import 'rule_condition.dart';

enum RuleOutcomeKind { none, transfer, refund }

class Rule {
  const Rule({
    required this.id,
    required this.name,
    required this.condition,
    required this.sync,
    this.categoryId,
    this.excludeFromAnalytics = false,
    this.outcomeKind = RuleOutcomeKind.none,
    this.applyToExisting = false,
    this.isActive = true,
    this.matchedCount = 0,
  });

  final String id;
  final String name;
  final RuleCondition condition;
  final int? categoryId;
  final bool excludeFromAnalytics;
  final RuleOutcomeKind outcomeKind;
  final bool applyToExisting;
  final bool isActive;
  final int matchedCount;
  final SyncMetadata sync;

  Rule copyWith({bool? isActive}) {
    return Rule(
      id: id,
      name: name,
      condition: condition,
      sync: sync,
      categoryId: categoryId,
      excludeFromAnalytics: excludeFromAnalytics,
      outcomeKind: outcomeKind,
      applyToExisting: applyToExisting,
      isActive: isActive ?? this.isActive,
      matchedCount: matchedCount,
    );
  }
}
