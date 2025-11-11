// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cleteci_cross_platform/app.dart';
import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset service locator before each test
    resetServiceLocator();
    // Setup service locator for testing with mock auth
    setupServiceLocatorForTesting(
      mockFirebaseAuth: MockFirebaseAuth(),
    );
  });

  tearDown(() => resetServiceLocator());

  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(auth: MockFirebaseAuth()));

    // Pump multiple times to handle async initialization
    await tester.pump();
    await tester.pump();
    await tester.pump();

    // Verify that the app loads without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
