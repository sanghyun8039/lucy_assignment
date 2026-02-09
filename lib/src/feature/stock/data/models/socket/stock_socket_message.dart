import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_socket_message.freezed.dart';
part 'stock_socket_message.g.dart';

@Freezed(unionKey: 'type')
sealed class StockSocketMessage with _$StockSocketMessage {
  // 1. 호가(주가) 업데이트
  @FreezedUnionValue('price_update')
  const factory StockSocketMessage.priceUpdate({
    required String stockCode,
    required double currentPrice,
    required double changeRate,
    required DateTime timestamp,
  }) = StockSocketMessagePriceUpdate;

  // 2. 체결 정보 (예시 - 확장성 증명용)
  @FreezedUnionValue('trade_execution')
  const factory StockSocketMessage.tradeExecution({
    required String stockCode,
    required double price,
    required int volume,
    required DateTime timestamp,
  }) = StockSocketMessageTradeExecution;

  factory StockSocketMessage.fromJson(Map<String, dynamic> json) =>
      _$StockSocketMessageFromJson(json);
}
