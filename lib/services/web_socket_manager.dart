import 'package:web_socket_channel/web_socket_channel.dart';

/// Manages the WebSocket connection for real-time communication.
class WebSocketManager {
  // Private constructor to enforce singleton pattern.
  static final WebSocketManager _instance = WebSocketManager._internal();

  // Private WebSocket channel.
  WebSocketChannel? _channel;

  // Private constructor.
  WebSocketManager._internal();

  // Factory constructor to return the singleton instance.
  factory WebSocketManager() => _instance;

  /// Returns the active WebSocket channel.
  /// Throws a StateError if the channel is not initialized.
  WebSocketChannel get channel {
    if (_channel == null) {
      throw StateError(
          'WebSocket channel not initialized. Call connect() first.');
    }
    return _channel!;
  }

  /// Establishes a WebSocket connection to the specified URI.
  /// The URI includes the access token for authentication.
  WebSocketChannel connect(String accessToken) {
    print("Creating WebSocket channel");
    _channel = WebSocketChannel.connect(
      Uri.parse(
        "wss://hangin-app-env.eba-hwfj6jrc.us-east-1.elasticbeanstalk.com/cable?access_token=$accessToken",
      ),
    );
    return _channel!;
  }

  /// Closes the WebSocket connection and disposes of the channel.
  void dispose() {
    _channel?.sink.close();
    _channel = null;
  }
}
