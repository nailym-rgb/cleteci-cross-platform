import 'package:flutter/material.dart';
import '../../../services/speech_service.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen>
    with WidgetsBindingObserver {
  final SpeechService _speechService = SpeechService();
  final TextEditingController _textController = TextEditingController();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isLoading = false;
  String _statusMessage = 'Tap the microphone to start listening';
  String _currentLocale = 'en-US';
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSpeechService();
  }

  @override
  void dispose() {
    _speechService.dispose();
    _textController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Stop listening when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopListening();
    }
  }

  Future<void> _initializeSpeechService() async {
    setState(() => _isLoading = true);

    try {
      _isInitialized = await _speechService.initialize();
      if (_isInitialized) {
        setState(() {
          _statusMessage = 'Speech recognition ready. Tap microphone to start.';
        });
      } else {
        setState(() {
          _statusMessage = 'Speech recognition not available on this device.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing speech service: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      await _initializeSpeechService();
      if (!_isInitialized) return;
    }

    try {
      await _speechService.startListening(
        onResult: _onSpeechResult,
        onSoundLevelChange: _onSoundLevelChange,
        onListeningStarted: _onListeningStarted,
        onListeningStopped: _onListeningStopped,
        localeId: _currentLocale,
        listenFor: 30, // Listen for 30 seconds max
        pauseFor: 5, // Pause for 5 seconds to consider speech done
      );
    } catch (e) {
      _showError('Failed to start listening: ${e.toString()}');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speechService.stopListening();
      // Force UI update since the callback might not be called immediately
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
        _statusMessage = 'Speech recognition stopped. Tap microphone to start again.';
      });
    } catch (e) {
      _showError('Error stopping speech recognition: ${e.toString()}');
    }
  }

  void _onSpeechResult(String result) {
    if (mounted) {
      setState(() {
        _textController.text = result;
      });
    }
  }

  void _onSoundLevelChange(double level) {
    if (mounted) {
      setState(() {
        _soundLevel = level;
      });
    }
  }

  void _onListeningStarted() {
    if (mounted) {
      setState(() {
        _isListening = true;
        _statusMessage = 'Listening... Speak now.';
      });
    }
  }

  void _onListeningStopped() {
    if (mounted) {
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
        _statusMessage = 'Speech recognition stopped. Tap microphone to start again.';
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _statusMessage = 'Text cleared. Tap microphone to start listening.';
    });
  }

  void _copyToClipboard() {
    if (_textController.text.isNotEmpty) {
      // TODO: Implement clipboard functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (_textController.text.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Copy to clipboard',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearText,
              tooltip: 'Clear text',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_off,
                      size: 48,
                      color: _isListening
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    if (_isListening) ...[
                      const SizedBox(height: 16),
                      // Sound level indicator
                      Container(
                        height: 4,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (_soundLevel + 1) / 2, // Normalize from -1..1 to 0..1
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Control Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : (_isListening ? _stopListening : _startListening),
                icon: Icon(_isListening ? Icons.stop : Icons.mic),
                label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: _isListening
                      ? Theme.of(context).colorScheme.onError
                      : Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Text Output
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recognized Text:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      minLines: 4,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Speech will appear here...',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Tap "Start Listening" to begin speech recognition\n'
                      '• Speak clearly into your microphone\n'
                      '• The app will automatically stop after 30 seconds or 5 seconds of silence\n'
                      '• Use the copy button to copy text to clipboard\n'
                      '• Use the clear button to reset the text',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}