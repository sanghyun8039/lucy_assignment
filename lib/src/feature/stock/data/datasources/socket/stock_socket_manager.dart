import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:lucy_assignment/src/feature/stock/data/models/socket/stock_socket_message.dart';
import 'package:rxdart/rxdart.dart';

class StockSocketManager {
  // 실제 소켓 연결 대신 BehaviorSubject로 데이터 스트림 흉내
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
    _messageSubject.close();
  }

  void subscribeToStock(String stockCode, double currentPrice) {
    if (_timers.containsKey(stockCode)) return;

    print('StockSocketManager: Subscribe to $stockCode');

    // 변동된 가격을 누적하기 위해 변수 사용
    double lastPrice = currentPrice;

    // 모의 데이터 생성 주기
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
        currentPrice: lastPrice, // 소수점 로직이 필요하면 조정
        changeRate: changeRate,
        timestamp: DateTime.now(),
      );

      _messageSubject.add(message);
    });
  }

  void unsubscribeFromStock(String stockCode) {
    print('StockSocketManager: Unsubscribe from $stockCode');
    _timers[stockCode]?.cancel();
    _timers.remove(stockCode);
  }
}
