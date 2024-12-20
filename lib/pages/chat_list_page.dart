import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whats_up/services/chat_service.dart';
import 'package:whats_up/services/token_provider.dart';
import 'package:whats_up/services/web_socket_manager.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late WebSocketChannel channel;
  List<Map<String, dynamic>> ongoingChats = [];

  bool _isMounted = false; // Track if the widget is still mounted

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isMounted) {
      _isMounted = true;
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      String accessToken = tokenProvider.token!;
      print("Initializing WebSocket connection...");
      connectToWebSocket(accessToken);
    }
  }

  void connectToWebSocket(String accessToken) {
    print("Connecting to WebSocket with token: $accessToken");
    channel = WebSocketManager().connect(accessToken);
    ChatService.subscribeToChats(channel);

    channel.stream.listen(
      (message) {
        if (mounted) {
          print("Received WebSocket message: $message");
          ChatService.handleIncomingMessage(
            message,
            context,
            (chats) {
              if (mounted) {
                setState(() {
                  print("Updating ongoing chats...");
                  ongoingChats = chats; // Update ongoing chats here
                });
              }
            },
          );
        }
      },
      onError: (error) {
        print("WebSocket Error: $error");
      },
      onDone: () {
        if (mounted) {
          print("WebSocket closed. Attempting to reconnect...");
          connectToWebSocket(accessToken); // Automatically reconnect
        }
      },
    );
  }

  void navigateToChatDetails(String chatId) {
    print("Navigating to chat details for chat ID: $chatId");
    ChatService.subscribeToSpecificChat(channel, chatId);
  }

  void createChatDialog() {
    final chatNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create New Chat"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: chatNameController,
                  decoration:
                      const InputDecoration(hintText: "Enter chat name"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final chatName = chatNameController.text.trim();

                if (chatName.isNotEmpty) {
                  createNewChat(chatName);
                  Navigator.of(context).pop();
                } else {
                  print("All fields are required.");
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void createNewChat(String chatName) {
    ChatService.createNewChat(channel, chatName);
  }

  @override
  void dispose() {
    _isMounted = false; // Mark as unmounted
    print("Disposing ChatListPage...");
    channel.sink.close(); // Close the WebSocket connection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ongoing Chats"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child:
                IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          )
        ],
      ),
      body: ongoingChats.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
      floatingActionButton: FloatingActionButton(
        onPressed: createChatDialog,
        tooltip: "Create New Chat",
        child: const Icon(Icons.add),
      ),
    );
  }
}
