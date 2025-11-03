import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

/// Service class for handling speech-to-text functionality
/// Provides a clean interface for speech recognition operations
class SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw SpeechServiceException('Microphone permission denied');
      }

      // Initialize speech to text
      _isInitialized = await _speechToText.initialize(
        onError: (error) => throw SpeechServiceException('Speech initialization failed: $error'),
        onStatus: (status) {
          // Handle status changes if needed
        },
      );

      return _isInitialized;
    } catch (e) {
      throw SpeechServiceException('Failed to initialize speech service: $e');
    }
  }

  /// Check if speech recognition is currently available
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speechToText.isAvailable;
  }

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    required Function(double) onSoundLevelChange,
    required Function() onListeningStarted,
    required Function() onListeningStopped,
    String? localeId,
    int? listenFor,
    int? pauseFor,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!await isAvailable()) {
      throw SpeechServiceException('Speech recognition is not available');
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      onSoundLevelChange: onSoundLevelChange,
      listenFor: listenFor != null ? Duration(seconds: listenFor) : null,
      pauseFor: pauseFor != null ? Duration(seconds: pauseFor) : null,
      localeId: localeId,
      cancelOnError: true,
      partialResults: true,
      onDevice: true,
    );

    onListeningStarted();
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    if (!_isInitialized) return;

    await _speechToText.stop();
  }

  /// Cancel speech recognition
  Future<void> cancelListening() async {
    if (!_isInitialized) return;

    await _speechToText.cancel();
  }

  /// Check if currently listening
  bool get isListening => _speechToText.isListening;

  /// Get available locales (async)
  Future<List<stt.LocaleName>> getLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speechToText.locales();
  }

  /// Get current locale
  String? get currentLocale => _speechToText.lastRecognizedWords;

  /// Dispose of resources
  void dispose() {
    _speechToText.cancel();
    _isInitialized = false;
  }
}

/// Custom exception for speech service errors
class SpeechServiceException implements Exception {
  final String message;

  SpeechServiceException(this.message);

  @override
  String toString() => 'SpeechServiceException: $message';
}

/// Enum for speech recognition status
enum SpeechStatus {
  notInitialized,
  initialized,
  listening,
  stopped,
  error,
}

/// Model class for speech recognition results
class SpeechResult {
  final String text;
  final bool isFinal;
  final double confidence;
  final SpeechStatus status;

  const SpeechResult({
    required this.text,
    required this.isFinal,
    required this.confidence,
    required this.status,
  });

  SpeechResult copyWith({
    String? text,
    bool? isFinal,
    double? confidence,
    SpeechStatus? status,
  }) {
    return SpeechResult(
      text: text ?? this.text,
      isFinal: isFinal ?? this.isFinal,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
    );
  }
}