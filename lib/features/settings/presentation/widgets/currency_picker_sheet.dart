import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import 'settings_sheet_shell.dart';

/// Один пункт списку валют. Поки що це статичний макет — підключення до
/// GET/PATCH /currencies/ буде додано окремо.
class CurrencyOption {
  const CurrencyOption({
    required this.symbol,
    required this.code,
    required this.name,
  });

  final String symbol;
  final String code;
  final String name;
}

const _currencyOptions = [
  CurrencyOption(symbol: '₴', code: 'UAH', name: 'Ukrainian Hryvnia'),
  CurrencyOption(symbol: '\$', code: 'USD', name: 'US Dollar'),
  CurrencyOption(symbol: '€', code: 'EUR', name: 'Euro'),
  CurrencyOption(symbol: '£', code: 'GBP', name: 'British Pound'),
];

/// Показує шторку вибору валюти за замовчуванням. Повертає обраний код
/// валюти (наприклад `'UAH'`), якщо користувач натиснув Save.
Future<String?> showCurrencyPickerSheet(
  BuildContext context, {
  required String currentCode,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => CurrencyPickerSheet(currentCode: currentCode),
  );
}

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({super.key, required this.currentCode});

  final String currentCode;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  late String _selectedCode =
      _currencyOptions.any((option) => option.code == widget.currentCode)
      ? widget.currentCode
      : _currencyOptions.first.code;

  @override
  Widget build(BuildContext context) {
    return SettingsBottomSheetShell(
      title: 'Default currency',
      children: [
        SettingsOptionsCard(
          children: [
            for (var i = 0; i < _currencyOptions.length; i++) ...[
              _CurrencyOptionRow(
                option: _currencyOptions[i],
                selected: _currencyOptions[i].code == _selectedCode,
                onTap: () =>
                    setState(() => _selectedCode = _currencyOptions[i].code),
              ),
              if (i != _currencyOptions.length - 1)
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
          onPressed: () => Navigator.of(context).pop(_selectedCode),
        ),
      ],
    );
  }
}

class _CurrencyOptionRow extends StatelessWidget {
  const _CurrencyOptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CurrencyOption option;
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
              SizedBox(
                width: 22,
                child: Text(
                  option.symbol,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grayText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${option.code} — ${option.name}',
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
