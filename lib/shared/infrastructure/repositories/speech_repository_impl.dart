import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../../domain/entities/speech_result.dart';
import '../../../domain/repositories/speech_repository.dart';

/// Infrastructure implementation of [SpeechRepository] using the
/// `speech_to_text` package. All platform-specific types are kept
/// inside this file — none leak into the domain layer.
class SpeechRepositoryImpl implements SpeechRepository {
  final stt.SpeechToText _speechToText;
  bool _isInitialized = false;

  /// Constructor with optional [speechToText] injection for testing.
  SpeechRepositoryImpl({stt.SpeechToText? speechToText})
    : _speechToText = speechToText ?? stt.SpeechToText();

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw const SpeechException('Microphone permission denied');
      }

      _isInitialized = await _speechToText.initialize(
        onError: (error) =>
            throw SpeechException('Speech initialization failed: $error'),
        onStatus: (status) {
          // Status changes are surfaced through callbacks in startListening.
        },
      );

      return _isInitialized;
    } catch (e) {
      if (e is SpeechException) rethrow;
      throw SpeechException('Failed to initialize speech service: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speechToText.isAvailable;
  }

  @override
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
      throw const SpeechException('Speech recognition is not available');
    }

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      onSoundLevelChange: onSoundLevelChange,
      listenFor: listenFor != null ? Duration(seconds: listenFor) : null,
      pauseFor: pauseFor != null ? Duration(seconds: pauseFor) : null,
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        cancelOnError: true,
        partialResults: true,
        onDevice: true,
      ),
    );

    onListeningStarted();
  }

  @override
  Future<void> stopListening() async {
    if (!_isInitialized) return;
    await _speechToText.stop();
  }

  @override
  Future<void> cancelListening() async {
    if (!_isInitialized) return;
    await _speechToText.cancel();
  }

  @override
  bool get isListening => _speechToText.isListening;

  @override
  Future<List<String>> getLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    final locales = await _speechToText.locales();
    return locales.map((l) => l.localeId).toList();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _isInitialized = false;
  }
}
