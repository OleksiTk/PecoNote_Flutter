import 'dart:ui';

import 'package:flutter/material.dart';

const _textColor = Color(0xFF3B4358);
const _accentBlue = Color(0xFF3D6FE5);

/// Повноширинна кнопка-пігулка з м'якою тінню (Next / Get started / Continue).
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.foregroundColor = _textColor,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? leading;

  @override
  @override
  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E87B4).withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: Material(
          color: enabled
              ? backgroundColor
              : backgroundColor.withValues(alpha: 0.5),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Текстове посилання по центру: звичайний текст + виділений синій сегмент.
class TextLinkRow extends StatelessWidget {
  const TextLinkRow({
    super.key,
    required this.prefix,
    required this.linkLabel,
    required this.onTap,
  });

  final String prefix;
  final String linkLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8A93A8),
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: '$prefix '),
              TextSpan(
                text: linkLabel,
                style: const TextStyle(
                  color: _accentBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Одноколірне клікабельне посилання по центру (без виділеного сегмента).
class PlainLinkText extends StatelessWidget {
  const PlainLinkText({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: _accentBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Кругла кнопка "назад" у скляному стилі (шеврон вліво).
class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: _textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
