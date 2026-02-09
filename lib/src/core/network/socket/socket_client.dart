import 'dart:async';

/// Abstract interface for socket communication.
/// Decouples the underlying socket implementation from the data layer.
abstract interface class SocketClient {
  /// Stream of raw messages received from the socket.
  /// Typically returns JSON String or Map<String, dynamic>.
  Stream<dynamic> get messageStream;

  /// Connects to the socket server.
  void connect();

  /// Disconnects from the socket server.
  void disconnect();

  /// Subscribes to a specific topic or channel.
  /// [data] can be used to pass initial state or parameters (e.g. initial price for mock).
  void subscribe(String topic, {dynamic data});

  /// Unsubscribes from a specific topic or channel .
  void unsubscribe(String topic);
}
