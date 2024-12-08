// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;
// import 'dart:convert';

// import 'package:whats_up/pages/chat_message.dart';
// import 'package:whats_up/services/token_provider.dart';

// class WebSocketExample extends StatefulWidget {
//   const WebSocketExample({super.key});

//   @override
//   _WebSocketExampleState createState() => _WebSocketExampleState();
// }

// class _WebSocketExampleState extends State<WebSocketExample> {
//   late WebSocketChannel channel;
//   bool isConnected = false;
//   String statusMessage = "Not connected";
//   List<String> initialMessages = [];
//   bool receivedInitialMessage = false;
//   List<Map<String, dynamic>> chats = [];
//   List<ChatMessage> chatMessages = [];

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
//     String accessToken = tokenProvider.token!;
//     print("Connecting to web socket");
//     connectToWebSocket(accessToken);
//   }

//   void connectToWebSocket(String accessToken) {
//     String url =
//         "wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken";
//     print(1003);
//     channel = WebSocketChannel.connect(Uri.parse(url));
//     channel.sink.add(jsonEncode({
//       "command": "subscribe",
//       "identifier": "{\"channel\":\"ChatsChannel\"}"
//     }));

//     channel.stream.listen(
//       (message) {
//         print(1004);

//         final decodedMessage = jsonDecode(message);
//         print("📩 Raw Message: $message");
//         print("📩 Decoded Message: $decodedMessage");

//         if (!receivedInitialMessage) {
//           print(1005);

//           initialMessages.add(message);
//           print("🆕 Initial Message: $message");
//           setState(() {
//             statusMessage = "Initial message: $message";
//             receivedInitialMessage = true;
//           });
//         }

//         setState(() {
//           print(1006);

//           if (decodedMessage['type'] == 'welcome') {
//             print("👋 WebSocket Connected: Welcome received");
//             statusMessage = "WebSocket connected: Welcome received";
//           } else if (decodedMessage.containsKey("identifier") &&
//               decodedMessage.containsKey("message")) {
//             handleMessage(decodedMessage);
//           } else if (decodedMessage['type'] == 'ping') {
//             print("🔄 Ping received: ${decodedMessage['message']}");
//             statusMessage = "Ping received: ${decodedMessage['message']}";
//           } else {
//             print("⚠️ Unhandled message: $message");
//             statusMessage = "Received: $message";
//           }
//           isConnected = true;
//         });
//       },
//       onDone: () {
//         print(1007);

//         print("❌ WebSocket connection closed.");
//         setState(() {
//           statusMessage = "Connection closed";
//           isConnected = false;
//         });
//       },
//       onError: (error) {
//         print("⚠️ WebSocket Error: $error");
//         setState(() {
//           statusMessage = "Connection error: $error";
//           isConnected = false;
//         });
//       },
//     );
//   }

//   void handleMessage(Map<String, dynamic> decodedMessage) {
//     print(1008);

//     final identifier = decodedMessage['identifier'] != null
//         ? jsonDecode(decodedMessage['identifier'])
//         : null;
//     final channel = identifier?['channel'];

//     if (channel == 'ChatsChannel') {
//       final messageData = decodedMessage['message'];
//       if (messageData.containsKey('chats')) {
//         print("💬 Chats Received: ${messageData['chats']}");
//         setState(() {
//           chats = List<Map<String, dynamic>>.from(messageData['chats']);
//         });
//       } else if (messageData.containsKey('contactsOnline')) {
//         print("🟢 Contacts Online: ${messageData['contactsOnline']}");
//         setState(() {
//           statusMessage = "Contacts online received.";
//         });
//       }
//     } else if (channel == 'ChatChannel') {
//       final messageData = decodedMessage['message'];
//       if (messageData.containsKey('messages')) {
//         // Initial message history
//         print("📜 Initial Chat History: ${messageData['messages']}");
//         final messageArray =
//             List<Map<String, dynamic>>.from(messageData['messages']);
//         setState(() {
//           chatMessages =
//               messageArray.map((msg) => ChatMessage.fromJson(msg)).toList();
//         });
//       } else if (messageData.containsKey('message')) {
//         // Live incoming messages
//         print("📩 New Live Message: ${messageData['message']['message']}");
//         final chatMessage =
//             ChatMessage.fromJson(messageData['message']['message']);
//         setState(() {
//           chatMessages.add(chatMessage);
//         });
//       }
//     } else if (decodedMessage.containsKey('message') &&
//         decodedMessage['message'].containsKey('chat')) {
//       // Handling a new chat creation
//       print("🆕 New Chat Created: ${decodedMessage['message']['chat']}");
//       final newChat = decodedMessage['message']['chat'];
//       setState(() {
//         chats.add(newChat);
//       });
//     } else {
//       print("⚠️ Unrecognized Message Structure: $decodedMessage");
//     }
//   }

//   @override
//   void dispose() {
//     channel.sink.close(status.goingAway);
//     super.dispose();
//   }

//   Widget buildInitialMessageDisplay() {
//     return initialMessages.isNotEmpty
//         ? Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: initialMessages.map((msg) => Text(msg)).toList(),
//           )
//         : const Text("No initial messages received.");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("WebSocket Example")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             buildInitialMessageDisplay(),
//             const SizedBox(height: 20),
//             Text(statusMessage),
//             const SizedBox(height: 20),
//             Expanded(
//               child: isConnected
//                   ? ListView.builder(
//                       itemCount: chats.length + chatMessages.length,
//                       itemBuilder: (context, index) {
//                         if (index < chats.length) {
//                           final chat = chats[index];
//                           return ListTile(
//                             title: Text(chat['name'] ?? 'Unnamed Chat'),
//                             subtitle: Text(
//                               "Users: ${(chat['users'] as List).map((user) => user['first_name']).join(', ')}",
//                             ),
//                           );
//                         } else {
//                           final message = chatMessages[index - chats.length];
//                           return ListTile(
//                             title: Text(
//                                 "${message.firstName} ${message.lastName}"),
//                             subtitle: Text(message.body),
//                           );
//                         }
//                       },
//                     )
//                   : ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           statusMessage = "Reconnecting...";
//                         });
//                         didChangeDependencies();
//                       },
//                       child: const Text("Reconnect to WebSocket"),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
