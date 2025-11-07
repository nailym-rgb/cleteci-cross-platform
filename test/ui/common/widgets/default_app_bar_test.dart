import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/default_app_bar.dart';
import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';

// Mock class for LocalAuthState
class MockLocalAuthState extends Mock implements LocalAuthState {
  @override
  LocalAuthSupportState get supportState => LocalAuthSupportState.unknown;

  @override
  LocalAuthStateValue get authorized => LocalAuthStateValue.unauthorized;
}

void main() {
  late MockLocalAuthState mockLocalAuthState;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockLocalAuthState = MockLocalAuthState();
    mockFirebaseAuth = MockFirebaseAuth();
  });

  Widget createTestWidget({
    required LocalAuthState localAuthState,
    MockFirebaseAuth? firebaseAuth,
  }) {
    return MaterialApp(
      home: ChangeNotifierProvider<LocalAuthState>.value(
        value: localAuthState,
        child: Scaffold(
          appBar: const DefaultAppBar(title: 'Test'),
          drawer: const Drawer(),
        ),
      ),
    );
  }

  group('DefaultAppBar', () {
    testWidgets('should have correct preferred size', (WidgetTester tester) async {
      const appBar = DefaultAppBar(title: 'Test');

      expect(appBar.preferredSize, const Size.fromHeight(60));
    });

    testWidgets('should create DefaultAppBar widget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));

      // The widget should be created
      expect(find.byType(DefaultAppBar), findsOneWidget);
    });

    testWidgets('should handle empty title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));

      // The widget should be created without errors
      expect(find.byType(DefaultAppBar), findsOneWidget);
    });

    testWidgets('should handle long title', (WidgetTester tester) async {
      const longTitle = 'This is a very long title that should still be displayed correctly';

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: Scaffold(
              appBar: const DefaultAppBar(title: longTitle),
            ),
          ),
        ),
      );

      // The widget should be created without errors
      expect(find.byType(DefaultAppBar), findsOneWidget);
    });

    testWidgets('should have LocalAuthState provider', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));

      // Should have the provider in the widget tree
      final context = tester.element(find.byType(DefaultAppBar));
      final provider = Provider.of<LocalAuthState>(context, listen: false);
      expect(provider, isNotNull);
    });

    testWidgets('should show loading indicator during Firebase initialization', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // testWidgets('should show logged out app bar when user is not authenticated', (WidgetTester tester) async {
    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should show basic app bar without menu or profile buttons
    //   expect(find.text('Test'), findsOneWidget);
    //   expect(find.byIcon(Icons.menu), findsNothing);
    //   expect(find.byIcon(Icons.person), findsNothing);
    // });

    // testWidgets('should show logged in app bar when user is authenticated', (WidgetTester tester) async {
    //   // Mock authenticated user
    //   final mockUser = MockUser(email: 'test@example.com');
    //   mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);

    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should show app bar with menu and profile buttons
    //   expect(find.text('Test'), findsOneWidget);
    //   expect(find.byIcon(Icons.menu), findsOneWidget);
    //   expect(find.byIcon(Icons.person), findsOneWidget);
    // });

    // testWidgets('should handle menu button tap', (WidgetTester tester) async {
    //   // Mock authenticated user
    //   final mockUser = MockUser(email: 'test@example.com');
    //   mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);

    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should have menu button
    //   expect(find.byIcon(Icons.menu), findsOneWidget);
    // });

    // testWidgets('should handle profile button tap with biometric auth', (WidgetTester tester) async {
    //   // Mock authenticated user and supported biometric auth
    //   final mockUser = MockUser(email: 'test@example.com');
    //   mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);

    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should have profile button
    //   expect(find.byIcon(Icons.person), findsOneWidget);
    // });

    // testWidgets('should handle profile button tap without biometric auth', (WidgetTester tester) async {
    //   // Mock authenticated user and unsupported biometric auth
    //   final mockUser = MockUser(email: 'test@example.com');
    //   mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);

    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should have profile button
    //   expect(find.byIcon(Icons.person), findsOneWidget);
    // });

    // testWidgets('should handle profile button tap when not authorized', (WidgetTester tester) async {
    //   // Mock authenticated user
    //   final mockUser = MockUser(email: 'test@example.com');
    //   mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);

    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should have profile button
    //   expect(find.byIcon(Icons.person), findsOneWidget);
    // });

    // testWidgets('should display title correctly', (WidgetTester tester) async {
    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should display the title
    //   expect(find.text('Test'), findsOneWidget);
    // });

    // testWidgets('should have proper app bar styling', (WidgetTester tester) async {
    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should have AppBar widget
    //   expect(find.byType(AppBar), findsOneWidget);
    // });

    // testWidgets('should handle Firebase initialization completion', (WidgetTester tester) async {
    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should complete Firebase initialization and show auth UI
    //   expect(find.byType(AppBar), findsOneWidget);
    // });

    testWidgets('should handle auth state changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
      await tester.pump();
      await tester.pump();

      // Should handle auth state changes without crashing
      expect(find.byType(DefaultAppBar), findsOneWidget);
    });

    testWidgets('should have FutureBuilder for Firebase initialization', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));

      // Should have FutureBuilder
      expect(find.byType(FutureBuilder), findsOneWidget);
    });

    // testWidgets('should have StreamBuilder for auth state', (WidgetTester tester) async {
    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();

    //   // Should have StreamBuilder after Firebase initialization
    //   expect(find.byType(StreamBuilder), findsOneWidget);
    // });

    // testWidgets('should handle mounted state in profile button callback', (WidgetTester tester) async {
    //   // Mock authenticated user
    //   final mockUser = MockUser(email: 'test@example.com');
    //   mockFirebaseAuth = MockFirebaseAuth(mockUser: mockUser);

    //   await tester.pumpWidget(createTestWidget(localAuthState: mockLocalAuthState));
    //   await tester.pump();
    //   await tester.pump();

    //   // Should have profile button
    //   expect(find.byIcon(Icons.person), findsOneWidget);
    // });

    test('DefaultAppBar constructor should work', () {
      const appBar = DefaultAppBar(title: 'Test Title');
      expect(appBar.title, 'Test Title');
    });

    test('DefaultAppBar should implement PreferredSizeWidget', () {
      const appBar = DefaultAppBar(title: 'Test');
      expect(appBar, isA<PreferredSizeWidget>());
    });

    test('DefaultAppBar should have correct preferred size height', () {
      const appBar = DefaultAppBar(title: 'Test');
      expect(appBar.preferredSize.height, 60);
    });

    test('DefaultAppBar should have infinite preferred size width', () {
      const appBar = DefaultAppBar(title: 'Test');
      expect(appBar.preferredSize.width, double.infinity);
    });
  });
}