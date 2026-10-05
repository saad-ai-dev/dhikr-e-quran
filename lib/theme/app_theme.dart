import 'package:flutter/material.dart';

class AppTheme {
  // Modern 2026 palette — deep navy + gold accent
  static const Color primaryColor = Color(0xFF1B2838);
  static const Color secondaryColor = Color(0xFF2D9596);
  static const Color accentGold = Color(0xFFD4A854);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF6B7280);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: secondaryColor,
        scaffoldBackgroundColor: surfaceLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 48,
          titleTextStyle: TextStyle(fontSize: 16, fontFamily: 'NotoNastaliqUrdu', color: Colors.white),
        ),
        cardTheme: CardTheme(
          color: cardColor,
          elevation: 1,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 13),
          ),
        ),
      );

  static const TextStyle arabicHeading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: 'ScheherazadeNew',
    color: accentGold,
  );

  static const TextStyle arabicBody = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'ScheherazadeNew',
    color: textDark,
  );

  static const TextStyle urduBody = TextStyle(
    fontSize: 14,
    fontFamily: 'NotoNastaliqUrdu',
    color: secondaryColor,
  );

  static const TextStyle urduTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'NotoNastaliqUrdu',
    color: primaryColor,
  );

  static const TextStyle urduSubtitle = TextStyle(
    fontSize: 13,
    fontFamily: 'NotoNastaliqUrdu',
    color: textMuted,
  );

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B2838), Color(0xFF0F1922)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B2838), Color(0xFF2D3A4A)],
  );
}
