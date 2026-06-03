import 'package:flutter/material.dart';

/// Soft Storybook / Toy palette + tokens for Bambaruush.
class AppColors {
  static const sky = Color(0xFF8FD3F0);
  static const meadow = Color(0xFF9BD16B);
  static const sun = Color(0xFFFFD23F);
  static const coral = Color(0xFFFF7A59); // PRIMARY ACTION ONLY
  static const cream = Color(0xFFFFF7E9);
  static const ink = Color(0xFF4A3B2A); // warm dark-brown text (not pure black)
  static const inkSoft = Color(0xFF8A7A66);
  static const cardBorder = Color(0xFFE7D9BE);
}

class AppRadii {
  static const card = 24.0;
  static const button = 28.0;
  static const tile = 20.0;
}

class AppFonts {
  static const display = 'Fredoka'; // UI headings, buttons
  static const body = 'Nunito'; // body text
  static const learning = 'Nunito'; // Mongolian Cyrillic content (full Cyrillic glyphs)
}

/// Soft brown shadow used on cards/buttons.
const kSoftShadow = BoxShadow(
  color: Color(0x1A4A3B2A),
  blurRadius: 12,
  offset: Offset(0, 4),
);

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.coral,
      primary: AppColors.coral,
      secondary: AppColors.sky,
      surface: AppColors.cream,
      brightness: Brightness.light,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: AppFonts.body,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ).copyWith(
        // Headings/titles use the rounded display font.
        headlineLarge: const TextStyle(fontFamily: AppFonts.display, fontWeight: FontWeight.w600, color: AppColors.ink),
        headlineMedium: const TextStyle(fontFamily: AppFonts.display, fontWeight: FontWeight.w600, color: AppColors.ink),
        titleLarge: const TextStyle(fontFamily: AppFonts.display, fontWeight: FontWeight.w600, color: AppColors.ink),
        titleMedium: const TextStyle(fontFamily: AppFonts.display, fontWeight: FontWeight.w600, color: AppColors.ink),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: AppColors.ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontFamily: AppFonts.display, fontWeight: FontWeight.w600, fontSize: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          minimumSize: const Size(0, 56),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sun,
          foregroundColor: AppColors.ink,
          textStyle: const TextStyle(fontFamily: AppFonts.display, fontWeight: FontWeight.w600, fontSize: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.button)),
          minimumSize: const Size(0, 52),
          elevation: 0,
        ),
      ),
    );
  }
}
