import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<LocalAuthState>(context);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the Homepage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              if (appState.supportState == LocalAuthSupportState.supported) {
                await appState.authenticateWithBiometrics();
              }

              if (!context.mounted) return;

              // Since we're not handling sensitive data, we just navigate to
              // the profile screen if the device does not support biometric
              // authentication.
              if (appState.authorized == LocalAuthStateValues.authorized ||
                  appState.supportState == LocalAuthSupportState.unsupported) {
                Navigator.push(
                  context,
                  MaterialPageRoute<ProfileScreen>(
                    builder: (context) => ProfileScreen(
                      appBar: AppBar(title: const Text('User Profile')),
                      actions: [
                        SignedOutAction((context) {
                          Navigator.of(context).pop();
                        }),
                      ],
                      children: [const Divider()],
                    ),
                  ),
                );
              }
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              //
              // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
              // action in the IDE, or press "p" in the console), to see the
              // wireframe for each widget.
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('You have pushed the button this many times:'),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Divider(height: 100),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Local Auth Support:'),
                    if (appState.supportState == LocalAuthSupportState.unknown)
                      const CircularProgressIndicator()
                    else if (appState.supportState ==
                        LocalAuthSupportState.supported)
                      const Text('This device is supported')
                    else
                      const Text('This device is not supported'),
                    const Divider(height: 100),
                    Text(
                      'Can check biometrics: ${appState.canCheckBiometrics}\n',
                    ),
                    ElevatedButton(
                      onPressed:
                          appState.supportState ==
                              LocalAuthSupportState.supported
                          ? appState.checkBiometrics
                          : null,
                      child: const Text('Check biometrics'),
                    ),
                    const Divider(height: 100),
                    Text(
                      'Available biometrics: ${appState.availableBiometrics}\n',
                    ),
                    ElevatedButton(
                      onPressed:
                          appState.supportState ==
                              LocalAuthSupportState.supported
                          ? appState.getAvailableBiometrics
                          : null,
                      child: const Text('Get available biometrics'),
                    ),
                    const Divider(height: 100),
                    Text('Current State: ${appState.authorized}\n'),
                    if (appState.isAuthenticating)
                      ElevatedButton(
                        onPressed: appState.cancelAuthentication,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Cancel Authentication'),
                            Icon(Icons.cancel),
                          ],
                        ),
                      )
                    else
                      Column(
                        spacing: 12,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed:
                                appState.supportState ==
                                    LocalAuthSupportState.supported
                                ? appState.authenticate
                                : null,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Authenticate'),
                                Icon(Icons.perm_device_information),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed:
                                appState.supportState ==
                                    LocalAuthSupportState.supported
                                ? appState.authenticateWithBiometrics
                                : null,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  appState.isAuthenticating
                                      ? 'Cancel'
                                      : 'Authenticate: biometrics only',
                                ),
                                const Icon(Icons.fingerprint),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
