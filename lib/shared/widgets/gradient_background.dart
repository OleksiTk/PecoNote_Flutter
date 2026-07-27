import 'dart:math' as math;
import 'package:flutter/material.dart';

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
  // Наскільки далеко центр плями відходить від центру екрана (частка від W/H).
  static const _travel = 0.5;
  static const _phaseStep = math.pi / 2; // 90° між шарами

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
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
    final topOpacity = widget.vivid ? 1.0 : 0.55;

    return Scaffold(
      backgroundColor: const Color(0xFFDCE2EC), // база як у CSS
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;
          // Пляма — коло діаметром 1.2 екрана (аналог 60% від 200%-тайла).
          final blobSize = math.max(w, h) * 1.2;

          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value * 2 * math.pi;
                  return Stack(
                    children: [
                      _blob(
                        const Color(0xFF9EC7FF),
                        blobSize,
                        w,
                        h,
                        t,
                        0,
                        topOpacity,
                      ),
                      _blob(
                        const Color(0xFFFFC9AE),
                        blobSize,
                        w,
                        h,
                        t,
                        1,
                        topOpacity,
                      ),
                      _blob(const Color(0xFFA6EFCB), blobSize, w, h, t, 2, 1.0),
                      _blob(const Color(0xFFF7BEDD), blobSize, w, h, t, 3, 1.0),
                    ],
                  );
                },
              ),
              widget.child,
            ],
          );
        },
      ),
    );
  }

  /// Центр плями їде по еліпсу навколо центру екрана:
  ///   cx = 0.5 + travel·sin(t + φ)
  ///   cy = 0.5 + travel·cos(t + φ)
  Widget _blob(
    Color color,
    double size,
    double w,
    double h,
    double t,
    int layer,
    double opacity,
  ) {
    final phase = t + layer * _phaseStep;
    final cx = (0.5 + _travel * math.sin(phase)) * w;
    final cy = (0.5 + _travel * math.cos(phase)) * h;

    return Positioned(
      left: cx - size / 2,
      top: cy - size / 2,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
              stops: const [0.0, 0.62], // "transparent 62%" з CSS
            ),
          ),
        ),
      ),
    );
  }
}
