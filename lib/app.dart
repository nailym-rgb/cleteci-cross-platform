import 'package:flutter/material.dart';

import 'package:cleteci_cross_platform/ui/auth/widgets/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Cleteci Cross Platform';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          primary: Color.fromARGB(255, 96, 165, 250),
          seedColor: Color(0xFF0000FF),
          secondary: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: AuthGate(),
    );
  }
}
