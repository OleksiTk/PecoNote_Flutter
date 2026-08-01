import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';

enum AppNavTab { home, ops, inbox, stats, settings }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.activeTab});

  final AppNavTab activeTab;

  static const _items = [
    (tab: AppNavTab.home, icon: Icons.home_outlined, label: 'Home'),
    (tab: AppNavTab.ops, icon: Icons.format_list_bulleted, label: 'Ops'),
    (tab: AppNavTab.inbox, icon: Icons.inbox_outlined, label: 'Inbox'),
    (tab: AppNavTab.settings, icon: Icons.tune, label: 'Settings'),
  ];

  void _onTap(BuildContext context, AppNavTab tab) {
    if (tab == activeTab) return;
    switch (tab) {
      case AppNavTab.home:
        context.goNamed(AppRoute.home.name);
      case AppNavTab.settings:
        context.goNamed(AppRoute.settings.name);
      case AppNavTab.ops:
        context.goNamed(AppRoute.operations.name);
      case AppNavTab.inbox:
        context.goNamed(AppRoute.inbox.name);
      case AppNavTab.stats:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // Плоский напівпрозорий колір замість BackdropFilter: під ним
            // лише гладкий градієнт без деталей, тож розмиття нічого не дає
            // візуально, а панель показана постійно на 4 екранах.
            color: AppColors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _items.map((item) {
              final active = item.tab == activeTab;
              final color = active ? AppColors.accentBlue : AppColors.grayText;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onTap(context, item.tab),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(item.icon, size: 22, color: color),
                          if (item.tab == AppNavTab.inbox)
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
                      const SizedBox(height: 5),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
