import '../../../../core/auth/auth_session.dart';
import '../../../../core/storage/app_settings_repository.dart';

enum StartupDestination { onboarding, auth, main }

class StartupController {
  const StartupController({
    required AppSettingsRepository settingsRepository,
    required AuthSession authSession,
  }) : _settingsRepository = settingsRepository,
       _authSession = authSession;

  final AppSettingsRepository _settingsRepository;
  final AuthSession _authSession;

  Future<StartupDestination> resolveDestination() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    final onboardingCompleted = await _settingsRepository
        .isOnboardingCompleted();
    if (!onboardingCompleted) {
      return StartupDestination.onboarding;
    }

    final authenticated = await _authSession.isAuthenticated();
    return authenticated ? StartupDestination.main : StartupDestination.auth;
  }
}
