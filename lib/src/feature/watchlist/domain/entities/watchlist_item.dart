import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';

part 'watchlist_item.freezed.dart';
part 'watchlist_item.g.dart';

@freezed
@HiveType(typeId: 0, adapterName: 'WatchlistItemAdapter')
abstract class WatchlistItem with _$WatchlistItem {
  const factory WatchlistItem({
    @HiveField(0) required String stockCode,
    @HiveField(1) int? targetPrice,
    @HiveField(2) @Default(AlertType.upper) AlertType alertType,
    @HiveField(3) required DateTime createdAt,
  }) = _WatchlistItem;
}
