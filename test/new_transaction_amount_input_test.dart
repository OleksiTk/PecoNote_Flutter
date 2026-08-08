import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peconote_mobile/core/sync/sync_metadata.dart';
import 'package:peconote_mobile/core/sync/sync_status.dart';
import 'package:peconote_mobile/features/accounts/application/providers/accounts_providers.dart';
import 'package:peconote_mobile/features/accounts/domain/entities/account.dart';
import 'package:peconote_mobile/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:peconote_mobile/features/transactions/presentation/screens/new_transaction_screen.dart';

void main() {
  testWidgets('amount caret follows the last entered character', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountsRepositoryProvider.overrideWithValue(
            _AmountInputAccountsRepository(),
          ),
        ],
        child: const MaterialApp(home: NewTransactionScreen()),
      ),
    );
    await tester.pump();

    EditableText amountField() => tester.widget(find.byType(EditableText));

    expect(amountField().controller.text, '0');
    expect(amountField().controller.selection.extentOffset, 1);
    expect(find.text('.00'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();

    expect(amountField().controller.text, '12');
    expect(amountField().controller.selection.extentOffset, 2);
    expect(find.text('.00'), findsOneWidget);

    await tester.tap(find.text(','));
    await tester.pump();

    expect(amountField().controller.text, '12.');
    expect(amountField().controller.selection.extentOffset, 3);
    expect(find.text('00'), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.pump();

    expect(amountField().controller.text, '12.5');
    expect(amountField().controller.selection.extentOffset, 4);
    expect(find.text('0'), findsNWidgets(2));
  });
}

class _AmountInputAccountsRepository implements AccountsRepository {
  @override
  Future<List<Account>> getAccounts() async => [_account()];

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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError();
  }
}

Account _account() {
  final createdAt = DateTime(2026, 8, 6);
  return Account(
    id: '12',
    name: 'Cash',
    currencyId: 1,
    sync: SyncMetadata(
      localId: '12',
      serverId: '12',
      syncStatus: SyncStatus.synced,
      createdAt: createdAt,
      updatedAt: createdAt,
      lastSyncedAt: createdAt,
    ),
  );
}
