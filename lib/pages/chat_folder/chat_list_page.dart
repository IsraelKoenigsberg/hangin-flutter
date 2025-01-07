import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whats_up/pages/contacts/contacts.dart';
import 'package:whats_up/pages/profile_page.dart';
import 'package:whats_up/pages/sign_in_folder/register_phone_number.dart';
import 'package:whats_up/services/chat_service.dart';
import 'package:whats_up/services/token_provider.dart';
import 'package:whats_up/services/web_socket_manager.dart';

/// Displays a list of ongoing chats and allows creating new chats.
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatListPageState createState() => _ChatListPageState();
}

/// Manages the state of the chat list page.
class _ChatListPageState extends State<ChatListPage> {
  /// WebSocket channel for real-time communication.
  late WebSocketChannel channel;

  /// List of ongoing chats.
  List<Map<String, dynamic>> ongoingChats = [];

  /// Tracks whether the widget is mounted.
  bool _isMounted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isMounted) {
      _isMounted = true;
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      String accessToken = tokenProvider.token!;
      connectToWebSocket(accessToken); // Establish WebSocket connection.
    }
  }

  /// Establishes a WebSocket connection and sets up listeners.
  void connectToWebSocket(String accessToken) {
    channel = WebSocketManager()
        .connect(accessToken); // Connect using WebSocketManager.
    ChatService.subscribeToChats(channel); // Subscribe to chats channel.

    channel.stream.listen(
      (message) {
        // Listen for incoming messages on the WebSocket.
        if (mounted) {
          ChatService.handleIncomingMessage(
            message, // Handle the received message.
            context,
            (chats) {
              // Callback to update ongoing chats.
              if (mounted) {
                setState(() {
                  ongoingChats = chats;
                });
              }
            },
          );
        }
      },
      onError: (error) {
        // Handle WebSocket errors.
        print("WebSocket Error: $error");
      },
      onDone: () {
        // Handle WebSocket closure.
        if (mounted) {
          connectToWebSocket(
              accessToken); // Reconnect if WebSocket connection closes.
        }
      },
    );
  }

  /// Subscribes to the chat details page for a given chat ID.
  void navigateToChatDetails(String chatId) {
    ChatService.subscribeToSpecificChat(channel, chatId);
  }

  /// Displays a dialog to create a new chat.
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
                  // Input field for the chat name.
                  controller: chatNameController,
                  decoration:
                      const InputDecoration(hintText: "Enter chat name"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog.
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                final chatName = chatNameController.text.trim();

                if (chatName.isNotEmpty) {
                  createNewChat(chatName); // Create the chat.
                  Navigator.of(context).pop(); // Close the dialog.
                } else {}
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  /// Creates a new chat with the given name.
  void createNewChat(String chatName) {
    ChatService.createNewChat(channel, chatName);
  }

  @override
  void dispose() {
    _isMounted = false;
    channel.sink.close(); // Close the WebSocket connection on dispose.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokenProvider = Provider.of<TokenProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ongoing Chats"),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String choice) {
              switch (choice) {
                case 'contacts': // Navigate to contacts page.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ContactsPage()),
                  );
                  break;
                case 'signout': // Sign out the user.
                  tokenProvider.deleteToken();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const RegisterPhoneNumber()),
                  );
                  break;
                case 'profile': // Navigate to profile page.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'contacts', // Contacts menu item.
                child: Text('Contacts'),
              ),
              const PopupMenuItem<String>(
                value: 'signout', // Sign out menu item.
                child: Text('Sign Out'),
              ),
              const PopupMenuItem<String>(
                value: 'profile', // Profile menu item.
                child: Text('Profile'),
              ),
            ],
          ),
        ],
      ),
      body: ongoingChats.isEmpty // Display loading indicator or chat list.
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ongoingChats.length,
              itemBuilder: (context, index) {
                final chat = ongoingChats[index];
                return Card(
                  // Display each chat as a card.
                  child: ListTile(
                    // Display chat information within ListTile.
                    title: Text(chat['name'] ??
                        'Unnamed Chat'), // Display chat name or "Unnamed Chat".
                    subtitle: Text(
                      // Display users in chat.
                      chat['users']
                              ?.map((u) => u['first_name'] ?? 'Unknown')
                              .join(", ") ??
                          'No users',
                    ),
                    onTap: () => navigateToChatDetails(chat['id']
                        .toString()), // Navigate to chat details when tapped.
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: createChatDialog, // Open create chat dialog.
        tooltip: "Create New Chat", // Tooltip for the button.
        child: const Icon(Icons.add),
      ),
    );
  }
}
