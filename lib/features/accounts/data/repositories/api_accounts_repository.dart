import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/sync/sync_metadata.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../remote/accounts_remote_data_source.dart';

class ApiAccountsRepository implements AccountsRepository {
  const ApiAccountsRepository(this._remoteDataSource);

  final AccountsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Account>> getAccounts() async {
    try {
      final json = await _remoteDataSource.getAccounts();
      return json.whereType<Map<String, dynamic>>().map(_fromJson).toList();
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<Account> create({
    required String name,
    String? description,
    required int currencyId,
  }) async {
    try {
      final json = await _remoteDataSource.create(
        name: name,
        description: description,
        currencyId: currencyId,
      );
      return _fromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<Account> update({
    required String id,
    required String name,
    String? description,
    required int currencyId,
  }) async {
    try {
      final json = await _remoteDataSource.update(
        id: id,
        name: name,
        description: description,
        currencyId: currencyId,
      );
      return _fromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _remoteDataSource.delete(id);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  Account _fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now();
    return Account(
      id: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      currencyId: json['currency'] as int,
      sync: SyncMetadata(
        localId: id,
        serverId: id,
        syncStatus: SyncStatus.synced,
        createdAt: createdAt,
        updatedAt: createdAt,
        lastSyncedAt: createdAt,
      ),
    );
  }

  AppFailure _failureFrom(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final fieldErrors = <String, List<String>>{};
    if (statusCode == 400 && data is Map) {
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
    }
    if (statusCode == 401) {
      return const AuthenticationFailure(
        'Your session has expired. Please sign in again.',
      );
    }
    if (statusCode == 404) {
      return const NotFoundFailure('This account no longer exists.');
    }
    return const NetworkFailure(
      'Could not connect to the server. Please try again.',
    );
  }
}
