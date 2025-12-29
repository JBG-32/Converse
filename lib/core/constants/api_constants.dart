/// API Constants for LLM providers
class ApiConstants {
    ApiConstants._();

    // OpenAI
    static const String openaiBaseUrl = 'https://api.openai.com/v1';
    static const List<String> openaiModels = [
          'gpt-4',
          'gpt-4-turbo',
          'gpt-4-turbo-preview',
          'gpt-4o',
          'gpt-4o-mini',
          'gpt-3.5-turbo',
          'gpt-3.5-turbo-16k',
        ];

    // Anthropic
    static const String anthropicBaseUrl = 'https://api.anthropic.com/v1';
    static const List<String> anthropicModels = [
          'claude-3-5-sonnet-20241022',
          'claude-3-opus-20240229',
          'claude-3-sonnet-20240229',
          'claude-3-haiku-20240307',
        ];

    // Default system prompts
    static const String defaultSystemPrompt = '''
    You are a helpful, friendly AI assistant engaged in a voice conversation. 
    Keep your responses concise and conversational, as they will be spoken aloud.
    Be natural and engaging, but get to the point quickly.
    ''';

    static const String codeAssistantPrompt = '''
    You are a helpful coding assistant. Provide clear, concise code examples 
    and explanations. When showing code, keep it focused and well-commented.
    ''';

    // Rate limits (requests per minute)
    static const int openaiRateLimit = 60;
    static const int anthropicRateLimit = 60;

    // Timeouts
    static const Duration requestTimeout = Duration(seconds: 60);
    static const Duration streamTimeout = Duration(seconds: 120);

    // Token limits
    static const Map<String, int> modelMaxTokens = {
          'gpt-4': 8192,
          'gpt-4-turbo': 128000,
          'gpt-4-turbo-preview': 128000,
          'gpt-4o': 128000,
          'gpt-4o-mini': 128000,
          'gpt-3.5-turbo': 4096,
          'gpt-3.5-turbo-16k': 16384,
          'claude-3-5-sonnet-20241022': 200000,
          'claude-3-opus-20240229': 200000,
          'claude-3-sonnet-20240229': 200000,
          'claude-3-haiku-20240307': 200000,
    };

    // Get max tokens for a model
    static int getMaxTokensForModel(String model) {
          return modelMaxTokens[model] ?? 4096;
    }

    // Model display names
    static const Map<String, String> modelDisplayNames = {
          'gpt-4': 'GPT-4',
          'gpt-4-turbo': 'GPT-4 Turbo',
          'gpt-4-turbo-preview': 'GPT-4 Turbo Preview',
          'gpt-4o': 'GPT-4o',
          'gpt-4o-mini': 'GPT-4o Mini',
          'gpt-3.5-turbo': 'GPT-3.5 Turbo',
          'gpt-3.5-turbo-16k': 'GPT-3.5 Turbo 16K',
          'claude-3-5-sonnet-20241022': 'Claude 3.5 Sonnet',
          'claude-3-opus-20240229': 'Claude 3 Opus',
          'claude-3-sonnet-20240229': 'Claude 3 Sonnet',
          'claude-3-haiku-20240307': 'Claude 3 Haiku',
    };

    static String getModelDisplayName(String model) {
          return modelDisplayNames[model] ?? model;
    }
}
