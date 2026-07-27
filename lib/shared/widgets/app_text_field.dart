import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Текстове поле у стилі PecoNote: велика сіра мітка-капс над напівпрозорим
/// заокругленим полем уводу.
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.72), // було 0.45
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.9),
              ), // було 0.70
              borderRadius: BorderRadius.circular(18),
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
                          color: AppColors.labelGray,
                          letterSpacing: 0.6,
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
                          fontSize: 14,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: widget.hintText,
                          hintStyle: TextStyle(color: AppColors.textDark),
                        ),
                      ),
                      if (widget.errorText != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.errorText!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.obscurable)
                  GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.labelGray,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
