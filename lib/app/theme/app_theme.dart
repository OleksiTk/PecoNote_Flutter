import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.light();

  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accentBlue),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme),
    useMaterial3: true,
  );
}
