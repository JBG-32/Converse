import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../core/di/service_locator.dart';

class SettingsViewModel extends ChangeNotifier {
      final StorageService _storageService;
      final AudioService _audioService;

      SettingsViewModel({
              required StorageService storageService,
      })  : _storageService = storageService,
            _audioService = getIt<AudioService>() {
                    _loadSettings();
                    _initializeAudioService();
            }

      // Theme settings
      ThemeMode _themeMode = ThemeMode.system;
      ThemeMode get themeMode => _themeMode;

      // API settings
      String _apiKey = '';
      String get apiKey => _apiKey;
      bool get hasApiKey => _apiKey.isNotEmpty;

      String _selectedModel = 'gpt-4';
      String get selectedModel => _selectedModel;

      String _selectedProvider = 'openai';
      String get selectedProvider => _selectedProvider;

      // Voice settings
      bool _voiceModeEnabled = true;
      bool get voiceModeEnabled => _voiceModeEnabled;

      bool _autoSpeakEnabled = true;
      bool get autoSpeakEnabled => _autoSpeakEnabled;

      double _speechRate = 0.5;
      double get speechRate => _speechRate;

      double _voicePitch = 1.0;
      double get voicePitch => _voicePitch;

      String _voiceLanguage = 'en-US';
      String get voiceLanguage => _voiceLanguage;

      String _selectedVoice = 'default';
      String get selectedVoice => _selectedVoice;

      // Audio service state
      bool get isSpeaking => _audioService.isSpeaking;
      List<dynamic> get availableVoices => _audioService.availableVoices;

      Future<void> _initializeAudioService() async {
              await _audioService.initialize();
              await _audioService.configure(
                        speechRate: _speechRate,
                        pitch: _voicePitch,
                        language: _voiceLanguage,
                      );
      }

      Future<void> _loadSettings() async {
              _themeMode = await _storageService.getThemeMode() ?? ThemeMode.system;
              _apiKey = await _storageService.getApiKey() ?? '';
              _selectedModel = await _storageService.getSelectedModel() ?? 'gpt-4';
              _selectedProvider = await _storageService.getSelectedProvider() ?? 'openai';
              _voiceModeEnabled = await _storageService.getVoiceModeEnabled() ?? true;
              _autoSpeakEnabled = await _storageService.getAutoSpeakEnabled() ?? true;
              _speechRate = await _storageService.getSpeechRate() ?? 0.5;
              _voicePitch = await _storageService.getVoicePitch() ?? 1.0;
              _voiceLanguage = await _storageService.getVoiceLanguage() ?? 'en-US';
              _selectedVoice = await _storageService.getSelectedVoice() ?? 'default';
              notifyListeners();
      }

      // Theme methods
      Future<void> setThemeMode(ThemeMode mode) async {
              _themeMode = mode;
              await _storageService.setThemeMode(mode);
              notifyListeners();
      }

      // API methods
      Future<void> setApiKey(String key) async {
              _apiKey = key;
              await _storageService.setApiKey(key);
              notifyListeners();
      }

      Future<void> setSelectedModel(String model) async {
              _selectedModel = model;
              await _storageService.setSelectedModel(model);
              notifyListeners();
      }

      Future<void> setSelectedProvider(String provider) async {
              _selectedProvider = provider;
              await _storageService.setSelectedProvider(provider);
              notifyListeners();
      }

      // Voice methods
      Future<void> setVoiceModeEnabled(bool enabled) async {
              _voiceModeEnabled = enabled;
              await _storageService.setVoiceModeEnabled(enabled);
              notifyListeners();
      }

      Future<void> setAutoSpeakEnabled(bool enabled) async {
              _autoSpeakEnabled = enabled;
              await _storageService.setAutoSpeakEnabled(enabled);
              notifyListeners();
      }

      Future<void> setSpeechRate(double rate) async {
              _speechRate = rate.clamp(0.25, 0.75);
              await _storageService.setSpeechRate(_speechRate);
              await _audioService.configure(speechRate: _speechRate);
              notifyListeners();
      }

      Future<void> setVoicePitch(double pitch) async {
              _voicePitch = pitch.clamp(0.5, 2.0);
              await _storageService.setVoicePitch(_voicePitch);
              await _audioService.configure(pitch: _voicePitch);
              notifyListeners();
      }

      Future<void> setVoiceLanguage(String language) async {
              _voiceLanguage = language;
              await _storageService.setVoiceLanguage(language);
              await _audioService.configure(language: language);
              notifyListeners();
      }

      Future<void> setSelectedVoice(String voice) async {
              _selectedVoice = voice;
              await _storageService.setSelectedVoice(voice);
              await _audioService.configure(voice: voice);
              notifyListeners();
      }

      // Voice preview/test
      Future<void> testVoice() async {
              const testText = 'Hello! This is a test of the voice settings. '
                          'You can adjust the speed and pitch to your preference.';
              await _audioService.speak(testText);
              notifyListeners();
      }

      Future<void> stopSpeaking() async {
              await _audioService.stop();
              notifyListeners();
      }

      // Speak text (used by chat to speak AI responses)
      Future<void> speakText(String text) async {
              if (_autoSpeakEnabled) {
                        await _audioService.speak(text);
              }
      }

      // Available models for different providers
      List<String> getAvailableModels() {
              switch (_selectedProvider) {
                  case 'openai':
                              return ['gpt-4', 'gpt-4-turbo', 'gpt-3.5-turbo'];
                  case 'anthropic':
                              return ['claude-3-opus', 'claude-3-sonnet', 'claude-3-haiku'];
                  default:
                              return ['gpt-4'];
              }
      }

      // Reset all settings to defaults
      Future<void> resetToDefaults() async {
              await setThemeMode(ThemeMode.system);
              await setSelectedModel('gpt-4');
              await setSelectedProvider('openai');
              await setVoiceModeEnabled(true);
              await setAutoSpeakEnabled(true);
              await setSpeechRate(0.5);
              await setVoicePitch(1.0);
              await setVoiceLanguage('en-US');
              await setSelectedVoice('default');
      }

      @override
      void dispose() {
              _audioService.dispose();
              super.dispose();
      }
}
