import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whats_up/services/chat_service.dart';
import 'package:whats_up/services/token_provider.dart';
import 'chat_detail_page.dart';

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
