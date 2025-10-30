import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cleteci_cross_platform/ui/auth/widgets/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.auth});

  final FirebaseAuth auth;

  static const appTitle = 'Cleteci Cross Platform';

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      primary: const Color.fromARGB(255, 96, 165, 250),
      seedColor: Color(0xFF0000FF),
    );
    final ThemeData themeData = ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Color de fondo de todas las pantallas
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
        indicatorColor: const Color.fromARGB(255, 96, 165, 250),
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

    return MaterialApp(
      title: appTitle,
      theme: themeData,
      home: AuthGate(auth: auth),
    );
  }
}
