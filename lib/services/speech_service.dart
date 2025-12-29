// Speech-to-text service placeholder
// Will be implemented in Phase 2 with speech_to_text package

class SpeechService {
    bool _isListening = false;
    bool get isListening => _isListening;

    Future<void> startListening({
          required Function(String) onResult,
          required Function(String) onError,
    }) async {
          _isListening = true;
          // TODO: Implement with speech_to_text package
          // For now, throw an error to indicate not implemented
          onError('Speech recognition not yet implemented');
    }

    Future<void> stopListening() async {
          _isListening = false;
    }

    Future<bool> checkPermission() async {
          // TODO: Check microphone permission
          return false;
    }

    Future<void> requestPermission() async {
          // TODO: Request microphone permission
    }
}
