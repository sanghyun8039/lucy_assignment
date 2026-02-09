import 'dart:async';

abstract interface class SocketClient {
  Stream<dynamic> get messageStream;

  void connect();

  void disconnect();

  void subscribe(String topic, {dynamic data});

  void unsubscribe(String topic);
}
