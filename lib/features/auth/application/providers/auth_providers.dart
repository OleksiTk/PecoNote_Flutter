import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/network/api_client.dart';
import '../../data/remote/auth_remote_data_source.dart';
import '../../data/repositories/api_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/register.dart';
import '../../domain/use_cases/sign_in.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    authSession: ref.watch(authSessionProvider),
  );
});

final signInProvider = Provider<SignIn>((ref) {
  return SignIn(ref.watch(authRepositoryProvider));
});

final registerProvider = Provider<Register>((ref) {
  return Register(ref.watch(authRepositoryProvider));
});
