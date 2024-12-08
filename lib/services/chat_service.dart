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
