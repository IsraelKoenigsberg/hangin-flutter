import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whats_up/pages/chat_detail_page.dart';

/// Service class for managing chat functionality, including WebSocket communication,
/// message handling, and navigation to the chat detail page.
class ChatService {
  /// Stores chat messages for each chat ID.  The key is the chatId, and the
  /// value is a list of messages for that chat.
  static final Map<String, List<Map<String, dynamic>>> chatMessagesMap = {};

  /// Appends a new message to the chat history for a given chat ID.
  static void appendMessage(String chatId, Map<String, dynamic> newMessage) {
    chatMessagesMap.putIfAbsent(chatId, () => []).add(newMessage);
  }

  /// Establishes a WebSocket connection using the provided access token.
  /// Consider moving this to WebSocketManager for better separation of concerns.
  static WebSocketChannel connectWebSocket(String accessToken) {
    String url =
        "wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken";
    print("Connecting to WebSocket with URL: $url");
    return WebSocketChannel.connect(Uri.parse(url));
  }

  /// Subscribes to the ChatsChannel to receive updates on ongoing chats.
  static void subscribeToChats(WebSocketChannel channel) {
    final subscriptionMessage = jsonEncode({
      "command": "subscribe",
      "identifier": "{\"channel\":\"ChatsChannel\"}"
    });
    print("Subscribing to ChatsChannel with message: $subscriptionMessage");
    channel.sink.add(subscriptionMessage);
  }

  /// Subscribes to a specific chat channel using the provided chat ID.
  static void subscribeToSpecificChat(WebSocketChannel channel, String chatId) {
    final chatSubscriptionMessage = jsonEncode({
      "command": "subscribe",
      "identifier": "{\"channel\":\"ChatChannel\", \"id\":\"$chatId\"}"
    });
    print(
        "Subscribing to specific chat ($chatId) with message: $chatSubscriptionMessage");
    channel.sink.add(chatSubscriptionMessage);
  }

  /// Handles incoming WebSocket messages and updates the UI accordingly.
  ///
  /// [message] The raw WebSocket message received.
  /// [context] The BuildContext used for navigation.
  /// [updateOngoingChats] Callback function to update the list of ongoing chats.
  static void handleIncomingMessage(
    String message,
    BuildContext context,
    Function(List<Map<String, dynamic>>) updateOngoingChats,
  ) {
    print("Handling incoming message: $message");

    try {
      final decodedMessage = jsonDecode(message);
      final identifierJson = decodedMessage['identifier'];
      if (identifierJson == null) return; // Early exit if no identifier.

      final identifier = jsonDecode(identifierJson);

      if (decodedMessage['type'] == 'confirm_subscription') {
        print("Subscription confirmed for: $identifier");
        return;
      }

      final channel = identifier['channel'];
      if (channel == 'ChatsChannel') {
        _handleChatsChannelMessage(decodedMessage, updateOngoingChats);
      } else if (channel == 'ChatChannel') {
        _handleChatChannelMessage(
            decodedMessage, identifier['id'].toString(), context);
      }
    } catch (e) {
      print("Error in handleIncomingMessage: $e");
    }
  }

  /// Handles messages received from the ChatsChannel.
  static void _handleChatsChannelMessage(Map<String, dynamic> decodedMessage,
      Function(List<Map<String, dynamic>>) updateOngoingChats) {
    final chatMessage = decodedMessage['message'];
    if (chatMessage != null && chatMessage['chats'] != null) {
      updateOngoingChats(List<Map<String, dynamic>>.from(chatMessage['chats']));
    }
  }

  /// Handles messages received from a specific ChatChannel.
  static void _handleChatChannelMessage(Map<String, dynamic> decodedMessage,
      String chatId, BuildContext context) {
    final chatMessage = decodedMessage['message'];

    if (chatMessage != null && chatMessage['messages'] != null) {
      // Initial chat history received when opening a chat.
      chatMessagesMap[chatId] =
          List<Map<String, dynamic>>.from(chatMessage['messages']);
      _navigateToChatDetail(context, chatId);
    } else if (chatMessage != null && chatMessage['message'] != null) {
      // New incoming message received within a chat.
      appendMessage(chatId, Map<String, dynamic>.from(chatMessage['message']));
      _navigateToChatDetail(context, chatId,
          replace: true); // Use pushReplacement to update the chat detail page.
    } else {
      print("No messages found in chatMessage for chatId: $chatId");
    }
  }

  /// Navigates to the ChatDetailPage.
  ///
  /// [replace] If true, uses pushReplacement to update the existing page.
  ///            If false, pushes a new page onto the navigation stack.
  static void _navigateToChatDetail(BuildContext context, String chatId,
      {bool replace = false}) {
    final route = MaterialPageRoute(
      builder: (context) => ChatDetailPage(
        chatId: chatId,
        chatMessages: ChatService.chatMessagesMap[chatId]!,
      ),
    );
    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  /// Sends a new message to a specific chat.
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
      try {
        channel.sink.add(sendM);
        print("Message sent successfully");
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  /// Unsubscribes from a specific chat channel.
  static void unsubscribeFromChat(String chatId, WebSocketChannel? channel) {
    final unsubscribeMessage = {
      "command": "unsubscribe",
      "identifier": '{"channel":"ChatChannel", "id":"$chatId"}',
    };

    final jsonMessage = jsonEncode(unsubscribeMessage);

    if (channel != null && channel.closeCode == null) {
      channel.sink.add(jsonMessage);
    } else {
      print("Channel unavailable for unsubscribing");
    }
  }
}
