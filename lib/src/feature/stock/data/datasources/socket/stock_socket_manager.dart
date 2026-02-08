import 'dart:async';
import 'dart:math';

import 'package:lucy_assignment/src/feature/stock/data/models/socket/stock_socket_message.dart';
import 'package:rxdart/rxdart.dart';

class StockSocketManager {
  final _messageSubject = BehaviorSubject<StockSocketMessage>();
  Stream<StockSocketMessage> get messageStream => _messageSubject.stream;

  // Mock용 타이머 관리
  final Map<String, Timer?> _timers = {};
  final Random _random = Random();

  void connect() {
    print('StockSocketManager: Connected');
    // 실제 연결 로직은 여기에 구현
  }

  void disconnect() {
    print('StockSocketManager: Disconnected');
    for (var timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
    _subscriberCount.clear(); // ✅ 추가: 카운트도 초기화
    _messageSubject.close();
  }

  // 구독자 수 관리 (Reference Waiting)
  final Map<String, int> _subscriberCount = {};

  void subscribeToStock(String stockCode, double currentPrice) {
    _subscriberCount[stockCode] = (_subscriberCount[stockCode] ?? 0) + 1;
    print(
      'StockSocketManager: Subscribe to $stockCode (Count: ${_subscriberCount[stockCode]})',
    );

    if (_timers.containsKey(stockCode)) return;

    double lastPrice = currentPrice;

    final interval = Duration(milliseconds: 500 + _random.nextInt(1500));

    _timers[stockCode] = Timer.periodic(interval, (timer) {
      if (_messageSubject.isClosed) {
        timer.cancel();
        return;
      }

      final volatility = (_random.nextDouble() * 0.02) - 0.01; // -1% ~ +1%
      lastPrice = lastPrice * (1 + volatility);
      final changeRate = volatility * 100;

      final message = StockSocketMessage.priceUpdate(
        type: 'price_update',
        stockCode: stockCode,
        currentPrice: lastPrice,
        changeRate: changeRate,
        timestamp: DateTime.now(),
      );

      _messageSubject.add(message);
    });
  }

  void unsubscribeFromStock(String stockCode) {
    if (!_subscriberCount.containsKey(stockCode)) return;

    _subscriberCount[stockCode] = (_subscriberCount[stockCode] ?? 0) - 1;
    print(
      'StockSocketManager: Unsubscribe from $stockCode (Count: ${_subscriberCount[stockCode]})',
    );

    if (_subscriberCount[stockCode]! <= 0) {
      _timers[stockCode]?.cancel();
      _timers.remove(stockCode);
      _subscriberCount.remove(stockCode);
    }
  }
}
