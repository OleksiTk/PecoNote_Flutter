import '../entities/transaction.dart';

abstract interface class TransactionsRepository {
  Stream<List<Transaction>> watchRecentTransactions();

  Future<Transaction> createOffline(Transaction transaction);

  Future<void> markSynced({required String localId, required String serverId});
}
