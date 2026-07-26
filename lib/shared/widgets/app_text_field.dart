import 'dart:ui';

import 'package:flutter/material.dart';

const _textColor = Color(0xFF3B4358);

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.70)),
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
                    color: Color(0xFF98A0B5),
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
                    color: _textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: _textColor.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                if (widget.errorText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.errorText!,
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
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
                color: const Color(0xFF98A0B5),
              ),
            ),
        ],
          ),
        ),
      ),
    );
  }
}
