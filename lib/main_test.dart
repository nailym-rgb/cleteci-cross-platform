import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:provider/provider.dart';
import 'config/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: 'assets/env.vars');
  } on FileNotFoundError catch (_) {
    // Handle the case where the .env file is not found,
    // for now, we're doing nothing.
  }

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create mock user for testing
  final mockUser = MockUser(
    uid: 'test-user-uid',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  // Create mock auth with signed out state initially
  final mockAuth = MockFirebaseAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalAuthState()),
      ],
      child: MyApp(auth: mockAuth),
    ),
  );
}