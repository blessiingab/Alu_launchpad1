import 'package:flutter/material.dart';

/// Design tokens for ALU LaunchPad.
///
/// Clean theme without external font dependencies.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF16233D);
  static const Color navyLight = Color(0xFF243654);
  static const Color gold = Color(0xFFF2A93B);
  static const Color goldDeep = Color(0xFFD98E1F);
  static const Color canvas = Color(0xFFFAF8F4);
  static const Color card = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkMuted = Color(0xFF5C6472);
  static const Color line = Color(0xFFE6E1D8);

  static const Color success = Color(0xFF2E8B57);
  static const Color warning = Color(0xFFD98E1F);
  static const Color danger = Color(0xFFC0463C);

  static const Color pending = Color(0xFFD98E1F);
  static const Color verified = Color(0xFF2E8B57);
  static const Color rejected = Color(0xFFC0463C);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        primary: AppColors.navy,
        secondary: AppColors.gold,
        surface: AppColors.card,
        error: AppColors.danger,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: null, // uses default system font
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: const TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(color: AppColors.ink),
        bodyMedium: const TextStyle(color: AppColors.inkMuted),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.navy),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.navy,
        ),
      ),
    );
  }
}