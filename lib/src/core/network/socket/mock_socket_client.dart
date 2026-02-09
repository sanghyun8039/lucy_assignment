import 'dart:async';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:lucy_assignment/src/core/network/socket/socket_client.dart';

class MockSocketClient implements SocketClient {
  final _messageSubject = BehaviorSubject<dynamic>();

  @override
  Stream<dynamic> get messageStream => _messageSubject.stream;

  // Mock용 타이머 관리
  final Map<String, Timer?> _timers = {};
  final Random _random = Random();

  // 구독자 수 관리 (Reference Counting)
  final Map<String, int> _subscriberCount = {};

  @override
  void connect() {
    print('MockSocketClient: Connected');
  }

  @override
  void disconnect() {
    print('MockSocketClient: Disconnected');
    for (var timer in _timers.values) {
      timer?.cancel();
    }
    _timers.clear();
    _subscriberCount.clear();
    _messageSubject.close();
  }

  @override
  void subscribe(String topic, {dynamic data}) {
    _subscriberCount[topic] = (_subscriberCount[topic] ?? 0) + 1;
    print(
      'MockSocketClient: Subscribe to $topic (Count: ${_subscriberCount[topic]})',
    );

    if (_timers.containsKey(topic)) return;

    // 초기 가격 설정 (전달받은 데이터가 있으면 사용, 없으면 랜덤)
    double currentPrice = 10000.0;
    if (data is num) {
      currentPrice = data.toDouble();
    } else if (data is String) {
      currentPrice = double.tryParse(data) ?? 10000.0;
    } else {
      currentPrice = 10000.0 + _random.nextInt(50000);
    }

    _startSimulation(topic, currentPrice);
  }

  void _startSimulation(String stockCode, double startPrice) {
    double lastPrice = startPrice;

    final interval = Duration(milliseconds: 500 + _random.nextInt(1500));

    _timers[stockCode] = Timer.periodic(interval, (timer) {
      if (_messageSubject.isClosed) {
        timer.cancel();
        return;
      }

      final volatility = (_random.nextDouble() * 0.02) - 0.01; // -1% ~ +1%
      lastPrice = lastPrice * (1 + volatility);
      final changeRate = volatility * 100;

      // Raw JSON Map 생성 (type 필드 포함)
      final message = {
        'type': 'price_update',
        'stockCode': stockCode,
        'currentPrice': lastPrice,
        'changeRate': changeRate,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _messageSubject.add(message);
    });
  }

  @override
  void unsubscribe(String topic) {
    if (!_subscriberCount.containsKey(topic)) return;

    _subscriberCount[topic] = (_subscriberCount[topic] ?? 0) - 1;
    print(
      'MockSocketClient: Unsubscribe from $topic (Count: ${_subscriberCount[topic]})',
    );

    if (_subscriberCount[topic]! <= 0) {
      _timers[topic]?.cancel();
      _timers.remove(topic);
      _subscriberCount.remove(topic);
    }
  }
}
