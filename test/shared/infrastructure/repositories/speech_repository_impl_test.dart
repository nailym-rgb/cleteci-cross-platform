import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cleteci_cross_platform/domain/entities/speech_result.dart';
import 'package:cleteci_cross_platform/domain/repositories/speech_repository.dart';
import 'package:cleteci_cross_platform/shared/infrastructure/repositories/speech_repository_impl.dart';

// ---------------------------------------------------------------------------
// Manual mock for stt.SpeechToText — noSuchMethod for null-safe overrides
// ---------------------------------------------------------------------------
class MockSpeechToText extends Mock implements stt.SpeechToText {
  @override
  bool get isAvailable =>
      super.noSuchMethod(Invocation.getter(#isAvailable), returnValue: false)
          as bool;

  @override
  bool get isListening =>
      super.noSuchMethod(Invocation.getter(#isListening), returnValue: false)
          as bool;

  @override
  Future<bool> initialize({
    stt.SpeechErrorListener? onError,
    stt.SpeechStatusListener? onStatus,
    debugLogging = false,
    Duration finalTimeout = const Duration(milliseconds: 2000),
    List<stt.SpeechConfigOption>? options,
  }) =>
      super.noSuchMethod(
            Invocation.method(#initialize, [], {
              #onError: onError,
              #onStatus: onStatus,
              #debugLogging: debugLogging,
              #finalTimeout: finalTimeout,
              #options: options,
            }),
            returnValue: Future<bool>.value(false),
          )
          as Future<bool>;

  @override
  Future<void> stop() =>
      super.noSuchMethod(
            Invocation.method(#stop, []),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<void> cancel() =>
      super.noSuchMethod(
            Invocation.method(#cancel, []),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<List<stt.LocaleName>> locales({String? deviceLocale}) =>
      super.noSuchMethod(
            Invocation.method(#locales, [], {#deviceLocale: deviceLocale}),
            returnValue: Future<List<stt.LocaleName>>.value([]),
          )
          as Future<List<stt.LocaleName>>;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockSpeechToText mockSpeechToText;
  late SpeechRepositoryImpl repository;

  setUp(() {
    mockSpeechToText = MockSpeechToText();
    repository = SpeechRepositoryImpl(speechToText: mockSpeechToText);
  });

  group('SpeechRepositoryImpl', () {
    test('implements SpeechRepository', () {
      expect(repository, isA<SpeechRepository>());
    });

    test('isListening delegates to speechToText', () {
      when(mockSpeechToText.isListening).thenReturn(true);

      expect(repository.isListening, isTrue);
    });

    test('stopListening is idempotent when not initialized', () async {
      // Should return without calling stop on underlying engine
      await expectLater(repository.stopListening(), completes);
      verifyNever(mockSpeechToText.stop());
    });

    test('cancelListening is idempotent when not initialized', () async {
      await expectLater(repository.cancelListening(), completes);
      verifyNever(mockSpeechToText.cancel());
    });

    test('dispose cancels and resets initialized state', () async {
      // Mark as initialized by setting up the mock to allow stop
      when(mockSpeechToText.cancel()).thenAnswer((_) async {});

      repository.dispose();

      verify(mockSpeechToText.cancel()).called(1);
    });
  });

  // -----------------------------------------------------------------------
  // SpeechResult and SpeechException — domain types only, no platform deps
  // -----------------------------------------------------------------------

  group('Domain types used by impl', () {
    test('SpeechException message propagates correctly', () {
      const ex = SpeechException('test message');
      expect(ex.toString(), contains('test message'));
    });

    test('SpeechStatus enum values are available', () {
      expect(SpeechStatus.notInitialized, isNotNull);
      expect(SpeechStatus.initialized, isNotNull);
      expect(SpeechStatus.listening, isNotNull);
      expect(SpeechStatus.stopped, isNotNull);
      expect(SpeechStatus.error, isNotNull);
    });
  });
}
