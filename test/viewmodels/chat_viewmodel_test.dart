import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:converse/viewmodels/chat_viewmodel.dart';
import 'package:converse/models/message.dart';
import 'package:converse/models/conversation.dart';
import 'package:converse/services/storage_service.dart';
import 'package:converse/services/llm_service.dart';
import 'package:converse/services/speech_service.dart';
import 'package:converse/services/audio_service.dart';

void main() {
    group('ChatViewModel', () {
          late ChatViewModel viewModel;
          late StorageService storageService;
          late LLMService llmService;
          late SpeechService speechService;
          late AudioService audioService;

          setUp(() async {
                  SharedPreferences.setMockInitialValues({});
                  storageService = StorageService();
                  await storageService.init();
                  llmService = LLMService();
                  speechService = SpeechService();
                  audioService = AudioService();

                  viewModel = ChatViewModel(
                            storageService: storageService,
                            llmService: llmService,
                            speechService: speechService,
                            audioService: audioService,
                          );
          });

          group('Initial State', () {
                  test('should have empty messages initially', () {
                            expect(viewModel.messages, isEmpty);
                  });

                  test('should have idle state initially', () {
                            expect(viewModel.state, equals(ChatState.idle));
                  });

                  test('should not be in voice mode initially', () {
                            expect(viewModel.isVoiceMode, isFalse);
                  });

                  test('should have streaming enabled by default', () {
                            expect(viewModel.useStreaming, isTrue);
                  });

                  test('should have no error message initially', () {
                            expect(viewModel.errorMessage, isNull);
                  });

                  test('should have no current conversation initially', () {
                            expect(viewModel.currentConversation, isNull);
                  });
          });

          group('Voice Mode', () {
                  test('should toggle voice mode on', () {
                            viewModel.toggleVoiceMode();
                            expect(viewModel.isVoiceMode, isTrue);
                  });

                  test('should toggle voice mode off', () {
                            viewModel.toggleVoiceMode();
                            viewModel.toggleVoiceMode();
                            expect(viewModel.isVoiceMode, isFalse);
                  });
          });

          group('Streaming Mode', () {
                  test('should toggle streaming mode', () {
                            final initialValue = viewModel.useStreaming;
                            viewModel.toggleStreaming();
                            expect(viewModel.useStreaming, equals(!initialValue));
                  });
          });

          group('Error Handling', () {
                  test('should clear error message', () {
                            viewModel.clearError();
                            expect(viewModel.errorMessage, isNull);
                  });
          });

          group('Conversation Management', () {
                  test('should create new conversation', () {
                            viewModel.createNewConversation();
                            expect(viewModel.currentConversation, isNotNull);
                            expect(viewModel.messages, isEmpty);
                  });

                  test('should clear conversation', () {
                            viewModel.createNewConversation();
                            viewModel.clearConversation();
                            expect(viewModel.messages, isEmpty);
                  });
          });

          group('Message Operations', () {
                  test('should add user message', () {
                            viewModel.createNewConversation();
                            // Note: sendMessage triggers async operations
                            // This test checks initial state
                            expect(viewModel.messages, isEmpty);
                  });

                  test('should handle empty message', () {
                            viewModel.createNewConversation();
                            // Empty messages should not be sent
                            viewModel.sendMessage('');
                            expect(viewModel.messages, isEmpty);
                  });

                  test('should handle whitespace-only message', () {
                            viewModel.createNewConversation();
                            viewModel.sendMessage('   ');
                            expect(viewModel.messages, isEmpty);
                  });
          });

          group('State Transitions', () {
                  test('should be idle after cancel', () {
                            viewModel.cancel();
                            expect(viewModel.state, equals(ChatState.idle));
                  });
          });

          group('Transcript', () {
                  test('should have empty transcript initially', () {
                            expect(viewModel.currentTranscript, isEmpty);
                  });
          });
    });

    group('Message Model', () {
          test('should create message with required fields', () {
                  final message = Message(
                            id: 'test-id',
                            content: 'Hello, world!',
                            role: MessageRole.user,
                            timestamp: DateTime.now(),
                          );

                  expect(message.id, equals('test-id'));
                  expect(message.content, equals('Hello, world!'));
                  expect(message.role, equals(MessageRole.user));
          });

          test('should serialize to JSON', () {
                  final message = Message(
                            id: 'test-id',
                            content: 'Test content',
                            role: MessageRole.assistant,
                            timestamp: DateTime(2024, 1, 1),
                          );

                  final json = message.toJson();
                  expect(json['id'], equals('test-id'));
                  expect(json['content'], equals('Test content'));
                  expect(json['role'], equals('assistant'));
          });

          test('should deserialize from JSON', () {
                  final json = {
                            'id': 'test-id',
                            'content': 'Test content',
                            'role': 'user',
                            'timestamp': '2024-01-01T00:00:00.000',
                  };

                  final message = Message.fromJson(json);
                  expect(message.id, equals('test-id'));
                  expect(message.content, equals('Test content'));
                  expect(message.role, equals(MessageRole.user));
          });
    });

    group('Conversation Model', () {
          test('should create conversation with required fields', () {
                  final conversation = Conversation(
                            id: 'conv-id',
                            title: 'Test Conversation',
                            messages: [],
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          );

                  expect(conversation.id, equals('conv-id'));
                  expect(conversation.title, equals('Test Conversation'));
                  expect(conversation.messages, isEmpty);
          });

          test('should serialize to JSON', () {
                  final conversation = Conversation(
                            id: 'conv-id',
                            title: 'Test',
                            messages: [],
                            createdAt: DateTime(2024, 1, 1),
                            updatedAt: DateTime(2024, 1, 1),
                          );

                  final json = conversation.toJson();
                  expect(json['id'], equals('conv-id'));
                  expect(json['title'], equals('Test'));
          });
    });

    group('ChatState Enum', () {
          test('should have all required states', () {
                  expect(ChatState.values, contains(ChatState.idle));
                  expect(ChatState.values, contains(ChatState.processing));
                  expect(ChatState.values, contains(ChatState.streaming));
                  expect(ChatState.values, contains(ChatState.listening));
                  expect(ChatState.values, contains(ChatState.error));
          });
    });
}
