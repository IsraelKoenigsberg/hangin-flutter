import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whats_up/services/chat_service.dart';
import 'package:whats_up/services/web_socket_manager.dart';

/// Widget that displays the details of a chat, including messages and input field.
class ChatDetailPage extends StatefulWidget {
  /// The ID of the chat being displayed.
  final String chatId;

  /// The initial list of chat messages.
  final List<Map<String, dynamic>> chatMessages;

  /// Creates a new ChatDetailPage.
  const ChatDetailPage(
      {super.key, required this.chatId, required this.chatMessages});

  @override
  // ignore: library_private_types_in_public_api
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

/// State class for managing the chat details page.
class _ChatDetailPageState extends State<ChatDetailPage> {
  /// List of chat messages displayed in the ListView.
  late List<Map<String, dynamic>> _chatMessages;

  /// Controller for the text input field.
  final TextEditingController _messageController = TextEditingController();

  /// WebSocket channel for communication with the server.
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _chatMessages = widget
        .chatMessages; // Initialize with messages passed from the previous screen
    _channel = WebSocketManager().channel; // Get the WebSocket channel
    ChatService.subscribeToSpecificChat(
        _channel, widget.chatId); // Subscribe to the specific chat channel
  }

  /// Sends a new message to the chat.
  void _sendMessage() {
    final messageText =
        _messageController.text.trim(); // Get the text from the input field
    final chatId = widget.chatId; // Get the chat ID
    ChatService.sendMessge(
        messageText, chatId, _channel); // Send the message using ChatService
    _messageController.clear(); // Clear the input field after sending
  }

  @override
  void dispose() {
    _messageController
        .dispose(); // Dispose of the text controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Chat #${widget.chatId}"), // Display the chat ID in the title.
        leading: IconButton(
          // Back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ChatService.unsubscribeFromChat(
                widget.chatId, _channel); // Unsubscribe from chat when leaving.
            Navigator.pop(context); // Navigate back to the previous screen.
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatMessages.isEmpty // Check if the message list is empty.
                ? const Center(
                    child:
                        Text("No messages yet.")) // Display message if empty.
                : ListView.builder(
                    itemCount: _chatMessages.length, // Number of messages.
                    itemBuilder: (context, index) {
                      final message = _chatMessages[
                          index]; // Get the message at the current index.
                      return ListTile(
                        title: Text(
                            "${message['first_name']} ${message['last_name']}"), // Display sender's name.
                        subtitle:
                            Text(message['body']), // Display the message body.
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
