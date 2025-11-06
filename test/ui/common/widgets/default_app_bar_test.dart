import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/default_app_bar.dart';
import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';

// Generate mocks
@GenerateMocks([LocalAuthState])
import 'default_app_bar_test.mocks.dart';

void main() {
  late MockLocalAuthState mockLocalAuthState;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() async {
    mockLocalAuthState = MockLocalAuthState();
    mockFirebaseAuth = MockFirebaseAuth();

    // Setup Firebase for testing
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      ),
    );
  });

  group('DefaultAppBar', () {
    testWidgets('should display title correctly', (WidgetTester tester) async {
      const title = 'Test Title';

      // Mock unauthenticated state
      when(mockLocalAuthState.authorized).thenReturn(LocalAuthStateValue.unauthorized);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: Scaffold(
              appBar: const DefaultAppBar(title: title),
            ),
          ),
        ),
      );

      // Wait for Firebase initialization and auth state to settle
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(find.byKey(const Key('app-bar-title')), findsOneWidget);
    });

    testWidgets('should have correct preferred size', (WidgetTester tester) async {
      const appBar = DefaultAppBar(title: 'Test');

      expect(appBar.preferredSize, const Size.fromHeight(60));
    });

    testWidgets('should handle empty title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: const Scaffold(
              appBar: DefaultAppBar(title: ''),
            ),
          ),
        ),
      );

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

    testWidgets('should create DefaultAppBar widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: const Scaffold(
              appBar: DefaultAppBar(title: 'Test'),
            ),
          ),
        ),
      );

      // The widget should be created
      expect(find.byType(DefaultAppBar), findsOneWidget);
    });

    testWidgets('should have LocalAuthState provider', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: const Scaffold(
              appBar: DefaultAppBar(title: 'Test'),
            ),
          ),
        ),
      );

      // Should have the provider in the widget tree
      final context = tester.element(find.byType(DefaultAppBar));
      final provider = Provider.of<LocalAuthState>(context, listen: false);
      expect(provider, isNotNull);
    });
  });
}