import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalAuthState()),
      ],
      child: MyApp(auth: FirebaseAuth.instance),
    ),
  );
}
