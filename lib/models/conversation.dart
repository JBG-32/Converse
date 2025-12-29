import 'message.dart';

class Conversation {
    final String id;
    final String title;
    final DateTime createdAt;
    final DateTime? updatedAt;
    final List<Message> messages;

    const Conversation({
          required this.id,
          required this.title,
          required this.createdAt,
          this.updatedAt,
          required this.messages,
    });

    Conversation copyWith({
          String? id,
          String? title,
          DateTime? createdAt,
          DateTime? updatedAt,
          List<Message>? messages,
    }) {
          return Conversation(
                  id: id ?? this.id,
                  title: title ?? this.title,
                  createdAt: createdAt ?? this.createdAt,
                  updatedAt: updatedAt ?? this.updatedAt,
                  messages: messages ?? this.messages,
                );
    }

    Map<String, dynamic> toJson() {
          return {
                  'id': id,
                  'title': title,
                  'createdAt': createdAt.toIso8601String(),
                  'updatedAt': updatedAt?.toIso8601String(),
                  'messages': messages.map((m) => m.toJson()).toList(),
          };
    }

    factory Conversation.fromJson(Map<String, dynamic> json) {
          return Conversation(
                  id: json['id'] as String,
                  title: json['title'] as String,
                  createdAt: DateTime.parse(json['createdAt'] as String),
                  updatedAt: json['updatedAt'] != null
                      ? DateTime.parse(json['updatedAt'] as String)
                      : null,
                  messages: (json['messages'] as List<dynamic>)
                      .map((m) => Message.fromJson(m as Map<String, dynamic>))
                      .toList(),
                );
    }

    // Get the last message preview
    String get lastMessagePreview {
          if (messages.isEmpty) return 'No messages';
          final lastMessage = messages.last;
          return lastMessage.content.length > 50
                    ? '${lastMessage.content.substring(0, 50)}...'
                    : lastMessage.content;
    }

    // Get display time
    String get displayTime {
          final now = DateTime.now();
          final date = updatedAt ?? createdAt;
          final difference = now.difference(date);

          if (difference.inMinutes < 1) {
                  return 'Just now';
          } else if (difference.inHours < 1) {
                  return '${difference.inMinutes}m ago';
          } else if (difference.inDays < 1) {
                  return '${difference.inHours}h ago';
          } else if (difference.inDays < 7) {
                  return '${difference.inDays}d ago';
          } else {
                  return '${date.day}/${date.month}/${date.year}';
          }
    }

    @override
    bool operator ==(Object other) {
          if (identical(this, other)) return true;
          return other is Conversation && other.id == id;
    }

    @override
    int get hashCode => id.hashCode;
}
