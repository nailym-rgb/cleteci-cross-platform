import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:flutter_svg/svg.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key, this.email, this.firebaseAuth});

  final String? email;
  final FirebaseAuth? firebaseAuth;

  @override
  Widget build(BuildContext context) {
    // Use the provided FirebaseAuth instance or fall back to GetIt registration
    final auth = firebaseAuth ?? getIt<FirebaseAuth>();

    return ForgotPasswordScreen(
      // Pass the email from the SignInScreen to pre-fill the field (if any)
      email: email,
      auth: auth,
      headerBuilder: (context, constraints, shrinkOffset) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset('assets/cleteci_logo.svg'),
          ),
        );
      },
    );
  }
}
