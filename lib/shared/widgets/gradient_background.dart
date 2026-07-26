import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Наскрізний анімований градієнтний фон PecoNote.
///
/// [vivid] — насичені плями у всіх чотирьох кутках (сплеш, вибір способу входу).
/// Не-[vivid] ("м'який") варіант притлумлює верхні плями, лишаючи верх майже
/// білим під заголовки й картки, а кольоровий "серпанок" концентрує знизу.
class GradientBackground extends StatefulWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.vivid = false,
  });

  final Widget child;
  final bool vivid;

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topOpacity = widget.vivid ? 1.0 : 0.35;
    final topSizeScale = widget.vivid ? 1.0 : 0.75;
    return Scaffold(
      backgroundColor: widget.vivid
          ? const Color(0xFFF7FAFD)
          : const Color(0xFFFCFDFE),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value * 2 * math.pi;
                return Stack(
                  children: [
                    _cornerBlob(
                      color: const Color(0xFFAED4FA), // blue → лівий верх
                      size: 620 * topSizeScale,
                      opacity: topOpacity,
                      top: true,
                      left: true,
                      dx: 26 * math.sin(t),
                      dy: 32 * math.cos(t * 0.8),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFFFD3BC), // orange → правий верх
                      size: 560 * topSizeScale,
                      opacity: topOpacity,
                      top: true,
                      left: false,
                      dx: 26 * math.cos(t * 0.9 + 1.0),
                      dy: 32 * math.sin(t * 0.7 + 1.0),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFB4E8CE), // green → правий низ
                      size: 600,
                      opacity: 1.0,
                      top: false,
                      left: false,
                      dx: 26 * math.sin(t * 0.6 + 2.0),
                      dy: 32 * math.cos(t + 2.0),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFF6C7DE), // pink → лівий низ
                      size: 560,
                      opacity: 1.0,
                      top: false,
                      left: true,
                      dx: 26 * math.cos(t * 0.7 + 3.0),
                      dy: 32 * math.sin(t * 0.9 + 3.0),
                    ),
                  ],
                );
              },
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  Widget _cornerBlob({
    required Color color,
    required double size,
    required double opacity,
    required bool top,
    required bool left,
    required double dx,
    required double dy,
  }) {
    const anchor = 0.34;
    return Positioned(
      top: top ? -size * anchor + dy : null,
      bottom: !top ? -size * anchor - dy : null,
      left: left ? -size * anchor + dx : null,
      right: !left ? -size * anchor - dx : null,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0.75),
                color.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
