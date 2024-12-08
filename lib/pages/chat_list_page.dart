import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whats_up/services/token_provider.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late WebSocketChannel channel;
  List<Map<String, dynamic>> ongoingChats = [];
  String? selectedChatId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    String accessToken = tokenProvider.token!;
    initializeWebSocket(accessToken);
    print("Access Token");
    print(accessToken);
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void initializeWebSocket(String accessToken) {
    String url =
        "wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken";
    channel = WebSocketChannel.connect(
      Uri.parse(url),
    );

    // Subscribe to the ongoing chats
    subscribeToChats();

    // Listen for incoming messages
    channel.stream.listen(
      (message) {
        print("Received: $message");
        handleIncomingMessage(message);
      },
      onError: (error) => print("WebSocket Error: $error"),
      onDone: () => print("WebSocket closed"),
    );
  }

  void subscribeToChats() {
    final subscriptionMessage = jsonEncode({
      "command": "subscribe",
      "identifier": "{\"channel\":\"ChatsChannel\"}"
    });
    channel.sink.add(subscriptionMessage);
    print("Subscribed to ChatsChannel: $subscriptionMessage");
  }

  void subscribeToSpecificChat(int chatId) {
    final chatSubscriptionMessage = jsonEncode({
      "command": "subscribe",
      "identifier": "{\"channel\":\"ChatChannel\", \"id\":\"$chatId\"}"
    });
    channel.sink.add(chatSubscriptionMessage);
    print("Subscribed to ChatChannel $chatId: $chatSubscriptionMessage");
  }

  void handleIncomingMessage(String message) {
    try {
      final decodedMessage = jsonDecode(message);
      print("Decoded Message: $decodedMessage");

      // Check and parse the identifier
      final identifier = decodedMessage['identifier'] != null
          ? jsonDecode(decodedMessage['identifier'])
          : null;
      print("Parsed Identifier: $identifier");

      if (identifier != null && identifier['channel'] == 'ChatsChannel') {
        // Ongoing chats
        final chatMessage = decodedMessage['message'];
        if (chatMessage != null && chatMessage['chats'] != null) {
          setState(() {
            ongoingChats =
                List<Map<String, dynamic>>.from(chatMessage['chats']);
          });
          print("Ongoing Chats Updated: $ongoingChats");
        }
      } else if (identifier != null && identifier['channel'] == 'ChatChannel') {
        // Specific chat
        final chatMessage = decodedMessage['message'];
        if (chatMessage != null) {
          if (chatMessage['message'] != null) {
            final chatDetailMessage = chatMessage['message'];
            print("New Message for ChatChannel: $chatDetailMessage");

            // ** Update ChatDetailPage's state with the new message **
            ChatDetailPage.updateMessages(chatDetailMessage);
          } else {
            print("ChatChannel message format unrecognized: $chatMessage");
          }
        } else {
          print("No message content in ChatChannel.");
        }
      } else {
        print("Unhandled message: $decodedMessage");
      }
    } catch (e) {
      print("Error in handleIncomingMessage: $e");
    }
  }

  void navigateToChatDetails(int chatId) {
    subscribeToSpecificChat(chatId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(chatId: chatId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ongoing Chats")),
      body: ongoingChats.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ongoingChats.length,
              itemBuilder: (context, index) {
                final chat = ongoingChats[index];
                return Card(
                  child: ListTile(
                    title: Text(chat['name']),
                    subtitle: Text(
                      chat['users']
                          .map((u) => u['first_name'] ?? 'Unknown')
                          .join(", "),
                    ),
                    onTap: () => navigateToChatDetails(chat['id']),
                  ),
                );
              },
            ),
    );
  }
}

class ChatDetailPage extends StatefulWidget {
  final int chatId;

  ChatDetailPage({required this.chatId});

  // ** Static method to update messages from WebSocket **
  static void updateMessages(Map<String, dynamic> message) {
    _ChatDetailPageState.addMessage(message);
  }

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  List<Map<String, dynamic>> messages = [];

  // ** Add new message to the state **
  static void addMessage(Map<String, dynamic> message) {
    _currentInstance?.addMessageInternal(message);
  }

  static _ChatDetailPageState? _currentInstance;

  @override
  void initState() {
    super.initState();
    _currentInstance = this;
  }

  @override
  void dispose() {
    _currentInstance = null;
    super.dispose();
  }

  void addMessageInternal(Map<String, dynamic> message) {
    setState(() {
      messages.add(message);
    });
    print("Message added: $message");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat #${widget.chatId}")),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ListTile(
            title: Text("${message['first_name']} ${message['last_name']}"),
            subtitle: Text(message['body']),
          );
        },
      ),
    );
  }
}
