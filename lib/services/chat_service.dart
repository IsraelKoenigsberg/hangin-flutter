import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whats_up/pages/chat_detail_page.dart';

class ChatService {
  static final Map<String, List<Map<String, dynamic>>> chatMessagesMap = {};
  static void appendMessage(String chatId, Map<String, dynamic> newMessage) {
    if (!chatMessagesMap.containsKey(chatId)) {
      chatMessagesMap[chatId] = [];
    }
    chatMessagesMap[chatId]!.add(newMessage);
  }

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

      // Check if identifier exists and decode it
      final identifier = decodedMessage['identifier'] != null
          ? jsonDecode(decodedMessage['identifier'])
          : null;

      // Handle subscription confirmation messages
      if (decodedMessage['type'] == 'confirm_subscription') {
        print("Subscription confirmed for: $identifier");
        return; // Nothing to do for subscription confirmations
      }

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

          print("First Else If");

          // Update the messages for a specific chat
          if (chatMessage != null && chatMessage['messages'] != null) {
            print("if of first else if");
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
          // Update the messages for a specific chat
          else if (chatMessage != null && chatMessage['message'] != null) {
            print("second Else If");
            print(chatMessage['message']);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                  chatId: chatId,
                  chatMessages:
                      List<Map<String, dynamic>>.from(chatMessage['message']),
                ),
              ),
            );
          } else {
            print("No messages found in chatMessage for chatId: $chatId");
          }
        }
      }
    } catch (e) {
      print("Error in handleIncomingMessage: $e");
    }
  }
}
