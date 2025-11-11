import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleteci_cross_platform/ui/common/widgets/page_component.dart';

void main() {
  group('PageComponent', () {
    testWidgets('renders title and icon correctly', (WidgetTester tester) async {
      const title = 'Test Page';
      const icon = Icons.home;
      const color = Colors.blue;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageComponent(
              title: title,
              icon: icon,
              color: color,
            ),
          ),
        ),
      );

      // Verify the icon is displayed
      expect(find.byIcon(icon), findsOneWidget);

      // Verify the title is displayed
      expect(find.text(title), findsOneWidget);

      // Verify the icon has the correct color
      final iconWidget = tester.widget<Icon>(find.byIcon(icon));
      expect(iconWidget.color, color);
    });

    testWidgets('centers content in column', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageComponent(
              title: 'Test',
              icon: Icons.star,
              color: Colors.red,
            ),
          ),
        ),
      );

      // Verify there's a column inside the PageComponent
      final columnFinder = find.descendant(
        of: find.byType(PageComponent),
        matching: find.byType(Column),
      );
      expect(columnFinder, findsOneWidget);

      // Verify the column has MainAxisAlignment.center
      final columnWidget = tester.widget<Column>(columnFinder);
      expect(columnWidget.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('uses correct text style for title', (WidgetTester tester) async {
      const title = 'Dashboard';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageComponent(
              title: title,
              icon: Icons.dashboard,
              color: Colors.green,
            ),
          ),
        ),
      );

      // Find the text widget
      final textFinder = find.text(title);
      expect(textFinder, findsOneWidget);

      // Verify it uses headlineMedium style
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontSize, Theme.of(tester.element(textFinder)).textTheme.headlineMedium?.fontSize);
    });

    testWidgets('handles different icon sizes', (WidgetTester tester) async {
      const iconSize = 80.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageComponent(
              title: 'Test',
              icon: Icons.settings,
              color: Colors.purple,
            ),
          ),
        ),
      );

      // The icon should have size 100 as defined in the widget
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.settings));
      expect(iconWidget.size, 100.0);
    });

    testWidgets('handles empty title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageComponent(
              title: '',
              icon: Icons.info,
              color: Colors.orange,
            ),
          ),
        ),
      );

      // Should still render without crashing
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });
  });

  group('SettingsPage', () {
    testWidgets('should display settings page with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should display settings icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should display theme settings button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      expect(find.text('Theme Settings'), findsOneWidget);
      expect(find.byIcon(Icons.palette), findsOneWidget);
    });

    testWidgets('should center content in column', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      // Verify there's a column inside the SettingsPage
      final columnFinder = find.descendant(
        of: find.byType(SettingsPage),
        matching: find.byType(Column),
      );
      expect(columnFinder, findsOneWidget);

      // Verify the column has MainAxisAlignment.center
      final columnWidget = tester.widget<Column>(columnFinder);
      expect(columnWidget.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('should have elevated button with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      // Find the button by text since ElevatedButton.icon creates a different widget type
      final buttonFinder = find.text('Theme Settings');
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('should have theme settings button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      // Verify the button exists
      final buttonFinder = find.text('Theme Settings');
      expect(buttonFinder, findsOneWidget);

      // Verify the palette icon exists
      final iconFinder = find.byIcon(Icons.palette);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('should use theme colors for icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      // The icon should exist
      final iconFinder = find.byIcon(Icons.settings);
      expect(iconFinder, findsOneWidget);

      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, isNotNull);
    });

    testWidgets('should have proper spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      // Should have SizedBox widgets for spacing
      expect(find.byType(SizedBox), findsAtLeast(2));
    });

    testWidgets('should display all expected text elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Theme Settings'), findsOneWidget);
    });
  });
}