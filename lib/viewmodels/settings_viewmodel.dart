import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
    final StorageService _storageService;

    SettingsViewModel({
          required StorageService storageService,
    }) : _storageService = storageService {
          _loadSettings();
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

    // Voice settings
    bool _autoSpeak = true;
    bool get autoSpeak => _autoSpeak;

    double _speechRate = 1.0;
    double get speechRate => _speechRate;

    double _pitch = 1.0;
    double get pitch => _pitch;

    String _selectedVoice = 'default';
    String get selectedVoice => _selectedVoice;

    // Available options
    List<String> get availableModels => [
          'gpt-4',
          'gpt-4-turbo',
          'gpt-3.5-turbo',
          'claude-3-opus',
          'claude-3-sonnet',
        ];

    // Load settings from storage
    Future<void> _loadSettings() async {
          _themeMode = await _storageService.getThemeMode();
          _apiKey = await _storageService.getApiKey() ?? '';
          _selectedModel = await _storageService.getSelectedModel() ?? 'gpt-4';
          _autoSpeak = await _storageService.getAutoSpeak();
          _speechRate = await _storageService.getSpeechRate();
          _pitch = await _storageService.getPitch();
          _selectedVoice = await _storageService.getSelectedVoice() ?? 'default';
          notifyListeners();
    }

    // Update theme mode
    Future<void> setThemeMode(ThemeMode mode) async {
          _themeMode = mode;
          await _storageService.setThemeMode(mode);
          notifyListeners();
    }

    // Update API key
    Future<void> setApiKey(String key) async {
          _apiKey = key;
          await _storageService.setApiKey(key);
          notifyListeners();
    }

    // Update selected model
    Future<void> setSelectedModel(String model) async {
          _selectedModel = model;
          await _storageService.setSelectedModel(model);
          notifyListeners();
    }

    // Update auto speak
    Future<void> setAutoSpeak(bool value) async {
          _autoSpeak = value;
          await _storageService.setAutoSpeak(value);
          notifyListeners();
    }

    // Update speech rate
    Future<void> setSpeechRate(double rate) async {
          _speechRate = rate;
          await _storageService.setSpeechRate(rate);
          notifyListeners();
    }

    // Update pitch
    Future<void> setPitch(double value) async {
          _pitch = value;
          await _storageService.setPitch(value);
          notifyListeners();
    }

    // Update selected voice
    Future<void> setSelectedVoice(String voice) async {
          _selectedVoice = voice;
          await _storageService.setSelectedVoice(voice);
          notifyListeners();
    }

    // Clear all settings
    Future<void> clearSettings() async {
          await _storageService.clearAll();
          await _loadSettings();
    }
}
