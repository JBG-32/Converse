import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/message.dart';
import '../core/constants/api_constants.dart';

enum LLMProvider { openai, anthropic, custom }

class LLMService {
      String? _apiKey;
      LLMProvider _provider = LLMProvider.openai;
      String _model = 'gpt-4';
      String _baseUrl = ApiConstants.openaiBaseUrl;
      double _temperature = 0.7;
      int _maxTokens = 2048;

      // Retry configuration
      int _maxRetries = 3;
      Duration _retryDelay = const Duration(seconds: 1);

      void configure({
              String? apiKey,
              LLMProvider? provider,
              String? model,
              String? baseUrl,
              double? temperature,
              int? maxTokens,
      }) {
              if (apiKey != null) _apiKey = apiKey;
              if (provider != null) {
                        _provider = provider;
                        _baseUrl = _getBaseUrlForProvider(provider);
              }
              if (model != null) _model = model;
              if (baseUrl != null) _baseUrl = baseUrl;
              if (temperature != null) _temperature = temperature;
              if (maxTokens != null) _maxTokens = maxTokens;
      }

      String _getBaseUrlForProvider(LLMProvider provider) {
              switch (provider) {
                  case LLMProvider.openai:
                              return ApiConstants.openaiBaseUrl;
                  case LLMProvider.anthropic:
                              return ApiConstants.anthropicBaseUrl;
                  case LLMProvider.custom:
                              return _baseUrl;
              }
      }

      bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

      Future<String> sendMessage({
              required List<Message> messages,
              String? systemPrompt,
      }) async {
              if (!isConfigured) {
                        throw LLMException('API key not configured');
              }

              Exception? lastException;

              for (int attempt = 0; attempt < _maxRetries; attempt++) {
                        try {
                                    return await _makeRequest(messages, systemPrompt);
                        } on LLMException {
                                    rethrow;
                        } catch (e) {
                                    lastException = e as Exception;
                                    if (attempt < _maxRetries - 1) {
                                                  await Future.delayed(_retryDelay * (attempt + 1));
                                    }
                        }
              }

              throw LLMException('Failed after $_maxRetries attempts: $lastException');
      }

      Future<String> _makeRequest(List<Message> messages, String? systemPrompt) async {
              switch (_provider) {
                  case LLMProvider.openai:
                              return _makeOpenAIRequest(messages, systemPrompt);
                  case LLMProvider.anthropic:
                              return _makeAnthropicRequest(messages, systemPrompt);
                  case LLMProvider.custom:
                              return _makeOpenAIRequest(messages, systemPrompt);
              }
      }

      Future<String> _makeOpenAIRequest(List<Message> messages, String? systemPrompt) async {
              final apiMessages = <Map<String, String>>[];

              if (systemPrompt != null) {
                        apiMessages.add({'role': 'system', 'content': systemPrompt});
              }

              for (final message in messages) {
                        apiMessages.add(message.toApiFormat());
              }

              final response = await http.post(
                        Uri.parse('$_baseUrl/chat/completions'),
                        headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $_apiKey',
                        },
                        body: jsonEncode({
                                    'model': _model,
                                    'messages': apiMessages,
                                    'temperature': _temperature,
                                    'max_tokens': _maxTokens,
                        }),
                      ).timeout(const Duration(seconds: 60));

              return _parseOpenAIResponse(response);
      }

      Future<String> _makeAnthropicRequest(List<Message> messages, String? systemPrompt) async {
              final apiMessages = <Map<String, String>>[];

              for (final message in messages) {
                        apiMessages.add({
                                    'role': message.role == MessageRole.user ? 'user' : 'assistant',
                                    'content': message.content,
                        });
              }

              final response = await http.post(
                        Uri.parse('$_baseUrl/messages'),
                        headers: {
                                    'Content-Type': 'application/json',
                                    'x-api-key': _apiKey!,
                                    'anthropic-version': '2023-06-01',
                        },
                        body: jsonEncode({
                                    'model': _model,
                                    'max_tokens': _maxTokens,
                                    'system': systemPrompt ?? 'You are a helpful assistant.',
                                    'messages': apiMessages,
                        }),
                      ).timeout(const Duration(seconds: 60));

              return _parseAnthropicResponse(response);
      }

      String _parseOpenAIResponse(http.Response response) {
              if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        return data['choices'][0]['message']['content'] as String;
              } else {
                        final error = _parseError(response);
                        throw LLMException(error, statusCode: response.statusCode);
              }
      }

      String _parseAnthropicResponse(http.Response response) {
              if (response.statusCode == 200) {
                        final data = jsonDecode(response.body);
                        final content = data['content'] as List;
                        if (content.isNotEmpty) {
                                    return content[0]['text'] as String;
                        }
                        throw LLMException('Empty response from API');
              } else {
                        final error = _parseError(response);
                        throw LLMException(error, statusCode: response.statusCode);
              }
      }

      String _parseError(http.Response response) {
              try {
                        final data = jsonDecode(response.body);
                        return data['error']?['message'] ?? 
                                         data['error']?['type'] ?? 
                                         'Request failed with status ${response.statusCode}';
              } catch (e) {
                        return 'Request failed with status ${response.statusCode}';
              }
      }

      // Streaming support
      Stream<String> streamMessage({
              required List<Message> messages,
              String? systemPrompt,
      }) async* {
              if (!isConfigured) {
                        throw LLMException('API key not configured');
              }

              final apiMessages = <Map<String, String>>[];

              if (systemPrompt != null) {
                        apiMessages.add({'role': 'system', 'content': systemPrompt});
              }

              for (final message in messages) {
                        apiMessages.add(message.toApiFormat());
              }

              final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
              request.headers.addAll({
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $_apiKey',
              });
              request.body = jsonEncode({
                        'model': _model,
                        'messages': apiMessages,
                        'temperature': _temperature,
                        'max_tokens': _maxTokens,
                        'stream': true,
              });

              final client = http.Client();
              try {
                        final streamedResponse = await client.send(request);

                        if (streamedResponse.statusCode != 200) {
                                    final body = await streamedResponse.stream.bytesToString();
                                    throw LLMException('Stream request failed: $body');
                        }

                        await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
                                    final lines = chunk.split('\n');
                                    for (final line in lines) {
                                                  if (line.startsWith('data: ') && !line.contains('[DONE]')) {
                                                                  try {
                                                                                    final json = jsonDecode(line.substring(6));
                                                                                    final content = json['choices']?[0]?['delta']?['content'];
                                                                                    if (content != null) {
                                                                                                        yield content as String;
                                                                                    }
                                                                  } catch (e) {
                                                                                    // Skip malformed chunks
                                                                  }
                                                  }
                                    }
                        }
              } finally {
                        client.close();
              }
      }

      // Get available models for current provider
      List<String> getAvailableModels() {
              switch (_provider) {
                  case LLMProvider.openai:
                              return ApiConstants.openaiModels;
                  case LLMProvider.anthropic:
                              return ApiConstants.anthropicModels;
                  case LLMProvider.custom:
                              return [_model];
              }
      }
}

class LLMException implements Exception {
      final String message;
      final int? statusCode;

      LLMException(this.message, {this.statusCode});

      @override
      String toString() => 'LLMException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';

      bool get isRateLimited => statusCode == 429;
      bool get isUnauthorized => statusCode == 401;
      bool get isServerError => statusCode != null && statusCode! >= 500;
}
