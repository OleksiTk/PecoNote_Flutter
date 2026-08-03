import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/remote/settings_remote_data_source.dart';
import '../../data/repositories/api_settings_repository.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/settings_repository.dart';

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((
  ref,
) {
  return SettingsRemoteDataSource(ref.watch(dioProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return ApiSettingsRepository(ref.watch(settingsRemoteDataSourceProvider));
});

final userProfileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(settingsRepositoryProvider).getProfile();
});

final userCurrenciesProvider = FutureProvider<List<Currency>>((ref) {
  return ref.watch(settingsRepositoryProvider).getCurrencies();
});
