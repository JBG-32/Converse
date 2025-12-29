import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/message.dart';
import '../models/conversation.dart';
import '../services/llm_service.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../core/constants/api_constants.dart';

enum ChatState { idle, listening, processing, streaming, speaking, error }

class ChatViewModel extends ChangeNotifier {
      final LLMService _llmService;
      final SpeechService _speechService;
      final AudioService _audioService;
      final StorageService _storageService;

      ChatViewModel({
              required LLMService llmService,
              required SpeechService speechService,
              required AudioService audioService,
              required StorageService storageService,
      })  : _llmService = llmService,
            _speechService = speechService,
            _audioService = audioService,
            _storageService = storageService;

      // State
      ChatState _state = ChatState.idle;
      ChatState get state => _state;

      List<Message> _messages = [];
      List<Message> get messages => List.unmodifiable(_messages);

      Conversation? _currentConversation;
      Conversation? get currentConversation => _currentConversation;

      String _currentTranscript = '';
      String get currentTranscript => _currentTranscript;

      String _streamingResponse = '';
      String get streamingResponse => _streamingResponse;

      String? _errorMessage;
      String? get errorMessage => _errorMessage;

      bool _isVoiceMode = true;
      bool get isVoiceMode => _isVoiceMode;

      bool _useStreaming = true;
      bool get useStreaming => _useStreaming;

      StreamSubscription<String>? _streamSubscription;

      // Initialize
      Future<void> initialize() async {
              final apiKey = await _storageService.getApiKey();
              final model = await _storageService.getSelectedModel();

              if (apiKey != null) {
                        _llmService.configure(apiKey: apiKey, model: model);
              }
      }

      // Load conversation
      Future<void> loadConversation(String? conversationId) async {
              if (conversationId != null) {
                        _currentConversation = await _storageService.getConversation(conversationId);
                        if (_currentConversation != null) {
                                    _messages = List.from(_currentConversation!.messages);
                                    notifyListeners();
                        }
              } else {
                        _currentConversation = Conversation(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    title: 'New Conversation',
                                    createdAt: DateTime.now(),
                                    messages: [],
                                  );
                        _messages = [];
                        notifyListeners();
              }
      }

      // Toggle modes
      void toggleVoiceMode() {
              _isVoiceMode = !_isVoiceMode;
              notifyListeners();
      }

      void toggleStreaming() {
              _useStreaming = !_useStreaming;
              notifyListeners();
      }

      // Start listening
      Future<void> startListening() async {
              if (_state != ChatState.idle) return;

              _state = ChatState.listening;
              _currentTranscript = '';
              _errorMessage = null;
              notifyListeners();

              try {
                        await _speechService.startListening(
                                    onResult: (transcript) {
                                                  _currentTranscript = transcript;
                                                  notifyListeners();
                                    },
                                    onError: (error) {
                                                  _errorMessage = error;
                                                  _state = ChatState.error;
                                                  notifyListeners();
                                    },
                                  );
              } catch (e) {
                        _errorMessage = e.toString();
                        _state = ChatState.error;
                        notifyListeners();
              }
      }

      // Stop listening
      Future<void> stopListening() async {
              if (_state != ChatState.listening) return;

              await _speechService.stopListening();

              if (_currentTranscript.isNotEmpty) {
                        await sendMessage(_currentTranscript);
              } else {
                        _state = ChatState.idle;
                        notifyListeners();
              }
      }

      // Send message
      Future<void> sendMessage(String text) async {
              if (text.trim().isEmpty) return;
              if (!_llmService.isConfigured) {
                        _errorMessage = 'Please configure your API key in settings';
                        _state = ChatState.error;
                        notifyListeners();
                        return;
              }

              _errorMessage = null;

              // Add user message
              final userMessage = Message(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        content: text.trim(),
                        role: MessageRole.user,
                        timestamp: DateTime.now(),
                      );
              _messages.add(userMessage);
              notifyListeners();

              if (_useStreaming) {
                        await _sendStreamingMessage();
              } else {
                        await _sendRegularMessage();
              }
      }

      Future<void> _sendRegularMessage() async {
              _state = ChatState.processing;
              notifyListeners();

              try {
                        final response = await _llmService.sendMessage(
                                    messages: _messages,
                                    systemPrompt: ApiConstants.defaultSystemPrompt,
                                  );

                        final assistantMessage = Message(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    content: response,
                                    role: MessageRole.assistant,
                                    timestamp: DateTime.now(),
                                  );
                        _messages.add(assistantMessage);

                        await _saveConversation();
                        await _speakIfVoiceMode(response);

                        _state = ChatState.idle;
                        _currentTranscript = '';
                        notifyListeners();
              } on LLMException catch (e) {
                        _handleError(e.message);
              } catch (e) {
                        _handleError(e.toString());
              }
      }

      Future<void> _sendStreamingMessage() async {
              _state = ChatState.streaming;
              _streamingResponse = '';
              notifyListeners();

              // Add placeholder assistant message
              final assistantMessage = Message(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        content: '',
                        role: MessageRole.assistant,
                        timestamp: DateTime.now(),
                      );
              _messages.add(assistantMessage);

              try {
                        final stream = _llmService.streamMessage(
                                    messages: _messages.sublist(0, _messages.length - 1),
                                    systemPrompt: ApiConstants.defaultSystemPrompt,
                                  );

                        _streamSubscription = stream.listen(
                                    (chunk) {
                                                  _streamingResponse += chunk;
                                                  // Update the last message content
                                                  _messages[_messages.length - 1] = assistantMessage.copyWith(
                                                                  content: _streamingResponse,
                                                                );
                                                  notifyListeners();
                                    },
                                    onDone: () async {
                                                  await _saveConversation();
                                                  await _speakIfVoiceMode(_streamingResponse);

                                                  _state = ChatState.idle;
                                                  _streamingResponse = '';
                                                  _currentTranscript = '';
                                                  notifyListeners();
                                    },
                                    onError: (error) {
                                                  // Remove the incomplete message
                                                  _messages.removeLast();
                                                  _handleError(error.toString());
                                    },
                                  );
              } catch (e) {
                        _messages.removeLast();
                        _handleError(e.toString());
              }
      }

      Future<void> _speakIfVoiceMode(String text) async {
              if (_isVoiceMode && text.isNotEmpty) {
                        _state = ChatState.speaking;
                        notifyListeners();
                        await _audioService.speak(text);
              }
      }

      void _handleError(String error) {
              _errorMessage = error;
              _state = ChatState.error;
              notifyListeners();

              // Auto-clear error after delay
              Future.delayed(const Duration(seconds: 5), () {
                        if (_state == ChatState.error) {
                                    _state = ChatState.idle;
                                    _errorMessage = null;
                                    notifyListeners();
                        }
              });
      }

      // Save conversation
      Future<void> _saveConversation() async {
              if (_currentConversation != null && _messages.isNotEmpty) {
                        // Generate title from first user message if needed
                        String title = _currentConversation!.title;
                        if (title == 'New Conversation' && _messages.isNotEmpty) {
                                    final firstUserMsg = _messages.firstWhere(
                                                  (m) => m.role == MessageRole.user,
                                                  orElse: () => _messages.first,
                                                );
                                    title = firstUserMsg.content.length > 30
                                                    ? '${firstUserMsg.content.substring(0, 30)}...'
                                                    : firstUserMsg.content;
                        }

                        _currentConversation = _currentConversation!.copyWith(
                                    title: title,
                                    messages: _messages,
                                    updatedAt: DateTime.now(),
                                  );
                        await _storageService.saveConversation(_currentConversation!);
              }
      }

      // Clear conversation
      Future<void> clearConversation() async {
              _messages = [];
              _currentTranscript = '';
              _streamingResponse = '';
              _state = ChatState.idle;
              _errorMessage = null;

              if (_currentConversation != null) {
                        _currentConversation = _currentConversation!.copyWith(
                                    messages: [],
                                    updatedAt: DateTime.now(),
                                  );
                        await _storageService.saveConversation(_currentConversation!);
              }
              notifyListeners();
      }

      // Retry last message
      Future<void> retryLastMessage() async {
              if (_messages.isEmpty) return;

              // Remove last assistant message if it exists
              if (_messages.last.role == MessageRole.assistant) {
                        _messages.removeLast();
              }

              // Get last user message
              final lastUserMessage = _messages.lastWhere(
                        (m) => m.role == MessageRole.user,
                        orElse: () => _messages.last,
                      );

              // Remove it and resend
              _messages.removeWhere((m) => m.id == lastUserMessage.id);
              notifyListeners();

              await sendMessage(lastUserMessage.content);
      }

      // Cancel operations
      void cancel() {
              _streamSubscription?.cancel();
              _speechService.stopListening();
              _audioService.stop();
              _state = ChatState.idle;
              _streamingResponse = '';
              notifyListeners();
      }

      // Clear error
      void clearError() {
              _errorMessage = null;
              if (_state == ChatState.error) {
                        _state = ChatState.idle;
              }
              notifyListeners();
      }

      @override
      void dispose() {
              cancel();
              super.dispose();
      }
}
