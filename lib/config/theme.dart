import 'package:flutter/material.dart';

class AppTheme {
  // Värimaailma
  static const Color primaryRed = Color(0xFFFF1919);
  static const Color darkGray = Color(0xFF191919);
  static const Color mediumGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMedium = Color(0xFF555555);
  
  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryRed,
      scaffoldBackgroundColor: lightGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkGray,
        elevation: 0,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkGray,
        selectedItemColor: primaryRed,
        unselectedItemColor: mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textMedium,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textMedium,
        ),
      ),
    );
  }
}
