import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_socket_message.freezed.dart';
part 'stock_socket_message.g.dart';

@freezed
sealed class StockSocketMessage with _$StockSocketMessage {
  const factory StockSocketMessage.priceUpdate({
    required String type,
    required String stockCode,
    required double currentPrice,
    required double changeRate,
    required DateTime timestamp,
  }) = StockSocketMessagePriceUpdate;

  factory StockSocketMessage.fromJson(Map<String, dynamic> json) =>
      _$StockSocketMessageFromJson(json);
}
