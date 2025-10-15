import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    return ForgotPasswordScreen(
      // Pass the email from the SignInScreen to pre-fill the field (if any)
      email: email,
      auth: FirebaseAuth.instance,
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
