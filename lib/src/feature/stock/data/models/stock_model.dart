import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucy_assignment/src/core/utils/parsers.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

part 'stock_model.freezed.dart';
part 'stock_model.g.dart';

@freezed
abstract class StockModel with _$StockModel {
  const StockModel._();
  factory StockModel({
    @JsonKey(name: 'mksc_shrn_iscd') required String stockCode,
    @JsonKey(name: 'hts_kor_isnm') required String stockName, // 종목명 추가 권장
    @JsonKey(name: 'stck_prpr', fromJson: Parsers.parsePrice)
    required int currentPrice,
    @JsonKey(name: 'prdy_ctrt', fromJson: Parsers.parseRate)
    required double changeRate,
    @Default(null) DateTime? timestamp, // JSON에 없으므로 Default 또는 수동 주입
  }) = _StockModel;

  factory StockModel.fromJson(Map<String, dynamic> json) =>
      _$StockModelFromJson(json);

  StockEntity toEntity() {
    return StockEntity(
      stockCode: stockCode,
      stockName: stockName,
      currentPrice: currentPrice,
      changeRate: changeRate,
      timestamp: timestamp,
    );
  }
}
