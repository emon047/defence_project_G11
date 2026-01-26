import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color spaceDark = Color(0xFF1A1C2E);
  static const Color deepPurple = Color(0xFF6366F1);
  static const Color auroraTeal = Color(0xFF2DD4BF);
  static const Color softLavender = Color(0xFFE0E7FF);
  
  // Background Colors
  static const Color bgGradientStart = Color(0xFFF8FAFC);
  static const Color bgGradientEnd = Color(0xFFEEF2FF);

  // FIXED: Re-added bgGradient for Auth Screens
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgGradientStart, bgGradientEnd],
  );

  static const LinearGradient auraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFFAC94F4)],
  );
}

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.bgGradientStart,
  textTheme: GoogleFonts.plusJakartaSansTextTheme(),
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.deepPurple,
    primary: AppColors.deepPurple,
  ),
);