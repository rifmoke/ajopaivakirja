import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get theme {
    if (_isDarkMode) {
      return ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFF1919),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF1919),
          secondary: Color(0xFFFF1919),
          surface: Color(0xFF1E1E1E),
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: const Color(0xFFFF1919),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF1919),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF1919),
          secondary: Color(0xFFFF1919),
          surface: Colors.white,
        ),
      );
    }
  }
}
