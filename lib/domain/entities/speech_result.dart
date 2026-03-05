// Domain entity for speech recognition results.
// Pure Dart — no speech_to_text, permission_handler, or Flutter imports.

/// Status of the speech recognition engine.
enum SpeechStatus { notInitialized, initialized, listening, stopped, error }

/// Value object representing a single speech recognition result.
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

  /// Creates a copy with selected fields overridden.
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeechResult &&
        other.text == text &&
        other.isFinal == isFinal &&
        other.confidence == confidence &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(text, isFinal, confidence, status);

  @override
  String toString() =>
      'SpeechResult(text: $text, isFinal: $isFinal, '
      'confidence: $confidence, status: $status)';
}

/// Domain exception for speech-related errors.
class SpeechException implements Exception {
  final String message;

  const SpeechException(this.message);

  @override
  String toString() => 'SpeechException: $message';
}
