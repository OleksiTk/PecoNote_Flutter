import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
import '../../features/auth/presentation/screens/auth_choice_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/startup/presentation/screens/start_choice_screen.dart';
import '../../features/startup/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authSession = ref.watch(authSessionProvider);
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    refreshListenable: authSession,
    redirect: (context, state) {
      if (state.uri.scheme == 'peconote' &&
          state.uri.host == 'reset-password') {
        return Uri(
          path: AppRoute.resetPassword.path,
          queryParameters: state.uri.queryParameters,
        ).toString();
      }
      final location = state.matchedLocation;
      final isPublic =
          location == AppRoute.splash.path ||
          location == AppRoute.onboarding.path ||
          location == AppRoute.auth.path ||
          location == AppRoute.login.path ||
          location == AppRoute.register.path ||
          location == AppRoute.forgotPassword.path ||
          location == AppRoute.resetPassword.path;
      final isAuthRoute =
          location == AppRoute.auth.path ||
          location == AppRoute.login.path ||
          location == AppRoute.register.path;

      if (!authSession.authenticated && !isPublic) {
        return AppRoute.login.path;
      }
      if (authSession.authenticated && isAuthRoute) {
        return AppRoute.startChoice.path;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.auth.path,
        name: AppRoute.auth.name,
        builder: (context, state) => const AuthChoiceScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoute.forgotPassword.path,
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoute.resetPassword.path,
        name: AppRoute.resetPassword.name,
        builder: (context, state) => ResetPasswordScreen(
          uid: state.uri.queryParameters['uid'] ?? '',
          token: state.uri.queryParameters['token'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoute.startChoice.path,
        name: AppRoute.startChoice.name,
        builder: (context, state) => const StartChoiceScreen(),
      ),
      GoRoute(
        path: AppRoute.ready.path,
        name: AppRoute.ready.name,
        builder: (context, state) {
          final option = state.uri.queryParameters['option'] ?? '';
          return ReadyScreen(option: option);
        },
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
