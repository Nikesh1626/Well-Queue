import 'package:flutter/material.dart';

class AdminSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AdminRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

class AdminTheme {
  static const Color primary = Color(0xFF00695C);
  static const Color primaryDark = Color(0xFF0C4F49);
  static const Color accent = Color(0xFF1A7E78);
  static const Color bg = Color(0xFFF2F6F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFEAF4F3);
  static const Color onSurface = Color(0xFF152024);
  static const Color onMuted = Color(0xFF51666C);
  static const Color success = Color(0xFF157347);
  static const Color warning = Color(0xFFB66A1F);
  static const Color danger = Color(0xFFB02A37);

  static ThemeData get light {
    final color = ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light).copyWith(
      primary: primary,
      secondary: accent,
      surface: surface,
      onSurface: onSurface,
      error: danger,
    );

    final textTheme = ThemeData.light().textTheme.copyWith(
          headlineLarge: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: onSurface),
          headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface),
          titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: onSurface),
          titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
          bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: onSurface),
          bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onMuted),
          labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: color,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceSoft,
        selectedColor: primary,
        labelStyle: const TextStyle(color: onMuted, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminRadii.pill)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminRadii.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminRadii.md),
          borderSide: const BorderSide(color: Color(0xFFB4E5DF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AdminSpacing.lg, vertical: AdminSpacing.lg),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminRadii.pill)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: Color(0xFFB4E5DF), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminRadii.pill)),
          foregroundColor: primaryDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdminRadii.lg)),
        shadowColor: Colors.black.withValues(alpha: 0.05),
        margin: const EdgeInsets.symmetric(vertical: AdminSpacing.sm),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurface,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminRadii.md),
        ),
      ),
    );
  }
}
