import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/sync/sync_metadata.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../remote/transactions_remote_data_source.dart';

class ApiTransactionsRepository implements TransactionsRepository {
  const ApiTransactionsRepository(this._remoteDataSource);

  final TransactionsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      final json = await _remoteDataSource.getTransactions();
      return json.whereType<Map<String, dynamic>>().map(_fromJson).toList();
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<Transaction> create({
    required TransactionType type,
    required String accountId,
    required double amount,
    required int currencyId,
    required String counterpartyName,
    required DateTime occurredAt,
    String? destinationAccountId,
    String? description,
    List<int> tagIds = const [],
  }) async {
    try {
      final counterpartyId = await _resolveCounterpartyId(counterpartyName);
      final json = await _remoteDataSource.create({
        'type': _typeToJson(type),
        'account': int.parse(accountId),
        'destination_account': destinationAccountId == null
            ? null
            : int.parse(destinationAccountId),
        'amount': amount,
        'total': amount,
        'currency': currencyId,
        'counterparty': counterpartyId,
        'description': description,
        'tr_datetime': occurredAt.toUtc().toIso8601String(),
        'tag': type == TransactionType.transfer ? const <int>[] : tagIds,
      });
      return _fromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<Transaction> updateTags({
    required String id,
    required List<int> tagIds,
  }) async {
    try {
      final json = await _remoteDataSource.updateTags(id, tagIds);
      return _fromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<void> trash(String id) async {
    try {
      await _remoteDataSource.trash(id);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  Future<int> _resolveCounterpartyId(String name) async {
    final wanted = name.trim().isEmpty ? 'Manual entry' : name.trim();
    final existing = await _remoteDataSource.getCounterparties();
    for (final item in existing) {
      if (item is Map &&
          (item['name'] as String?)?.toLowerCase() == wanted.toLowerCase()) {
        return item['id'] as int;
      }
    }
    final created = await _remoteDataSource.createCounterparty(wanted);
    return created['id'] as int;
  }

  Transaction _fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final occurredAt =
        DateTime.tryParse(json['tr_datetime'] as String? ?? '') ??
        DateTime.now();
    final destinationAccount = json['destination_account'];
    final tags = json['tag'];
    return Transaction(
      id: id,
      type: _typeFromJson(json['type'] as String?),
      accountId: json['account'].toString(),
      destinationAccountId: destinationAccount?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      currencyId: json['currency'] as int,
      counterpartyId: json['counterparty'] as int,
      description: json['description'] as String?,
      tagIds: tags is List
          ? tags
                .map((tag) => tag is Map ? tag['id'] : tag)
                .whereType<num>()
                .map((id) => id.toInt())
                .toList()
          : const [],
      occurredAt: occurredAt,
      isTrashed: json['is_trashed'] as bool? ?? false,
      sync: SyncMetadata(
        localId: id,
        serverId: id,
        syncStatus: SyncStatus.synced,
        createdAt: occurredAt,
        updatedAt: occurredAt,
        lastSyncedAt: occurredAt,
      ),
    );
  }

  String _typeToJson(TransactionType type) => switch (type) {
    TransactionType.income => 'income',
    TransactionType.expense => 'expense',
    TransactionType.transfer => 'transfer',
  };

  TransactionType _typeFromJson(String? value) => switch (value) {
    'income' => TransactionType.income,
    'transfer' => TransactionType.transfer,
    _ => TransactionType.expense,
  };

  AppFailure _failureFrom(DioException error) {
    final data = error.response?.data;
    final fieldErrors = <String, List<String>>{};
    if (data is Map) {
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
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return error.response?.statusCode == 401
            ? AuthenticationFailure(detail)
            : NetworkFailure(detail);
      }
    }
    return const NetworkFailure(
      'Could not connect to the server. Please try again.',
    );
  }
}
