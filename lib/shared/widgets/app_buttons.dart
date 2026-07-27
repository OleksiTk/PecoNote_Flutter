import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.white,
    this.foregroundColor = AppColors.textDark,
    this.borderColor = AppColors.balanceGradientEnd,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color borderColor;
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
            color: AppColors.shadowBlue.withValues(alpha: 0.16),
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
                border: Border.all(
                  color: enabled ? borderColor : AppColors.accentBlueMuted,
                ),
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
              color: AppColors.grayTextLight,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(text: '$prefix '),
              TextSpan(
                text: linkLabel,
                style: const TextStyle(
                  color: AppColors.accentBlue,
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
            color: AppColors.accentBlueMuted,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class GlassBackButton extends StatelessWidget {
  const GlassBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
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
                color: AppColors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.65),
                ),
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
