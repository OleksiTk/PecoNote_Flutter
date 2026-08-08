import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peconote_mobile/core/errors/app_failure.dart';
import 'package:peconote_mobile/core/sync/sync_metadata.dart';
import 'package:peconote_mobile/core/sync/sync_status.dart';
import 'package:peconote_mobile/features/accounts/application/providers/accounts_providers.dart';
import 'package:peconote_mobile/features/accounts/domain/entities/account.dart';
import 'package:peconote_mobile/features/accounts/domain/repositories/accounts_repository.dart';

void main() {
  group('AccountsNotifier', () {
    test('replaces an account with the object returned by update', () async {
      final repository = _FakeAccountsRepository([_account(name: 'Cash')]);
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      await container.read(accountsProvider.future);

      await container
          .read(accountsProvider.notifier)
          .updateAccount(
            id: '42',
            name: 'Shopping',
            description: null,
            currencyId: 1,
          );

      final accounts = container.read(accountsProvider).requireValue;
      expect(accounts, hasLength(1));
      expect(accounts.single.name, 'Shopping');
      expect(accounts.single.description, isNull);
    });

    test('keeps the existing account when update fails', () async {
      final repository = _FakeAccountsRepository([_account(name: 'Cash')])
        ..updateError = const NetworkFailure('Update failed.');
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      await container.read(accountsProvider.future);

      await expectLater(
        container
            .read(accountsProvider.notifier)
            .updateAccount(
              id: '42',
              name: 'Shopping',
              description: null,
              currencyId: 1,
            ),
        throwsA(isA<NetworkFailure>()),
      );

      expect(container.read(accountsProvider).requireValue.single.name, 'Cash');
    });

    test('keeps an account when delete fails', () async {
      final repository = _FakeAccountsRepository([_account(name: 'Cash')])
        ..deleteError = const NetworkFailure('Delete failed.');
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      await container.read(accountsProvider.future);

      await expectLater(
        container.read(accountsProvider.notifier).delete('42'),
        throwsA(isA<NetworkFailure>()),
      );

      expect(container.read(accountsProvider).requireValue, hasLength(1));
    });

    test('removes an account after delete succeeds', () async {
      final repository = _FakeAccountsRepository([_account(name: 'Cash')]);
      final container = _containerWith(repository);
      addTearDown(container.dispose);
      await container.read(accountsProvider.future);

      await container.read(accountsProvider.notifier).delete('42');

      expect(container.read(accountsProvider).requireValue, isEmpty);
    });
  });
}

ProviderContainer _containerWith(AccountsRepository repository) {
  return ProviderContainer(
    overrides: [accountsRepositoryProvider.overrideWithValue(repository)],
  );
}

Account _account({required String name, String? description}) {
  final createdAt = DateTime(2026, 8, 6);
  return Account(
    id: '42',
    name: name,
    description: description,
    currencyId: 1,
    sync: SyncMetadata(
      localId: '42',
      serverId: '42',
      syncStatus: SyncStatus.synced,
      createdAt: createdAt,
      updatedAt: createdAt,
      lastSyncedAt: createdAt,
    ),
  );
}

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository(this.accounts);

  final List<Account> accounts;
  AppFailure? updateError;
  AppFailure? deleteError;

  @override
  Future<List<Account>> getAccounts() async => List.of(accounts);

  @override
  Future<Account> create({
    required String name,
    String? description,
    required int currencyId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Account> update({
    required String id,
    required String name,
    String? description,
    required int currencyId,
  }) async {
    final error = updateError;
    if (error != null) throw error;
    return _account(name: name, description: description);
  }

  @override
  Future<void> delete(String id) async {
    final error = deleteError;
    if (error != null) throw error;
  }
}
