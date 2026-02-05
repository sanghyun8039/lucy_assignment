import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lucy_assignment_1/src/core/constants/alert_type.dart';

part 'watchlist_item.freezed.dart';

@freezed
abstract class WatchlistItem with _$WatchlistItem {
  const factory WatchlistItem({
    required String stockCode,
    int? targetPrice,
    required AlertType alertType,
    required DateTime createdAt,
  }) = _WatchlistItem;
}
