import '../entities/rule.dart';

abstract interface class RulesRepository {
  Future<List<Rule>> getRules();

  Future<Rule> create(Rule rule);

  Future<void> softDelete(String id);
}
