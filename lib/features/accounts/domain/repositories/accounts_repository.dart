import '../entities/account.dart';

abstract interface class AccountsRepository {
  Future<List<Account>> getAccounts();

  Future<Account> create(Account account);
}
