import 'package:flutter/material.dart';

class ChatDetailPage extends StatelessWidget {
  final String chatId;
  final List<Map<String, dynamic>> chatMessages;

  ChatDetailPage({required this.chatId, required this.chatMessages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat #$chatId"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: chatMessages.isEmpty
          ? Center(child: Text("No messages yet."))
          : ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                return ListTile(
                  title:
                      Text("${message['first_name']} ${message['last_name']}"),
                  subtitle: Text(message['body']),
                );
              },
            ),
    );
  }
}
