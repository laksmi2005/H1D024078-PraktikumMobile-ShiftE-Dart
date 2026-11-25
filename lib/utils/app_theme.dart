import 'package:flutter/material.dart';

class AppTheme {
  static const Color primarySky = Color(0xFF0284C7);
  static const Color accentCyan = Color(0xFF0891B2);
  static const Color scaffoldLight = Color(0xFFF4F7FA);
  static const Color scaffoldDark = Color(0xFF0F172A);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySky,
      brightness: Brightness.light,
      primary: primarySky,
      secondary: accentCyan,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: scaffoldLight,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFFF4F7FA),
      foregroundColor: Color(0xFF1E293B),
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: primarySky.withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primarySky.withValues(alpha: 0.3)),
      ),
      showCheckmark: false,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySky,
      brightness: Brightness.dark,
      primary: const Color(0xFF38BDF8),
      surface: const Color(0xFF1E293B),
    ),
    scaffoldBackgroundColor: scaffoldDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: scaffoldDark,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFF1E293B),
    ),
  );
}
