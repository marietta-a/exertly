import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemePalette {
  final String name;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;

  const ThemePalette({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
  });
}

class ThemeProvider extends ChangeNotifier {
  static const List<ThemePalette> palettes = [
    ThemePalette(
      name: 'Exertly Classic',
      primary: Color(0xFF0A2540), // Deep Corporate Blue
      secondary: Color(0xFFFF6B00), // Energetic Orange
      background: Color(0xFFF4F7FC), // Ice Blue Gray
      surface: Color(0xFFFFFFFF),
    ),
    ThemePalette(
      name: 'Tech Emerald',
      primary: Color(0xFF0D3B2E), // Forest Teal
      secondary: Color(0xFFD4AF37), // Amber Gold
      background: Color(0xFFF0F5F2), // Pale Emerald Mint
      surface: Color(0xFFFFFFFF),
    ),
    ThemePalette(
      name: 'Modern Platinum',
      primary: Color(0xFF1E293B), // Slate Charcoal
      secondary: Color(0xFF6366F1), // Royal Indigo
      background: Color(0xFFF8FAFC), // Pure Platinum Gray
      surface: Color(0xFFFFFFFF),
    ),
    ThemePalette(
      name: 'Ocean Breeze',
      primary: Color(0xFF0B4F6C), // Deep Ocean Navy
      secondary: Color(0xFFF15025), // Energetic Coral
      background: Color(0xFFF0F8FA), // Coastal Ice Blue
      surface: Color(0xFFFFFFFF),
    ),
    ThemePalette(
      name: 'Sunset Velvet',
      primary: Color(0xFF4A0E17), // Velvet Burgundy
      secondary: Color(0xFFF26419), // Sunset Peach
      background: Color(0xFFFAF0F1), // Champagne Rose
      surface: Color(0xFFFFFFFF),
    ),
    ThemePalette(
      name: 'Nordic Aurora',
      primary: Color(0xFF1E352F), // Borealis Forest
      secondary: Color(0xFF00A896), // Aurora Mint
      background: Color(0xFFF3FBF9), // Polar White Frost
      surface: Color(0xFFFFFFFF),
    ),
  ];

  int _selectedPaletteIndex = 0;

  int get selectedPaletteIndex => _selectedPaletteIndex;
  ThemePalette get currentPalette => palettes[_selectedPaletteIndex];

  void selectPalette(int index) {
    if (index >= 0 && index < palettes.length) {
      _selectedPaletteIndex = index;
      notifyListeners();
    }
  }

  ThemeData get themeData {
    final palette = currentPalette;
    const textDark = Color(0xFF1E293B);
    const textMuted = Color(0xFF64748B);
    const borderGray = Color(0xFFE2E8F0);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: palette.primary,
        secondary: palette.secondary,
        background: palette.background,
        surface: palette.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textDark,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: palette.background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: palette.primary),
          displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: palette.primary),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: palette.primary),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: palette.primary),
          bodyLarge: const TextStyle(fontSize: 16, color: textDark),
          bodyMedium: const TextStyle(fontSize: 14, color: textMuted),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: palette.secondary),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderGray, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.secondary,
          foregroundColor: Colors.white,
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
