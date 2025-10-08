import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cleteci_cross_platform/ui/homepage/widgets/homepage.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.apps.isEmpty ? Firebase.initializeApp() : Future.value(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show a loading indicator while Firebase initializes
          return const Center(child: CircularProgressIndicator());
        }
        // Firebase is initialized, proceed with auth logic
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SignInScreen(
                providers: [
                  EmailAuthProvider(),
                  if (dotenv.maybeGet('GOOGLE_OAUTH_CLIENT_ID')?.isNotEmpty ??
                      false)
                    GoogleProvider(
                      clientId: dotenv.get('GOOGLE_OAUTH_CLIENT_ID'),
                    ),
                ],
                headerBuilder: (context, constraints, shrinkOffset) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset('assets/flutterfire_300x.png'),
                    ),
                  );
                },
                subtitleBuilder: (context, action) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: action == AuthAction.signIn
                        ? const Text(
                            'Welcome to Cleteci Cross Platform, please sign in!',
                          )
                        : const Text(
                            'Welcome to Cleteci Cross Platform, please sign up!',
                          ),
                  );
                },
              );
            }
            
            return const Homepage(title: 'Cleteci Cross Platform Homepage');
          },
        );
      },
    );
  }
}

typedef HeaderBuilder =
    Widget Function(
      BuildContext context,
      BoxConstraints constraints,
      double shrinkOffset,
    );
