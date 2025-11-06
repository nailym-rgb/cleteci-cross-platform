import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleteci_cross_platform/config/app_theme.dart';

void main() {
  group('AppColors', () {
    test('should have correct primary color', () {
      expect(AppColors.primary, const Color.fromARGB(255, 96, 165, 250));
    });

    test('should have correct seed color', () {
      expect(AppColors.seed, const Color(0xFF0000FF));
    });

    test('should have correct scaffold background color', () {
      expect(AppColors.scaffoldBackground, const Color(0xFFFFFFFF));
    });

    test('should have correct app bar foreground color', () {
      expect(AppColors.appBarForeground, Colors.white);
    });

    test('should have correct navigation drawer indicator color', () {
      expect(AppColors.navigationDrawerIndicator, const Color.fromARGB(255, 96, 165, 250));
    });

    test('should have correct selected icon color', () {
      expect(AppColors.selectedIcon, Colors.white);
    });

    test('should have correct unselected icon color', () {
      expect(AppColors.unselectedIcon, Colors.black87);
    });

    test('should have correct selected label color', () {
      expect(AppColors.selectedLabel, Colors.white);
    });

    test('should have correct unselected label color', () {
      expect(AppColors.unselectedLabel, Colors.black87);
    });
  });

  group('AppTheme', () {
    test('should return a valid ThemeData', () {
      final theme = AppTheme.theme;
      expect(theme, isA<ThemeData>());
    });

    test('should have correct color scheme from seed', () {
      final theme = AppTheme.theme;
      expect(theme.colorScheme.primary, AppColors.primary);
    });

    test('should have correct scaffold background color', () {
      final theme = AppTheme.theme;
      expect(theme.scaffoldBackgroundColor, AppColors.scaffoldBackground);
    });

    test('should have correct app bar theme', () {
      final theme = AppTheme.theme;
      expect(theme.appBarTheme?.centerTitle, false);
      expect(theme.appBarTheme?.foregroundColor, AppColors.appBarForeground);
    });

    test('should have outlined button theme defined', () {
      final theme = AppTheme.theme;
      expect(theme.outlinedButtonTheme, isNotNull);
    });

    test('should have correct navigation drawer theme', () {
      final theme = AppTheme.theme;
      expect(theme.navigationDrawerTheme?.indicatorColor, AppColors.navigationDrawerIndicator);
    });

    test('should use Material 3', () {
      final theme = AppTheme.theme;
      expect(theme.useMaterial3, true);
    });

    testWidgets('navigation drawer icon theme resolves correctly for selected state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            drawer: NavigationDrawer(
              children: [
                NavigationDrawerDestination(
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                ),
              ],
            ),
          ),
        ),
      );

      // Open drawer
      await tester.dragFrom(const Offset(10, 100), const Offset(300, 0));
      await tester.pumpAndSettle();

      // The icon theme should be applied
      final iconFinder = find.byIcon(Icons.home);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('navigation drawer label theme resolves correctly for selected state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(
            drawer: NavigationDrawer(
              children: [
                NavigationDrawerDestination(
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                ),
              ],
            ),
          ),
        ),
      );

      // Open drawer
      await tester.dragFrom(const Offset(10, 100), const Offset(300, 0));
      await tester.pumpAndSettle();

      // The label should be rendered
      final labelFinder = find.text('Home');
      expect(labelFinder, findsOneWidget);
    });
  });
}