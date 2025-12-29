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
      static const String _providerKey = 'selected_provider';
      static const String _conversationsKey = 'conversations';

      // Voice settings keys
      static const String _voiceModeEnabledKey = 'voice_mode_enabled';
      static const String _autoSpeakEnabledKey = 'auto_speak_enabled';
      static const String _speechRateKey = 'speech_rate';
      static const String _voicePitchKey = 'voice_pitch';
      static const String _voiceLanguageKey = 'voice_language';
      static const String _selectedVoiceKey = 'selected_voice';

      Future<void> init() async {
              _prefs = await SharedPreferences.getInstance();
      }

      // Theme
      Future<ThemeMode?> getThemeMode() async {
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
              String value;
              switch (mode) {
                  case ThemeMode.light:
                              value = 'light';
                              break;
                  case ThemeMode.dark:
                              value = 'dark';
                              break;
                  default:
                              value = 'system';
              }
              await _prefs?.setString(_themeKey, value);
      }

      // API Key
      Future<String?> getApiKey() async {
              return _prefs?.getString(_apiKeyKey);
      }

      Future<void> setApiKey(String key) async {
              await _prefs?.setString(_apiKeyKey, key);
      }

      // Selected Model
      Future<String?> getSelectedModel() async {
              return _prefs?.getString(_modelKey);
      }

      Future<void> setSelectedModel(String model) async {
              await _prefs?.setString(_modelKey, model);
      }

      // Selected Provider
      Future<String?> getSelectedProvider() async {
              return _prefs?.getString(_providerKey);
      }

      Future<void> setSelectedProvider(String provider) async {
              await _prefs?.setString(_providerKey, provider);
      }

      // Voice Mode Enabled
      Future<bool?> getVoiceModeEnabled() async {
              return _prefs?.getBool(_voiceModeEnabledKey);
      }

      Future<void> setVoiceModeEnabled(bool enabled) async {
              await _prefs?.setBool(_voiceModeEnabledKey, enabled);
      }

      // Auto Speak Enabled
      Future<bool?> getAutoSpeakEnabled() async {
              return _prefs?.getBool(_autoSpeakEnabledKey);
      }

      Future<void> setAutoSpeakEnabled(bool enabled) async {
              await _prefs?.setBool(_autoSpeakEnabledKey, enabled);
      }

      // Speech Rate
      Future<double?> getSpeechRate() async {
              return _prefs?.getDouble(_speechRateKey);
      }

      Future<void> setSpeechRate(double rate) async {
              await _prefs?.setDouble(_speechRateKey, rate);
      }

      // Voice Pitch
      Future<double?> getVoicePitch() async {
              return _prefs?.getDouble(_voicePitchKey);
      }

      Future<void> setVoicePitch(double pitch) async {
              await _prefs?.setDouble(_voicePitchKey, pitch);
      }

      // Voice Language
      Future<String?> getVoiceLanguage() async {
              return _prefs?.getString(_voiceLanguageKey);
      }

      Future<void> setVoiceLanguage(String language) async {
              await _prefs?.setString(_voiceLanguageKey, language);
      }

      // Selected Voice
      Future<String?> getSelectedVoice() async {
              return _prefs?.getString(_selectedVoiceKey);
      }

      Future<void> setSelectedVoice(String voice) async {
              await _prefs?.setString(_selectedVoiceKey, voice);
      }

      // Conversations
      Future<List<Conversation>> getConversations() async {
              final jsonString = _prefs?.getString(_conversationsKey);
              if (jsonString == null) return [];

              try {
                        final List<dynamic> jsonList = json.decode(jsonString);
                        return jsonList.map((json) => Conversation.fromJson(json)).toList();
              } catch (e) {
                        return [];
              }
      }

      Future<void> saveConversations(List<Conversation> conversations) async {
              final jsonList = conversations.map((c) => c.toJson()).toList();
              await _prefs?.setString(_conversationsKey, json.encode(jsonList));
      }

      Future<void> saveConversation(Conversation conversation) async {
              final conversations = await getConversations();
              final index = conversations.indexWhere((c) => c.id == conversation.id);

              if (index >= 0) {
                        conversations[index] = conversation;
              } else {
                        conversations.add(conversation);
              }

              await saveConversations(conversations);
      }

      Future<Conversation?> getConversation(String id) async {
              final conversations = await getConversations();
              try {
                        return conversations.firstWhere((c) => c.id == id);
              } catch (e) {
                        return null;
              }
      }

      Future<void> deleteConversation(String id) async {
              final conversations = await getConversations();
              conversations.removeWhere((c) => c.id == id);
              await saveConversations(conversations);
      }

      // Clear all data
      Future<void> clearAll() async {
              await _prefs?.clear();
      }

      // Clear only conversations
      Future<void> clearConversations() async {
              await _prefs?.remove(_conversationsKey);
      }
}
