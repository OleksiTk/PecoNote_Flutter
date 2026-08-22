import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../application/providers/settings_providers.dart';
import 'settings_sheet_shell.dart';

/// Показує шторку зміни пароля. Повертає `true`, якщо пароль успішно
/// оновлено.
Future<bool?> showChangePasswordSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => const ChangePasswordSheet(),
  );
}

class ChangePasswordSheet extends ConsumerStatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  ConsumerState<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<ChangePasswordSheet> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _fieldError(String field) => _fieldErrors[field]?.join('\n');

  Future<void> _submit() async {
    if (_newPassword.text.length < 8) {
      setState(
        () => _fieldErrors = const {
          'new_password': ['Password must contain at least 8 characters.'],
        },
      );
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      setState(
        () => _fieldErrors = const {
          'confirm_new_password': ['Passwords do not match.'],
        },
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _fieldErrors = const {};
    });
    try {
      await ref
          .read(settingsRepositoryProvider)
          .changePassword(
            currentPassword: _currentPassword.text,
            newPassword: _newPassword.text,
            confirmNewPassword: _confirmPassword.text,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ValidationFailure catch (failure) {
      if (mounted) {
        setState(() {
          _error = failure.message;
          _fieldErrors = failure.fieldErrors;
        });
      }
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsBottomSheetShell(
      title: 'Change password',
      children: [
        AppTextField(
          label: 'CURRENT PASSWORD',
          controller: _currentPassword,
          obscurable: true,
          enabled: !_loading,
          textInputAction: TextInputAction.next,
          errorText: _fieldError('current_password'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'NEW PASSWORD',
          controller: _newPassword,
          obscurable: true,
          enabled: !_loading,
          textInputAction: TextInputAction.next,
          errorText: _fieldError('new_password'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'CONFIRM NEW PASSWORD',
          controller: _confirmPassword,
          obscurable: true,
          enabled: !_loading,
          textInputAction: TextInputAction.done,
          errorText: _fieldError('confirm_new_password'),
          onSubmitted: (_) => unawaited(_submit()),
        ),
        const SizedBox(height: 8),
        const Text(
          'At least 8 characters, with a number.',
          style: TextStyle(fontSize: 11, color: AppColors.grayText),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
        const SizedBox(height: 18),
        PillButton(
          label: _loading ? 'Updating…' : 'Update password',
          backgroundColor: AppColors.accentBlueMuted,
          foregroundColor: AppColors.white,
          borderColor: AppColors.accentBlueMuted,
          onPressed: _loading ? null : () => unawaited(_submit()),
        ),
      ],
    );
  }
}
