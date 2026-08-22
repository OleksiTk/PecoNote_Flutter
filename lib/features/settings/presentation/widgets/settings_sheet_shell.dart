import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Спільна "рама" для нижніх шторок налаштувань (Profile, Change email,
/// Change password) — та сама стилістика скла й drag-хендла, що й у
/// _CategoryPickerSheet на екрані сортування Monobank.
class SettingsBottomSheetShell extends StatelessWidget {
  const SettingsBottomSheetShell({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: BoxDecoration(
            color: AppColors.scaffoldVivid.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.dotInactive,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Скляна картка зі списком опцій (валюта / мова тощо) всередині нижньої
/// шторки.
class SettingsOptionsCard extends StatelessWidget {
  const SettingsOptionsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
        ),
        child: Column(children: children),
      ),
    );
  }
}

/// Розділювач між рядками у [SettingsOptionsCard].
class SettingsOptionDivider extends StatelessWidget {
  const SettingsOptionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.dotInactive.withValues(alpha: 0.6),
    );
  }
}

/// Кругла позначка вибору у стилі radio-button з макета.
class SettingsRadioDot extends StatelessWidget {
  const SettingsRadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accentBlue : AppColors.dotInactive,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlue,
              ),
            )
          : null,
    );
  }
}
