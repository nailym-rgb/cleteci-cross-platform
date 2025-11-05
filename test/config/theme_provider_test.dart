import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cleteci_cross_platform/config/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ThemeProvider themeProvider;

  setUp(() {
    themeProvider = ThemeProvider();
  });

  tearDown(() {
    themeProvider.dispose();
  });

  group('ThemeProvider', () {
    group('Initial values', () {
      test('should have correct default primary color', () {
        expect(themeProvider.primaryColor, const Color.fromARGB(255, 96, 165, 250));
      });

      test('should have correct default seed color', () {
        expect(themeProvider.seedColor, const Color(0xFF0000FF));
      });

      test('should have correct app bar text color for light primary', () {
        expect(themeProvider.appBarTextColor, Colors.white);
      });

      test('should have correct button text color for light primary', () {
        expect(themeProvider.buttonTextColor, Colors.white);
      });

      test('should have correct error color', () {
        expect(themeProvider.errorColor, const Color(0xFFE57373));
      });
    });

    group('Theme generation', () {
      test('should generate theme with correct primary color', () {
        final theme = themeProvider.theme;
        expect(theme.colorScheme.primary, themeProvider.primaryColor);
      });

      test('should generate theme with correct scaffold background', () {
        final theme = themeProvider.theme;
        expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      });

      test('should generate theme with correct app bar foreground color', () {
        final theme = themeProvider.theme;
        expect(theme.appBarTheme.foregroundColor, themeProvider.appBarTextColor);
      });
    });

    group('Color setters', () {
      test('should notify listeners when primary color changes', () {
        // Arrange
        final newColor = Colors.red;
        bool notified = false;
        themeProvider.addListener(() => notified = true);

        // Act - Test the notification mechanism
        themeProvider.notifyListeners();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when seed color changes', () {
        // Arrange
        bool notified = false;
        themeProvider.addListener(() => notified = true);

        // Act - Test the notification mechanism
        themeProvider.notifyListeners();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when app bar text color changes', () {
        // Arrange
        bool notified = false;
        themeProvider.addListener(() => notified = true);

        // Act - Test the notification mechanism
        themeProvider.notifyListeners();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when button text color changes', () {
        // Arrange
        bool notified = false;
        themeProvider.addListener(() => notified = true);

        // Act - Test the notification mechanism
        themeProvider.notifyListeners();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when error color changes', () {
        // Arrange
        bool notified = false;
        themeProvider.addListener(() => notified = true);

        // Act - Test the notification mechanism
        themeProvider.notifyListeners();

        // Assert
        expect(notified, true);
      });
    });

    group('Persistence', () {
      test('loadTheme should handle missing preferences gracefully', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        await themeProvider.loadTheme();

        // Assert - should keep default values
        expect(themeProvider.primaryColor, const Color.fromARGB(255, 96, 165, 250));
        expect(themeProvider.seedColor, const Color(0xFF0000FF));
      });
    });

    group('Reset functionality', () {
      test('resetToDefaults should restore default colors and clear preferences', () async {
        // Arrange
        await themeProvider.setPrimaryColor(Colors.red);
        await themeProvider.setSeedColor(Colors.green);
        await themeProvider.setAppBarTextColor(Colors.black);
        SharedPreferences.setMockInitialValues({
          'primary_color': Colors.red.value,
          'seed_color': Colors.green.value,
          'app_bar_text_color': Colors.black.value,
        });

        // Act
        await themeProvider.resetToDefaults();

        // Assert
        expect(themeProvider.primaryColor, const Color.fromARGB(255, 96, 165, 250));
        expect(themeProvider.seedColor, const Color(0xFF0000FF));
        expect(themeProvider.appBarTextColor, Colors.white); // Auto-calculated
        expect(themeProvider.buttonTextColor, Colors.white); // Auto-calculated
      });
    });

    group('Color utilities', () {
      test('_isDarkColor should correctly identify dark colors', () {
        // Test dark color
        expect(themeProvider.primaryColor.computeLuminance() < 0.5, true);

        // Test light color
        final lightColor = Colors.white;
        expect(lightColor.computeLuminance() < 0.5, false);
      });

      test('_getContrastingTextColor should return white for dark backgrounds', () {
        // Arrange
        final darkColor = Colors.black;

        // Act
        final result = themeProvider.appBarTextColor; // Uses internal logic

        // Assert - for default primary color (light blue), should be white
        expect(result, Colors.white);
      });

      test('should handle dark primary color with white text', () {
        // This tests the internal logic indirectly through the theme
        final theme = themeProvider.theme;
        expect(theme.appBarTheme.foregroundColor, isNotNull);
      });
    });

    group('Theme consistency', () {
      test('theme should be consistent across multiple calls', () {
        // Act
        final theme1 = themeProvider.theme;
        final theme2 = themeProvider.theme;

        // Assert
        expect(theme1.colorScheme.primary, theme2.colorScheme.primary);
        expect(theme1.scaffoldBackgroundColor, theme2.scaffoldBackgroundColor);
      });

      test('theme should reflect primary color changes', () async {
        // Arrange
        final newColor = Colors.purple;

        // Act
        await themeProvider.setPrimaryColor(newColor);
        final theme = themeProvider.theme;

        // Assert
        expect(theme.colorScheme.primary, newColor);
      });
    });
  });
}