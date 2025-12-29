import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

/// Service for handling speech-to-text functionality
/// Provides real-time speech recognition with configurable options
class SpeechService {
      final SpeechToText _speech = SpeechToText();
      final Logger _logger = Logger();

      // State
      bool _isInitialized = false;
      bool _isListening = false;
      String _currentLocale = 'en_US';
      List<LocaleName> _availableLocales = [];

      // Callbacks
      Function(String)? _onResult;
      Function(String)? _onPartialResult;
      Function(String)? _onError;
      Function()? _onListeningStarted;
      Function()? _onListeningStopped;

      // Configuration
      Duration _listenFor = const Duration(seconds: 30);
      Duration _pauseFor = const Duration(seconds: 3);
      bool _partialResults = true;
      bool _onDevice = false;
      bool _cancelOnError = true;

      // Getters
      bool get isInitialized => _isInitialized;
      bool get isListening => _isListening;
      String get currentLocale => _currentLocale;
      List<LocaleName> get availableLocales => _availableLocales;
      bool get isAvailable => _speech.isAvailable;

      /// Initialize the speech recognition service
      Future<bool> initialize() async {
              if (_isInitialized) return true;

              try {
                        _isInitialized = await _speech.initialize(
                                    onStatus: _handleStatus,
                                    onError: _handleError,
                                    debugLogging: false,
                                  );

                        if (_isInitialized) {
                                    _availableLocales = await _speech.locales();
                                    _logger.i('Speech service initialized with ${_availableLocales.length} locales');
                        } else {
                                    _logger.w('Speech service initialization failed');
                        }

                        return _isInitialized;
              } catch (e) {
                        _logger.e('Speech initialization error: $e');
                        return false;
              }
      }

      /// Check and request microphone permission
      Future<bool> checkPermission() async {
              final status = await Permission.microphone.status;
              return status.isGranted;
      }

      /// Request microphone permission
      Future<bool> requestPermission() async {
              final status = await Permission.microphone.request();
              return status.isGranted;
      }

      /// Configure speech recognition options
      void configure({
              Duration? listenFor,
              Duration? pauseFor,
              bool? partialResults,
              bool? onDevice,
              bool? cancelOnError,
              String? locale,
      }) {
              if (listenFor != null) _listenFor = listenFor;
              if (pauseFor != null) _pauseFor = pauseFor;
              if (partialResults != null) _partialResults = partialResults;
              if (onDevice != null) _onDevice = onDevice;
              if (cancelOnError != null) _cancelOnError = cancelOnError;
              if (locale != null) _currentLocale = locale;
      }

      /// Set callback for final results
      void setOnResult(Function(String) callback) {
              _onResult = callback;
      }

      /// Set callback for partial/interim results
      void setOnPartialResult(Function(String) callback) {
              _onPartialResult = callback;
      }

      /// Set callback for errors
      void setOnError(Function(String) callback) {
              _onError = callback;
      }

      /// Set callback for listening started
      void setOnListeningStarted(Function() callback) {
              _onListeningStarted = callback;
      }

      /// Set callback for listening stopped
      void setOnListeningStopped(Function() callback) {
              _onListeningStopped = callback;
      }

      /// Start listening for speech
      Future<void> startListening({
              required Function(String) onResult,
              required Function(String) onError,
              Function(String)? onPartialResult,
              Function()? onListeningStarted,
              Function()? onListeningStopped,
      }) async {
              if (!_isInitialized) {
                        final initialized = await initialize();
                        if (!initialized) {
                                    onError('Speech recognition not available');
                                    return;
                        }
              }

              // Check permission
              final hasPermission = await checkPermission();
              if (!hasPermission) {
                        final granted = await requestPermission();
                        if (!granted) {
                                    onError('Microphone permission denied');
                                    return;
                        }
              }

              // Set callbacks
              _onResult = onResult;
              _onError = onError;
              _onPartialResult = onPartialResult;
              _onListeningStarted = onListeningStarted;
              _onListeningStopped = onListeningStopped;

              try {
                        _isListening = true;
                        _onListeningStarted?.call();

                        await _speech.listen(
                                    onResult: _handleResult,
                                    listenFor: _listenFor,
                                    pauseFor: _pauseFor,
                                    partialResults: _partialResults,
                                    onDevice: _onDevice,
                                    cancelOnError: _cancelOnError,
                                    localeId: _currentLocale,
                                    listenMode: ListenMode.confirmation,
                                  );

                        _logger.i('Started listening in locale: $_currentLocale');
              } catch (e) {
                        _isListening = false;
                        _logger.e('Start listening error: $e');
                        onError('Failed to start listening: $e');
              }
      }

      /// Stop listening for speech
      Future<void> stopListening() async {
              if (!_isListening) return;

              try {
                        await _speech.stop();
                        _isListening = false;
                        _onListeningStopped?.call();
                        _logger.i('Stopped listening');
              } catch (e) {
                        _logger.e('Stop listening error: $e');
              }
      }

      /// Cancel speech recognition
      Future<void> cancel() async {
              try {
                        await _speech.cancel();
                        _isListening = false;
                        _onListeningStopped?.call();
                        _logger.i('Cancelled listening');
              } catch (e) {
                        _logger.e('Cancel error: $e');
              }
      }

      /// Get available locales for speech recognition
      Future<List<LocaleName>> getAvailableLocales() async {
              if (!_isInitialized) {
                        await initialize();
              }
              return _availableLocales;
      }

      /// Set the locale for speech recognition
      void setLocale(String localeId) {
              _currentLocale = localeId;
      }

      /// Handle speech recognition result
      void _handleResult(SpeechRecognitionResult result) {
              final text = result.recognizedWords;

              if (result.finalResult) {
                        _logger.i('Final result: $text');
                        _onResult?.call(text);
              } else {
                        _logger.d('Partial result: $text');
                        _onPartialResult?.call(text);
              }
      }

      /// Handle speech recognition status changes
      void _handleStatus(String status) {
              _logger.d('Speech status: $status');

              switch (status) {
                  case 'listening':
                              _isListening = true;
                              break;
                  case 'notListening':
                              _isListening = false;
                              _onListeningStopped?.call();
                              break;
                  case 'done':
                              _isListening = false;
                              _onListeningStopped?.call();
                              break;
              }
      }

      /// Handle speech recognition errors
      void _handleError(SpeechRecognitionError error) {
              _logger.e('Speech error: ${error.errorMsg}');
              _isListening = false;

              String userMessage;
              switch (error.errorMsg) {
                  case 'error_no_match':
                              userMessage = 'No speech detected. Please try again.';
                              break;
                  case 'error_speech_timeout':
                              userMessage = 'Speech timeout. Please try again.';
                              break;
                  case 'error_audio':
                              userMessage = 'Audio recording error. Please check your microphone.';
                              break;
                  case 'error_network':
                              userMessage = 'Network error. Please check your connection.';
                              break;
                  case 'error_permission':
                              userMessage = 'Microphone permission denied.';
                              break;
                  default:
                              userMessage = 'Speech recognition error: ${error.errorMsg}';
              }

              _onError?.call(userMessage);
              _onListeningStopped?.call();
      }

      /// Dispose the service
      void dispose() {
              if (_isListening) {
                        _speech.cancel();
              }
              _isListening = false;
              _isInitialized = false;
      }

      /// Get the sound level while listening (useful for UI feedback)
      double get soundLevel => _speech.lastSoundLevel;

      /// Check if speech recognition has stopped due to silence
      bool get hasTimedOut => !_isListening && _speech.lastStatus == 'done';
}
