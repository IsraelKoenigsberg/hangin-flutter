import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  WebSocketChannel? _channel;

  WebSocketManager._internal();

  factory WebSocketManager() => _instance;

  WebSocketChannel get channel {
    if (_channel == null) {
      throw StateError(
          'WebSocket channel not initialized. Call connect() first.');
    }
    return _channel!;
  }

  WebSocketChannel connect(String accessToken) {
    print("Creating WebSocket channel");
    _channel = WebSocketChannel.connect(
      Uri.parse(
        "wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken",
      ),
    );
    return _channel!;
  }

  void dispose() {
    _channel?.sink.close();
    _channel = null;
  }
}
