import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Наскрізний анімований градієнтний фон PecoNote.
///
/// [vivid] — насичені плями у всіх чотирьох кутках (сплеш, вибір способу входу).
/// Не-[vivid] ("м'який") варіант притлумлює верхні плями, лишаючи верх майже
/// білим під заголовки й картки, а кольоровий "серпанок" концентрує знизу.
///
/// Кожна пляма рухається по еліпсу за спільною формулою:
///   dx(t) = travelX · sin(2π·t/T + φ)
///   dy(t) = travelY · cos(2π·t/T + φ)
/// Усі чотири плями мають один період [period] (T), але зсунуті по фазі
/// на 90° (π/2) одна від одної — тому рух ніколи не синхронізується й не
/// "стрибає". Якщо система просить менше анімації (accessibility →
/// reduce motion), плями завмирають на t=0.
class GradientBackground extends StatefulWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.vivid = false,
    this.period = const Duration(seconds: 22),
  });

  final Widget child;
  final bool vivid;
  final Duration period;

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  static const _travelX = 26.0;
  static const _travelY = 32.0;
  static const _phaseStep = math.pi / 2; // 90° between layers

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
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
                      dx: _travelX * math.sin(t),
                      dy: _travelY * math.cos(t),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFFFD3BC), // orange → правий верх
                      size: 560 * topSizeScale,
                      opacity: topOpacity,
                      top: true,
                      left: false,
                      dx: _travelX * math.sin(t + _phaseStep),
                      dy: _travelY * math.cos(t + _phaseStep),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFB4E8CE), // green → правий низ
                      size: 600,
                      opacity: 1.0,
                      top: false,
                      left: false,
                      dx: _travelX * math.sin(t + 2 * _phaseStep),
                      dy: _travelY * math.cos(t + 2 * _phaseStep),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFF6C7DE), // pink → лівий низ
                      size: 560,
                      opacity: 1.0,
                      top: false,
                      left: true,
                      dx: _travelX * math.sin(t + 3 * _phaseStep),
                      dy: _travelY * math.cos(t + 3 * _phaseStep),
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
