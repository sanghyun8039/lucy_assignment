import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucy_assignment_1/src/feature/stock/domain/entities/stock_entity.dart';

part 'stock_model.freezed.dart';
part 'stock_model.g.dart';

@freezed
abstract class StockModel with _$StockModel {
  const StockModel._();
  const factory StockModel({
    required String stockCode,
    required int currentPrice,
    required double changeRate,
    required DateTime timestamp,
  }) = _StockModel;

  factory StockModel.fromJson(Map<String, dynamic> json) =>
      _$StockModelFromJson(json);

  StockEntity toEntity() {
    return StockEntity(
      stockCode: stockCode,
      currentPrice: currentPrice,
      changeRate: changeRate,
      timestamp: timestamp,
    );
  }
}
