import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleteci_cross_platform/ui/speech_to_text/widgets/speech_to_text_screen.dart';

void main() {
  group('SpeechToTextScreen Widget Tests', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(
        home: SpeechToTextScreen(),
      ));

      // Assert - widget should render without throwing exceptions
      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should contain basic UI elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const MaterialApp(
        home: SpeechToTextScreen(),
      ));

      // Assert - basic structure should be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}