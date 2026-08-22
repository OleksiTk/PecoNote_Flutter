import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../application/providers/settings_providers.dart';
import 'settings_sheet_shell.dart';

/// Показує шторку зміни email. Повертає `true`, якщо email успішно
/// оновлено, щоб виклик міг оновити [userProfileProvider].
Future<bool?> showChangeEmailSheet(
  BuildContext context, {
  required String currentEmail,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => ChangeEmailSheet(currentEmail: currentEmail),
  );
}

class ChangeEmailSheet extends ConsumerStatefulWidget {
  const ChangeEmailSheet({super.key, required this.currentEmail});

  final String currentEmail;

  @override
  ConsumerState<ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends ConsumerState<ChangeEmailSheet> {
  late final _currentEmail = TextEditingController(text: widget.currentEmail);
  final _newEmail = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _currentEmail.dispose();
    _newEmail.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _fieldError(String field) => _fieldErrors[field]?.join('\n');

  Future<void> _submit() async {
    final email = _newEmail.text.trim();
    if (email.isEmpty || _password.text.isEmpty) {
      setState(
        () => _fieldErrors = {
          if (email.isEmpty) 'email': ['Enter your new email address.'],
          if (_password.text.isEmpty)
            'current_password': ['Enter your current password.'],
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
          .changeEmail(email: email, currentPassword: _password.text);
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
      title: 'Change email',
      children: [
        AppTextField(
          label: 'CURRENT EMAIL',
          controller: _currentEmail,
          enabled: false,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'NEW EMAIL',
          controller: _newEmail,
          hintText: 'New email',
          keyboardType: TextInputType.emailAddress,
          enabled: !_loading,
          textInputAction: TextInputAction.next,
          errorText: _fieldError('email'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'CURRENT PASSWORD',
          controller: _password,
          hintText: 'Current password, to confirm',
          obscurable: true,
          enabled: !_loading,
          textInputAction: TextInputAction.done,
          errorText: _fieldError('current_password'),
          onSubmitted: (_) => unawaited(_submit()),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ],
        const SizedBox(height: 22),
        PillButton(
          label: _loading ? 'Updating…' : 'Update email',
          backgroundColor: AppColors.accentBlueMuted,
          foregroundColor: AppColors.white,
          borderColor: AppColors.accentBlueMuted,
          onPressed: _loading ? null : () => unawaited(_submit()),
        ),
      ],
    );
  }
}
