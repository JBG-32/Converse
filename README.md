# Converse 🎙️

A Flutter application for voice-powered conversations with Large Language Models (LLMs).

## Features

- 🗣️ **Voice Chat** - Speak naturally and get AI responses
- - 💬 **Text Chat** - Traditional text-based conversations
  - - 🎨 **Dark/Light Theme** - Automatic and manual theme switching
    - - 💾 **Conversation History** - Save and manage your chats
      - - ⚙️ **Customizable** - Configure API keys, voice settings, and more
       
        - ## Architecture
       
        - This project follows the **MVVM (Model-View-ViewModel)** pattern with Provider for state management:
       
        - ```
          lib/
          ├── core/
          │   ├── di/              # Dependency injection (GetIt)
          │   ├── routes/          # App navigation
          │   └── theme/           # Theme configuration
          ├── models/              # Data models
          ├── services/            # Business logic services
          ├── viewmodels/          # State management
          └── views/               # UI screens (coming soon)
          ```

          ## Getting Started

          ### Prerequisites

          - Flutter SDK >= 3.0.0
          - - Dart SDK >= 3.0.0
            - - An OpenAI API key (or compatible LLM API)
             
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

                         ### Configuration

                         Set up your API key in the app settings or configure it in a `.env` file (implementation coming in Phase 2).

                         ## Roadmap

                         - [x] **Phase 1**: Project structure and architecture
                         - [ ]   - Core folder structure
                         - [ ]     - State management setup (Provider + GetIt)
                         - [ ]   - Theme configuration
                         - [ ]     - Route management
                         - [ ]   - Service layer foundation
                        
                         - [ ]   - [ ] **Phase 2**: LLM Integration
                         - [ ]     - OpenAI API integration
                         - [ ]   - Message streaming
                         - [ ]     - Error handling
                        
                         - [ ] - [ ] **Phase 3**: Chat Interface
                         - [ ]   - Message bubbles UI
                         - [ ]     - Typing indicators
                         - [ ]   - Chat history view
                        
                         - [ ]   - [ ] **Phase 4**: Voice Features
                         - [ ]     - Speech-to-text
                         - [ ]   - Text-to-speech
                         - [ ]     - Voice settings
                        
                         - [ ] - [ ] **Phase 5**: Polish & Testing
                         - [ ]   - Unit tests
                         - [ ]     - Widget tests
                         - [ ]   - Performance optimization
                        
                         - [ ]   ## Dependencies
                        
                         - [ ]   | Package | Purpose |
                         - [ ]   |---------|---------|
                         - [ ]   | provider | State management |
                         - [ ]   | get_it | Dependency injection |
                         - [ ]   | http | API communication |
                         - [ ]   | shared_preferences | Local storage |
                        
                         - [ ]   ## Contributing
                        
                         - [ ]   Contributions are welcome! Please feel free to submit a Pull Request.
                        
                         - [ ]   ## License
                        
                         - [ ]   This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
