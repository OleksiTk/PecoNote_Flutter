import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../remote/settings_remote_data_source.dart';

class ApiSettingsRepository implements SettingsRepository {
  const ApiSettingsRepository(this._remoteDataSource);

  final SettingsRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getProfile() async {
    try {
      final json = await _remoteDataSource.getProfile();
      return UserProfile.fromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<List<Currency>> getCurrencies() async {
    try {
      final json = await _remoteDataSource.getCurrencies();
      return json
          .whereType<Map<String, dynamic>>()
          .map(Currency.fromJson)
          .toList();
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  AppFailure _failureFrom(DioException error) {
    final data = error.response?.data;
    final detail = data is Map ? data['detail'] : null;
    if (detail is String && detail.isNotEmpty) {
      return error.response?.statusCode == 401
          ? AuthenticationFailure(detail)
          : NetworkFailure(detail);
    }
    return const NetworkFailure('Could not load settings. Please try again.');
  }
}
