import 'package:flutter/material.dart';

class AppColors {
  static const Color primary    = Color(0xFF2C5F4F);
  static const Color secondary  = Color(0xFF5C8D7A);
  static const Color background = Color(0xFFF5F3ED);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color text       = Color(0xFF2C3E3C);
  static const Color textLight  = Color(0xFF6B7876);
  static const Color green      = Color(0xFF4CAF50);
  static const Color blue       = Color(0xFF1565C0);
  static const Color grey       = Color(0xFF9E9E9E);
  static const Color greyLight  = Color(0xFFE0E0E0);
}

class AppTheme {
  // ── Light Theme (default) ───────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary:   AppColors.primary,
      secondary: AppColors.secondary,
      surface:   Colors.white,
      background: AppColors.background,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.text),
      titleTextStyle: TextStyle(
          color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600),
    ),
    cardTheme: const CardThemeData(elevation: 0, color: Colors.white),
    dividerColor: Color(0xFFE0E0E0),
  );

  // ── Dark Theme ──────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4CAF88),
    scaffoldBackgroundColor: const Color(0xFF0F1923),
    colorScheme: const ColorScheme.dark(
      primary:    Color(0xFF4CAF88),
      secondary:  Color(0xFF6EC6A0),
      surface:    Color(0xFF1A2535),
      background: Color(0xFF0F1923),
      onBackground: Color(0xFFE8F0EE),
      onSurface:    Color(0xFFE8F0EE),
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F1923),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE8F0EE)),
      titleTextStyle: TextStyle(
          color: Color(0xFFE8F0EE), fontSize: 18, fontWeight: FontWeight.w600),
    ),
    cardTheme: const CardThemeData(elevation: 0, color: Color(0xFF1A2535)),
    dividerColor: Color(0xFF2A3A4A),
  );
}

/// Convenience extension — use context.cardColor, context.bgColor etc.
extension ThemeColors on BuildContext {
  bool   get isDark        => Theme.of(this).brightness == Brightness.dark;
  Color  get bgColor       => isDark ? const Color(0xFF0F1923)   : const Color(0xFFF5F3ED);
  Color  get cardColor     => isDark ? const Color(0xFF1A2535)   : Colors.white;
  Color  get cardColor2    => isDark ? const Color(0xFF243040)   : const Color(0xFFF8F8F8);
  Color  get textColor     => isDark ? const Color(0xFFE8F0EE)   : const Color(0xFF2C3E3C);
  Color  get textSub       => isDark ? const Color(0xFF8CA0A8)   : Colors.grey.shade500;
  Color  get borderColor   => isDark ? const Color(0xFF2A3A4A)   : Colors.grey.shade200;
  Color  get primaryGreen  => isDark ? const Color(0xFF4CAF88)   : const Color(0xFF2C5F4F);
  Color  get inputFill     => isDark ? const Color(0xFF1A2535)   : Colors.white;
  Color  get iconBg        => isDark ? const Color(0xFF243040)   : const Color(0xFFF0F4F2);
  Color  get shadowColor   => isDark ? Colors.black38           : Colors.black12;
}
