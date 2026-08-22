import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import 'settings_sheet_shell.dart';

/// Статичний список мов для макета. Підключення до бекенду (якщо з'явиться)
/// буде додано окремо.
const _languageOptions = ['Українська', 'English', 'Polski', 'Deutsch'];

/// Показує шторку вибору мови інтерфейсу. Повертає обрану мову, якщо
/// користувач натиснув Save.
Future<String?> showLanguagePickerSheet(
  BuildContext context, {
  required String currentLanguage,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => LanguagePickerSheet(currentLanguage: currentLanguage),
  );
}

class LanguagePickerSheet extends StatefulWidget {
  const LanguagePickerSheet({super.key, required this.currentLanguage});

  final String currentLanguage;

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  late String _selected = _languageOptions.contains(widget.currentLanguage)
      ? widget.currentLanguage
      : _languageOptions.first;

  @override
  Widget build(BuildContext context) {
    return SettingsBottomSheetShell(
      title: 'Language',
      children: [
        SettingsOptionsCard(
          children: [
            for (var i = 0; i < _languageOptions.length; i++) ...[
              _LanguageOptionRow(
                label: _languageOptions[i],
                selected: _languageOptions[i] == _selected,
                onTap: () => setState(() => _selected = _languageOptions[i]),
              ),
              if (i != _languageOptions.length - 1)
                const SettingsOptionDivider(),
            ],
          ],
        ),
        const SizedBox(height: 22),
        PillButton(
          label: 'Save',
          backgroundColor: AppColors.accentBlueMuted,
          foregroundColor: AppColors.white,
          borderColor: AppColors.accentBlueMuted,
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}

class _LanguageOptionRow extends StatelessWidget {
  const _LanguageOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              SettingsRadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}
