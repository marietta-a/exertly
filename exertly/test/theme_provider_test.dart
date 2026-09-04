import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:exertly/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('ThemeProvider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() {
      themeProvider = ThemeProvider();
    });

    test('Initializes with index 0 and default palette (Exertly Classic)', () {
      expect(themeProvider.selectedPaletteIndex, 0);
      expect(themeProvider.currentPalette.name, 'Exertly Classic');
      expect(themeProvider.currentPalette.primary, const Color(0xFF0A2540));
    });

    test('selectPalette successfully changes palette and updates themeData', () {
      // Select index 1 (Tech Emerald)
      themeProvider.selectPalette(1);
      
      expect(themeProvider.selectedPaletteIndex, 1);
      expect(themeProvider.currentPalette.name, 'Tech Emerald');
      expect(themeProvider.currentPalette.primary, const Color(0xFF0D3B2E));
      expect(themeProvider.themeData.appBarTheme.backgroundColor, const Color(0xFF0D3B2E));
    });

    test('selectPalette successfully selects newly added premium themes', () {
      // Select index 3 (Ocean Breeze)
      themeProvider.selectPalette(3);
      expect(themeProvider.selectedPaletteIndex, 3);
      expect(themeProvider.currentPalette.name, 'Ocean Breeze');
      expect(themeProvider.currentPalette.secondary, const Color(0xFFF15025));

      // Select index 5 (Nordic Aurora)
      themeProvider.selectPalette(5);
      expect(themeProvider.selectedPaletteIndex, 5);
      expect(themeProvider.currentPalette.name, 'Nordic Aurora');
      expect(themeProvider.currentPalette.primary, const Color(0xFF1E352F));
    });

    test('selectPalette ignores invalid out of bounds indices', () {
      final initialIndex = themeProvider.selectedPaletteIndex;

      // Select invalid index
      themeProvider.selectPalette(99);
      expect(themeProvider.selectedPaletteIndex, initialIndex);

      themeProvider.selectPalette(-5);
      expect(themeProvider.selectedPaletteIndex, initialIndex);
    });
  });
}
