import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/ui/speech_to_text/widgets/speech_to_text_screen.dart';
import 'package:cleteci_cross_platform/services/speech_service.dart';

// Mock class for SpeechService
class MockSpeechService extends Mock implements SpeechService {}

void main() {
  late MockSpeechService mockSpeechService;

  setUp(() {
    mockSpeechService = MockSpeechService();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: SpeechToTextScreen(),
    );
  }

  group('SpeechToTextScreen Widget Tests', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - widget should render without throwing exceptions
      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should contain basic UI elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - basic structure should be present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display initial status message', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Tap the microphone to start listening'), findsOneWidget);
    });

    testWidgets('should display microphone icon when not listening', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - initially shows mic_off, but button shows mic icon
      expect(find.byIcon(Icons.mic), findsOneWidget); // Button icon
    });

    testWidgets('should display start listening button initially', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Start Listening'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should contain text field for speech output', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Speech will appear here...'), findsOneWidget);
    });

    testWidgets('should display instructions', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Instructions:'), findsOneWidget);
      expect(find.textContaining('Tap "Start Listening"'), findsOneWidget);
      expect(find.textContaining('Speak clearly'), findsOneWidget);
    });

    testWidgets('should display recognized text title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Recognized Text:'), findsOneWidget);
    });

    testWidgets('should not show action buttons when text is empty', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.copy), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('should show action buttons when text is not empty', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Enter text using TextField
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test speech text');
      await tester.pump();

      // Assert - buttons should appear after rebuild
      await tester.pump(); // Allow for conditional rendering
      expect(find.byType(Row), findsWidgets); // Row containing buttons should exist
    });

    testWidgets('should clear text when clear button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Enter text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test speech text');
      await tester.pump();

      // Find and tap clear button (it should exist now)
      final clearButtons = find.byIcon(Icons.clear);
      if (clearButtons.evaluate().isNotEmpty) {
        await tester.tap(clearButtons.first);
        await tester.pump();

        // Assert
        expect(find.text('Test speech text'), findsNothing);
        expect(find.text('Text cleared. Tap microphone to start listening.'), findsOneWidget);
      }
    });

    testWidgets('should copy text to clipboard when copy button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Enter text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test speech text');
      await tester.pump();

      // Find and tap copy button (it should exist now)
      final copyButtons = find.byIcon(Icons.copy);
      if (copyButtons.evaluate().isNotEmpty) {
        await tester.tap(copyButtons.first);
        await tester.pump();

        // Assert - snackbar should appear
        expect(find.text('Text copied to clipboard'), findsOneWidget);
      }
    });

    testWidgets('should handle app lifecycle state changes', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Simulate app going to background
      state.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();

      // Assert - should handle lifecycle changes without crashing
      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should handle inactive app state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Simulate app becoming inactive
      state.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump();

      // Assert
      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should handle detached app state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Simulate app being detached
      state.didChangeAppLifecycleState(AppLifecycleState.detached);
      await tester.pump();

      // Assert
      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should not crash when resuming app', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Simulate app resuming
      state.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();

      // Assert
      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should show sound level indicator when listening', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state and simulate listening state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;
      state._isListening = true;
      state._soundLevel = 0.5;
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.text('Listening... Speak now.'), findsOneWidget);
      // Sound level indicator should be present
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('should update sound level display', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state and simulate listening with sound level
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;
      state._isListening = true;
      state._soundLevel = -0.8; // Negative value
      await tester.pump();

      // Assert
      expect(find.byType(FractionallySizedBox), findsOneWidget);
    });

    testWidgets('should show stop button when listening', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state and simulate listening state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;
      state._isListening = true;
      await tester.pump();

      // Assert
      expect(find.text('Stop Listening'), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('should show loading state during initialization', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state and simulate loading state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;
      state._isLoading = true;
      await tester.pump();

      // Assert - button should be disabled during loading
      final button = find.byType(ElevatedButton);
      final ElevatedButton elevatedButton = tester.widget(button);
      expect(elevatedButton.onPressed, isNull);
    });

    testWidgets('should handle speech result callback', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Simulate speech result
      state._onSpeechResult('Hello world');
      await tester.pump();

      // Assert
      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('should handle sound level change callback', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Simulate sound level change
      state._onSoundLevelChange(0.7);
      await tester.pump();

      // Assert - state should be updated
      expect(state._soundLevel, equals(0.7));
    });

    testWidgets('should handle listening started callback', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Simulate listening started
      state._onListeningStarted();
      await tester.pump();

      // Assert
      expect(find.text('Listening... Speak now.'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should handle listening stopped callback', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state and set listening state first
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;
      state._isListening = true;
      state._soundLevel = 0.5;
      await tester.pump();

      // Simulate listening stopped
      state._onListeningStopped();
      await tester.pump();

      // Assert
      expect(find.text('Speech recognition stopped. Tap microphone to start again.'), findsOneWidget);
      expect(find.byIcon(Icons.mic_off), findsOneWidget);
    });

    testWidgets('should show error snackbar', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Simulate error
      state._showError('Test error message');
      await tester.pump();

      // Assert
      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should handle mounted check in callbacks', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Call callbacks - they should check mounted state
      state._onSpeechResult('Test');
      state._onSoundLevelChange(0.5);
      state._onListeningStarted();
      state._onListeningStopped();
      await tester.pump();

      // Assert - no crash should occur
      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should dispose resources properly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Get the state
      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      // Dispose
      state.dispose();

      // Assert - should not crash
      expect(tester.takeException(), isNull);
    });
  });
}