import 'package:cleteci_cross_platform/ui/auth/widgets/forgot_password.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/register.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/default_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cleteci_cross_platform/ui/common/widgets/default_page.dart';
import 'package:flutter_svg/svg.dart';

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
              return Scaffold(
                appBar: const DefaultAppBar(title: 'Sign In'),
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: SignInScreen(
                      showAuthActionSwitch: false,
                      showPasswordVisibilityToggle: true,
                      actions: [
                        ForgotPasswordAction((context, email) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<ForgotPasswordScreen>(
                              builder: (context) {
                                return Scaffold(
                                  appBar: const DefaultAppBar(
                                    title: 'Forgotten Password',
                                  ),
                                  body: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 500,
                                      ),
                                      child: ForgotPassword(
                                        // Pass the email from the SignInScreen to pre-fill the field (if any)
                                        email: email,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ],
                      providers: [
                        EmailAuthProvider(),
                        if (dotenv
                                .maybeGet('GOOGLE_OAUTH_CLIENT_ID')
                                ?.isNotEmpty ??
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
                            child: SvgPicture.asset('assets/cleteci_logo.svg'),
                          ),
                        );
                      },
                      subtitleBuilder: (context, action) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Welcome to Cleteci Cross Platform, please sign in!',
                          ),
                        );
                      },
                      footerBuilder: (context, action) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              const Padding(padding: EdgeInsets.all(4.0)),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<RegisterScreen>(
                                      builder: (context) {
                                        return Scaffold(
                                          appBar: const DefaultAppBar(
                                            title: 'Register',
                                          ),
                                          body: Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 500,
                                              ),
                                              child: const Register(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text('Register'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }

            return const DefaultPage(title: 'Cleteci Cross Platform Homepage');
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
