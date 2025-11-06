import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/default_app_bar.dart';
import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';

void main() {
  group('DefaultAppBar', () {
    testWidgets('should have correct preferred size', (WidgetTester tester) async {
      const appBar = DefaultAppBar(title: 'Test');

      expect(appBar.preferredSize, const Size.fromHeight(60));
    });

    testWidgets('should create DefaultAppBar widget', (WidgetTester tester) async {
      // Create a mock LocalAuthState
      final mockLocalAuthState = LocalAuthState();

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

    testWidgets('should handle empty title', (WidgetTester tester) async {
      final mockLocalAuthState = LocalAuthState();

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
      final mockLocalAuthState = LocalAuthState();

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
      final mockLocalAuthState = LocalAuthState();

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

    test('DefaultAppBar constructor should work', () {
      const appBar = DefaultAppBar(title: 'Test Title');
      expect(appBar.title, 'Test Title');
    });

    test('DefaultAppBar should implement PreferredSizeWidget', () {
      const appBar = DefaultAppBar(title: 'Test');
      expect(appBar, isA<PreferredSizeWidget>());
    });
  });
}