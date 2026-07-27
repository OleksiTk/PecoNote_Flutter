enum AppRoute {
  splash('/'),
  onboarding('/onboarding'),
  auth('/auth'),
  login('/auth/login'),
  register('/auth/register'),
  forgotPassword('/auth/forgot-password'),
  resetPassword('/reset-password'),
  startChoice('/start'),
  ready('/ready'),
  home('/home'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;
}
