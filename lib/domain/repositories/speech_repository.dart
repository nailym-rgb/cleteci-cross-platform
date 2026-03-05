import '../entities/speech_result.dart';

/// Abstract repository for speech-to-text operations.
/// Pure Dart contract — no speech_to_text, permission_handler, or Flutter imports.
abstract class SpeechRepository {
  /// Requests microphone permission and initializes the STT engine.
  /// Returns true if initialization succeeded, false otherwise.
  /// Idempotent — returns true immediately if already initialized.
  /// Throws [SpeechException] if permission is denied or engine fails.
  Future<bool> initialize();

  /// Returns true if the STT engine is available on this device.
  /// Lazy-initializes if not yet initialized.
  Future<bool> isAvailable();

  /// Starts listening for speech.
  ///
  /// [onResult] — called with each recognized words string as speech is recognized.
  /// [onSoundLevelChange] — called with sound level values as the user speaks.
  /// [onListeningStarted] — called once when the engine starts listening.
  /// [onListeningStopped] — called once when the engine stops listening.
  /// [localeId] — BCP 47 locale ID (e.g. "en-US"). Defaults to device locale.
  /// [listenFor] — maximum listening duration in seconds.
  /// [pauseFor] — silence duration in seconds after which listening stops.
  /// Throws [SpeechException] if not available or engine fails to start.
  Future<void> startListening({
    required Function(String) onResult,
    required Function(double) onSoundLevelChange,
    required Function() onListeningStarted,
    required Function() onListeningStopped,
    String? localeId,
    int? listenFor,
    int? pauseFor,
  });

  /// Stops active speech recognition gracefully.
  Future<void> stopListening();

  /// Cancels active speech recognition without emitting a final result.
  Future<void> cancelListening();

  /// Returns true if the engine is currently listening.
  bool get isListening;

  /// Returns the list of available locale IDs (BCP 47 format, e.g. "en-US").
  /// Lazy-initializes if not yet initialized.
  Future<List<String>> getLocales();

  /// Releases resources held by the repository.
  void dispose();
}
