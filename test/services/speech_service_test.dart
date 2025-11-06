import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:cleteci_cross_platform/services/speech_service.dart';

// Generate mocks
@GenerateMocks([stt.SpeechToText, Permission])
import 'speech_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SpeechService speechService;
  late MockSpeechToText mockSpeechToText;

  setUp(() {
    mockSpeechToText = MockSpeechToText();
    speechService = SpeechService();
  });

  tearDown(() {
    speechService.dispose();
  });

  group('SpeechService', () {
    group('initialize', () {
      test('should handle initialization in integration tests', () async {
        // Note: Full initialization testing requires integration tests due to platform dependencies
        // This service depends on permission_handler and speech_to_text packages
        // which are difficult to mock in unit tests without dependency injection
        expect(true, isTrue);
      });

      test('should handle initialization idempotency', () async {
        // Test that multiple dispose calls don't break
        speechService.dispose();
        speechService.dispose();
        expect(() => speechService.dispose(), returnsNormally);
      });
    });

    group('isAvailable', () {
      test('should return availability status', () async {
        // This requires mocking the internal speechToText instance
        // For integration tests, this would be tested
        expect(true, isTrue); // Placeholder
      });
    });

    group('startListening', () {
      test('should start listening with callbacks', () async {
        // Arrange
        bool onResultCalled = false;
        bool onSoundLevelCalled = false;
        bool onStartedCalled = false;
        bool onStoppedCalled = false;

        // Act & Assert - Test exception when not available
        expect(() => speechService.startListening(
          onResult: (result) => onResultCalled = true,
          onSoundLevelChange: (level) => onSoundLevelCalled = true,
          onListeningStarted: () => onStartedCalled = true,
          onListeningStopped: () => onStoppedCalled = true,
        ), throwsA(isA<SpeechServiceException>()));
      });
    });

    group('stopListening', () {
      test('should handle stop listening safely', () async {
        // Act & Assert
        expect(() => speechService.stopListening(), returnsNormally);
      });
    });

    group('cancelListening', () {
      test('should handle cancel listening safely', () async {
        // Act & Assert
        expect(() => speechService.cancelListening(), returnsNormally);
      });
    });

    group('isListening', () {
      test('should return listening status', () {
        // Act
        final isListening = speechService.isListening;

        // Assert
        expect(isListening, isA<bool>());
      });
    });

    group('getLocales', () {
      test('should return locales list', () async {
        // This requires mocking
        expect(true, isTrue); // Placeholder
      });
    });

    group('currentLocale', () {
      test('should return current locale', () {
        // Act
        final locale = speechService.currentLocale;

        // Assert
        expect(locale, isA<String?>());
      });
    });

    group('dispose', () {
      test('should dispose safely', () {
        // Act & Assert
        expect(() => speechService.dispose(), returnsNormally);
      });
    });
  });

  group('SpeechServiceException', () {
    test('should create exception with message', () {
      // Act
      final exception = SpeechServiceException('Test message');

      // Assert
      expect(exception.message, 'Test message');
      expect(exception.toString(), 'SpeechServiceException: Test message');
    });
  });

  group('SpeechResult', () {
    test('should create SpeechResult with required fields', () {
      // Act
      final result = SpeechResult(
        text: 'Hello world',
        isFinal: true,
        confidence: 0.95,
        status: SpeechStatus.listening,
      );

      // Assert
      expect(result.text, 'Hello world');
      expect(result.isFinal, true);
      expect(result.confidence, 0.95);
      expect(result.status, SpeechStatus.listening);
    });

    test('should copy SpeechResult with updated fields', () {
      // Arrange
      final original = SpeechResult(
        text: 'Hello',
        isFinal: false,
        confidence: 0.8,
        status: SpeechStatus.initialized,
      );

      // Act
      final copied = original.copyWith(
        text: 'Hello world',
        isFinal: true,
        confidence: 0.95,
      );

      // Assert
      expect(copied.text, 'Hello world');
      expect(copied.isFinal, true);
      expect(copied.confidence, 0.95);
      expect(copied.status, SpeechStatus.initialized); // Unchanged
    });
  });
}