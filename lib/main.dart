import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'widgets/app_logo.dart';
import 'widgets/gradient_background.dart';

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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const GradientBackground(
      vivid: true,
      child: _SplashContent(),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const AppLogoMark(),
            const SizedBox(height: 28),
            const AppWordmark(),
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
