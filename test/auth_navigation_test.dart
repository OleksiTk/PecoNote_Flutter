import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:peconote_mobile/app/router/app_routes.dart';
import 'package:peconote_mobile/features/auth/presentation/screens/auth_choice_screen.dart';
import 'package:peconote_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:peconote_mobile/features/auth/presentation/screens/register_screen.dart';

void main() {
  testWidgets('register back button falls back to the auth route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRoute.register.path,
      routes: [
        GoRoute(
          path: AppRoute.auth.path,
          name: AppRoute.auth.name,
          builder: (context, state) => const AuthChoiceScreen(),
        ),
        GoRoute(
          path: AppRoute.register.path,
          name: AppRoute.register.name,
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.text('PHONE NUMBER'), findsNothing);
    expect(find.text('USERNAME'), findsOneWidget);
    expect(find.text('FIRST NAME'), findsNothing);
    expect(find.text('LAST NAME'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Continue with Email'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login does not show remember-me control', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoute.login.path,
      routes: [
        GoRoute(
          path: AppRoute.login.path,
          name: AppRoute.login.name,
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    expect(find.text('Remember me'), findsNothing);
    expect(find.byType(Checkbox), findsNothing);
  });
}
