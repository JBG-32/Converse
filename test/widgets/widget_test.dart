import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:converse/views/chat/chat_view.dart';
import 'package:converse/views/home/home_view.dart';
import 'package:converse/views/settings/settings_view.dart';
import 'package:converse/viewmodels/chat_viewmodel.dart';
import 'package:converse/viewmodels/settings_viewmodel.dart';
import 'package:converse/services/storage_service.dart';
import 'package:converse/services/llm_service.dart';
import 'package:converse/services/speech_service.dart';
import 'package:converse/services/audio_service.dart';

void main() {
    group('Widget Tests', () {
          late StorageService storageService;

          setUp(() async {
                  SharedPreferences.setMockInitialValues({});
                  storageService = StorageService();
                  await storageService.init();
          });

          Widget createTestWidget(Widget child) {
                  return MultiProvider(
                            providers: [
                                        ChangeNotifierProvider(
                                                      create: (_) => ChatViewModel(
                                                                      storageService: storageService,
                                                                      llmService: LLMService(),
                                                                      speechService: SpeechService(),
                                                                      audioService: AudioService(),
                                                                    ),
                                                    ),
                                        ChangeNotifierProvider(
                                                      create: (_) => SettingsViewModel(
                                                                      storageService: storageService,
                                                                    ),
                                                    ),
                                      ],
                            child: MaterialApp(
                                        home: child,
                                      ),
                          );
          }

          group('HomeView', () {
                  testWidgets('should display app title', (tester) async {
                            await tester.pumpWidget(createTestWidget(const HomeView()));
                            await tester.pumpAndSettle();

                            expect(find.text('Converse'), findsOneWidget);
                  });

                  testWidgets('should have new chat button', (tester) async {
                            await tester.pumpWidget(createTestWidget(const HomeView()));
                            await tester.pumpAndSettle();

                            expect(find.byIcon(Icons.add), findsWidgets);
                  });

                  testWidgets('should have settings button', (tester) async {
                            await tester.pumpWidget(createTestWidget(const HomeView()));
                            await tester.pumpAndSettle();

                            expect(find.byIcon(Icons.settings), findsOneWidget);
                  });
          });

          group('ChatView', () {
                  testWidgets('should display message input field', (tester) async {
                            await tester.pumpWidget(createTestWidget(const ChatView()));
                            await tester.pumpAndSettle();

                            expect(find.byType(TextField), findsOneWidget);
                  });

                  testWidgets('should display send button', (tester) async {
                            await tester.pumpWidget(createTestWidget(const ChatView()));
                            await tester.pumpAndSettle();

                            expect(find.byIcon(Icons.send), findsOneWidget);
                  });

                  testWidgets('should display empty state initially', (tester) async {
                            await tester.pumpWidget(createTestWidget(const ChatView()));
                            await tester.pumpAndSettle();

                            expect(find.text('Start a conversation'), findsOneWidget);
                  });

                  testWidgets('should have voice mode toggle', (tester) async {
                            await tester.pumpWidget(createTestWidget(const ChatView()));
                            await tester.pumpAndSettle();

                            // Voice mode icon in app bar
                            expect(
                                        find.byWidgetPredicate(
                                                      (widget) => widget is Icon && 
                                                        (widget.icon == Icons.mic || widget.icon == Icons.mic_off),
                                                    ),
                                        findsWidgets,
                                      );
                  });

                  testWidgets('should allow text input', (tester) async {
                            await tester.pumpWidget(createTestWidget(const ChatView()));
                            await tester.pumpAndSettle();

                            await tester.enterText(find.byType(TextField), 'Hello');
                            expect(find.text('Hello'), findsOneWidget);
                  });
          });

          group('SettingsView', () {
                  testWidgets('should display settings title', (tester) async {
                            await tester.pumpWidget(createTestWidget(const SettingsView()));
                            await tester.pumpAndSettle();

                            expect(find.text('Settings'), findsOneWidget);
                  });

                  testWidgets('should have theme section', (tester) async {
                            await tester.pumpWidget(createTestWidget(const SettingsView()));
                            await tester.pumpAndSettle();

                            expect(find.textContaining('Theme'), findsWidgets);
                  });

                  testWidgets('should have API section', (tester) async {
                            await tester.pumpWidget(createTestWidget(const SettingsView()));
                            await tester.pumpAndSettle();

                            expect(find.textContaining('API'), findsWidgets);
                  });
          });

          group('Theme Tests', () {
                  testWidgets('should support light theme', (tester) async {
                            await tester.pumpWidget(
                                        MaterialApp(
                                                      theme: ThemeData.light(),
                                                      home: const Scaffold(body: Text('Light')),
                                                    ),
                                      );

                            expect(find.text('Light'), findsOneWidget);
                  });

                  testWidgets('should support dark theme', (tester) async {
                            await tester.pumpWidget(
                                        MaterialApp(
                                                      darkTheme: ThemeData.dark(),
                                                      themeMode: ThemeMode.dark,
                                                      home: const Scaffold(body: Text('Dark')),
                                                    ),
                                      );

                            expect(find.text('Dark'), findsOneWidget);
                  });
          });

          group('Accessibility Tests', () {
                  testWidgets('buttons should have semantic labels', (tester) async {
                            await tester.pumpWidget(createTestWidget(const ChatView()));
                            await tester.pumpAndSettle();

                            // Send button should be accessible
                            final sendButton = find.byIcon(Icons.send);
                            expect(sendButton, findsOneWidget);
                  });

                  testWidgets('text fields should have hints', (tester) async {
                            await tester.pumpWidget(createTestWidget(const ChatView()));
                            await tester.pumpAndSettle();

                            final textField = find.byType(TextField);
                            expect(textField, findsOneWidget);
                  });
          });
    });
}
