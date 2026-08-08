import '../entities/account.dart';

abstract interface class AccountsRepository {
  Future<List<Account>> getAccounts();

  Future<Account> create({
    required String name,
    String? description,
    required int currencyId,
  });

  Future<Account> update({
    required String id,
    required String name,
    String? description,
    required int currencyId,
  });

  Future<void> delete(String id);
}
