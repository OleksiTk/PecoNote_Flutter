import 'dart:math' as math;
import 'dart:ui' as ui;

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
  late final AnimationController _controller;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period);
    // The engine already skips scheduling frames while backgrounded, so this
    // isn't fixing visible jank — it's explicit belt-and-suspenders so the
    // ticker doesn't sit "running" (and the controller re-syncs correctly)
    // across pause/resume instead of relying on that implicit behaviour.
    _lifecycleListener = AppLifecycleListener(
      onResume: _syncAnimation,
      onInactive: () => _controller.stop(),
      onHide: () => _controller.stop(),
      onPause: () => _controller.stop(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    if (!mounted) return;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final isForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    if (reduce) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!isCurrent || !isForeground) {
      // Covered by another route, or the app isn't in the foreground — no
      // point animating something nobody can see.
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topOpacity = widget.vivid ? 1.0 : 0.55;

    return Scaffold(
      backgroundColor: const Color(0xFFDCE2EC), // база як у CSS
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Isolated in its own layer: this is the only part of the tree
          // that actually needs to repaint every animation tick.
          RepaintBoundary(
            child: CustomPaint(
              painter: _BlobsPainter(
                animation: _controller,
                topOpacity: topOpacity,
              ),
            ),
          ),
          RepaintBoundary(child: widget.child),
        ],
      ),
    );
  }
}

/// Малює 4 плями одним шаром замість 4 окремих Container/Opacity —
/// менше офскрін-компоузу на слабких GPU.
class _BlobsPainter extends CustomPainter {
  _BlobsPainter({required this.animation, required this.topOpacity})
    : super(repaint: animation);

  final Animation<double> animation;
  final double topOpacity;

  // Наскільки далеко центр плями відходить від центру екрана (частка від W/H).
  static const _travel = 0.5;
  static const _phaseStep = math.pi / 2; // 90° між шарами
  static const _stops = [0.0, 0.62]; // "transparent 62%" з CSS
  static const _colors = [
    Color(0xFF9EC7FF),
    Color(0xFFFFC9AE),
    Color(0xFFA6EFCB),
    Color(0xFFF7BEDD),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Пляма — коло діаметром 1.2 екрана (аналог 60% від 200%-тайла).
    final radius = math.max(w, h) * 1.2 / 2;
    final t = animation.value * 2 * math.pi;

    for (var layer = 0; layer < _colors.length; layer++) {
      final opacity = layer < 2 ? topOpacity : 1.0;
      if (opacity <= 0) continue;

      // Центр плями їде по еліпсу навколо центру екрана:
      //   cx = 0.5 + travel·sin(t + φ)
      //   cy = 0.5 + travel·cos(t + φ)
      final phase = t + layer * _phaseStep;
      final center = Offset(
        (0.5 + _travel * math.sin(phase)) * w,
        (0.5 + _travel * math.cos(phase)) * h,
      );
      final color = _colors[layer];

      final paint = Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0),
        ], _stops);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobsPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.topOpacity != topOpacity;
}
