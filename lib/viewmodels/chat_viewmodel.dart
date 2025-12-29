import 'package:flutter/foundation.dart';

import '../models/message.dart';
import '../models/conversation.dart';
import '../services/llm_service.dart';
import '../services/speech_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

enum ChatState { idle, listening, processing, speaking, error }

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

    String? _errorMessage;
    String? get errorMessage => _errorMessage;

    bool _isVoiceMode = true;
    bool get isVoiceMode => _isVoiceMode;

    // Initialize with conversation
    Future<void> loadConversation(String? conversationId) async {
          if (conversationId != null) {
                  _currentConversation = await _storageService.getConversation(conversationId);
                  if (_currentConversation != null) {
                            _messages = _currentConversation!.messages;
                            notifyListeners();
                  }
          } else {
                  // Create new conversation
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

    // Toggle voice mode
    void toggleVoiceMode() {
          _isVoiceMode = !_isVoiceMode;
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

    // Stop listening and send message
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

    // Send text message
    Future<void> sendMessage(String text) async {
          if (text.trim().isEmpty) return;

          _state = ChatState.processing;
          _errorMessage = null;
          notifyListeners();

          // Add user message
          final userMessage = Message(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  content: text,
                  role: MessageRole.user,
                  timestamp: DateTime.now(),
                );
          _messages.add(userMessage);
          notifyListeners();

          try {
                  // Get LLM response
                  final response = await _llmService.sendMessage(
                            messages: _messages,
                          );

                  // Add assistant message
                  final assistantMessage = Message(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            content: response,
                            role: MessageRole.assistant,
                            timestamp: DateTime.now(),
                          );
                  _messages.add(assistantMessage);

                  // Save conversation
                  await _saveConversation();

                  // Speak response if in voice mode
                  if (_isVoiceMode) {
                            _state = ChatState.speaking;
                            notifyListeners();
                            await _audioService.speak(response);
                  }

                  _state = ChatState.idle;
                  _currentTranscript = '';
                  notifyListeners();
          } catch (e) {
                  _errorMessage = e.toString();
                  _state = ChatState.error;
                  notifyListeners();
          }
    }

    // Save conversation
    Future<void> _saveConversation() async {
          if (_currentConversation != null) {
                  _currentConversation = _currentConversation!.copyWith(
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
          _state = ChatState.idle;
          await _saveConversation();
          notifyListeners();
    }

    // Cancel current operation
    void cancel() {
          _speechService.stopListening();
          _audioService.stop();
          _state = ChatState.idle;
          notifyListeners();
    }

    @override
    void dispose() {
          cancel();
          super.dispose();
    }
}
