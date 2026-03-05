import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:cleteci_cross_platform/domain/repositories/auth_repository.dart';
import 'package:cleteci_cross_platform/domain/usecases/auth/sign_in_use_case.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/custom_register_form.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/forgot_password.dart';
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
  const AuthGate({super.key, this.auth, this.isTestMode = false});
  static const signIn = 'sign-in';
  final FirebaseAuth? auth;
  final bool isTestMode;

  Widget _buildTestModeUI(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(title: signIn),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 150, // Limitamos la altura del logo a 150px
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: SvgPicture.asset(
                      'assets/cleteci_logo.svg',
                      semanticsLabel: 'Cleteci Logo',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to Cleteci Cross Platform, please sign in!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Semantics(
                  label: 'email-input',
                  child: const TextField(
                    key: Key('email-field'),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'password-input',
                  child: const TextField(
                    key: Key('password-field'),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  label: 'sign-in-button',
                  child: ElevatedButton(
                    key: const Key('sign-in-button'),
                    onPressed: () async {
                      try {
                        final signInUseCase = getIt<SignInUseCase>();
                        await signInUseCase(
                          email: 'test@example.com',
                          password: 'testpassword123',
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sign in failed: $e')),
                        );
                      }
                    },
                    child: const Text(signIn),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'register-button',
                  child: TextButton(
                    key: const Key('register-button'),
                    onPressed: () {},
                    child: const Text('Register'),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'forgot-password-button',
                  child: TextButton(
                    key: const Key('forgot-password-button'),
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductionUI() {
    return Scaffold(
      appBar: const DefaultAppBar(title: signIn),
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
                    builder: (context) => Scaffold(
                      appBar: const DefaultAppBar(title: 'Forgotten Password'),
                      body: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: ForgotPassword(email: email),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
            providers: [
              EmailAuthProvider(),
              if (dotenv.maybeGet('GOOGLE_OAUTH_CLIENT_ID')?.isNotEmpty ??
                  false)
                GoogleProvider(clientId: dotenv.get('GOOGLE_OAUTH_CLIENT_ID')),
            ],
            headerBuilder: (context, constraints, shrinkOffset) => Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: SvgPicture.asset(
                  'assets/cleteci_logo.svg',
                  semanticsLabel: 'Cleteci Logo',
                ),
              ),
            ),
            subtitleBuilder: (context, action) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Welcome to Cleteci Cross Platform, please sign in!',
                key: Key('auth-subtitle'),
              ),
            ),
            footerBuilder: (context, action) => Padding(
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
                          builder: (context) => CustomRegisterForm(),
                        ),
                      );
                    },
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = getIt<AuthRepository>();

    // If a FirebaseAuth instance is provided (e.g., in tests), use it directly.
    // Otherwise, delegate to the domain AuthRepository.
    final authStream = auth != null
        ? auth!.authStateChanges().map((user) => user != null ? user.uid : null)
        : authRepository.authStateChanges.map((entity) => entity?.uid);

    return FutureBuilder(
      future: Firebase.apps.isEmpty ? Firebase.initializeApp() : Future.value(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<String?>(
          stream: authStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return isTestMode
                  ? _buildTestModeUI(context)
                  : _buildProductionUI();
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
