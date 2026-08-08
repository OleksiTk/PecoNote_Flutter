import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peconote_mobile/features/accounts/data/remote/accounts_remote_data_source.dart';

void main() {
  group('AccountsRemoteDataSource', () {
    test('updates an account with PUT and a complete payload', () async {
      final adapter = _StubHttpClientAdapter(
        statusCode: 200,
        body:
            '{"id":42,"name":"Shopping",'
            '"created_at":"2026-08-06T14:30:00+03:00",'
            '"description":null,"currency":1}',
      );
      final dataSource = AccountsRemoteDataSource(_dioWith(adapter));

      final result = await dataSource.update(
        id: '42',
        name: 'Shopping',
        description: null,
        currencyId: 1,
      );

      expect(adapter.request?.method, 'PUT');
      expect(adapter.request?.uri.path, '/v1.0/accounts/42/');
      expect(adapter.request?.data, {
        'name': 'Shopping',
        'description': null,
        'currency': 1,
      });
      expect(result['id'], 42);
    });

    test('deletes an account only after 204 No Content', () async {
      final adapter = _StubHttpClientAdapter(statusCode: 204);
      final dataSource = AccountsRemoteDataSource(_dioWith(adapter));

      await dataSource.delete('42');

      expect(adapter.request?.method, 'DELETE');
      expect(adapter.request?.uri.path, '/v1.0/accounts/42/');
    });

    test('rejects a delete response with a status other than 204', () async {
      final adapter = _StubHttpClientAdapter(statusCode: 200, body: '{}');
      final dataSource = AccountsRemoteDataSource(_dioWith(adapter));

      await expectLater(dataSource.delete('42'), throwsA(isA<DioException>()));
    });
  });
}

Dio _dioWith(HttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'http://localhost:8006/v1.0'))
    ..httpClientAdapter = adapter;
}

class _StubHttpClientAdapter implements HttpClientAdapter {
  _StubHttpClientAdapter({required this.statusCode, this.body = ''});

  final int statusCode;
  final String body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
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
