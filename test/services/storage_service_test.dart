import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:converse/services/storage_service.dart';
import 'package:converse/models/conversation.dart';
import 'package:converse/models/message.dart';

void main() {
    group('StorageService', () {
          late StorageService storageService;

          setUp(() async {
                  SharedPreferences.setMockInitialValues({});
                  storageService = StorageService();
                  await storageService.init();
          });

          group('Theme Settings', () {
                  test('should return system theme by default', () async {
                            final theme = await storageService.getThemeMode();
                            expect(theme, equals(ThemeMode.system));
                  });

                  test('should save and retrieve light theme', () async {
                            await storageService.setThemeMode(ThemeMode.light);
                            final theme = await storageService.getThemeMode();
                            expect(theme, equals(ThemeMode.light));
                  });

                  test('should save and retrieve dark theme', () async {
                            await storageService.setThemeMode(ThemeMode.dark);
                            final theme = await storageService.getThemeMode();
                            expect(theme, equals(ThemeMode.dark));
                  });
          });

          group('API Settings', () {
                  test('should return null for unset API key', () async {
                            final apiKey = await storageService.getApiKey();
                            expect(apiKey, isNull);
                  });

                  test('should save and retrieve API key', () async {
                            const testKey = 'test-api-key-12345';
                            await storageService.setApiKey(testKey);
                            final apiKey = await storageService.getApiKey();
                            expect(apiKey, equals(testKey));
                  });

                  test('should save and retrieve selected model', () async {
                            const model = 'gpt-4-turbo';
                            await storageService.setSelectedModel(model);
                            final savedModel = await storageService.getSelectedModel();
                            expect(savedModel, equals(model));
                  });

                  test('should save and retrieve selected provider', () async {
                            const provider = 'anthropic';
                            await storageService.setSelectedProvider(provider);
                            final savedProvider = await storageService.getSelectedProvider();
                            expect(savedProvider, equals(provider));
                  });
          });

          group('Voice Settings', () {
                  test('should return default voice mode enabled', () async {
                            final enabled = await storageService.getVoiceModeEnabled();
                            expect(enabled, isNull);
                  });

                  test('should save and retrieve voice mode enabled', () async {
                            await storageService.setVoiceModeEnabled(true);
                            final enabled = await storageService.getVoiceModeEnabled();
                            expect(enabled, isTrue);
                  });

                  test('should save and retrieve auto speak enabled', () async {
                            await storageService.setAutoSpeakEnabled(false);
                            final enabled = await storageService.getAutoSpeakEnabled();
                            expect(enabled, isFalse);
                  });

                  test('should save and retrieve speech rate', () async {
                            const rate = 0.75;
                            await storageService.setSpeechRate(rate);
                            final savedRate = await storageService.getSpeechRate();
                            expect(savedRate, equals(rate));
                  });

                  test('should save and retrieve voice pitch', () async {
                            const pitch = 1.5;
                            await storageService.setVoicePitch(pitch);
                            final savedPitch = await storageService.getVoicePitch();
                            expect(savedPitch, equals(pitch));
                  });

                  test('should save and retrieve voice language', () async {
                            const language = 'es-ES';
                            await storageService.setVoiceLanguage(language);
                            final savedLanguage = await storageService.getVoiceLanguage();
                            expect(savedLanguage, equals(language));
                  });
          });

          group('Conversations', () {
                  test('should return empty list for no conversations', () async {
                            final conversations = await storageService.getConversations();
                            expect(conversations, isEmpty);
                  });

                  test('should save and retrieve conversation', () async {
                            final conversation = Conversation(
                                        id: 'test-id',
                                        title: 'Test Conversation',
                                        messages: [
                                                      Message(
                                                                      id: 'msg-1',
                                                                      content: 'Hello',
                                                                      role: MessageRole.user,
                                                                      timestamp: DateTime.now(),
                                                                    ),
                                                    ],
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );

                            await storageService.saveConversation(conversation);
                            final conversations = await storageService.getConversations();

                            expect(conversations, hasLength(1));
                            expect(conversations.first.id, equals('test-id'));
                            expect(conversations.first.title, equals('Test Conversation'));
                  });

                  test('should delete conversation', () async {
                            final conversation = Conversation(
                                        id: 'delete-test',
                                        title: 'To Delete',
                                        messages: [],
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );

                            await storageService.saveConversation(conversation);
                            await storageService.deleteConversation('delete-test');

                            final conversations = await storageService.getConversations();
                            expect(conversations, isEmpty);
                  });

                  test('should update existing conversation', () async {
                            final conversation = Conversation(
                                        id: 'update-test',
                                        title: 'Original Title',
                                        messages: [],
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );

                            await storageService.saveConversation(conversation);

                            final updatedConversation = Conversation(
                                        id: 'update-test',
                                        title: 'Updated Title',
                                        messages: [],
                                        createdAt: conversation.createdAt,
                                        updatedAt: DateTime.now(),
                                      );

                            await storageService.saveConversation(updatedConversation);

                            final conversations = await storageService.getConversations();
                            expect(conversations, hasLength(1));
                            expect(conversations.first.title, equals('Updated Title'));
                  });
          });

          group('Clear Data', () {
                  test('should clear all conversations', () async {
                            final conversation = Conversation(
                                        id: 'clear-test',
                                        title: 'Test',
                                        messages: [],
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      );

                            await storageService.saveConversation(conversation);
                            await storageService.clearConversations();

                            final conversations = await storageService.getConversations();
                            expect(conversations, isEmpty);
                  });
          });
    });
}
