import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscurable = false,
    this.keyboardType,
    this.errorText,
    this.enabled = true,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscurable;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool enabled;
  final TextInputAction? textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlue.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasError
                        ? AppColors.error.withValues(alpha: 0.5)
                        : AppColors.white.withValues(alpha: 0.70),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grayText,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: widget.controller,
                            enabled: widget.enabled,
                            obscureText: widget.obscurable && _obscured,
                            keyboardType: widget.keyboardType,
                            textInputAction: widget.textInputAction,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: widget.hintText,
                              hintStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.obscurable)
                      GestureDetector(
                        onTap: () => setState(() => _obscured = !_obscured),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            _obscured
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.grayText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
