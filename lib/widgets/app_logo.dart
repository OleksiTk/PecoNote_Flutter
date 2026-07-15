import 'package:flutter/material.dart';

const _textColor = Color(0xFF3B4358);

/// Скляна квадратна картка з символом-логотипом "ə".
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 88, this.fontSize = 40});

  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E87B4).withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'ə',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
      ),
    );
  }
}

/// Текстовий вордмарк "pecoNote" (тонкий "peco" + жирний "Note").
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.fontSize = 30});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: _textColor,
          letterSpacing: -0.3,
        ),
        children: [
          const TextSpan(text: 'peco', style: TextStyle(fontWeight: FontWeight.w300)),
          TextSpan(
            text: 'Note',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
