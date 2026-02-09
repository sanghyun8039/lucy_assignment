import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/network/socket/socket_client.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/socket/stock_socket_message.dart';

abstract interface class StockRealtimeDataSource {
  Stream<StockSocketMessage> get messageStream;
  void connect();
  void disconnect();
  void subscribeToStock(String stockCode, double currentPrice);
  void unsubscribeFromStock(String stockCode);
}

class StockRealtimeDataSourceImpl implements StockRealtimeDataSource {
  final SocketClient _socketClient;

  StockRealtimeDataSourceImpl(this._socketClient);

  @override
  Stream<StockSocketMessage> get messageStream {
    return _socketClient.messageStream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          try {
            final Map<String, dynamic> json;
            if (data is String) {
              json = jsonDecode(data);
            } else if (data is Map<String, dynamic>) {
              json = data;
            } else {
              return; // Unknown data type
            }

            final message = StockSocketMessage.fromJson(json);
            sink.add(message);
          } catch (e) {
            debugPrint('Error parsing socket message: $e');
          }
        },
      ),
    );
  }

  @override
  void connect() {
    _socketClient.connect();
  }

  @override
  void disconnect() {
    _socketClient.disconnect();
  }

  @override
  void subscribeToStock(String stockCode, double currentPrice) {
    _socketClient.subscribe(stockCode, data: currentPrice);
  }

  @override
  void unsubscribeFromStock(String stockCode) {
    _socketClient.unsubscribe(stockCode);
  }
}
