import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:whats_up/services/token_provider.dart';

class WebSocketExample extends StatefulWidget {
  const WebSocketExample({super.key});

  @override
  _WebSocketExampleState createState() => _WebSocketExampleState();
}

class _WebSocketExampleState extends State<WebSocketExample> {
  late WebSocketChannel channel;
  bool isConnected = false;
  String statusMessage = "Not connected";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Accessing the token from the provider in didChangeDependencies
    final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    String accessToken = tokenProvider.token!;

    connectToWebSocket(accessToken);
  }

  void connectToWebSocket(String accessToken) {
    String url =
        "wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken";

    channel = WebSocketChannel.connect(Uri.parse(url));

    channel.stream.listen(
      (message) {
        setState(() {
          print("Connected");
          statusMessage = "Connected: $message"; // Display messages
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebSocket Example")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(statusMessage),
            SizedBox(height: 20),
            isConnected
                ? TextField(
                    onSubmitted: sendMessage,
                    decoration: InputDecoration(
                      labelText: "Send a message",
                      border: OutlineInputBorder(),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      // Reconnect by calling didChangeDependencies
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
