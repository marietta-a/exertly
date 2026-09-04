import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Constant fallbacks
  static const Color darkBlue = Color(0xFF0A2540);
  static const Color lightBlueBg = Color(0xFFF4F7FC);
  static const Color accentOrange = Color(0xFFFF6B00);
  static const Color accentOrangeLight = Color(0xFFFFEBE0);
  static const Color crispWhite = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xD20A2540);
  
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderGray = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: darkBlue,
        secondary: accentOrange,
        background: lightBlueBg,
        surface: crispWhite,
        onPrimary: crispWhite,
        onSecondary: crispWhite,
        onBackground: textDark,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: lightBlueBg,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkBlue),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkBlue),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkBlue),
          bodyLarge: TextStyle(fontSize: 16, color: textDark),
          bodyMedium: TextStyle(fontSize: 14, color: textMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentOrange),
        ),
      ),
      cardTheme: CardThemeData(
        color: crispWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderGray, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBlue,
        foregroundColor: crispWhite,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: crispWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
