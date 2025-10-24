import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class CustomUserProfileScreen extends StatelessWidget {
  const CustomUserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);

    return ProfileScreen(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: appTheme.colorScheme.primary,
      ),
      actions: [
        SignedOutAction((context) {
          Navigator.of(context).pop();
        }),
      ],
      showDeleteConfirmationDialog: true,
      showUnlinkConfirmationDialog: true,
      children: [const Divider()],
    );
  }
}
