import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_entity.freezed.dart';

@freezed
abstract class StockEntity with _$StockEntity {
  const factory StockEntity({
    required String stockCode,
    required String stockName,
    required int currentPrice,
    required double changeRate,
    required DateTime? timestamp,
  }) = _StockEntity;
}
