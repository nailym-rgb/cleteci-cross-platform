import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:cleteci_cross_platform/config/theme_provider.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/auth_gate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.auth});

  final FirebaseAuth auth;

  static const appTitle = 'Cleteci Cross Platform';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..loadTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: appTitle,
            theme: themeProvider.theme,
            home: AuthGate(auth: auth),
          );
        },
      ),
    );
  }
}
