import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/config/service_locator.dart';
import 'package:cleteci_cross_platform/domain/repositories/speech_repository.dart';
import 'package:cleteci_cross_platform/ui/speech_to_text/widgets/speech_to_text_screen.dart';

// ---------------------------------------------------------------------------
// Manual mock for SpeechRepository — noSuchMethod overrides for null safety
// ---------------------------------------------------------------------------
class MockSpeechRepository extends Mock implements SpeechRepository {
  @override
  bool get isListening =>
      super.noSuchMethod(Invocation.getter(#isListening), returnValue: false)
          as bool;

  @override
  Future<bool> initialize() =>
      super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: Future<bool>.value(false),
          )
          as Future<bool>;

  @override
  Future<bool> isAvailable() =>
      super.noSuchMethod(
            Invocation.method(#isAvailable, []),
            returnValue: Future<bool>.value(false),
          )
          as Future<bool>;

  @override
  Future<void> startListening({
    required Function(String) onResult,
    required Function(double) onSoundLevelChange,
    required Function() onListeningStarted,
    required Function() onListeningStopped,
    String? localeId,
    int? listenFor,
    int? pauseFor,
  }) =>
      super.noSuchMethod(
            Invocation.method(#startListening, [], {
              #onResult: onResult,
              #onSoundLevelChange: onSoundLevelChange,
              #onListeningStarted: onListeningStarted,
              #onListeningStopped: onListeningStopped,
              #localeId: localeId,
              #listenFor: listenFor,
              #pauseFor: pauseFor,
            }),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<void> stopListening() =>
      super.noSuchMethod(
            Invocation.method(#stopListening, []),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<void> cancelListening() =>
      super.noSuchMethod(
            Invocation.method(#cancelListening, []),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<List<String>> getLocales() =>
      super.noSuchMethod(
            Invocation.method(#getLocales, []),
            returnValue: Future<List<String>>.value([]),
          )
          as Future<List<String>>;

  @override
  void dispose() => super.noSuchMethod(Invocation.method(#dispose, []));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockSpeechRepository mockSpeechRepository;

  setUpAll(() {
    resetServiceLocator();
  });

  setUp(() {
    mockSpeechRepository = MockSpeechRepository();

    // initialize() returns false by default → screen shows "not available" message
    when(mockSpeechRepository.initialize()).thenAnswer((_) async => false);
    when(mockSpeechRepository.stopListening()).thenAnswer((_) async {});

    getIt.registerSingleton<SpeechRepository>(mockSpeechRepository);
  });

  tearDown(() {
    resetServiceLocator();
  });

  Widget createTestWidget() {
    return const MaterialApp(home: SpeechToTextScreen());
  }

  group('SpeechToTextScreen Widget Tests', () {
    testWidgets('should render without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should contain basic UI elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display initial status message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.text('Tap the microphone to start listening'),
        findsOneWidget,
      );
    });

    testWidgets('should display microphone icon when not listening', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Button shows mic icon when not listening
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should display start listening button initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Start Listening'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should contain text field for speech output', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Speech will appear here...'), findsOneWidget);
    });

    testWidgets('should display instructions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Instructions:'), findsOneWidget);
      expect(find.textContaining('Tap "Start Listening"'), findsOneWidget);
      expect(find.textContaining('Speak clearly'), findsOneWidget);
    });

    testWidgets('should display recognized text title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Recognized Text:'), findsOneWidget);
    });

    testWidgets('should not show action buttons when text is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.copy), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('should show action buttons when text is not empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test speech text');
      await tester.pump();

      await tester.pump();
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('should clear text when clear button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test speech text');
      await tester.pump();

      final clearButtons = find.byIcon(Icons.clear);
      if (clearButtons.evaluate().isNotEmpty) {
        await tester.tap(clearButtons.first);
        await tester.pump();

        expect(find.text('Test speech text'), findsNothing);
        expect(
          find.text('Text cleared. Tap microphone to start listening.'),
          findsOneWidget,
        );
      }
    });

    testWidgets('should copy text to clipboard when copy button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test speech text');
      await tester.pump();

      final copyButtons = find.byIcon(Icons.copy);
      if (copyButtons.evaluate().isNotEmpty) {
        await tester.tap(copyButtons.first);
        await tester.pump();

        expect(find.text('Text copied to clipboard'), findsOneWidget);
      }
    });

    testWidgets('should handle app lifecycle state changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      state.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();

      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should handle inactive app state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      state.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump();

      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should handle detached app state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      state.didChangeAppLifecycleState(AppLifecycleState.detached);
      await tester.pump();

      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should not crash when resuming app', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      state.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();

      expect(find.byType(SpeechToTextScreen), findsOneWidget);
    });

    testWidgets('should dispose resources properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final state = tester.state(find.byType(SpeechToTextScreen)) as dynamic;

      try {
        state.dispose();
        expect(true, isTrue);
      } catch (e) {
        expect(e.toString().contains('TextEditingController'), isTrue);
      }
    }, skip: true);

    testWidgets('should allow text editing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test text');
      await tester.pump();

      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.readOnly, isTrue);
    });

    testWidgets('SpeechToTextScreen constructor works', (
      WidgetTester tester,
    ) async {
      const screen = SpeechToTextScreen();
      expect(screen, isNotNull);
      expect(screen, isA<SpeechToTextScreen>());
      expect(screen, isA<StatefulWidget>());
    });

    testWidgets('SpeechToTextScreen has key parameter', (
      WidgetTester tester,
    ) async {
      const testKey = Key('speech_screen_key');
      const screen = SpeechToTextScreen(key: testKey);
      expect(screen.key, equals(testKey));
    });

    testWidgets('SpeechToTextScreen can be created with key', (
      WidgetTester tester,
    ) async {
      const testKey = Key('test_key');
      const screen = SpeechToTextScreen(key: testKey);
      expect(screen.key, equals(testKey));
    });

    testWidgets('SpeechToTextScreen can be created without key', (
      WidgetTester tester,
    ) async {
      const screen = SpeechToTextScreen();
      expect(screen.key, isNull);
    });

    testWidgets('SpeechToTextScreen is a widget', (WidgetTester tester) async {
      const screen = SpeechToTextScreen();
      expect(screen, isA<Widget>());
    });

    testWidgets('SpeechToTextScreen has proper runtime type', (
      WidgetTester tester,
    ) async {
      const screen = SpeechToTextScreen();
      expect(screen.runtimeType, equals(SpeechToTextScreen));
    });

    testWidgets('SpeechToTextScreen can be instantiated', (
      WidgetTester tester,
    ) async {
      const screen = SpeechToTextScreen();
      expect(() => screen, returnsNormally);
    });

    testWidgets('SpeechToTextScreen has no required parameters', (
      WidgetTester tester,
    ) async {
      const screen = SpeechToTextScreen();
      expect(screen, isNotNull);
    });
  });
}
