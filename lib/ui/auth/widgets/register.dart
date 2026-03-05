import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:flutter_svg/svg.dart';

class Register extends StatelessWidget {
  const Register({super.key, this.firebaseAuth});

  final FirebaseAuth? firebaseAuth;

  @override
  Widget build(BuildContext context) {
    final auth = firebaseAuth ?? getIt<FirebaseAuth>();

    return RegisterScreen(
      showPasswordVisibilityToggle: true,
      auth: auth,
      providers: [EmailAuthProvider()],
      showAuthActionSwitch: false,
      actions: [
        AuthStateChangeAction<UserCreated>((context, state) {
          // Mostrar mensaje de éxito inmediatamente
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Registro exitoso! Redirigiendo al login...'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 2),
            ),
          );

          // Redireccionar al login después de un breve delay
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
        }),
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
    );
  }
}
