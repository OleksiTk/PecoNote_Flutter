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

  @override
  Future<UserProfile> updateProfile({required String username}) async {
    try {
      final json = await _remoteDataSource.updateProfile(username: username);
      return UserProfile.fromJson(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<void> changeEmail({
    required String email,
    required String currentPassword,
  }) async {
    try {
      await _remoteDataSource.changeEmail(
        email: email,
        currentPassword: currentPassword,
      );
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  AppFailure _failureFrom(DioException error) {
    final data = error.response?.data;
    final fieldErrors = <String, List<String>>{};
    if (data is Map) {
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
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return error.response?.statusCode == 401
            ? AuthenticationFailure(detail)
            : NetworkFailure(detail);
      }
    }
    return const NetworkFailure('Could not load settings. Please try again.');
  }
}
