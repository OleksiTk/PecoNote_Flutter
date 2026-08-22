import '../entities/rule.dart';
import '../entities/rule_condition.dart';
import '../entities/rule_match.dart';

abstract interface class RulesRepository {
  Future<List<Rule>> getRules();

  Future<Rule> create({
    required String name,
    required RuleCondition condition,
    int? categoryId,
    bool excludeFromAnalytics = false,
    RuleOutcomeKind outcomeKind = RuleOutcomeKind.none,
    bool applyToExisting = false,
  });

  Future<Rule> update({
    required String id,
    required String name,
    required RuleCondition condition,
    int? categoryId,
    bool excludeFromAnalytics = false,
    RuleOutcomeKind outcomeKind = RuleOutcomeKind.none,
    bool applyToExisting = false,
  });

  Future<Rule> setActive(String id, bool isActive);

  Future<void> delete(String id);

  Future<RuleMatchPreview> previewMatches(RuleCondition condition);

  Future<int> applyRule(String ruleId, List<String> transactionIds);
}
