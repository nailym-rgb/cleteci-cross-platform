import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return RegisterScreen(
      showPasswordVisibilityToggle: true,
      auth: FirebaseAuth.instance,
      providers: [EmailAuthProvider()],
      showAuthActionSwitch: false,
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
