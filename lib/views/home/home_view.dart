import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/conversation.dart';

class HomeView extends StatefulWidget {
    const HomeView({super.key});

    @override
    State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
    List<Conversation> _conversations = [];
    bool _isLoading = true;

    @override
    void initState() {
          super.initState();
          _loadConversations();
    }

    Future<void> _loadConversations() async {
          final storage = getIt<StorageService>();
          final conversations = await storage.getConversations();
          setState(() {
                  _conversations = conversations;
                  _isLoading = false;
          });
    }

    @override
    Widget build(BuildContext context) {
          return Scaffold(
                  appBar: AppBar(
                            title: const Text('Converse'),
                            actions: [
                                        IconButton(
                                                      icon: const Icon(Icons.settings),
                                                      onPressed: () => AppRoutes.navigateToSettings(context),
                                                    ),
                                      ],
                          ),
                  body: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _conversations.isEmpty
                          ? _buildEmptyState()
                          : _buildConversationList(),
                  floatingActionButton: FloatingActionButton.extended(
                            onPressed: () => AppRoutes.navigateToChat(context),
                            icon: const Icon(Icons.add),
                            label: const Text('New Chat'),
                          ),
                );
    }

    Widget _buildEmptyState() {
          return Center(
                  child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                        Icon(
                                                      Icons.chat_bubble_outline,
                                                      size: 80,
                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                                    ),
                                        const SizedBox(height: 16),
                                        Text(
                                                      'No conversations yet',
                                                      style: Theme.of(context).textTheme.headlineSmall,
                                                    ),
                                        const SizedBox(height: 8),
                                        Text(
                                                      'Start a new chat to begin',
                                                      style: Theme.of(context).textTheme.bodyMedium,
                                                    ),
                                      ],
                          ),
                );
    }

    Widget _buildConversationList() {
          return RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                                        final conversation = _conversations[index];
                                        return _ConversationCard(
                                                      conversation: conversation,
                                                      onTap: () => AppRoutes.navigateToChat(
                                                                      context,
                                                                      conversationId: conversation.id,
                                                                    ),
                                                      onDelete: () => _deleteConversation(conversation.id),
                                                    );
                            },
                          ),
                );
    }

    Future<void> _deleteConversation(String id) async {
          final storage = getIt<StorageService>();
          await storage.deleteConversation(id);
          await _loadConversations();
    }
}

class _ConversationCard extends StatelessWidget {
    final Conversation conversation;
    final VoidCallback onTap;
    final VoidCallback onDelete;

    const _ConversationCard({
          required this.conversation,
          required this.onTap,
          required this.onDelete,
    });

    @override
    Widget build(BuildContext context) {
          return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                                        conversation.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                            subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                                      const SizedBox(height: 4),
                                                      Text(
                                                                      conversation.lastMessagePreview,
                                                                      maxLines: 2,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                                      conversation.displayTime,
                                                                      style: Theme.of(context).textTheme.bodySmall,
                                                                    ),
                                                    ],
                                      ),
                            trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _showDeleteDialog(context),
                                      ),
                            onTap: onTap,
                          ),
                );
    }

    void _showDeleteDialog(BuildContext context) {
          showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                            title: const Text('Delete Conversation'),
                            content: const Text('Are you sure you want to delete this conversation?'),
                            actions: [
                                        TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Cancel'),
                                                    ),
                                        TextButton(
                                                      onPressed: () {
                                                                      Navigator.pop(context);
                                                                      onDelete();
                                                      },
                                                      child: const Text('Delete'),
                                                    ),
                                      ],
                          ),
                );
    }
}
