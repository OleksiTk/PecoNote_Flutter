enum AppRoute {
  splash('/'),
  onboarding('/onboarding'),
  auth('/auth'),
  login('/auth/login'),
  register('/auth/register'),
  forgotPassword('/auth/forgot-password'),
  resetPassword('/reset-password'),
  startChoice('/start'),
  connectMonobank('/start/connect-monobank'),
  monobankQrScan('/start/connect-monobank/scan'),
  monobankCards('/start/connect-monobank/cards'),
  monobankPeriod('/start/connect-monobank/period'),
  monobankSyncing('/start/connect-monobank/syncing'),
  monobankDone('/start/connect-monobank/done'),
  monobankSort('/start/connect-monobank/sort'),
  monobankRulesCreated('/start/connect-monobank/rules-created'),
  ready('/ready'),
  home('/home'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
