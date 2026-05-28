import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

class AppTheme {
  static const Color primary = Color(0xFF00695C);
  static const Color primaryDark = Color(0xFF0B4F47);
  static const Color accent = Color(0xFF1B8D87);
  static const Color background = Color(0xFFF2F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFE8F3F2);
  static const Color textMain = Color(0xFF1A1D1E);
  static const Color textMuted = Color(0xFF4F646B);
  static const Color softMint = Color(0xFFBFE7E1);
  static const Color success = Color(0xFF157347);
  static const Color warning = Color(0xFFB66A1F);
  static const Color danger = Color(0xFFB02A37);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      surface: surface,
      onSurface: textMain,
      tertiary: softMint,
      secondary: accent,
      error: danger,
    );

    final textTheme = ThemeData.light().textTheme.copyWith(
          headlineLarge: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: textMain),
          headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textMain),
          titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textMain),
          titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textMain),
          bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textMain),
          bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textMuted),
          labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textMain,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSoft,
        selectedColor: primary,
        labelStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.06),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textMain,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: softMint, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: softMint, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          foregroundColor: primaryDark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
