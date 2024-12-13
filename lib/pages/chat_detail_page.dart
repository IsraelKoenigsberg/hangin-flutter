import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whats_up/services/chat_service.dart';
import 'package:whats_up/services/token_provider.dart';
import 'package:whats_up/services/web-socket-manager.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final List<Map<String, dynamic>> chatMessages;

  ChatDetailPage({required this.chatId, required this.chatMessages});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late List<Map<String, dynamic>> _chatMessages;
  final TextEditingController _messageController = TextEditingController();
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _chatMessages = widget.chatMessages;
    // Assuming you already have access to the WebSocketChannel
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    String accessToken = tokenProvider.token!;
    print("Access token: ");
    print(accessToken);
    _channel = WebSocketManager().channel;
    print("Channel");
    print(_channel);
    // _channel
    //     ChatService.connectWebSocket(accessToken); // Replace with actual token
    ChatService.subscribeToSpecificChat(_channel, widget.chatId);
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    print("message text: $messageText");
    final chatId = widget.chatId;
    final sendM = jsonEncode({
      "command": "message",
      "identifier": "{\"channel\":\"ChatChannel\", \"id\":\"$chatId\"}",
      "data":
          "{\"action\":\"speak\",\"body\":\"$messageText\", \"kind\":\"text\", \"status\":\"sent\"}"
    });

    if (messageText.isNotEmpty) {
      print("Attempting to send message: $sendM");
      print("Channel: ");
      print(_channel);
      try {
        _channel.sink.add(sendM);
        print("Message sent successfully");
        _messageController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat #${widget.chatId}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatMessages.isEmpty
                ? Center(child: Text("No messages yet."))
                : ListView.builder(
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = _chatMessages[index];
                      return ListTile(
                        title: Text(
                            "${message['first_name']} ${message['last_name']}"),
                        subtitle: Text(message['body']),
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
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
