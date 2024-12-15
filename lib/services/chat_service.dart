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

  static void handleIncomingMessage(
    String message,
    BuildContext context,
    Function(List<Map<String, dynamic>>) updateOngoingChats,
  ) {
    print("Handling incoming message: $message");

    try {
      final decodedMessage = jsonDecode(message);
      final identifier = decodedMessage['identifier'] != null
          ? jsonDecode(decodedMessage['identifier'])
          : null;

      if (decodedMessage['type'] == 'confirm_subscription') {
        print("Subscription confirmed for: $identifier");
        return;
      }

      if (identifier != null) {
        if (identifier['channel'] == 'ChatsChannel') {
          final chatMessage = decodedMessage['message'];
          if (chatMessage != null && chatMessage['chats'] != null) {
            updateOngoingChats(
                List<Map<String, dynamic>>.from(chatMessage['chats']));
          }
        } else if (identifier['channel'] == 'ChatChannel') {
          final chatId = identifier['id'].toString();
          final chatMessage = decodedMessage['message'];

          if (chatMessage != null && chatMessage['messages'] != null) {
            // Save the chat history
            ChatService.chatMessagesMap[chatId] =
                List<Map<String, dynamic>>.from(chatMessage['messages']);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                  chatId: chatId,
                  chatMessages: ChatService.chatMessagesMap[chatId]!,
                ),
              ),
            );
          } else if (chatMessage != null && chatMessage['message'] != null) {
            // Append new message to the list
            ChatService.appendMessage(
                chatId, Map<String, dynamic>.from(chatMessage['message']));

            // Find the ChatDetailPage if it's already open and update the UI
            final navigatorState = Navigator.of(context);
            navigatorState.pushReplacement(MaterialPageRoute(
              builder: (context) => ChatDetailPage(
                chatId: chatId,
                chatMessages: ChatService.chatMessagesMap[chatId]!,
              ),
            ));
          } else {
            print("No messages found in chatMessage for chatId: $chatId");
          }
        }
      }
    } catch (e) {
      print("Error in handleIncomingMessage: $e");
    }
  }

  static void sendMessge(
      final messageText, final chatId, WebSocketChannel channel) {
    final sendM = jsonEncode({
      "command": "message",
      "identifier": "{\"channel\":\"ChatChannel\", \"id\":\"$chatId\"}",
      "data":
          "{\"action\":\"speak\",\"body\":\"$messageText\", \"kind\":\"text\", \"status\":\"sent\"}"
    });

    if (messageText.isNotEmpty) {
      print("Attempting to send message: $sendM");
      print("Channel: ");
      print(channel);
      try {
        channel.sink.add(sendM);
        print("Message sent successfully");
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  static void unsubscribeFromChat(String chatId, WebSocketChannel? channel) {
    final unsubscribeMessage = {
      "command": "unsubscribe",
      "identifier": '{"channel":"ChatChannel", "id":"$chatId"}',
    };

    final jsonMessage =
        jsonEncode(unsubscribeMessage); //Convert to JSON string.
    channel?.sink.add(jsonMessage);
  }
}
