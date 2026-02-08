import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucy_assignment/src/core/utils/parsers.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

part 'stock_model.freezed.dart';
part 'stock_model.g.dart';

@freezed
abstract class StockModel with _$StockModel {
  const StockModel._();
  factory StockModel({
    String? type,
    @JsonKey(name: 'mksc_shrn_iscd') required String stockCode,
    @JsonKey(name: 'hts_kor_isnm') String? stockName, // 종목명 추가 권장
    @JsonKey(name: 'stck_prpr', fromJson: Parsers.parsePrice)
    required int currentPrice,
    @JsonKey(name: 'prdy_ctrt', fromJson: Parsers.parseRate)
    required double changeRate,
    @JsonKey(name: 'data_rank', fromJson: Parsers.parseStringToInt)
    required int rank,
    @Default("No summary available") String summary,
    @JsonKey(name: 'acml_vol', fromJson: Parsers.parseStringToInt)
    required int accumulatedVolume,
    @JsonKey(name: 'stck_avls', fromJson: Parsers.parseStringToInt)
    required int marketCap,
    @JsonKey(name: 'lstn_stcn', fromJson: Parsers.parseStringToInt)
    required int listedShares,
    @JsonKey(name: 'mrkt_whol_avls_rlim', fromJson: Parsers.parseStringToDouble)
    required double marketWeight,
    @Default(null) DateTime? timestamp, // JSON에 없으므로 Default 또는 수동 주입
  }) = _StockModel;

  factory StockModel.fromJson(Map<String, dynamic> json) =>
      _$StockModelFromJson(json);

  StockEntity toEntity() {
    return StockEntity(
      type: type,
      stockCode: stockCode,
      stockName: stockName,
      currentPrice: currentPrice,
      changeRate: changeRate,
      rank: rank,
      summary: summary,
      accumulatedVolume: accumulatedVolume,
      marketCap: marketCap,
      listedShares: listedShares,
      marketWeight: marketWeight,
      timestamp: timestamp,
    );
  }
}
