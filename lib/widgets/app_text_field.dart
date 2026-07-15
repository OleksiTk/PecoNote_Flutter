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
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscurable;
  final TextInputType? keyboardType;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
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
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF98A0B5),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: widget.controller,
                  obscureText: widget.obscurable && _obscured,
                  keyboardType: widget.keyboardType,
                  style: const TextStyle(
                    fontSize: 16,
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
    );
  }
}
