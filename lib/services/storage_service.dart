import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation.dart';

class StorageService {
    SharedPreferences? _prefs;

    // Keys
    static const String _themeKey = 'theme_mode';
    static const String _apiKeyKey = 'api_key';
    static const String _modelKey = 'selected_model';
    static const String _autoSpeakKey = 'auto_speak';
    static const String _speechRateKey = 'speech_rate';
    static const String _pitchKey = 'pitch';
    static const String _voiceKey = 'selected_voice';
    static const String _conversationsKey = 'conversations';

    Future<void> init() async {
          _prefs = await SharedPreferences.getInstance();
    }

    // Theme
    Future<ThemeMode> getThemeMode() async {
          final value = _prefs?.getString(_themeKey);
          switch (value) {
            case 'light':
                      return ThemeMode.light;
            case 'dark':
                      return ThemeMode.dark;
            default:
                      return ThemeMode.system;
          }
    }

    Future<void> setThemeMode(ThemeMode mode) async {
          await _prefs?.setString(_themeKey, mode.name);
    }

    // API Key
    Future<String?> getApiKey() async {
          return _prefs?.getString(_apiKeyKey);
    }

    Future<void> setApiKey(String key) async {
          await _prefs?.setString(_apiKeyKey, key);
    }

    // Model
    Future<String?> getSelectedModel() async {
          return _prefs?.getString(_modelKey);
    }

    Future<void> setSelectedModel(String model) async {
          await _prefs?.setString(_modelKey, model);
    }

    // Auto Speak
    Future<bool> getAutoSpeak() async {
          return _prefs?.getBool(_autoSpeakKey) ?? true;
    }

    Future<void> setAutoSpeak(bool value) async {
          await _prefs?.setBool(_autoSpeakKey, value);
    }

    // Speech Rate
    Future<double> getSpeechRate() async {
          return _prefs?.getDouble(_speechRateKey) ?? 1.0;
    }

    Future<void> setSpeechRate(double rate) async {
          await _prefs?.setDouble(_speechRateKey, rate);
    }

    // Pitch
    Future<double> getPitch() async {
          return _prefs?.getDouble(_pitchKey) ?? 1.0;
    }

    Future<void> setPitch(double value) async {
          await _prefs?.setDouble(_pitchKey, value);
    }

    // Voice
    Future<String?> getSelectedVoice() async {
          return _prefs?.getString(_voiceKey);
    }

    Future<void> setSelectedVoice(String voice) async {
          await _prefs?.setString(_voiceKey, voice);
    }

    // Conversations
    Future<List<Conversation>> getConversations() async {
          final data = _prefs?.getString(_conversationsKey);
          if (data == null) return [];

          final list = jsonDecode(data) as List<dynamic>;
          return list.map((e) => Conversation.fromJson(e)).toList();
    }

    Future<Conversation?> getConversation(String id) async {
          final conversations = await getConversations();
          try {
                  return conversations.firstWhere((c) => c.id == id);
          } catch (e) {
                  return null;
          }
    }

    Future<void> saveConversation(Conversation conversation) async {
          final conversations = await getConversations();
          final index = conversations.indexWhere((c) => c.id == conversation.id);

          if (index >= 0) {
                  conversations[index] = conversation;
          } else {
                  conversations.insert(0, conversation);
          }

          await _prefs?.setString(
                  _conversationsKey,
                  jsonEncode(conversations.map((c) => c.toJson()).toList()),
                );
    }

    Future<void> deleteConversation(String id) async {
          final conversations = await getConversations();
          conversations.removeWhere((c) => c.id == id);
          await _prefs?.setString(
                  _conversationsKey,
                  jsonEncode(conversations.map((c) => c.toJson()).toList()),
                );
    }

    Future<void> clearAll() async {
          await _prefs?.clear();
    }
}
