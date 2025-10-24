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
  @override
  Widget build(BuildContext context) {
    final ThemeData appTheme = Theme.of(context);
    final appState = Provider.of<LocalAuthState>(context);

    Future<dynamic> futureBuilder = Firebase.apps.isEmpty
        ? Firebase.initializeApp()
        : Future.value();

    void handleOnPressedProfile() async {
      if (appState.supportState == LocalAuthSupportState.supported) {
        await appState.authenticateWithBiometrics();
      }

      if (!context.mounted) return;

      // Since we're not handling sensitive data, we just navigate to
      // the profile screen if the device does not support biometric
      // authentication.
      if (appState.authorized == LocalAuthStateValue.authorized ||
          appState.supportState == LocalAuthSupportState.unsupported) {
        Navigator.push(
          context,
          MaterialPageRoute<ProfileScreen>(
            builder: (context) => const CustomUserProfileScreen(),
          ),
        );
      }
    }

    return FutureBuilder(
      future: futureBuilder,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show a loading indicator while Firebase initializes
          return const Center(child: CircularProgressIndicator());
        }

        // Firebase is initialized, proceed with auth logic
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            bool isLoggedIn = snapshot.hasData;

            if (!isLoggedIn) {
              return AppBar(
                backgroundColor: appTheme.colorScheme.primary,
                title: Text(
                  widget.title,
                  key: Key('app-bar-title'),
                  textAlign: TextAlign.left,
                ),
              );
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
                  onPressed: handleOnPressedProfile,
                ),
              ],
              automaticallyImplyLeading: false,
            );
          },
        );
      },
    );
  }
}
