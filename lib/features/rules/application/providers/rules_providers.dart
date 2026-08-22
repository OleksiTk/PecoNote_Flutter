import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/remote/rules_remote_data_source.dart';
import '../../data/repositories/api_rules_repository.dart';
import '../../domain/entities/rule.dart';
import '../../domain/entities/rule_condition.dart';
import '../../domain/repositories/rules_repository.dart';

final rulesRemoteDataSourceProvider = Provider<RulesRemoteDataSource>((ref) {
  return RulesRemoteDataSource(ref.watch(dioProvider));
});

final rulesRepositoryProvider = Provider<RulesRepository>((ref) {
  return ApiRulesRepository(ref.watch(rulesRemoteDataSourceProvider));
});

class RulesNotifier extends AsyncNotifier<List<Rule>> {
  @override
  Future<List<Rule>> build() {
    return ref.watch(rulesRepositoryProvider).getRules();
  }

  Future<Rule> create({
    required String name,
    required RuleCondition condition,
    int? categoryId,
    bool excludeFromAnalytics = false,
    RuleOutcomeKind outcomeKind = RuleOutcomeKind.none,
    bool applyToExisting = false,
  }) async {
    final created = await ref
        .read(rulesRepositoryProvider)
        .create(
          name: name,
          condition: condition,
          categoryId: categoryId,
          excludeFromAnalytics: excludeFromAnalytics,
          outcomeKind: outcomeKind,
          applyToExisting: applyToExisting,
        );
    state = AsyncData([...?state.value, created]);
    return created;
  }

  Future<Rule> updateRule({
    required String id,
    required String name,
    required RuleCondition condition,
    int? categoryId,
    bool excludeFromAnalytics = false,
    RuleOutcomeKind outcomeKind = RuleOutcomeKind.none,
    bool applyToExisting = false,
  }) async {
    final updated = await ref
        .read(rulesRepositoryProvider)
        .update(
          id: id,
          name: name,
          condition: condition,
          categoryId: categoryId,
          excludeFromAnalytics: excludeFromAnalytics,
          outcomeKind: outcomeKind,
          applyToExisting: applyToExisting,
        );
    state = AsyncData([
      for (final rule in state.value ?? const <Rule>[])
        if (rule.id == updated.id) updated else rule,
    ]);
    return updated;
  }

  /// Flips the switch immediately and reverts it if the request fails, so
  /// the toggle in the list feels instant.
  Future<void> setActive(String id, bool isActive) async {
    final previous = state.value ?? const <Rule>[];
    state = AsyncData([
      for (final rule in previous)
        if (rule.id == id) rule.copyWith(isActive: isActive) else rule,
    ]);
    try {
      final updated = await ref.read(rulesRepositoryProvider).setActive(id, isActive);
      state = AsyncData([
        for (final rule in state.value ?? const <Rule>[])
          if (rule.id == updated.id) updated else rule,
      ]);
    } on Object {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    await ref.read(rulesRepositoryProvider).delete(id);
    state = AsyncData(
      (state.value ?? const <Rule>[]).where((rule) => rule.id != id).toList(),
    );
  }
}

final rulesProvider = AsyncNotifierProvider<RulesNotifier, List<Rule>>(
  RulesNotifier.new,
);
