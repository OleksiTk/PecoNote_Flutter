import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_session.dart';
import '../../features/auth/presentation/screens/auth_choice_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_reset_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/accounts/presentation/screens/new_account_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/operations/presentation/screens/operations_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/startup/presentation/screens/connect_monobank_screen.dart';
import '../../features/startup/presentation/screens/monobank_cards_screen.dart';
import '../../features/startup/presentation/screens/monobank_done_screen.dart';
import '../../features/startup/presentation/screens/monobank_period_screen.dart';
import '../../features/startup/presentation/screens/monobank_qr_scan_screen.dart';
import '../../features/startup/presentation/screens/monobank_rules_created_screen.dart';
import '../../features/startup/presentation/screens/monobank_sort_screen.dart';
import '../../features/startup/presentation/screens/monobank_syncing_screen.dart';
import '../../features/startup/presentation/screens/start_choice_screen.dart';
import '../../features/startup/presentation/screens/splash_screen.dart';
import '../../features/transactions/presentation/models/transaction_draft.dart';
import '../../features/transactions/presentation/screens/new_transaction_screen.dart';
import '../../features/transactions/presentation/screens/transaction_details_screen.dart';
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
        path: AppRoute.connectMonobank.path,
        name: AppRoute.connectMonobank.name,
        builder: (context, state) => const ConnectMonobankScreen(),
      ),
      GoRoute(
        path: AppRoute.monobankQrScan.path,
        name: AppRoute.monobankQrScan.name,
        builder: (context, state) => const MonobankQrScanScreen(),
      ),
      GoRoute(
        path: AppRoute.monobankCards.path,
        name: AppRoute.monobankCards.name,
        builder: (context, state) => const MonobankCardsScreen(),
      ),
      GoRoute(
        path: AppRoute.monobankPeriod.path,
        name: AppRoute.monobankPeriod.name,
        builder: (context, state) => const MonobankPeriodScreen(),
      ),
      GoRoute(
        path: AppRoute.monobankSyncing.path,
        name: AppRoute.monobankSyncing.name,
        builder: (context, state) => const MonobankSyncingScreen(),
      ),
      GoRoute(
        path: AppRoute.monobankDone.path,
        name: AppRoute.monobankDone.name,
        builder: (context, state) => const MonobankDoneScreen(),
      ),
      GoRoute(
        path: AppRoute.monobankSort.path,
        name: AppRoute.monobankSort.name,
        builder: (context, state) => const MonobankSortScreen(),
      ),
      GoRoute(
        path: AppRoute.monobankRulesCreated.path,
        name: AppRoute.monobankRulesCreated.name,
        builder: (context, state) => const MonobankRulesCreatedScreen(),
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
        builder: (context, state) => HomeScreen(
          startOnAddAccount:
              state.uri.queryParameters['openAddAccount'] == 'true',
        ),
      ),
      GoRoute(
        path: AppRoute.stats.path,
        name: AppRoute.stats.name,
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: AppRoute.newAccount.path,
        name: AppRoute.newAccount.name,
        builder: (context, state) => const NewAccountScreen(),
      ),
      GoRoute(
        path: AppRoute.newTransaction.path,
        name: AppRoute.newTransaction.name,
        builder: (context, state) => const NewTransactionScreen(),
      ),
      GoRoute(
        path: AppRoute.transactionDetails.path,
        name: AppRoute.transactionDetails.name,
        builder: (context, state) => TransactionDetailsScreen(
          draft:
              state.extra as TransactionDraft? ??
              const TransactionDraft(
                kind: TransactionKind.expense,
                wholeAmount: '0',
                decimalAmount: '00',
                accountLabel: 'Mono Black •4421',
              ),
        ),
      ),
      GoRoute(
        path: AppRoute.operations.path,
        name: AppRoute.operations.name,
        builder: (context, state) => const OperationsScreen(),
      ),
      GoRoute(
        path: AppRoute.inbox.path,
        name: AppRoute.inbox.name,
        builder: (context, state) => const InboxScreen(),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
