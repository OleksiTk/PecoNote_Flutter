import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const PecoNoteApp());
}

class PecoNoteApp extends StatelessWidget {
  const PecoNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      body: Stack(
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
                      size: 620,
                      top: true,
                      left: true,
                      dx: 26 * math.sin(t),
                      dy: 32 * math.cos(t * 0.8),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFFFD3BC), // orange → правий верх
                      size: 560,
                      top: true,
                      left: false,
                      dx: 26 * math.cos(t * 0.9 + 1.0),
                      dy: 32 * math.sin(t * 0.7 + 1.0),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFB4E8CE), // green → правий низ
                      size: 600,
                      top: false,
                      left: false,
                      dx: 26 * math.sin(t * 0.6 + 2.0),
                      dy: 32 * math.cos(t + 2.0),
                    ),
                    _cornerBlob(
                      color: const Color(0xFFF6C7DE), // pink → лівий низ
                      size: 560,
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
          const _SplashContent(), // статичний контент не перебудовується
        ],
      ),
    );
  }

  /// Розмита кольорова пляма, заякорена в кутку екрана.
  /// top/left обирають кут, dx/dy — невеликий зсув у пікселях (ефект живих шпалер).
  Widget _cornerBlob({
    required Color color,
    required double size,
    required bool top,
    required bool left,
    required double dx,
    required double dy,
  }) {
    const anchor = 0.34; // частка розміру, на яку пляма виходить за край екрана
    return Positioned(
      top: top ? -size * anchor + dy : null,
      bottom: !top ? -size * anchor - dy : null,
      left: left ? -size * anchor + dx : null,
      right: !left ? -size * anchor - dx : null,
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
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF3B4358);
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // логотип-картка
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E87B4).withValues(alpha: 0.18),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'ə',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'pecoNote',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w300,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'FINANCE, SOFTLY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF98A0B5),
                letterSpacing: 3,
              ),
            ),
            const Spacer(flex: 4),
            // прогрес-смужка внизу
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  width: 96,
                  height: 4,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF8FA8D6)),
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
