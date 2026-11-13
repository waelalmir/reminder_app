import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

abstract class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: b,
      primary: isDark ? const Color(0xFF818CF8) : AppColors.seed,
      secondary: AppColors.accent,
      error: AppColors.danger,
      surface: isDark ? const Color(0xFF1E293B) : Colors.white,
    );

    final baseText = ThemeData(brightness: b).textTheme.apply(
          fontFamily: AppFonts.family,
          bodyColor: cs.onSurface,
          displayColor: cs.onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: cs,
      fontFamily: AppFonts.family,
      textTheme: baseText,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppFonts.title.copyWith(color: cs.onSurface),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.035),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppFonts.body.copyWith(
          color: cs.onSurface.withValues(alpha: 0.45),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelStyle: AppFonts.small,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.seed,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
