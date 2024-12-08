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
    final decodedMessage = jsonDecode(message);
    final identifier = decodedMessage['identifier'] != null
        ? jsonDecode(decodedMessage['identifier'])
        : null;

    if (identifier != null && identifier['channel'] == 'ChatsChannel') {
      if (decodedMessage['message'] != null &&
          decodedMessage['message']['chats'] != null) {
        setState(() {
          ongoingChats = List<Map<String, dynamic>>.from(
              decodedMessage['message']['chats']);
        });
        print("Ongoing Chats: $ongoingChats");
      }
    } else if (identifier != null && identifier['channel'] == 'ChatChannel') {
      if (decodedMessage['message']['messages'] != null) {
        print("Chat History: ${decodedMessage['message']['messages']}");
      } else if (decodedMessage['message']['message'] != null) {
        print("New Message: ${decodedMessage['message']['message']}");
      }
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

class ChatDetailPage extends StatelessWidget {
  final int chatId;

  ChatDetailPage({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat #$chatId")),
      body: Center(
        child: Text("Chat messages for Chat #$chatId will appear here."),
      ),
    );
  }
}
