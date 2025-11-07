import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _primaryColorKey = 'primary_color';
  static const String _seedColorKey = 'seed_color';
  static const String _appBarTextColorKey = 'app_bar_text_color';
  static const String _buttonTextColorKey = 'button_text_color';
  static const String _errorColorKey = 'error_color';
  static const String _errorTextColorKey = 'error_text_color';

  Color _primaryColor = const Color.fromARGB(255, 96, 165, 250);
  Color _seedColor = const Color(0xFF0000FF);
  Color? _customAppBarTextColor;
  Color? _customButtonTextColor;
  Color? _customErrorColor;
  Color? _customErrorTextColor;

  // Helper method to determine if a color is dark
  bool _isDarkColor(Color color) {
    return color.computeLuminance() < 0.5;
  }

  // Helper method to get contrasting text color
  Color _getContrastingTextColor(Color backgroundColor) {
    return _isDarkColor(backgroundColor) ? Colors.white : Colors.black87;
  }

  Color get primaryColor => _primaryColor;
  Color get seedColor => _seedColor;

  // Customizable text colors with fallback to auto-contrast
  Color get appBarTextColor => _customAppBarTextColor ?? _getContrastingTextColor(_primaryColor);
  Color get buttonTextColor => _customButtonTextColor ?? _getContrastingTextColor(_primaryColor);
  Color get errorColor => _customErrorColor ?? const Color(0xFFE57373); // Default light red
  Color get errorTextColor => _customErrorTextColor ?? _getContrastingTextColor(errorColor);

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
        foregroundColor: appBarTextColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: buttonTextColor,
        ),
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
            return IconThemeData(color: _getContrastingTextColor(_primaryColor));
          }
          return const IconThemeData(color: Colors.black87);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: _getContrastingTextColor(_primaryColor),
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
    final appBarTextColorValue = prefs.getInt(_appBarTextColorKey);
    final buttonTextColorValue = prefs.getInt(_buttonTextColorKey);
    final errorColorValue = prefs.getInt(_errorColorKey);
    final errorTextColorValue = prefs.getInt(_errorTextColorKey);

    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }
    if (seedColorValue != null) {
      _seedColor = Color(seedColorValue);
    }
    if (appBarTextColorValue != null) {
      _customAppBarTextColor = Color(appBarTextColorValue);
    }
    if (buttonTextColorValue != null) {
      _customButtonTextColor = Color(buttonTextColorValue);
    }
    if (errorColorValue != null) {
      _customErrorColor = Color(errorColorValue);
    }
    if (errorTextColorValue != null) {
      _customErrorTextColor = Color(errorTextColorValue);
    }
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setAppBarTextColor(Color color) async {
    _customAppBarTextColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_appBarTextColorKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setButtonTextColor(Color color) async {
    _customButtonTextColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_buttonTextColorKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setErrorColor(Color color) async {
    _customErrorColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_errorColorKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> setErrorTextColor(Color color) async {
    _customErrorTextColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_errorTextColorKey, color.toARGB32());
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _primaryColor = const Color.fromARGB(255, 96, 165, 250);
    _seedColor = const Color(0xFF0000FF);
    _customAppBarTextColor = null;
    _customButtonTextColor = null;
    _customErrorColor = null;
    _customErrorTextColor = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryColorKey);
    await prefs.remove(_seedColorKey);
    await prefs.remove(_appBarTextColorKey);
    await prefs.remove(_buttonTextColorKey);
    await prefs.remove(_errorColorKey);
    await prefs.remove(_errorTextColorKey);
    notifyListeners();
  }
}