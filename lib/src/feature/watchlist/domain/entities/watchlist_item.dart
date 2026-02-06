import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';

part 'watchlist_item.freezed.dart';
part 'watchlist_item.g.dart';

@freezed
abstract class WatchlistItem with _$WatchlistItem {
  const factory WatchlistItem({
    required String stockCode,
    int? targetPrice,
    @Default(AlertType.upperLimit) AlertType alertType,
    required DateTime createdAt,
  }) = _WatchlistItem;

  factory WatchlistItem.fromJson(Map<String, dynamic> json) =>
      _$WatchlistItemFromJson(json);
}
