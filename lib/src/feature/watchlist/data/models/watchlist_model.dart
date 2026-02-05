import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';

part 'watchlist_model.freezed.dart';
part 'watchlist_model.g.dart';

@freezed
abstract class WatchlistModel with _$WatchlistModel {
  const WatchlistModel._();
  const factory WatchlistModel({
    required String stockCode,
    int? targetPrice,
    required AlertType alertType,
    required DateTime createdAt,
  }) = _WatchlistModel;

  factory WatchlistModel.fromJson(Map<String, dynamic> json) =>
      _$WatchlistModelFromJson(json);

  WatchlistItem toEntity() {
    return WatchlistItem(
      stockCode: stockCode,
      targetPrice: targetPrice,
      alertType: alertType,
      createdAt: createdAt,
    );
  }
}
