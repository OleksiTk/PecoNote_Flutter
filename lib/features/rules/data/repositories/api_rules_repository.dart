import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/sync/sync_metadata.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/rule.dart';
import '../../domain/entities/rule_condition.dart';
import '../../domain/entities/rule_match.dart';
import '../../domain/repositories/rules_repository.dart';
import '../remote/rules_remote_data_source.dart';

class ApiRulesRepository implements RulesRepository {
  const ApiRulesRepository(this._remoteDataSource);

  final RulesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Rule>> getRules() async {
    try {
      final json = await _remoteDataSource.getRules();
      return json.whereType<Map<String, dynamic>>().map(_ruleFromJson).toList();
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<Rule> create({
    required String name,
    required RuleCondition condition,
    int? categoryId,
    bool excludeFromAnalytics = false,
    RuleOutcomeKind outcomeKind = RuleOutcomeKind.none,
    bool applyToExisting = false,
  }) async {
    try {
      final json = await _remoteDataSource.create(
        _ruleBody(
          name: name,
          condition: condition,
          categoryId: categoryId,
          excludeFromAnalytics: excludeFromAnalytics,
          outcomeKind: outcomeKind,
          applyToExisting: applyToExisting,
        ),
      );
      return _ruleFromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<Rule> update({
    required String id,
    required String name,
    required RuleCondition condition,
    int? categoryId,
    bool excludeFromAnalytics = false,
    RuleOutcomeKind outcomeKind = RuleOutcomeKind.none,
    bool applyToExisting = false,
  }) async {
    try {
      final json = await _remoteDataSource.update(
        id,
        _ruleBody(
          name: name,
          condition: condition,
          categoryId: categoryId,
          excludeFromAnalytics: excludeFromAnalytics,
          outcomeKind: outcomeKind,
          applyToExisting: applyToExisting,
        ),
      );
      return _ruleFromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<Rule> setActive(String id, bool isActive) async {
    try {
      final json = await _remoteDataSource.setActive(id, isActive);
      return _ruleFromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remoteDataSource.delete(id);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<RuleMatchPreview> previewMatches(RuleCondition condition) async {
    try {
      final json = await _remoteDataSource.preview(_conditionBody(condition));
      return _previewFromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<int> applyRule(String ruleId, List<String> transactionIds) async {
    try {
      final json = await _remoteDataSource.apply(ruleId, transactionIds);
      return (json['applied_count'] as num?)?.toInt() ?? 0;
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  /// Always sends all six condition fields, blanking/nulling whichever
  /// aren't the active type. The backend has no single condition_type
  /// column - it just ANDs together whatever's non-blank - so on update
  /// this is what actually clears a previous condition when the user
  /// switches the IF block to a different type; sending only the active
  /// field would leave the old one stuck (silently ANDed with the new one).
  Map<String, dynamic> _conditionBody(RuleCondition condition) {
    final type = condition.type;
    return {
      'merchant_contains': type == CategoryRuleConditionType.merchantContains
          ? (condition.textValue ?? '')
          : '',
      'description_contains':
          type == CategoryRuleConditionType.descriptionContains
          ? (condition.textValue ?? '')
          : '',
      'counterparty_equals':
          type == CategoryRuleConditionType.counterpartyEquals
          ? (condition.textValue ?? '')
          : '',
      'mcc': type == CategoryRuleConditionType.mccEquals ? condition.mcc : null,
      'account': type == CategoryRuleConditionType.accountEquals
          ? int.tryParse(condition.accountId ?? '')
          : null,
      'min_amount': type == CategoryRuleConditionType.amountRange
          ? condition.amountMin
          : null,
      'max_amount': type == CategoryRuleConditionType.amountRange
          ? condition.amountMax
          : null,
    };
  }

  Map<String, dynamic> _ruleBody({
    required String name,
    required RuleCondition condition,
    required int? categoryId,
    required bool excludeFromAnalytics,
    required RuleOutcomeKind outcomeKind,
    required bool applyToExisting,
  }) {
    return {
      'name': name,
      'set_tag': categoryId,
      'exclude_from_analytics': excludeFromAnalytics,
      'outcome': _outcomeApiValue(outcomeKind),
      'apply_to_existing': applyToExisting,
      ..._conditionBody(condition),
    };
  }

  String _outcomeApiValue(RuleOutcomeKind kind) => switch (kind) {
    RuleOutcomeKind.none => 'none',
    RuleOutcomeKind.transfer => 'transfer',
    RuleOutcomeKind.refund => 'refund',
  };

  RuleOutcomeKind _outcomeFromApi(String? value) => switch (value) {
    'transfer' => RuleOutcomeKind.transfer,
    'refund' => RuleOutcomeKind.refund,
    _ => RuleOutcomeKind.none,
  };

  /// The backend has no single condition_type column - it stores whichever
  /// field the app populated and leaves the rest blank/null, so the
  /// condition type is inferred from which field actually has a value.
  RuleCondition _conditionFromJson(Map<String, dynamic> json) {
    final merchant = json['merchant_contains'] as String? ?? '';
    final counterparty = json['counterparty_equals'] as String? ?? '';
    final mcc = json['mcc'] as int?;
    final account = json['account'];
    final minAmount = (json['min_amount'] as num?)?.toDouble();
    final maxAmount = (json['max_amount'] as num?)?.toDouble();
    final description = json['description_contains'] as String? ?? '';

    if (merchant.isNotEmpty) {
      return RuleCondition(
        type: CategoryRuleConditionType.merchantContains,
        textValue: merchant,
      );
    }
    if (counterparty.isNotEmpty) {
      return RuleCondition(
        type: CategoryRuleConditionType.counterpartyEquals,
        textValue: counterparty,
      );
    }
    if (mcc != null) {
      return RuleCondition(type: CategoryRuleConditionType.mccEquals, mcc: mcc);
    }
    if (account != null) {
      return RuleCondition(
        type: CategoryRuleConditionType.accountEquals,
        accountId: account.toString(),
      );
    }
    if (minAmount != null || maxAmount != null) {
      return RuleCondition(
        type: CategoryRuleConditionType.amountRange,
        amountMin: minAmount,
        amountMax: maxAmount,
      );
    }
    return RuleCondition(
      type: CategoryRuleConditionType.descriptionContains,
      textValue: description,
    );
  }

  Rule _ruleFromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now();
    final updatedAt =
        DateTime.tryParse(json['updated_at'] as String? ?? '') ?? createdAt;
    return Rule(
      id: id,
      name: json['name'] as String? ?? '',
      condition: _conditionFromJson(json),
      categoryId: json['set_tag'] as int?,
      excludeFromAnalytics: json['exclude_from_analytics'] as bool? ?? false,
      outcomeKind: _outcomeFromApi(json['outcome'] as String?),
      applyToExisting: json['apply_to_existing'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      matchedCount: (json['matched_count'] as num?)?.toInt() ?? 0,
      sync: SyncMetadata(
        localId: id,
        serverId: id,
        syncStatus: SyncStatus.synced,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastSyncedAt: updatedAt,
      ),
    );
  }

  RuleMatchPreview _previewFromJson(Map<String, dynamic> json) {
    final list = (json['transactions'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_matchTransactionFromJson)
        .toList();
    return RuleMatchPreview(
      count: (json['count'] as num?)?.toInt() ?? list.length,
      transactions: list,
    );
  }

  RuleMatchTransaction _matchTransactionFromJson(Map<String, dynamic> json) {
    return RuleMatchTransaction(
      id: json['id'].toString(),
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      occurredAt:
          DateTime.tryParse(json['tr_datetime'] as String? ?? '') ?? DateTime.now(),
      accountName: json['account_name'] as String?,
    );
  }

  AppFailure _failureFrom(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final fieldErrors = <String, List<String>>{};
    if (statusCode == 400 && data is Map) {
      for (final entry in data.entries) {
        if (entry.key == 'detail') continue;
        final value = entry.value;
        if (value is List) {
          fieldErrors[entry.key.toString()] = value
              .map((message) => message.toString())
              .toList();
        } else if (value != null) {
          fieldErrors[entry.key.toString()] = [value.toString()];
        }
      }
      if (fieldErrors.isNotEmpty) {
        return ValidationFailure(
          'Please check the highlighted fields.',
          fieldErrors,
        );
      }
    }
    if (statusCode == 401) {
      return const AuthenticationFailure(
        'Your session has expired. Please sign in again.',
      );
    }
    if (statusCode == 404) {
      return const NotFoundFailure('This rule no longer exists.');
    }
    return const NetworkFailure(
      'Could not connect to the server. Please try again.',
    );
  }
}
