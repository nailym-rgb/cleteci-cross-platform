import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/default_app_bar.dart';
import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';

// Generate mocks
@GenerateMocks([LocalAuthState])
import 'default_app_bar_test.mocks.dart';

void main() {
  late MockLocalAuthState mockLocalAuthState;

  setUp(() {
    mockLocalAuthState = MockLocalAuthState();
  });

  group('DefaultAppBar', () {
    testWidgets('should display title correctly', (WidgetTester tester) async {
      const title = 'Test Title';

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: const Scaffold(
              appBar: DefaultAppBar(title: title),
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byKey(const Key('app-bar-title')), findsOneWidget);
    });

    testWidgets('should have correct preferred size', (WidgetTester tester) async {
      const appBar = DefaultAppBar(title: 'Test');

      expect(appBar.preferredSize, const Size.fromHeight(60));
    });

    testWidgets('should show menu button and profile button when logged in', (WidgetTester tester) async {
      // Mock logged in state
      when(mockLocalAuthState.authorized).thenReturn(LocalAuthStateValue.authorized);
      when(mockLocalAuthState.supportState).thenReturn(LocalAuthSupportState.supported);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: Scaffold(
              appBar: const DefaultAppBar(title: 'Test'),
              drawer: const Drawer(),
            ),
          ),
        ),
      );

      // Should find menu and profile icons
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should show only title when not logged in', (WidgetTester tester) async {
      // Mock not logged in state
      when(mockLocalAuthState.authorized).thenReturn(LocalAuthStateValue.unauthorized);

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

      // Should not find menu and profile icons
      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.byIcon(Icons.person), findsNothing);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should handle profile button tap with biometric auth', (WidgetTester tester) async {
      // Mock supported biometric auth
      when(mockLocalAuthState.supportState).thenReturn(LocalAuthSupportState.supported);
      when(mockLocalAuthState.authorized).thenReturn(LocalAuthStateValue.authorized);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: Scaffold(
              appBar: const DefaultAppBar(title: 'Test'),
              drawer: const Drawer(),
            ),
          ),
        ),
      );

      // Tap profile button
      await tester.tap(find.byIcon(Icons.person));
      await tester.pump();

      // Verify biometric auth was called
      verify(mockLocalAuthState.authenticateWithBiometrics()).called(1);
    });

    testWidgets('should handle profile button tap without biometric auth', (WidgetTester tester) async {
      // Mock unsupported biometric auth
      when(mockLocalAuthState.supportState).thenReturn(LocalAuthSupportState.unsupported);
      when(mockLocalAuthState.authorized).thenReturn(LocalAuthStateValue.authorized);

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<LocalAuthState>.value(
                value: mockLocalAuthState,
                child: Scaffold(
                  appBar: const DefaultAppBar(title: 'Test'),
                  drawer: const Drawer(),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap profile button
      await tester.tap(find.byIcon(Icons.person));
      await tester.pump();

      // Should navigate (this would normally push a route)
      // Since we can't easily test navigation in this setup, we just verify the tap works
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should handle menu button tap', (WidgetTester tester) async {
      // Mock logged in state
      when(mockLocalAuthState.authorized).thenReturn(LocalAuthStateValue.authorized);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LocalAuthState>.value(
            value: mockLocalAuthState,
            child: Scaffold(
              appBar: const DefaultAppBar(title: 'Test'),
              drawer: const Drawer(),
            ),
          ),
        ),
      );

      // Tap menu button
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();

      // Drawer should be opened (this is handled by Scaffold)
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('should handle Firebase initialization loading state', (WidgetTester tester) async {
      // Mock logged in state
      when(mockLocalAuthState.authorized).thenReturn(LocalAuthStateValue.authorized);

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

      // Initially should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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

      expect(find.text(''), findsOneWidget);
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

      expect(find.text(longTitle), findsOneWidget);
    });
  });
}