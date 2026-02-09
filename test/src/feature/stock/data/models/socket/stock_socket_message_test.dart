import 'package:flutter_test/flutter_test.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/socket/stock_socket_message.dart';

void main() {
  group('StockSocketMessage', () {
    test('fromJson validates price_update message', () {
      final json = {
        "type": "price_update",
        "stockCode": "005930",
        "currentPrice": 72500.0,
        "changeRate": 1.25,
        "timestamp": "2024-01-15T09:30:00.000Z",
      };

      final message = StockSocketMessage.fromJson(json);

      expect(message, isA<StockSocketMessagePriceUpdate>());
      final priceUpdate = message as StockSocketMessagePriceUpdate;
      // expect(priceUpdate.type, 'price_update'); // type field is handled by union internals
      expect(priceUpdate.stockCode, '005930');
      expect(priceUpdate.currentPrice, 72500.0);
      expect(priceUpdate.changeRate, 1.25);
      expect(priceUpdate.timestamp, DateTime.utc(2024, 1, 15, 9, 30));
    });

    test('toJson validates price_update message', () {
      final message = StockSocketMessage.priceUpdate(
        // type: 'price_update', // Handled by Freezed
        stockCode: '005930',
        currentPrice: 72500,
        changeRate: 1.25,
        timestamp: DateTime.utc(2024, 1, 15, 9, 30),
      );

      final json = message.toJson();

      expect(json['type'], 'price_update');
      expect(json['stockCode'], '005930');
      expect(json['currentPrice'], 72500);
      expect(json['changeRate'], 1.25);
      expect(json['timestamp'], '2024-01-15T09:30:00.000Z');
    });
  });
}
