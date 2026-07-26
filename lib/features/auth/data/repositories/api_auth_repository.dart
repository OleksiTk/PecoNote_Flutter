import 'package:dio/dio.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../remote/auth_remote_data_source.dart';

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required AuthSession authSession,
  }) : _remoteDataSource = remoteDataSource,
       _authSession = authSession;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthSession _authSession;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final json = await _remoteDataSource.login(
        email: email.trim(),
        password: password,
      );
      await _saveTokens(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    } on FormatException catch (error) {
      throw AuthenticationFailure(error.message);
    }
  }

  @override
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final json = await _remoteDataSource.register(
        username: username.trim(),
        email: email.trim(),
        password: password,
        confirmPassword: confirmPassword,
      );
      await _saveTokens(json);
    } on DioException catch (error) {
      throw _failureFrom(error);
    } on Object {
      throw const NetworkFailure('The server returned an invalid response.');
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> json) async {
    final accessToken = json['access'];
    final refreshToken = json['refresh'];
    if (accessToken is! String ||
        accessToken.isEmpty ||
        refreshToken is! String ||
        refreshToken.isEmpty) {
      throw const FormatException(
        'Authentication response has invalid tokens.',
      );
    }
    await _authSession.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.logout();
    } on Object {
      // Logout is best-effort until the backend can invalidate login tokens.
    } finally {
      await _authSession.clear();
    }
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _remoteDataSource.requestPasswordReset(email: email.trim());
    } on DioException catch (error) {
      throw _failureFrom(error);
    }
  }

  @override
  Future<void> resetPassword({
    required String uid,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        uid: uid,
        token: token,
        password: password,
        confirmPassword: confirmPassword,
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
    return const NetworkFailure(
      'Could not connect to the server. Please try again.',
    );
  }
}
