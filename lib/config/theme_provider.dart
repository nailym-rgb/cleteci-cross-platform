import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _primaryColorKey = 'primary_color';
  static const String _seedColorKey = 'seed_color';

  Color _primaryColor = const Color.fromARGB(255, 96, 165, 250);
  Color _seedColor = const Color(0xFF0000FF);

  Color get primaryColor => _primaryColor;
  Color get seedColor => _seedColor;

  ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      primary: _primaryColor,
      seedColor: _seedColor,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      appBarTheme: AppBarThemeData(
        centerTitle: false,
        foregroundColor: Colors.white,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        indicatorColor: _primaryColor,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: Colors.black87);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            );
          }
          return const TextStyle(color: Colors.black87);
        }),
      ),
      useMaterial3: true,
    );
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final primaryColorValue = prefs.getInt(_primaryColorKey);
    final seedColorValue = prefs.getInt(_seedColorKey);

    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }
    if (seedColorValue != null) {
      _seedColor = Color(seedColorValue);
    }
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.value);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _primaryColor = const Color.fromARGB(255, 96, 165, 250);
    _seedColor = const Color(0xFF0000FF);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryColorKey);
    await prefs.remove(_seedColorKey);
    notifyListeners();
  }
}