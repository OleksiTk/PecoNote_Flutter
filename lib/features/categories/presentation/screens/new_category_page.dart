import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../application/providers/categories_providers.dart';

/// Full-screen "New category" form: emoji + title, with a live preview,
/// matching the Categories grid picker's visual language.
class NewCategoryPage extends ConsumerStatefulWidget {
  const NewCategoryPage({super.key, this.parentId});

  final int? parentId;

  @override
  ConsumerState<NewCategoryPage> createState() => _NewCategoryPageState();
}

class _NewCategoryPageState extends ConsumerState<NewCategoryPage> {
  final _name = TextEditingController();
  final _emoji = TextEditingController();
  bool _saving = false;
  Map<String, List<String>> _fieldErrors = const {};
  String? _error;

  String? _fieldError(String field) => _fieldErrors[field]?.join('\n');

  @override
  void initState() {
    super.initState();
    _name.addListener(_clearNameError);
    _emoji.addListener(() => setState(() {}));
  }

  void _clearNameError() {
    if (_fieldErrors.containsKey('name')) {
      setState(() => _fieldErrors = Map.of(_fieldErrors)..remove('name'));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    super.dispose();
  }

  Future<void> _pasteEmoji() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _emoji.text = text;
      setState(() {});
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _saving) {
      if (name.isEmpty) {
        setState(() {
          _fieldErrors = const {
            'name': ['Enter a category name.'],
          };
        });
      }
      return;
    }

    setState(() {
      _saving = true;
      _fieldErrors = const {};
      _error = null;
    });
    try {
      final emoji = _emoji.text.trim();
      final created = await ref
          .read(categoriesProvider.notifier)
          .createCategory(
            name: name,
            parentId: widget.parentId,
            emoji: emoji.isEmpty ? null : emoji,
          );
      if (mounted) Navigator.of(context).pop(created);
    } on ValidationFailure catch (failure) {
      if (mounted) {
        setState(() {
          _fieldErrors = failure.fieldErrors;
          _error = failure.fieldErrors.keys.any((field) => field != 'name')
              ? failure.message
              : null;
        });
      }
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewEmoji = _emoji.text.trim();
    final previewName = _name.text.trim();

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlassBackButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 14),
                  const Text(
                    'New category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: GestureDetector(
                  onTap: _pasteEmoji,
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        child: Text(
                          previewEmoji.isEmpty ? '🙂' : previewEmoji,
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to paste an emoji',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const _FieldLabel('TITLE'),
              _GlassField(
                controller: _name,
                enabled: !_saving,
                hintText: 'Category name',
                errorText: _fieldError('name'),
                maxLength: 64,
              ),
              const _FieldLabel('EMOJI'),
              _GlassField(
                controller: _emoji,
                enabled: !_saving,
                hintText: 'Paste an emoji…',
                errorText: _fieldError('icon'),
                maxLength: 8,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 6, 4, 0),
                child: Text(
                  'Copy any emoji and paste it here — it becomes the '
                  'category icon.',
                  style: TextStyle(fontSize: 12, color: AppColors.grayTextLight),
                ),
              ),
              const _FieldLabel('PREVIEW'),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        previewEmoji.isEmpty ? '🙂' : previewEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        previewName.isEmpty ? 'Category name' : previewName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.error),
                ),
              ],
              const SizedBox(height: 28),
              PillButton(
                label: _saving ? 'Saving…' : 'Save category',
                onPressed: _saving ? null : () => unawaited(_save()),
                backgroundColor: AppColors.accentBlue,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.labelGray,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.controller,
    required this.hintText,
    required this.enabled,
    this.errorText,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final String? errorText;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorText != null
              ? AppColors.error
              : AppColors.white.withValues(alpha: 0.75),
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLength: maxLength,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.placeholderGray),
          border: InputBorder.none,
          errorText: errorText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
