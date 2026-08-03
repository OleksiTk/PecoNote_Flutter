import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/labeled_field.dart';

const int _nameMaxLength = 24;

class NewAccountScreen extends StatefulWidget {
  const NewAccountScreen({super.key});

  @override
  State<NewAccountScreen> createState() => _NewAccountScreenState();
}

class _NewAccountScreenState extends State<NewAccountScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _balance = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  void _onNameChanged() => setState(() {});

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _description.dispose();
    _balance.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.home.name);
    }
  }

  void _addAccount() {
    // Немає ще бекенду для рахунків — повертаємось на Home, як і решта
    // онбординг-флоу (Monobank, "Add manually").
    context.goNamed(AppRoute.home.name);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlassBackButton(onPressed: _goBack),
                        const SizedBox(width: 14),
                        const Text(
                          'New account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Name it, add a short note, set what is in it today.',
                      style: TextStyle(fontSize: 13.5, color: AppColors.grayText),
                    ),
                    const SizedBox(height: 26),
                    LabeledField(
                      label: 'NAME',
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _name,
                              maxLength: _nameMaxLength,
                              buildCounter:
                                  (
                                    context, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) => null,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                hintText: 'e.g. Cash wallet',
                                hintStyle: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.placeholderGray,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_name.text.length}/$_nameMaxLength',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grayTextLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    LabeledField(
                      label: 'DESCRIPTION',
                      child: TextField(
                        controller: _description,
                        minLines: 3,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText:
                              'What this account is for — e.g. everyday '
                              'spending money kept in the wallet',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.placeholderGray,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    LabeledField(
                      label: 'STARTING BALANCE',
                      child: Row(
                        children: [
                          const Text(
                            '₴',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grayText,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _balance,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.placeholderGray,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            child: const Text(
                              'UAH',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                children: [
                  PillButton(
                    label: 'Add account',
                    onPressed: _addAccount,
                    backgroundColor: AppColors.accentBlueMuted,
                    foregroundColor: AppColors.white,
                    borderColor: AppColors.accentBlueMuted,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _goBack,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grayText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
