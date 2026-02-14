import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo
        brightness: Brightness.dark,
        surface: const Color(0xFF0F172A), // Slate 900
        background: const Color(0xFF020617), // Slate 950
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFFF43F5E), // Rose 500
        tertiary: const Color(0xFF10B981), // Emerald 500
      ),
      scaffoldBackgroundColor: const Color(0xFF020617),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: const Color(0xFFE2E8F0),
        displayColor: const Color(0xFFF8FAFC),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 4,
        extendedTextStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
