import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/chat_viewmodel.dart';
import '../../models/message.dart';
import '../../core/di/service_locator.dart';

class ChatView extends StatefulWidget {
    final String? conversationId;

    const ChatView({super.key, this.conversationId});

    @override
    State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
    final TextEditingController _textController = TextEditingController();
    final ScrollController _scrollController = ScrollController();

    @override
    void initState() {
          super.initState();
          WidgetsBinding.instance.addPostFrameCallback((_) {
                  final viewModel = context.read<ChatViewModel>();
                  viewModel.initialize();
                  viewModel.loadConversation(widget.conversationId);
          });
    }

    @override
    void dispose() {
          _textController.dispose();
          _scrollController.dispose();
          super.dispose();
    }

    void _scrollToBottom() {
          if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
          }
    }

    @override
    Widget build(BuildContext context) {
          return Consumer<ChatViewModel>(
                  builder: (context, viewModel, child) {
                            // Auto scroll when new messages arrive
                            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                            return Scaffold(
                                        appBar: _buildAppBar(viewModel),
                                        body: Column(
                                                      children: [
                                                                      Expanded(child: _buildMessageList(viewModel)),
                                                                      if (viewModel.errorMessage != null)
                                                                        _buildErrorBanner(viewModel),
                                                                      _buildInputArea(viewModel),
                                                                    ],
                                                    ),
                                      );
                  },
                );
    }

    PreferredSizeWidget _buildAppBar(ChatViewModel viewModel) {
          return AppBar(
                  title: Text(viewModel.currentConversation?.title ?? 'Chat'),
                  actions: [
                            IconButton(
                                        icon: Icon(viewModel.isVoiceMode ? Icons.mic : Icons.mic_off),
                                        onPressed: viewModel.toggleVoiceMode,
                                        tooltip: viewModel.isVoiceMode ? 'Voice mode on' : 'Voice mode off',
                                      ),
                            PopupMenuButton<String>(
                                        onSelected: (value) {
                                                      switch (value) {
                                                        case 'clear':
                                                                          _showClearDialog(viewModel);
                                                                          break;
                                                        case 'streaming':
                                                                          viewModel.toggleStreaming();
                                                                          break;
                                                      }
                                        },
                                        itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                                      value: 'streaming',
                                                                      child: Row(
                                                                                        children: [
                                                                                                            Icon(
                                                                                                                                  viewModel.useStreaming ? Icons.check : Icons.close,
                                                                                                                                  size: 20,
                                                                                                                                ),
                                                                                                            const SizedBox(width: 8),
                                                                                                            const Text('Streaming mode'),
                                                                                                          ],
                                                                                      ),
                                                                    ),
                                                      const PopupMenuItem(
                                                                      value: 'clear',
                                                                      child: Text('Clear chat'),
                                                                    ),
                                                    ],
                                      ),
                          ],
                );
    }

    Widget _buildMessageList(ChatViewModel viewModel) {
          if (viewModel.messages.isEmpty) {
                  return _buildEmptyState();
          }

          return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                            final message = viewModel.messages[index];
                            return _MessageBubble(
                                        message: message,
                                        isStreaming: viewModel.state == ChatState.streaming &&
                                            index == viewModel.messages.length - 1,
                                      );
                  },
                );
    }

    Widget _buildEmptyState() {
          return Center(
                  child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                        Icon(
                                                      Icons.chat,
                                                      size: 64,
                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                                    ),
                                        const SizedBox(height: 16),
                                        Text(
                                                      'Start a conversation',
                                                      style: Theme.of(context).textTheme.titleLarge,
                                                    ),
                                        const SizedBox(height: 8),
                                        Text(
                                                      'Type a message or tap the mic to speak',
                                                      style: Theme.of(context).textTheme.bodyMedium,
                                                    ),
                                      ],
                          ),
                );
    }

    Widget _buildErrorBanner(ChatViewModel viewModel) {
          return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Row(
                            children: [
                                        Icon(
                                                      Icons.error_outline,
                                                      color: Theme.of(context).colorScheme.error,
                                                    ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                                      child: Text(
                                                                      viewModel.errorMessage!,
                                                                      style: TextStyle(
                                                                                        color: Theme.of(context).colorScheme.onErrorContainer,
                                                                                      ),
                                                                    ),
                                                    ),
                                        IconButton(
                                                      icon: const Icon(Icons.close),
                                                      onPressed: viewModel.clearError,
                                                    ),
                                      ],
                          ),
                );
    }

    Widget _buildInputArea(ChatViewModel viewModel) {
          final isProcessing = viewModel.state == ChatState.processing ||
                    viewModel.state == ChatState.streaming;

          return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: [
                                        BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, -2),
                                                    ),
                                      ],
                          ),
                  child: SafeArea(
                            child: Row(
                                        children: [
                                                      if (viewModel.isVoiceMode) _buildMicButton(viewModel),
                                                      Expanded(
                                                                      child: TextField(
                                                                                        controller: _textController,
                                                                                        decoration: InputDecoration(
                                                                                                            hintText: viewModel.state == ChatState.listening
                                                                                                                ? viewModel.currentTranscript.isEmpty
                                                                                                                    ? 'Listening...'
                                                                                                                    : viewModel.currentTranscript
                                                                                                                : 'Type a message...',
                                                                                                            border: OutlineInputBorder(
                                                                                                                                  borderRadius: BorderRadius.circular(24),
                                                                                                                                ),
                                                                                                            contentPadding: const EdgeInsets.symmetric(
                                                                                                                                  horizontal: 16,
                                                                                                                                  vertical: 12,
                                                                                                                                ),
                                                                                                          ),
                                                                                        enabled: !isProcessing && viewModel.state != ChatState.listening,
                                                                                        onSubmitted: (text) => _sendMessage(viewModel, text),
                                                                                      ),
                                                                    ),
                                                      const SizedBox(width: 8),
                                                      _buildSendButton(viewModel, isProcessing),
                                                    ],
                                      ),
                          ),
                );
    }

    Widget _buildMicButton(ChatViewModel viewModel) {
          final isListening = viewModel.state == ChatState.listening;

          return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FloatingActionButton.small(
                            onPressed: isListening
                                ? viewModel.stopListening
                                : viewModel.startListening,
                            backgroundColor: isListening
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                            child: Icon(
                                        isListening ? Icons.stop : Icons.mic,
                                        color: Colors.white,
                                      ),
                          ),
                );
    }

    Widget _buildSendButton(ChatViewModel viewModel, bool isProcessing) {
          if (isProcessing) {
                  return FloatingActionButton.small(
                            onPressed: viewModel.cancel,
                            backgroundColor: Theme.of(context).colorScheme.error,
                            child: const Icon(Icons.stop, color: Colors.white),
                          );
          }

          return FloatingActionButton.small(
                  onPressed: () => _sendMessage(viewModel, _textController.text),
                  child: const Icon(Icons.send),
                );
    }

    void _sendMessage(ChatViewModel viewModel, String text) {
          if (text.trim().isEmpty) return;
          viewModel.sendMessage(text);
          _textController.clear();
    }

    void _showClearDialog(ChatViewModel viewModel) {
          showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                            title: const Text('Clear Chat'),
                            content: const Text('Are you sure you want to clear all messages?'),
                            actions: [
                                        TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Cancel'),
                                                    ),
                                        TextButton(
                                                      onPressed: () {
                                                                      Navigator.pop(context);
                                                                      viewModel.clearConversation();
                                                      },
                                                      child: const Text('Clear'),
                                                    ),
                                      ],
                          ),
                );
    }
}

class _MessageBubble extends StatelessWidget {
    final Message message;
    final bool isStreaming;

    const _MessageBubble({
          required this.message,
          this.isStreaming = false,
    });

    @override
    Widget build(BuildContext context) {
          final isUser = message.role == MessageRole.user;

          return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                        if (!isUser) _buildAvatar(context, isUser),
                                        const SizedBox(width: 8),
                                        Flexible(
                                                      child: Container(
                                                                      padding: const EdgeInsets.all(12),
                                                                      decoration: BoxDecoration(
                                                                                        color: isUser
                                                                                            ? Theme.of(context).colorScheme.primary
                                                                                            : Theme.of(context).colorScheme.surfaceVariant,
                                                                                        borderRadius: BorderRadius.circular(16),
                                                                                      ),
                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                                            Text(
                                                                                                                                  message.content.isEmpty && isStreaming ? '...' : message.content,
                                                                                                                                  style: TextStyle(
                                                                                                                                                          color: isUser
                                                                                                                                                              ? Colors.white
                                                                                                                                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                                                                                                                                        ),
                                                                                                                                ),
                                                                                                            if (isStreaming)
                                                                                                              Padding(
                                                                                                                                      padding: const EdgeInsets.only(top: 4),
                                                                                                                                      child: SizedBox(
                                                                                                                                                                width: 16,
                                                                                                                                                                height: 16,
                                                                                                                                                                child: CircularProgressIndicator(
                                                                                                                                                                                            strokeWidth: 2,
                                                                                                                                                                                            color: Theme.of(context).colorScheme.primary,
                                                                                                                                                                                          ),
                                                                                                                                                              ),
                                                                                                                                    ),
                                                                                                          ],
                                                                                      ),
                                                                    ),
                                                    ),
                                        const SizedBox(width: 8),
                                        if (isUser) _buildAvatar(context, isUser),
                                      ],
                          ),
                );
    }

    Widget _buildAvatar(BuildContext context, bool isUser) {
          return CircleAvatar(
                  radius: 16,
                  backgroundColor: isUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  child: Icon(
                            isUser ? Icons.person : Icons.smart_toy,
                            size: 18,
                            color: Colors.white,
                          ),
                );
    }
}
