import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_price_update.freezed.dart';

/// Domain 레이어의 순수 값 객체.
/// Presentation이 실시간 가격을 구독할 때 이 타입만 알면 됩니다.
@freezed
abstract class StockPriceUpdate with _$StockPriceUpdate {
  const factory StockPriceUpdate({
    required String stockCode,
    required double currentPrice,
    required double changeRate,
    required DateTime timestamp,
  }) = _StockPriceUpdate;
}
