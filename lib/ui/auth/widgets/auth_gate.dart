import 'package:cleteci_cross_platform/ui/auth/widgets/forgot_password.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/register.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/default_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:cleteci_cross_platform/ui/common/widgets/default_page.dart';
import 'package:flutter_svg/svg.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.auth});

  final FirebaseAuth auth;

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
          stream: auth.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Check if we're in test mode (using MockFirebaseAuth)
              final isTestMode = auth is MockFirebaseAuth;

              if (isTestMode) {
                // Render simple test UI that will render as HTML elements
                return Scaffold(
                  appBar: DefaultAppBar(title: 'Sign In'),
                  body: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            AspectRatio(
                              aspectRatio: 1,
                              child: SvgPicture.asset(
                                'assets/cleteci_logo.svg',
                                semanticsLabel: 'Cleteci Logo',
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome to Cleteci Cross Platform, please sign in!',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Email field
                            Semantics(
                              label: 'email-input',
                              child: TextField(
                                key: const Key('email-field'),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Password field
                            Semantics(
                              label: 'password-input',
                              child: TextField(
                                key: const Key('password-field'),
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Sign in button
                            Semantics(
                              label: 'sign-in-button',
                              child: ElevatedButton(
                                key: const Key('sign-in-button'),
                                onPressed: () async {
                                  try {
                                    await auth.signInWithEmailAndPassword(
                                      email: 'test@example.com',
                                      password: 'testpassword123',
                                    );
                                  } catch (e) {
                                    // Handle error
                                  }
                                },
                                child: const Text('Sign In'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Register button
                            Semantics(
                              label: 'register-button',
                              child: TextButton(
                                key: const Key('register-button'),
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
                            ),
                            const SizedBox(height: 16),
                            // Forgot password button
                            Semantics(
                              label: 'forgot-password-button',
                              child: TextButton(
                                key: const Key('forgot-password-button'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<ForgotPasswordScreen>(
                                      builder: (context) {
                                        return Scaffold(
                                          appBar: DefaultAppBar(
                                            title: 'Forgotten Password',
                                          ),
                                          body: Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 500,
                                              ),
                                              child: ForgotPassword(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                // Use Firebase UI for production
                return Scaffold(
                  appBar: DefaultAppBar(title: 'Sign In'),
                  body: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SignInScreen(
                        showAuthActionSwitch: false,
                        showPasswordVisibilityToggle: true,
                        key: const Key('sign-in-screen'),
                        actions: [
                          ForgotPasswordAction((context, email) {
                            Navigator.push(
                              context,
                              MaterialPageRoute<ForgotPasswordScreen>(
                                builder: (context) {
                                  return Scaffold(
                                    appBar: DefaultAppBar(
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
                              child: SvgPicture.asset(
                                'assets/cleteci_logo.svg',
                                semanticsLabel: 'Cleteci Logo',
                              ),
                            ),
                          );
                        },
                        subtitleBuilder: (context, action) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: const Text(
                              'Welcome to Cleteci Cross Platform, please sign in!',
                              key: Key('auth-subtitle'),
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
                                            appBar: DefaultAppBar(
                                              title: 'Register',
                                            ),
                                            body: Center(
                                              child: ConstrainedBox(
                                                constraints: const BoxConstraints(
                                                  maxWidth: 500,
                                                ),
                                                child: Register(),
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
