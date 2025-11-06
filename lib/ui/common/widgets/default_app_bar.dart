import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/custom_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DefaultAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DefaultAppBar({super.key, required this.title});

  final String title;

  @override
  State<DefaultAppBar> createState() => _DefaultAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _DefaultAppBarState extends State<DefaultAppBar> {
  Future<bool> _handleOnPressedProfile(LocalAuthState appState) async {
    if (appState.supportState == LocalAuthSupportState.supported) {
      await appState.authenticateWithBiometrics();
    }

    // Since we're not handling sensitive data, we just navigate to
    // the profile screen if the device does not support biometric
    // authentication.
    return appState.authorized == LocalAuthStateValue.authorized ||
        appState.supportState == LocalAuthSupportState.unsupported;
  }

  Widget _buildLoggedOutAppBar(ThemeData appTheme) {
    return AppBar(
      backgroundColor: appTheme.colorScheme.primary,
      title: Text(
        widget.title,
        key: Key('app-bar-title'),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildFutureBuilder(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      // Show a loading indicator while Firebase initializes
      return const Center(child: CircularProgressIndicator());
    }

    // Firebase is initialized, proceed with auth logic
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: _buildStreamBuilder,
    );
  }

  Widget _buildStreamBuilder(BuildContext context, AsyncSnapshot<User?> snapshot) {
    final ThemeData appTheme = Theme.of(context);
    final appState = Provider.of<LocalAuthState>(context);
    bool isLoggedIn = snapshot.hasData;

    if (!isLoggedIn) {
      return _buildLoggedOutAppBar(appTheme);
    }

    return AppBar(
      backgroundColor: appTheme.colorScheme.primary,
      title: Text(widget.title, textAlign: TextAlign.left),
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () async {
            if (mounted) {
              final shouldNavigate = await _handleOnPressedProfile(appState);
              if (shouldNavigate) {
                Navigator.push(
                  context,
                  MaterialPageRoute<ProfileScreen>(
                    builder: (context) => CustomUserProfileScreen(),
                  ),
                );
              }
            }
          },
        ),
      ],
      automaticallyImplyLeading: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LocalAuthState>(context);

    Future<dynamic> futureBuilder = Firebase.apps.isEmpty
        ? Firebase.initializeApp()
        : Future.value();

    return FutureBuilder(
      future: futureBuilder,
      builder: _buildFutureBuilder,
    );
  }
}
