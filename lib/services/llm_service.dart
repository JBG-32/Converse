import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/message.dart';

class LLMService {
    String? _apiKey;
    String _baseUrl = 'https://api.openai.com/v1';
    String _model = 'gpt-4';

    void configure({
          String? apiKey,
          String? baseUrl,
          String? model,
    }) {
          if (apiKey != null) _apiKey = apiKey;
          if (baseUrl != null) _baseUrl = baseUrl;
          if (model != null) _model = model;
    }

    Future<String> sendMessage({
          required List<Message> messages,
          String? systemPrompt,
    }) async {
          if (_apiKey == null || _apiKey!.isEmpty) {
                  throw Exception('API key not configured');
          }

          final apiMessages = <Map<String, String>>[];

          // Add system prompt if provided
          if (systemPrompt != null) {
                  apiMessages.add({
                            'role': 'system',
                            'content': systemPrompt,
                  });
          }

          // Add conversation messages
          for (final message in messages) {
                  apiMessages.add(message.toApiFormat());
          }

          try {
                  final response = await http.post(
                            Uri.parse('$_baseUrl/chat/completions'),
                            headers: {
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer $_apiKey',
                            },
                            body: jsonEncode({
                                        'model': _model,
                                        'messages': apiMessages,
                                        'temperature': 0.7,
                                        'max_tokens': 2048,
                            }),
                          );

                  if (response.statusCode == 200) {
                            final data = jsonDecode(response.body);
                            return data['choices'][0]['message']['content'] as String;
                  } else {
                            final error = jsonDecode(response.body);
                            throw Exception(error['error']['message'] ?? 'API request failed');
                  }
          } catch (e) {
                  throw Exception('Failed to get response: $e');
          }
    }

    // Stream response for real-time display (placeholder for future)
    Stream<String> streamMessage({
          required List<Message> messages,
          String? systemPrompt,
    }) async* {
          // TODO: Implement streaming API
          final response = await sendMessage(
                  messages: messages,
                  systemPrompt: systemPrompt,
                );
          yield response;
    }
}
