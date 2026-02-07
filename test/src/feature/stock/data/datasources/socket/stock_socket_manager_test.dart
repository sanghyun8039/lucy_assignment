import 'package:flutter_test/flutter_test.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/socket/stock_socket_manager.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/socket/stock_socket_message.dart';

void main() {
  late StockSocketManager socketManager;

  setUp(() {
    socketManager = StockSocketManager();
    socketManager.connect();
  });

  tearDown(() {
    socketManager.disconnect();
  });

  test('Should emit price updates when subscribed', () async {
    const stockCode = '005930';
    const initialPrice = 70000.0;

    socketManager.subscribeToStock(stockCode, initialPrice);

    final event = await socketManager.messageStream.first;

    expect(event, isA<StockSocketMessagePriceUpdate>());
    final update = event as StockSocketMessagePriceUpdate;
    expect(update.stockCode, stockCode);
    expect(update.type, 'price_update');
  });
}
