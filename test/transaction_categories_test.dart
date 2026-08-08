import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peconote_mobile/core/config/app_config.dart';
import 'package:peconote_mobile/core/network/api_client.dart';
import 'package:peconote_mobile/features/categories/data/remote/categories_remote_data_source.dart';
import 'package:peconote_mobile/features/categories/data/repositories/api_categories_repository.dart';
import 'package:peconote_mobile/features/categories/domain/entities/category.dart';
import 'package:peconote_mobile/features/categories/domain/entities/category_tree.dart';
import 'package:peconote_mobile/features/transactions/data/remote/transactions_remote_data_source.dart';
import 'package:peconote_mobile/features/transactions/data/repositories/api_transactions_repository.dart';
import 'package:peconote_mobile/features/transactions/domain/entities/transaction.dart';

void main() {
  group('transaction categories', () {
    test('sends the configured interface language in API requests', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);

      expect(
        dio.options.headers['Accept-Language'],
        AppConfig.defaultLanguageCode,
      );
    });

    test('builds a category tree from the flat API response', () {
      const income = Category(id: 1, name: 'Income', isPublic: true);
      const salary = Category(
        id: 2,
        name: 'Salary',
        isPublic: true,
        parentId: 1,
      );
      const orphan = Category(
        id: 3,
        name: 'Orphan',
        isPublic: false,
        parentId: 999,
      );

      final tree = buildCategoryTree([income, salary, orphan]);

      expect(tree.map((item) => item.category.id), [1, 3]);
      expect(tree.first.children.single.category.id, 2);
    });

    test('loads and maps categories from GET /tags/', () async {
      final adapter = _RoutingAdapter();
      final repository = ApiCategoriesRepository(
        CategoriesRemoteDataSource(_dioWith(adapter)),
      );

      final categories = await repository.getCategories();

      expect(adapter.requests.single.method, 'GET');
      expect(adapter.requests.single.uri.path, '/v1.0/tags/');
      expect(categories.first.name, 'Income');
      expect(categories.last.parentId, 1);
    });

    test('creates a private category with its parent ID', () async {
      final adapter = _RoutingAdapter();
      final repository = ApiCategoriesRepository(
        CategoriesRemoteDataSource(_dioWith(adapter)),
      );

      final created = await repository.create(
        name: 'Pets',
        description: 'Food and vet',
        parentId: 9,
      );

      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/v1.0/tags/');
      expect(request.data, {
        'name': 'Pets',
        'description': 'Food and vet',
        'is_public': false,
        'parent': 9,
      });
      expect(created.id, 14);
    });

    test('sends the selected category as a tag ID array', () async {
      final adapter = _RoutingAdapter();
      final repository = ApiTransactionsRepository(
        TransactionsRemoteDataSource(_dioWith(adapter)),
      );

      await repository.create(
        type: TransactionType.expense,
        accountId: '12',
        amount: 250,
        currencyId: 1,
        counterpartyName: 'Shop',
        occurredAt: DateTime.utc(2026, 8, 6, 15, 30),
        tagIds: const [10],
      );

      final request = adapter.requests.last;
      expect(request.method, 'POST');
      expect(request.uri.path, '/v1.0/transactions/');
      expect((request.data as Map<String, dynamic>)['tag'], [10]);
    });

    test('always sends an empty tag array for transfers', () async {
      final adapter = _RoutingAdapter();
      final repository = ApiTransactionsRepository(
        TransactionsRemoteDataSource(_dioWith(adapter)),
      );

      await repository.create(
        type: TransactionType.transfer,
        accountId: '12',
        destinationAccountId: '13',
        amount: 250,
        currencyId: 1,
        counterpartyName: 'Transfer',
        occurredAt: DateTime.utc(2026, 8, 6, 15, 30),
        tagIds: const [10],
      );

      final request = adapter.requests.last;
      expect((request.data as Map<String, dynamic>)['tag'], isEmpty);
    });

    test('updates transaction tags through PATCH', () async {
      final adapter = _RoutingAdapter();
      final repository = ApiTransactionsRepository(
        TransactionsRemoteDataSource(_dioWith(adapter)),
      );

      final updated = await repository.updateTags(id: '50', tagIds: const [14]);

      final request = adapter.requests.single;
      expect(request.method, 'PATCH');
      expect(request.uri.path, '/v1.0/transactions/50/');
      expect(request.data, {
        'tag': [14],
      });
      expect(updated.tagIds, [14]);
    });
  });
}

Dio _dioWith(HttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'http://localhost:8006/v1.0'))
    ..httpClientAdapter = adapter;
}

class _RoutingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final path = options.uri.path;

    if (path == '/v1.0/tags/' && options.method == 'GET') {
      return _jsonResponse(
        '[{"id":1,"name":"Income","description":null,'
        '"is_public":true,"parent":null},'
        '{"id":2,"name":"Salary","description":null,'
        '"is_public":true,"parent":1}]',
      );
    }
    if (path == '/v1.0/tags/' && options.method == 'POST') {
      return _jsonResponse(
        '{"id":14,"name":"Pets","description":"Food and vet",'
        '"is_public":false,"parent":9}',
        statusCode: 201,
      );
    }
    if (path == '/v1.0/counterparts/' && options.method == 'GET') {
      return _jsonResponse('[]');
    }
    if (path == '/v1.0/counterparts/' && options.method == 'POST') {
      return _jsonResponse('{"id":7,"name":"Shop"}', statusCode: 201);
    }
    if (path == '/v1.0/transactions/' && options.method == 'POST') {
      final data = options.data as Map<String, dynamic>;
      final type = data['type'];
      final destination = data['destination_account'];
      final tags = (data['tag'] as List).join(',');
      return _jsonResponse(
        '{"id":50,"type":"$type","account":12,'
        '"destination_account":$destination,"amount":250,"total":250,'
        '"currency":1,"counterparty":7,"description":null,'
        '"tr_datetime":"2026-08-06T15:30:00Z","is_trashed":false,'
        '"tag":[$tags]}',
        statusCode: 201,
      );
    }
    if (path == '/v1.0/transactions/50/' && options.method == 'PATCH') {
      final tags = ((options.data as Map<String, dynamic>)['tag'] as List).join(
        ',',
      );
      return _jsonResponse(
        '{"id":50,"type":"expense","account":12,'
        '"destination_account":null,"amount":250,"total":250,'
        '"currency":1,"counterparty":7,"description":null,'
        '"tr_datetime":"2026-08-06T15:30:00Z","is_trashed":false,'
        '"tag":[$tags]}',
      );
    }

    return _jsonResponse('{"detail":"Not found"}', statusCode: 404);
  }

  ResponseBody _jsonResponse(String body, {int statusCode = 200}) {
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
