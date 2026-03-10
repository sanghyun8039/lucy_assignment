import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';

part 'watchlist_model.freezed.dart';
part 'watchlist_model.g.dart';

@freezed
@HiveType(typeId: 0, adapterName: 'WatchlistModelAdapter')
abstract class WatchlistModel with _$WatchlistModel {
  const WatchlistModel._();
  const factory WatchlistModel({
    @HiveField(0) required String stockCode,
    @HiveField(1) int? targetPrice,
    @HiveField(2) @Default(AlertType.upper) AlertType alertType,
    @HiveField(3) required DateTime createdAt,
  }) = _WatchlistModel;

  factory WatchlistModel.fromJson(Map<String, dynamic> json) =>
      _$WatchlistModelFromJson(json);

  factory WatchlistModel.fromEntity(WatchlistItem entity) => WatchlistModel(
    stockCode: entity.stockCode,
    targetPrice: entity.targetPrice,
    alertType: entity.alertType,
    createdAt: entity.createdAt,
  );

  WatchlistItem toEntity() {
    return WatchlistItem(
      stockCode: stockCode,
      targetPrice: targetPrice,
      alertType: alertType,
      createdAt: createdAt,
    );
  }
}
