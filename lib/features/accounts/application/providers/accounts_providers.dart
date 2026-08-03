import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/remote/accounts_remote_data_source.dart';
import '../../data/repositories/api_accounts_repository.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/accounts_repository.dart';

final accountsRemoteDataSourceProvider = Provider<AccountsRemoteDataSource>((
  ref,
) {
  return AccountsRemoteDataSource(ref.watch(dioProvider));
});

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return ApiAccountsRepository(ref.watch(accountsRemoteDataSourceProvider));
});

class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() {
    return ref.watch(accountsRepositoryProvider).getAccounts();
  }

  Future<void> create({
    required String name,
    String? description,
    required int currencyId,
  }) async {
    final created = await ref
        .read(accountsRepositoryProvider)
        .create(name: name, description: description, currencyId: currencyId);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> delete(String id) async {
    await ref.read(accountsRepositoryProvider).delete(id);
    state = AsyncData(
      (state.value ?? const <Account>[])
          .where((account) => account.id != id)
          .toList(),
    );
  }
}

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(
  AccountsNotifier.new,
);
