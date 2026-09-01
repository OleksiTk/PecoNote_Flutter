import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_session.dart';
import '../core/config/app_config.dart';
import '../core/notifications/notification_route.dart';
import '../features/notifications/application/providers/notification_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class PecoNoteApp extends ConsumerStatefulWidget {
  const PecoNoteApp({super.key});

  @override
  ConsumerState<PecoNoteApp> createState() => _PecoNoteAppState();
}

class _PecoNoteAppState extends ConsumerState<PecoNoteApp> {
  StreamSubscription<NotificationRoute>? _routeSub;
  AuthSession? _authSession;
  VoidCallback? _authListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _wireNotifications());
  }

  void _wireNotifications() {
    if (!mounted) return;
    final push = ref.read(pushServiceProvider);

    // Deep-link from a notification the user tapped to cold-start the app.
    final initialRoute = push.takeInitialRoute();
    if (initialRoute != null) {
      ref.read(appRouterProvider).go(initialRoute.location);
    }

    // Taps while the app is running.
    _routeSub = push.routeRequests.listen((route) {
      if (mounted) ref.read(appRouterProvider).go(route.location);
    });

    // Register this device for push whenever a session becomes (or already is)
    // active. A session restored from secure storage flips `authenticated`
    // without a login call, so a listener is the reliable hook.
    final auth = ref.read(authSessionProvider);
    void syncFromAuth() {
      if (auth.authenticated) {
        unawaited(ref.read(deviceTokenSyncProvider).register());
      }
    }

    auth.addListener(syncFromAuth);
    _authSession = auth;
    _authListener = syncFromAuth;
    syncFromAuth();
  }

  @override
  void dispose() {
    _routeSub?.cancel();
    if (_authSession != null && _authListener != null) {
      _authSession!.removeListener(_authListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildAppTheme(),
      locale: const Locale(AppConfig.defaultLanguageCode),
      supportedLocales: const [Locale('en'), Locale('uk')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
