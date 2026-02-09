import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_entity.freezed.dart';

@freezed
abstract class StockEntity with _$StockEntity {
  const factory StockEntity({
    required String stockCode,
    String? stockName,
    @Default(0) int rank,
    required int currentPrice,
    required double changeRate,
    @Default("No summary available") String summary,
    @Default(0) int accumulatedVolume,
    @Default(0) int marketCap,
    @Default(0) int listedShares,
    @Default(0.0) double marketWeight,
    required DateTime? timestamp,
  }) = _StockEntity;
}
