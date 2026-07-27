import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';

/// Tabs shown in [AppBottomNavBar]. Only [home] and [settings] are wired to
/// real routes so far — the rest are placeholders (§3.2 mockup).
enum AppNavTab { home, ops, inbox, stats, settings }

/// Shared bottom navigation bar used by top-level screens (Home, Settings, …).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.activeTab});

  final AppNavTab activeTab;

  static const _items = [
    (tab: AppNavTab.home, icon: Icons.home_rounded, label: 'Home'),
    (tab: AppNavTab.ops, icon: Icons.list_alt_outlined, label: 'Ops'),
    (tab: AppNavTab.inbox, icon: Icons.inbox_outlined, label: 'Inbox'),
    (tab: AppNavTab.stats, icon: Icons.bar_chart_rounded, label: 'Stats'),
    (tab: AppNavTab.settings, icon: Icons.tune_outlined, label: 'Settings'),
  ];

  void _onTap(BuildContext context, AppNavTab tab) {
    if (tab == activeTab) return;
    switch (tab) {
      case AppNavTab.home:
        context.goNamed(AppRoute.home.name);
      case AppNavTab.settings:
        context.goNamed(AppRoute.settings.name);
      case AppNavTab.ops:
      case AppNavTab.inbox:
      case AppNavTab.stats:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items.map((item) {
          final active = item.tab == activeTab;
          final color = active
              ? AppColors.accentBlue
              : AppColors.placeholderGray;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onTap(context, item.tab),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(item.icon, size: 22, color: color),
                    if (item.label == 'Inbox')
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.notificationDot,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
