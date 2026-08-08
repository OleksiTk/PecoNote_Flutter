import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../accounts/application/providers/accounts_providers.dart';
import '../../data/remote/transactions_remote_data_source.dart';
import '../../data/repositories/api_transactions_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';

final transactionsRemoteDataSourceProvider =
    Provider<TransactionsRemoteDataSource>((ref) {
      return TransactionsRemoteDataSource(ref.watch(dioProvider));
    });

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return ApiTransactionsRepository(
    ref.watch(transactionsRemoteDataSourceProvider),
  );
});

class TransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() {
    return ref.watch(transactionsRepositoryProvider).getTransactions();
  }

  Future<void> create({
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
    final created = await ref
        .read(transactionsRepositoryProvider)
        .create(
          type: type,
          accountId: accountId,
          amount: amount,
          currencyId: currencyId,
          counterpartyName: counterpartyName,
          occurredAt: occurredAt,
          destinationAccountId: destinationAccountId,
          description: description,
          tagIds: tagIds,
        );
    state = AsyncData([created, ...?state.value]);
    // The backend recalculates account balances as a side effect of saving
    // a transaction; refresh accounts so the new balance shows up.
    ref.invalidate(accountsProvider);
  }

  Future<void> updateTransactionTags({
    required String id,
    required List<int> tagIds,
  }) async {
    final updated = await ref
        .read(transactionsRepositoryProvider)
        .updateTags(id: id, tagIds: tagIds);
    state = AsyncData([
      for (final transaction in state.value ?? const <Transaction>[])
        if (transaction.id == updated.id) updated else transaction,
    ]);
  }

  Future<void> trash(String id) async {
    await ref.read(transactionsRepositoryProvider).trash(id);
    state = AsyncData(
      (state.value ?? const <Transaction>[])
          .where((transaction) => transaction.id != id)
          .toList(),
    );
    ref.invalidate(accountsProvider);
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<Transaction>>(
      TransactionsNotifier.new,
    );
