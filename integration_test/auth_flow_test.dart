import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

// Imports de tu proyecto
import 'package:cleteci_cross_platform/app.dart';
import 'package:cleteci_cross_platform/config/theme_provider.dart';
import 'package:cleteci_cross_platform/config/service_locator.dart'; // Tu locator
import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    resetServiceLocator();
  });

  group('Authentication Flow Integration Tests', () {
    testWidgets('complete authentication flow from launch to dashboard', (
      WidgetTester tester,
    ) async {
      // Launch the app with mock auth
      final mockAuth = MockFirebaseAuth();

      // 2. MAGIC CONFIGURATION
      // We use your function to inject the mock.
      // By passing 'mockAuth', your function automatically creates the AuthService
      //using that mock instead of the real Firebase.
      setupServiceLocatorForTesting(mockFirebaseAuth: mockAuth);

      // 3. We render the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            // LocalAuthState seguramente necesita acceso a auth o lógica local
            ChangeNotifierProvider(create: (_) => getIt<LocalAuthState>()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          // Pasamos el mockAuth también al constructor de MyApp
          child: MyApp(auth: mockAuth),
        ),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: MyApp(auth: mockAuth),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify we're on the auth gate screen
      expect(find.byType(MaterialApp), findsOneWidget);

      // Test would continue with actual authentication flow
      // This is a skeleton for the integration test structure
    });

    testWidgets('theme customization persists across app restart', (
      WidgetTester tester,
    ) async {
      // This test would verify that theme changes persist
      // and are applied when the app restarts
    });

    testWidgets('speech-to-text functionality works end-to-end', (
      WidgetTester tester,
    ) async {
      // This test would verify the complete speech-to-text flow
      // from navigation to actual speech recognition
    });
  });
}
