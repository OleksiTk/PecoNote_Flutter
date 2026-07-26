import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_session.dart';
import '../../../../core/storage/app_settings_repository.dart';
import '../controllers/startup_controller.dart';

final startupControllerProvider = FutureProvider<StartupDestination>((ref) {
  return StartupController(
    settingsRepository: ref.watch(appSettingsRepositoryProvider),
    authSession: ref.watch(authSessionProvider),
  ).resolveDestination();
});
