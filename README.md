# Converse 🎙️

A Flutter application for voice-powered conversations with Large Language Models (LLMs).

## Features

- 🎤 **Voice Chat** - Speak naturally and get AI responses read aloud
- - 💬 **Text Chat** - Traditional text-based conversations
  - - 🎨 **Dark/Light Theme** - Automatic and manual theme switching
    - - 📝 **Conversation History** - Save and manage your chats
      - - ⚙️ **Customizable** - Configure API keys, voice settings, and more
        - - 🔊 **Text-to-Speech** - Adjustable speech rate, pitch, and language
          - - 🌐 **Multi-Provider** - Support for OpenAI and Anthropic APIs
           
            - ## Architecture
           
            - This project follows the **MVVM (Model-View-ViewModel)** pattern with Provider for state management:
           
            - ```
              lib/
              ├── core/
              │   ├── di/             # Dependency injection (GetIt)
              │   ├── routes/         # App navigation
              │   ├── theme/          # Theme configuration
              │   └── constants/      # API constants
              ├── models/             # Data models
              ├── services/           # Business logic services
              ├── viewmodels/         # State management
              └── views/              # UI screens
              ```

              ## Getting Started

              ### Prerequisites

              - Flutter SDK >= 3.0.0
              - - Dart SDK >= 3.0.0
                - - An OpenAI or Anthropic API key
                 
                  - ### Installation
                 
                  - 1. Clone the repository:
                    2. ```bash
                       git clone https://github.com/JBG-32/Converse.git
                       cd Converse
                       ```

                       2. Install dependencies:
                       3. ```bash
                          flutter pub get
                          ```

                          3. Run the app:
                          4. ```bash
                             flutter run
                             ```

                             ### Platform Setup

                             #### Android
                             Add microphone permission to `android/app/src/main/AndroidManifest.xml`:
                             ```xml
                             <uses-permission android:name="android.permission.RECORD_AUDIO"/>
                             <uses-permission android:name="android.permission.INTERNET"/>
                             ```

                             #### iOS
                             Add to `ios/Runner/Info.plist`:
                             ```xml
                             <key>NSMicrophoneUsageDescription</key>
                             <string>This app needs microphone access for voice input</string>
                             <key>NSSpeechRecognitionUsageDescription</key>
                             <string>This app needs speech recognition for voice commands</string>
                             ```

                             ## Testing

                             The project includes comprehensive tests for services, viewmodels, and widgets.

                             ### Running Tests

                             Run all tests:
                             ```bash
                             flutter test
                             ```

                             Run specific test file:
                             ```bash
                             flutter test test/services/llm_service_test.dart
                             ```

                             Run with coverage:
                             ```bash
                             flutter test --coverage
                             ```

                             ### Test Structure

                             ```
                             test/
                             ├── services/
                             │   ├── llm_service_test.dart      # LLM API tests
                             │   └── storage_service_test.dart  # Storage tests
                             ├── viewmodels/
                             │   └── chat_viewmodel_test.dart   # ViewModel tests
                             └── widgets/
                                 └── widget_test.dart           # UI widget tests
                             ```

                             ### Test Categories

                             - **Unit Tests**: Service and model logic
                             - - **Widget Tests**: UI component behavior
                               - - **Integration Tests**: End-to-end flows
                                
                                 - ## Configuration
                                
                                 - ### API Keys
                                
                                 - Configure your API key in the Settings screen or programmatically:
                                
                                 - ```dart
                                   final settingsViewModel = context.read<SettingsViewModel>();
                                   settingsViewModel.setApiKey('your-api-key');
                                   settingsViewModel.setSelectedProvider('openai'); // or 'anthropic'
                                   ```

                                   ### Voice Settings

                                   Customize voice output:

                                   ```dart
                                   settingsViewModel.setSpeechRate(0.5);  // 0.25 - 0.75
                                   settingsViewModel.setVoicePitch(1.0);  // 0.5 - 2.0
                                   settingsViewModel.setVoiceLanguage('en-US');
                                   ```

                                   ## Dependencies

                                   | Package | Purpose |
                                   |---------|---------|
                                   | provider | State management |
                                   | get_it | Dependency injection |
                                   | http | API requests |
                                   | shared_preferences | Local storage |
                                   | speech_to_text | Voice input |
                                   | flutter_tts | Text-to-speech |
                                   | permission_handler | Runtime permissions |

                                   ## Project Status

                                   - [x] Phase 1: Project Structure & Architecture
                                   - [ ] - [x] Phase 2: LLM Integration (OpenAI/Anthropic)
                                   - [ ] - [x] Phase 3: Chat Interface
                                   - [ ] - [x] Phase 4: Voice Features
                                   - [ ] - [x] Phase 5: Testing & Documentation
                                  
                                   - [ ] ## Contributing
                                  
                                   - [ ] 1. Fork the repository
                                   - [ ] 2. Create your feature branch (`git checkout -b feature/amazing-feature`)
                                   - [ ] 3. Commit your changes (`git commit -m 'Add amazing feature'`)
                                   - [ ] 4. Push to the branch (`git push origin feature/amazing-feature`)
                                   - [ ] 5. Open a Pull Request
                                  
                                   - [ ] ## License
                                  
                                   - [ ] This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
                                  
                                   - [ ] ## Acknowledgments
                                  
                                   - [ ] - OpenAI for GPT API
                                   - [ ] - Anthropic for Claude API
                                   - [ ] - Flutter team for the amazing framework
