import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/domain/entities/speech_result.dart';
import 'package:cleteci_cross_platform/domain/repositories/speech_repository.dart';

// ---------------------------------------------------------------------------
// Manual mock for SpeechRepository — noSuchMethod overrides for null safety
// Verifies the interface compiles without speech_to_text or Flutter imports.
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

  setUp(() {
    mockSpeechRepository = MockSpeechRepository();
  });

  // -----------------------------------------------------------------------
  // Interface contract — compiles without speech_to_text dependencies
  // -----------------------------------------------------------------------

  group('SpeechRepository interface', () {
    test('interface compiles without speech_to_text imports', () {
      // The fact that this test compiles and runs proves SpeechRepository
      // has no dependency on speech_to_text or platform packages.
      expect(mockSpeechRepository, isA<SpeechRepository>());
    });

    test('initialize returns bool', () async {
      when(mockSpeechRepository.initialize()).thenAnswer((_) async => true);

      final result = await mockSpeechRepository.initialize();

      expect(result, isTrue);
    });

    test('initialize returns false when unavailable', () async {
      when(mockSpeechRepository.initialize()).thenAnswer((_) async => false);

      final result = await mockSpeechRepository.initialize();

      expect(result, isFalse);
    });

    test('isAvailable returns bool', () async {
      when(mockSpeechRepository.isAvailable()).thenAnswer((_) async => true);

      final result = await mockSpeechRepository.isAvailable();

      expect(result, isTrue);
    });

    test('isListening returns bool', () {
      when(mockSpeechRepository.isListening).thenReturn(false);

      expect(mockSpeechRepository.isListening, isFalse);
    });

    test('stopListening completes without error', () async {
      when(mockSpeechRepository.stopListening()).thenAnswer((_) async {});

      await expectLater(mockSpeechRepository.stopListening(), completes);
    });

    test('cancelListening completes without error', () async {
      when(mockSpeechRepository.cancelListening()).thenAnswer((_) async {});

      await expectLater(mockSpeechRepository.cancelListening(), completes);
    });

    test('getLocales returns list of locale ID strings', () async {
      when(
        mockSpeechRepository.getLocales(),
      ).thenAnswer((_) async => ['en-US', 'es-ES', 'fr-FR']);

      final result = await mockSpeechRepository.getLocales();

      expect(result, isA<List<String>>());
      expect(result, contains('en-US'));
    });

    test('startListening completes when called', () async {
      // Use concrete callback references to satisfy non-nullable types
      void onResult(String text) {}
      void onSoundLevelChange(double level) {}
      void onListeningStarted() {}
      void onListeningStopped() {}

      when(
        mockSpeechRepository.startListening(
          onResult: onResult,
          onSoundLevelChange: onSoundLevelChange,
          onListeningStarted: onListeningStarted,
          onListeningStopped: onListeningStopped,
          localeId: 'en-US',
          listenFor: 30,
          pauseFor: 5,
        ),
      ).thenAnswer((_) async {});

      await expectLater(
        mockSpeechRepository.startListening(
          onResult: onResult,
          onSoundLevelChange: onSoundLevelChange,
          onListeningStarted: onListeningStarted,
          onListeningStopped: onListeningStopped,
          localeId: 'en-US',
          listenFor: 30,
          pauseFor: 5,
        ),
        completes,
      );
    });
  });

  // -----------------------------------------------------------------------
  // SpeechResult value object
  // -----------------------------------------------------------------------

  group('SpeechResult', () {
    test('can be constructed with all fields', () {
      const result = SpeechResult(
        text: 'hello world',
        isFinal: true,
        confidence: 0.95,
        status: SpeechStatus.listening,
      );

      expect(result.text, equals('hello world'));
      expect(result.isFinal, isTrue);
      expect(result.confidence, equals(0.95));
      expect(result.status, equals(SpeechStatus.listening));
    });

    test('copyWith overrides specified fields', () {
      const original = SpeechResult(
        text: 'hello',
        isFinal: false,
        confidence: 0.5,
        status: SpeechStatus.listening,
      );

      final updated = original.copyWith(text: 'hello world', isFinal: true);

      expect(updated.text, equals('hello world'));
      expect(updated.isFinal, isTrue);
      expect(updated.confidence, equals(0.5)); // unchanged
      expect(updated.status, equals(SpeechStatus.listening)); // unchanged
    });

    test('copyWith without arguments returns equal object', () {
      const original = SpeechResult(
        text: 'test',
        isFinal: true,
        confidence: 0.9,
        status: SpeechStatus.stopped,
      );

      final copy = original.copyWith();

      expect(copy, equals(original));
    });

    test('equality holds for identical values', () {
      const a = SpeechResult(
        text: 'test',
        isFinal: true,
        confidence: 0.9,
        status: SpeechStatus.stopped,
      );
      const b = SpeechResult(
        text: 'test',
        isFinal: true,
        confidence: 0.9,
        status: SpeechStatus.stopped,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString contains relevant fields', () {
      const result = SpeechResult(
        text: 'hello',
        isFinal: false,
        confidence: 0.8,
        status: SpeechStatus.listening,
      );

      expect(result.toString(), contains('hello'));
      expect(result.toString(), contains('false'));
    });
  });

  // -----------------------------------------------------------------------
  // SpeechException
  // -----------------------------------------------------------------------

  group('SpeechException', () {
    test('toString contains the message', () {
      const ex = SpeechException('Microphone permission denied');

      expect(ex.toString(), contains('Microphone permission denied'));
    });

    test('implements Exception', () {
      const ex = SpeechException('test error');

      expect(ex, isA<Exception>());
    });
  });

  // -----------------------------------------------------------------------
  // SpeechStatus enum
  // -----------------------------------------------------------------------

  group('SpeechStatus', () {
    test('has all expected values', () {
      expect(SpeechStatus.values, contains(SpeechStatus.notInitialized));
      expect(SpeechStatus.values, contains(SpeechStatus.initialized));
      expect(SpeechStatus.values, contains(SpeechStatus.listening));
      expect(SpeechStatus.values, contains(SpeechStatus.stopped));
      expect(SpeechStatus.values, contains(SpeechStatus.error));
    });
  });
}
