import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:whats_up/pages/chat_detail_page.dart';
import 'package:whats_up/services/token_provider.dart';

class ChatService {
  static WebSocketChannel connectWebSocket(String accessToken) {
    String url =
        "wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken";
    print("Connecting to WebSocket with URL: $url");
    return WebSocketChannel.connect(Uri.parse(url));
  }

  static void subscribeToChats(WebSocketChannel channel) {
    final subscriptionMessage = jsonEncode({
      "command": "subscribe",
      "identifier": "{\"channel\":\"ChatsChannel\"}"
    });
    print("Subscribing to ChatsChannel with message: $subscriptionMessage");
    channel.sink.add(subscriptionMessage);
  }

  static void subscribeToSpecificChat(WebSocketChannel channel, String chatId) {
    final chatSubscriptionMessage = jsonEncode({
      "command": "subscribe",
      "identifier": "{\"channel\":\"ChatChannel\", \"id\":\"$chatId\"}"
    });
    print(
        "Subscribing to specific chat ($chatId) with message: $chatSubscriptionMessage");
    channel.sink.add(chatSubscriptionMessage);
  }

  static void handleIncomingMessage(String message, BuildContext context,
      Function(List<Map<String, dynamic>>) updateOngoingChats) {
    print("Handling incoming message: $message");

    try {
      final decodedMessage = jsonDecode(message);
      print("Decoded message: $decodedMessage");

      final identifier = decodedMessage['identifier'] != null
          ? jsonDecode(decodedMessage['identifier'])
          : null;

      if (identifier != null) {
        if (identifier['channel'] == 'ChatsChannel') {
          final chatMessage = decodedMessage['message'];
          if (chatMessage != null && chatMessage['chats'] != null) {
            // Update ongoing chats list
            updateOngoingChats(
                List<Map<String, dynamic>>.from(chatMessage['chats']));
          }
        } else if (identifier['channel'] == 'ChatChannel') {
          final chatId = identifier['id'].toString();
          final chatMessage = decodedMessage['message'];

          // Update the messages for a specific chat
          if (chatMessage != null && chatMessage['messages'] != null) {
            // Directly navigate to chat details if needed (you can skip this if you just need the message update)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                  chatId: chatId,
                  chatMessages:
                      List<Map<String, dynamic>>.from(chatMessage['messages']),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      print("Error in handleIncomingMessage: $e");
    }
  }
}

// ChatListPage to show ongoing chats
class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late WebSocketChannel channel;
  List<Map<String, dynamic>> ongoingChats = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    String accessToken = tokenProvider.token!;
    print("Initializing WebSocket connection...");
    initializeWebSocket(accessToken);
  }

  @override
  void dispose() {
    print("Closing WebSocket channel...");
    channel.sink.close();
    super.dispose();
  }

  void initializeWebSocket(String accessToken) {
    print("Initializing WebSocket with token: $accessToken");
    channel = ChatService.connectWebSocket(accessToken);
    ChatService.subscribeToChats(channel);

    // Listen to incoming messages for both ChatsChannel and ChatChannel
    channel.stream.listen(
      (message) {
        print("Received WebSocket message: $message");
        ChatService.handleIncomingMessage(
          message,
          context,
          (chats) => setState(() {
            print("Updating ongoing chats...");
            ongoingChats = chats; // Update ongoing chats here
          }),
        );
      },
      onError: (error) {
        print("WebSocket Error: $error");
      },
      onDone: () {
        print("WebSocket closed. Attempting to reconnect...");
        initializeWebSocket(accessToken); // Automatically reconnect
      },
    );
  }

  void navigateToChatDetails(String chatId) {
    print("Navigating to chat details for chat ID: $chatId");
    ChatService.subscribeToSpecificChat(channel, chatId);
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
                    title: Text(chat['name'] ?? 'Unnamed Chat'),
                    subtitle: Text(
                      chat['users']
                              ?.map((u) => u['first_name'] ?? 'Unknown')
                              .join(", ") ??
                          'No users',
                    ),
                    onTap: () => navigateToChatDetails(chat['id'].toString()),
                  ),
                );
              },
            ),
    );
  }
}
