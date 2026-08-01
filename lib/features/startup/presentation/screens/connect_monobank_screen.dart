import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';

class ConnectMonobankScreen extends StatefulWidget {
  const ConnectMonobankScreen({super.key});

  @override
  State<ConnectMonobankScreen> createState() => _ConnectMonobankScreenState();
}

class _ConnectMonobankScreenState extends State<ConnectMonobankScreen> {
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final token = await context.pushNamed<String>(AppRoute.monobankQrScan.name);
    if (token != null && token.isNotEmpty && mounted) {
      _tokenController.text = token;
      _tokenController.selection = TextSelection.collapsed(
        offset: token.length,
      );
    }
  }

  void _continue() {
    context.pushNamed(AppRoute.monobankCards.name);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassBackButton(onPressed: () => context.pop()),
                  const Text(
                    'STEP 1 OF 4',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _StepProgressBar(step: 1, total: 4),
              const SizedBox(height: 28),
              const _IconBadge(emoji: '🏦'),
              const SizedBox(height: 18),
              const Text(
                'Connect Monobank',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grayText,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'Get your token at '),
                    TextSpan(
                      text: 'api.monobank.ua',
                      style: TextStyle(
                        color: AppColors.accentBlueMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' — PecoNote only reads transactions, it never '
                          'touches your money.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _TokenField(controller: _tokenController),
              const SizedBox(height: 14),
              _ScanQrRow(onTap: _scanQr),
              const SizedBox(height: 26),
              PillButton(
                label: 'Continue',
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
                onPressed: _continue,
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  '🔒 Read-only access · revoke any time',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grayTextLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i < step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? AppColors.accentBlueMuted : AppColors.dotInactive,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // Плоский колір замість BackdropFilter: разом з полем токена й
        // кнопкою QR на екрані одночасно було 3 блюри.
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }
}

class _TokenField extends StatelessWidget {
  const _TokenField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      // Плоский колір замість BackdropFilter — див. коментар у _IconBadge.
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.subChipBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 18,
              color: AppColors.placeholderGray,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'paste your token here…',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.placeholderGray,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanQrRow extends StatelessWidget {
  const _ScanQrRow({required this.onTap});

  final VoidCallback onTap;

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
        // Плоский колір замість BackdropFilter — див. коментар у _IconBadge.
        child: Material(
          color: AppColors.white.withValues(alpha: 0.6),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accentBlueBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 20,
                      color: AppColors.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan QR from Mono app',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'faster than copy-pasting',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.grayTextLight,
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
