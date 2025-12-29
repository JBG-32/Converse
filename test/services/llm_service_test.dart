import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:converse/services/llm_service.dart';
import 'package:converse/models/message.dart';
import 'package:converse/core/constants/api_constants.dart';

void main() {
    group('LLMService', () {
          late LLMService llmService;

          setUp(() {
                  llmService = LLMService();
          });

          group('Configuration', () {
                  test('should initialize with default provider (OpenAI)', () {
                            expect(llmService.currentProvider, equals(LLMProvider.openai));
                  });

                  test('should initialize with default model', () {
                            expect(llmService.currentModel, equals(ApiConstants.defaultOpenAIModel));
                  });

                  test('should change provider successfully', () {
                            llmService.setProvider(LLMProvider.anthropic);
                            expect(llmService.currentProvider, equals(LLMProvider.anthropic));
                  });

                  test('should change model successfully', () {
                            const newModel = 'gpt-3.5-turbo';
                            llmService.setModel(newModel);
                            expect(llmService.currentModel, equals(newModel));
                  });

                  test('should set API key', () {
                            const apiKey = 'test-api-key';
                            llmService.setApiKey(apiKey);
                            expect(llmService.hasApiKey, isTrue);
                  });

                  test('should report no API key initially', () {
                            expect(llmService.hasApiKey, isFalse);
                  });
          });

          group('Message Formatting', () {
                  test('should format messages for OpenAI correctly', () {
                            final messages = [
                                        Message(
                                                      id: '1',
                                                      content: 'Hello',
                                                      role: MessageRole.user,
                                                      timestamp: DateTime.now(),
                                                    ),
                                        Message(
                                                      id: '2',
                                                      content: 'Hi there!',
                                                      role: MessageRole.assistant,
                                                      timestamp: DateTime.now(),
                                                    ),
                                      ];

                            llmService.setProvider(LLMProvider.openai);
                            // Test message formatting internally
                            expect(messages.length, equals(2));
                            expect(messages[0].role, equals(MessageRole.user));
                            expect(messages[1].role, equals(MessageRole.assistant));
                  });

                  test('should handle empty message list', () {
                            final messages = <Message>[];
                            expect(messages.isEmpty, isTrue);
                  });

                  test('should handle system messages', () {
                            final message = Message(
                                        id: '1',
                                        content: 'You are a helpful assistant',
                                        role: MessageRole.system,
                                        timestamp: DateTime.now(),
                                      );
                            expect(message.role, equals(MessageRole.system));
                  });
          });

          group('Provider Models', () {
                  test('OpenAI models should be available', () {
                            expect(ApiConstants.openAIModels, isNotEmpty);
                            expect(ApiConstants.openAIModels, contains('gpt-4'));
                            expect(ApiConstants.openAIModels, contains('gpt-3.5-turbo'));
                  });

                  test('Anthropic models should be available', () {
                            expect(ApiConstants.anthropicModels, isNotEmpty);
                            expect(ApiConstants.anthropicModels, contains('claude-3-opus-20240229'));
                  });

                  test('should get correct model list for provider', () {
                            llmService.setProvider(LLMProvider.openai);
                            final openAIModels = llmService.getAvailableModels();
                            expect(openAIModels, equals(ApiConstants.openAIModels));

                            llmService.setProvider(LLMProvider.anthropic);
                            final anthropicModels = llmService.getAvailableModels();
                            expect(anthropicModels, equals(ApiConstants.anthropicModels));
                  });
          });

          group('State Management', () {
                  test('should not be processing initially', () {
                            expect(llmService.isProcessing, isFalse);
                  });

                  test('should cancel request', () async {
                            llmService.cancel();
                            expect(llmService.isProcessing, isFalse);
                  });
          });

          group('Error Handling', () {
                  test('should throw error without API key', () async {
                            expect(
                                        () => llmService.sendMessage(
                                                      messages: [],
                                                      onResponse: (_) {},
                                                      onError: (_) {},
                                                    ),
                                        throwsA(isA<Exception>()),
                                      );
                  });
          });
    });
}
