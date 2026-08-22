import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../application/providers/settings_providers.dart';
import 'settings_sheet_shell.dart';

/// Показує шторку редагування профілю (ім'я + аватар-заглушка).
/// Повертає `true`, якщо ім'я було успішно збережено, щоб виклик міг
/// оновити [userProfileProvider].
Future<bool?> showEditProfileSheet(
  BuildContext context, {
  required String currentUsername,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => EditProfileSheet(currentUsername: currentUsername),
  );
}

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.currentUsername});

  final String currentUsername;

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final _name = TextEditingController(text: widget.currentUsername);
  bool _loading = false;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? _fieldError(String field) => _fieldErrors[field]?.join('\n');

  void _tapAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo upload is coming soon.')),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(
        () => _fieldErrors = const {
          'username': ['Name cannot be empty.'],
        },
      );
      return;
    }
    if (name == widget.currentUsername) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _fieldErrors = const {};
    });
    try {
      await ref.read(settingsRepositoryProvider).updateProfile(username: name);
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
    final initial = widget.currentUsername.isNotEmpty
        ? widget.currentUsername[0].toUpperCase()
        : '?';

    return SettingsBottomSheetShell(
      title: 'Profile',
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _tapAvatar,
                child: Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _tapAvatar,
                child: const Text(
                  'Tap to change photo',
                  style: TextStyle(fontSize: 12, color: AppColors.grayText),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        AppTextField(
          label: 'NAME',
          controller: _name,
          enabled: !_loading,
          textInputAction: TextInputAction.done,
          errorText: _fieldError('username'),
          onSubmitted: (_) => unawaited(_save()),
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
          label: _loading ? 'Saving…' : 'Save',
          backgroundColor: AppColors.accentBlueMuted,
          foregroundColor: AppColors.white,
          borderColor: AppColors.accentBlueMuted,
          onPressed: _loading ? null : () => unawaited(_save()),
        ),
      ],
    );
  }
}
