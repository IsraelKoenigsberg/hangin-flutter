import 'package:flutter/material.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final List<Map<String, dynamic>> chatMessages;

  ChatDetailPage({required this.chatId, required this.chatMessages});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late List<Map<String, dynamic>> _chatMessages;

  @override
  void initState() {
    super.initState();
    _chatMessages = widget.chatMessages;
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
      body: _chatMessages.isEmpty
          ? Center(child: Text("No messages yet."))
          : ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
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
