import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromARGB(255, 96, 165, 250);
  static const Color seed = Color(0xFF0000FF);
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color appBarForeground = Colors.white;
  static const Color navigationDrawerIndicator = Color.fromARGB(255, 96, 165, 250);
  static const Color selectedIcon = Colors.white;
  static const Color unselectedIcon = Colors.black87;
  static const Color selectedLabel = Colors.white;
  static const Color unselectedLabel = Colors.black87;
}

class AppTheme {
  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      primary: AppColors.primary,
      seedColor: AppColors.seed,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      appBarTheme: AppBarThemeData(
        centerTitle: false,
        foregroundColor: AppColors.appBarForeground,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        indicatorColor: AppColors.navigationDrawerIndicator,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.selectedIcon);
          }
          return const IconThemeData(color: AppColors.unselectedIcon);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.selectedLabel,
              fontWeight: FontWeight.bold,
            );
          }
          return const TextStyle(color: AppColors.unselectedLabel);
        }),
      ),
      useMaterial3: true,
    );
  }
}