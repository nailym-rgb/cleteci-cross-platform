import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' show ListenMode;
import 'package:cleteci_cross_platform/domain/entities/speech_result.dart';
import 'package:cleteci_cross_platform/domain/repositories/speech_repository.dart';
import 'package:cleteci_cross_platform/shared/infrastructure/repositories/speech_repository_impl.dart';

// ---------------------------------------------------------------------------
// Mock permission handler platform — controls permission grant/deny
// ---------------------------------------------------------------------------
class _FakePermissionHandlerPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {
  final PermissionStatus _status;

  _FakePermissionHandlerPlatform({
    PermissionStatus status = PermissionStatus.granted,
  }) : _status = status;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async =>
      _status;

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async => {for (var p in permissions) p: _status};

  @override
  Future<bool> shouldShowPermissionRationale(Permission permission) async =>
      false;

  @override
  Future<bool> openAppSettings() async => true;
}

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
  Future<dynamic> listen({
    stt.SpeechResultListener? onResult,
    Duration? listenFor,
    Duration? pauseFor,
    String? localeId,
    stt.SpeechSoundLevelChange? onSoundLevelChange,
    // ignore: deprecated_member_use
    cancelOnError = false,
    // ignore: deprecated_member_use
    partialResults = true,
    // ignore: deprecated_member_use
    onDevice = false,
    // ignore: deprecated_member_use
    ListenMode listenMode = ListenMode.confirmation,
    // ignore: deprecated_member_use
    sampleRate = 0,
    stt.SpeechListenOptions? listenOptions,
  }) => super.noSuchMethod(
    Invocation.method(#listen, [], {
      #onResult: onResult,
      #listenFor: listenFor,
      #pauseFor: pauseFor,
      #localeId: localeId,
      #onSoundLevelChange: onSoundLevelChange,
      #cancelOnError: cancelOnError,
      #partialResults: partialResults,
      #onDevice: onDevice,
      #listenMode: listenMode,
      #sampleRate: sampleRate,
      #listenOptions: listenOptions,
    }),
    returnValue: Future<void>.value(),
  );

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
// Helper: install a fake permission platform
// ---------------------------------------------------------------------------
void _grantMicrophonePermission() {
  PermissionHandlerPlatform.instance = _FakePermissionHandlerPlatform(
    status: PermissionStatus.granted,
  );
}

void _denyMicrophonePermission() {
  PermissionHandlerPlatform.instance = _FakePermissionHandlerPlatform(
    status: PermissionStatus.denied,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSpeechToText mockSpeechToText;
  late SpeechRepositoryImpl repository;

  setUp(() {
    mockSpeechToText = MockSpeechToText();
    repository = SpeechRepositoryImpl(speechToText: mockSpeechToText);
  });

  group('SpeechRepositoryImpl basic', () {
    test('implements SpeechRepository', () {
      expect(repository, isA<SpeechRepository>());
    });

    test('isListening delegates to speechToText', () {
      when(mockSpeechToText.isListening).thenReturn(true);
      expect(repository.isListening, isTrue);
    });

    test('isListening returns false when not listening', () {
      when(mockSpeechToText.isListening).thenReturn(false);
      expect(repository.isListening, isFalse);
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

  group('SpeechRepositoryImpl.initialize with granted permission', () {
    setUp(() {
      _grantMicrophonePermission();
    });

    test('initialize returns true when stt.initialize succeeds', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);

      final result = await repository.initialize();
      expect(result, isTrue);
    });

    test(
      'initialize returns false when stt.initialize returns false',
      () async {
        when(
          mockSpeechToText.initialize(
            onError: anyNamed('onError'),
            onStatus: anyNamed('onStatus'),
          ),
        ).thenAnswer((_) async => false);

        final result = await repository.initialize();
        expect(result, isFalse);
      },
    );

    test(
      'initialize is idempotent — returns cached result on second call',
      () async {
        when(
          mockSpeechToText.initialize(
            onError: anyNamed('onError'),
            onStatus: anyNamed('onStatus'),
          ),
        ).thenAnswer((_) async => true);

        final first = await repository.initialize();
        final second = await repository.initialize();

        expect(first, isTrue);
        expect(second, isTrue);
        // Only called once — second call short-circuits
        verify(
          mockSpeechToText.initialize(
            onError: anyNamed('onError'),
            onStatus: anyNamed('onStatus'),
          ),
        ).called(1);
      },
    );

    test(
      'initialize wraps non-SpeechException errors in SpeechException',
      () async {
        when(
          mockSpeechToText.initialize(
            onError: anyNamed('onError'),
            onStatus: anyNamed('onStatus'),
          ),
        ).thenThrow(Exception('STT engine crashed'));

        await expectLater(
          () => repository.initialize(),
          throwsA(isA<SpeechException>()),
        );
      },
    );
  });

  group('SpeechRepositoryImpl.initialize with denied permission', () {
    setUp(() {
      _denyMicrophonePermission();
    });

    test('initialize throws SpeechException when permission denied', () async {
      await expectLater(
        () => repository.initialize(),
        throwsA(
          isA<SpeechException>().having(
            (e) => e.message,
            'message',
            contains('permission'),
          ),
        ),
      );
    });
  });

  group('SpeechRepositoryImpl.isAvailable', () {
    setUp(() {
      _grantMicrophonePermission();
    });

    test('isAvailable initializes then checks stt.isAvailable', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);
      when(mockSpeechToText.isAvailable).thenReturn(true);

      final result = await repository.isAvailable();
      expect(result, isTrue);
    });

    test('isAvailable returns false when stt is not available', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);
      when(mockSpeechToText.isAvailable).thenReturn(false);

      final result = await repository.isAvailable();
      expect(result, isFalse);
    });
  });

  group('SpeechRepositoryImpl.startListening', () {
    setUp(() {
      _grantMicrophonePermission();
    });

    test(
      'startListening calls stt.listen and invokes onListeningStarted',
      () async {
        when(
          mockSpeechToText.initialize(
            onError: anyNamed('onError'),
            onStatus: anyNamed('onStatus'),
          ),
        ).thenAnswer((_) async => true);
        when(mockSpeechToText.isAvailable).thenReturn(true);
        when(
          mockSpeechToText.listen(
            onResult: anyNamed('onResult'),
            onSoundLevelChange: anyNamed('onSoundLevelChange'),
            listenFor: anyNamed('listenFor'),
            pauseFor: anyNamed('pauseFor'),
            localeId: anyNamed('localeId'),
            listenOptions: anyNamed('listenOptions'),
          ),
        ).thenAnswer((_) async {});

        bool listeningStarted = false;
        await repository.startListening(
          onResult: (_) {},
          onSoundLevelChange: (_) {},
          onListeningStarted: () {
            listeningStarted = true;
          },
          onListeningStopped: () {},
          localeId: 'en-US',
          listenFor: 30,
          pauseFor: 5,
        );

        expect(listeningStarted, isTrue);
      },
    );

    test('startListening throws SpeechException when not available', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);
      when(mockSpeechToText.isAvailable).thenReturn(false);

      await expectLater(
        () => repository.startListening(
          onResult: (_) {},
          onSoundLevelChange: (_) {},
          onListeningStarted: () {},
          onListeningStopped: () {},
        ),
        throwsA(isA<SpeechException>()),
      );
    });

    test('startListening passes results via onResult callback', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);
      when(mockSpeechToText.isAvailable).thenReturn(true);

      stt.SpeechResultListener? capturedOnResult;
      when(
        mockSpeechToText.listen(
          onResult: anyNamed('onResult'),
          onSoundLevelChange: anyNamed('onSoundLevelChange'),
          listenFor: anyNamed('listenFor'),
          pauseFor: anyNamed('pauseFor'),
          localeId: anyNamed('localeId'),
          listenOptions: anyNamed('listenOptions'),
        ),
      ).thenAnswer((invocation) {
        capturedOnResult =
            invocation.namedArguments[#onResult] as stt.SpeechResultListener?;
        return Future.value();
      });

      final List<String> results = [];
      await repository.startListening(
        onResult: results.add,
        onSoundLevelChange: (_) {},
        onListeningStarted: () {},
        onListeningStopped: () {},
      );

      // Simulate speech result being fired
      capturedOnResult?.call(
        SpeechRecognitionResult([
          SpeechRecognitionWords('hello world', null, 0.9),
        ], true),
      );

      expect(results, contains('hello world'));
    });

    test(
      'startListening without localeId, listenFor, pauseFor succeeds',
      () async {
        when(
          mockSpeechToText.initialize(
            onError: anyNamed('onError'),
            onStatus: anyNamed('onStatus'),
          ),
        ).thenAnswer((_) async => true);
        when(mockSpeechToText.isAvailable).thenReturn(true);
        when(
          mockSpeechToText.listen(
            onResult: anyNamed('onResult'),
            onSoundLevelChange: anyNamed('onSoundLevelChange'),
            listenFor: anyNamed('listenFor'),
            pauseFor: anyNamed('pauseFor'),
            localeId: anyNamed('localeId'),
            listenOptions: anyNamed('listenOptions'),
          ),
        ).thenAnswer((_) async {});

        await repository.startListening(
          onResult: (_) {},
          onSoundLevelChange: (_) {},
          onListeningStarted: () {},
          onListeningStopped: () {},
        );

        verify(
          mockSpeechToText.listen(
            onResult: anyNamed('onResult'),
            onSoundLevelChange: anyNamed('onSoundLevelChange'),
            listenFor: anyNamed('listenFor'),
            pauseFor: anyNamed('pauseFor'),
            localeId: anyNamed('localeId'),
            listenOptions: anyNamed('listenOptions'),
          ),
        ).called(1);
      },
    );
  });

  group('SpeechRepositoryImpl.stopListening when initialized', () {
    setUp(() {
      _grantMicrophonePermission();
    });

    test('stopListening calls stt.stop when initialized', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);
      when(mockSpeechToText.stop()).thenAnswer((_) async {});

      await repository.initialize();
      await repository.stopListening();

      verify(mockSpeechToText.stop()).called(1);
    });
  });

  group('SpeechRepositoryImpl.cancelListening when initialized', () {
    setUp(() {
      _grantMicrophonePermission();
    });

    test('cancelListening calls stt.cancel when initialized', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);
      when(mockSpeechToText.cancel()).thenAnswer((_) async {});

      await repository.initialize();
      await repository.cancelListening();

      // cancel is also called in dispose, so check it was called at least once
      verify(mockSpeechToText.cancel()).called(greaterThanOrEqualTo(1));
    });
  });

  group('SpeechRepositoryImpl.getLocales', () {
    setUp(() {
      _grantMicrophonePermission();
    });

    test('getLocales returns list of locale IDs', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);
      when(mockSpeechToText.locales()).thenAnswer(
        (_) async => [
          stt.LocaleName('en-US', 'English (US)'),
          stt.LocaleName('es-ES', 'Spanish (Spain)'),
        ],
      );

      final locales = await repository.getLocales();
      expect(locales, containsAll(['en-US', 'es-ES']));
    });

    test('getLocales returns empty list when no locales available', () async {
      when(
        mockSpeechToText.initialize(
          onError: anyNamed('onError'),
          onStatus: anyNamed('onStatus'),
        ),
      ).thenAnswer((_) async => true);
      when(mockSpeechToText.locales()).thenAnswer((_) async => []);

      final locales = await repository.getLocales();
      expect(locales, isEmpty);
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
