import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:whats_up/services/token_provider.dart';
import 'dart:convert';

class WebSocketExample extends StatefulWidget {
  const WebSocketExample({super.key});

  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  late WebSocketChannel channel;
  bool isConnected = false;
  String statusMessage = "Not connected";
  List<String> initialMessages = [];
  bool receivedInitialMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    String accessToken = tokenProvider.token!;
    connectToWebSocket(accessToken);
  }

  void connectToWebSocket(String accessToken) {
    String url =
        "wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken";

    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.sink.add(jsonEncode({
      "command": "subscribe",
      "identifier": "{\"channel\":\"ChatsChannel\"}"
    }));

    channel.stream.listen(
      (message) {
        final decodedMessage = jsonDecode(message);
        print("Message received: $message");

        if (!receivedInitialMessage) {
          initialMessages.add(message);
          print("Initial Message: $message");
          setState(() {
            statusMessage = "Initial message: $message";
            receivedInitialMessage = true;
          });
        }

        setState(() {
          if (decodedMessage['type'] == 'welcome') {
            statusMessage = "WebSocket connected: Welcome received";
          } else if (decodedMessage.containsKey("identifier") &&
              decodedMessage.containsKey("message")) {
            handleMessage(decodedMessage);
          } else {
            statusMessage = "Received: $message";
          }
          isConnected = true;
        });
      },
      onDone: () {
        setState(() {
          statusMessage = "Connection closed";
          isConnected = false;
        });
      },
      onError: (error) {
        setState(() {
          statusMessage = "Connection error: $error";
          isConnected = false;
        });
      },
    );
  }

  List<Map<String, dynamic>> chats = [];

  void handleMessage(Map<String, dynamic> decodedMessage) {
    final identifier = decodedMessage['identifier'];
    final messageData = decodedMessage['message'];

    if (messageData.containsKey('chats')) {
      setState(() {
        chats = List<Map<String, dynamic>>.from(messageData['chats']);
        statusMessage = "Subscribed and received chat list.";
      });
    } else if (messageData.containsKey('chat')) {
      setState(() {
        chats.add(messageData['chat']);
        statusMessage = "New chat received.";
      });
    } else if (messageData.containsKey('delete_chat')) {
      setState(() {
        chats.removeWhere((chat) => chat['id'] == messageData['delete_chat']);
        statusMessage = "Chat deleted.";
      });
    } else if (messageData.containsKey('update_chat')) {
      setState(() {
        final updatedChat = messageData['update_chat'];
        final index =
            chats.indexWhere((chat) => chat['id'] == updatedChat['id']);
        if (index != -1) chats[index] = updatedChat;
        statusMessage = "Chat updated.";
      });
    }
  }

  void sendMessage(String message) {
    if (isConnected) {
      channel.sink.add(message);
    }
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  Widget buildInitialMessageDisplay() {
    return initialMessages.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: initialMessages.map((msg) => Text(msg)).toList(),
          )
        : Text("No initial messages received.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebSocket Example")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            buildInitialMessageDisplay(),
            SizedBox(height: 20),
            Text(statusMessage),
            SizedBox(height: 20),
            isConnected
                ? Expanded(
                    child: ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return ListTile(
                          title: Text(chat['name'] ?? 'Unnamed Chat'),
                          subtitle: Text(
                            "Users: ${(chat['users'] as List).map((user) => user['first_name']).join(', ')}",
                          ),
                        );
                      },
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        statusMessage = "Reconnecting...";
                      });
                      didChangeDependencies();
                    },
                    child: Text("Reconnect to WebSocket"),
                  ),
          ],
        ),
      ),
    );
  }
}
