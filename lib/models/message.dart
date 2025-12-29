enum MessageRole { user, assistant, system }

class Message {
    final String id;
    final String content;
    final MessageRole role;
    final DateTime timestamp;
    final bool isError;

    const Message({
          required this.id,
          required this.content,
          required this.role,
          required this.timestamp,
          this.isError = false,
    });

    Message copyWith({
          String? id,
          String? content,
          MessageRole? role,
          DateTime? timestamp,
          bool? isError,
    }) {
          return Message(
                  id: id ?? this.id,
                  content: content ?? this.content,
                  role: role ?? this.role,
                  timestamp: timestamp ?? this.timestamp,
                  isError: isError ?? this.isError,
                );
    }

    Map<String, dynamic> toJson() {
          return {
                  'id': id,
                  'content': content,
                  'role': role.name,
                  'timestamp': timestamp.toIso8601String(),
                  'isError': isError,
          };
    }

    factory Message.fromJson(Map<String, dynamic> json) {
          return Message(
                  id: json['id'] as String,
                  content: json['content'] as String,
                  role: MessageRole.values.firstWhere(
                            (e) => e.name == json['role'],
                            orElse: () => MessageRole.user,
                          ),
                  timestamp: DateTime.parse(json['timestamp'] as String),
                  isError: json['isError'] as bool? ?? false,
                );
    }

    // Helper to convert to API format
    Map<String, String> toApiFormat() {
          return {
                  'role': role.name,
                  'content': content,
          };
    }

    @override
    bool operator ==(Object other) {
          if (identical(this, other)) return true;
          return other is Message && other.id == id;
    }

    @override
    int get hashCode => id.hashCode;

    @override
    String toString() {
          return 'Message(id: $id, role: $role, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
    }
}
