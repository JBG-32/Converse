import 'dart:async';
import 'dart:collection';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

/// Service for handling text-to-speech functionality
/// Provides voice synthesis with queue management and customization
class AudioService {
      final FlutterTts _tts = FlutterTts();
      final Logger _logger = Logger();

      // State
      bool _isInitialized = false;
      bool _isSpeaking = false;
      bool _isPaused = false;
      double _currentProgress = 0;
      String _currentText = '';

      // Queue for sequential speech
      final Queue<String> _speechQueue = Queue<String>();
      bool _isProcessingQueue = false;

      // Configuration
      double _speechRate = 0.5;  // 0.0 to 1.0
      double _pitch = 1.0;       // 0.5 to 2.0
      double _volume = 1.0;      // 0.0 to 1.0
      String? _voice;
      String _language = 'en-US';

      // Available voices
      List<dynamic> _availableVoices = [];
      List<dynamic> _availableLanguages = [];

      // Callbacks
      Function()? _onStart;
      Function()? _onComplete;
      Function()? _onCancel;
      Function()? _onPause;
      Function()? _onContinue;
      Function(String, int, int)? _onProgress;
      Function(String)? _onError;

      // Getters
      bool get isInitialized => _isInitialized;
      bool get isSpeaking => _isSpeaking;
      bool get isPaused => _isPaused;
      double get speechRate => _speechRate;
      double get pitch => _pitch;
      double get volume => _volume;
      String? get voice => _voice;
      String get language => _language;
      double get currentProgress => _currentProgress;
      String get currentText => _currentText;
      List<dynamic> get availableVoices => _availableVoices;
      List<dynamic> get availableLanguages => _availableLanguages;
      int get queueLength => _speechQueue.length;

      /// Initialize the TTS service
      Future<bool> initialize() async {
              if (_isInitialized) return true;

              try {
                        // Set up handlers
                        _tts.setStartHandler(() {
                                    _isSpeaking = true;
                                    _isPaused = false;
                                    _onStart?.call();
                                    _logger.i('TTS started speaking');
                        });

                        _tts.setCompletionHandler(() {
                                    _isSpeaking = false;
                                    _isPaused = false;
                                    _currentProgress = 0;
                                    _onComplete?.call();
                                    _logger.i('TTS completed');
                                    _processQueue();
                        });

                        _tts.setCancelHandler(() {
                                    _isSpeaking = false;
                                    _isPaused = false;
                                    _onCancel?.call();
                                    _logger.i('TTS cancelled');
                        });

                        _tts.setPauseHandler(() {
                                    _isPaused = true;
                                    _onPause?.call();
                                    _logger.i('TTS paused');
                        });

                        _tts.setContinueHandler(() {
                                    _isPaused = false;
                                    _onContinue?.call();
                                    _logger.i('TTS continued');
                        });

                        _tts.setProgressHandler((text, start, end, word) {
                                    _currentProgress = end / text.length;
                                    _onProgress?.call(word, start, end);
                        });

                        _tts.setErrorHandler((message) {
                                    _isSpeaking = false;
                                    _isPaused = false;
                                    _logger.e('TTS error: $message');
                                    _onError?.call(message);
                        });

                        // Get available voices and languages
                        _availableVoices = await _tts.getVoices;
                        _availableLanguages = await _tts.getLanguages;

                        // Apply default settings
                        await _applySettings();

                        _isInitialized = true;
                        _logger.i('Audio service initialized with ${_availableVoices.length} voices');
                        return true;
              } catch (e) {
                        _logger.e('TTS initialization error: $e');
                        return false;
              }
      }

      /// Apply current settings to TTS engine
      Future<void> _applySettings() async {
              await _tts.setSpeechRate(_speechRate);
              await _tts.setPitch(_pitch);
              await _tts.setVolume(_volume);
              await _tts.setLanguage(_language);
              if (_voice != null) {
                        await _tts.setVoice({'name': _voice, 'locale': _language});
              }
      }

      /// Configure TTS settings
      Future<void> configure({
              double? speechRate,
              double? pitch,
              double? volume,
              String? voice,
              String? language,
      }) async {
              if (speechRate != null) _speechRate = speechRate.clamp(0.0, 1.0);
              if (pitch != null) _pitch = pitch.clamp(0.5, 2.0);
              if (volume != null) _volume = volume.clamp(0.0, 1.0);
              if (voice != null) _voice = voice;
              if (language != null) _language = language;

              if (_isInitialized) {
                        await _applySettings();
              }
      }

      /// Set callbacks for TTS events
      void setCallbacks({
              Function()? onStart,
              Function()? onComplete,
              Function()? onCancel,
              Function()? onPause,
              Function()? onContinue,
              Function(String, int, int)? onProgress,
              Function(String)? onError,
      }) {
              _onStart = onStart;
              _onComplete = onComplete;
              _onCancel = onCancel;
              _onPause = onPause;
              _onContinue = onContinue;
              _onProgress = onProgress;
              _onError = onError;
      }

      /// Speak text immediately (interrupts current speech)
      Future<void> speak(String text) async {
              if (text.isEmpty) return;

              if (!_isInitialized) {
                        final initialized = await initialize();
                        if (!initialized) {
                                    _onError?.call('TTS not available');
                                    return;
                        }
              }

              // Stop current speech
              if (_isSpeaking) {
                        await stop();
              }

              _currentText = text;
              await _tts.speak(text);
              _logger.i('Speaking: ${text.substring(0, text.length.clamp(0, 50))}...');
      }

      /// Add text to speech queue
      void enqueue(String text) {
              if (text.isEmpty) return;
              _speechQueue.add(text);
              _logger.d('Enqueued text. Queue length: ${_speechQueue.length}');

              if (!_isProcessingQueue && !_isSpeaking) {
                        _processQueue();
              }
      }

      /// Process the speech queue
      Future<void> _processQueue() async {
              if (_isProcessingQueue || _speechQueue.isEmpty) return;

              _isProcessingQueue = true;

              while (_speechQueue.isNotEmpty) {
                        final text = _speechQueue.removeFirst();
                        _currentText = text;

                        // Wait for speech to complete
                        final completer = Completer<void>();
                        final originalOnComplete = _onComplete;

                        _onComplete = () {
                                    originalOnComplete?.call();
                                    completer.complete();
                        };

                        await _tts.speak(text);
                        await completer.future;

                        _onComplete = originalOnComplete;
              }

              _isProcessingQueue = false;
              _logger.d('Queue processing complete');
      }

      /// Stop speaking
      Future<void> stop() async {
              await _tts.stop();
              _speechQueue.clear();
              _isProcessingQueue = false;
              _isSpeaking = false;
              _isPaused = false;
              _logger.i('Stopped speaking and cleared queue');
      }

      /// Pause speech
      Future<void> pause() async {
              if (_isSpeaking && !_isPaused) {
                        await _tts.pause();
              }
      }

      /// Resume paused speech
      Future<void> resume() async {
              if (_isPaused) {
                        // Note: Not all platforms support resume
                        // May need to restart speech from current position
                        _logger.w('Resume may not be supported on all platforms');
              }
      }

      /// Clear the speech queue without stopping current speech
      void clearQueue() {
              _speechQueue.clear();
              _logger.d('Queue cleared');
      }

      /// Get available voices for a specific language
      List<dynamic> getVoicesForLanguage(String languageCode) {
              return _availableVoices.where((voice) {
                        final locale = voice['locale'] as String? ?? '';
                        return locale.startsWith(languageCode);
              }).toList();
      }

      /// Check if a specific language is supported
      bool isLanguageSupported(String languageCode) {
              return _availableLanguages.any((lang) =>
                                                     lang.toString().startsWith(languageCode));
      }

      /// Set speech rate with user-friendly range (slow/normal/fast)
      Future<void> setSpeechRatePreset(SpeechRatePreset preset) async {
              switch (preset) {
                  case SpeechRatePreset.verySlow:
                              _speechRate = 0.25;
                              break;
                  case SpeechRatePreset.slow:
                              _speechRate = 0.4;
                              break;
                  case SpeechRatePreset.normal:
                              _speechRate = 0.5;
                              break;
                  case SpeechRatePreset.fast:
                              _speechRate = 0.65;
                              break;
                  case SpeechRatePreset.veryFast:
                              _speechRate = 0.8;
                              break;
              }
              await _tts.setSpeechRate(_speechRate);
      }

      /// Speak with specific settings (one-time, doesn't affect global settings)
      Future<void> speakWith({
              required String text,
              double? speechRate,
              double? pitch,
              double? volume,
              String? language,
      }) async {
              if (!_isInitialized) await initialize();

              // Temporarily apply settings
              if (speechRate != null) await _tts.setSpeechRate(speechRate);
              if (pitch != null) await _tts.setPitch(pitch);
              if (volume != null) await _tts.setVolume(volume);
              if (language != null) await _tts.setLanguage(language);

              await speak(text);

              // Restore original settings after speech completes
              _tts.setCompletionHandler(() async {
                        await _applySettings();
                        _isSpeaking = false;
                        _onComplete?.call();
                        _processQueue();
              });
      }

      /// Dispose the service
      void dispose() {
              _tts.stop();
              _speechQueue.clear();
              _isSpeaking = false;
              _isPaused = false;
              _isInitialized = false;
              _logger.i('Audio service disposed');
      }
}

/// Presets for speech rate
enum SpeechRatePreset {
      verySlow,
      slow,
      normal,
      fast,
      veryFast,
}
