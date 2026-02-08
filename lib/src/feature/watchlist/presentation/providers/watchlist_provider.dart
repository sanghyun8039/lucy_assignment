import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/add_watchlist_item_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/get_watch_stream_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/remove_watchlist_item_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/get_price_stream_usecase.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class AlertEvent {
  final String message;
  final AlertType type;

  AlertEvent(this.message, this.type);
}

class WatchlistProvider extends ChangeNotifier {
  final GetWatchStreamUseCase _getWatchStreamUseCase;
  final AddWatchlistItemUseCase _addWatchlistItemUseCase;
  final RemoveWatchlistItemUseCase _removeWatchlistItemUseCase;

  final GetPriceStreamUseCase _getPriceStreamUseCase;

  StreamSubscription<List<WatchlistItem>>? _watchlistSubscription;
  StreamSubscription<StockEntity>? _priceSubscription;

  List<WatchlistItem> _watchlist = [];
  final Set<String> _watchedStockCodes = {};

  final _alertController = StreamController<AlertEvent>.broadcast();
  Stream<AlertEvent> get alertStream => _alertController.stream;
  final Set<String> _alertedConditions = {};

  final Map<String, StockEntity> _priceMap = {};

  WatchlistProvider({
    required GetWatchStreamUseCase getWatchStreamUseCase,
    required AddWatchlistItemUseCase addWatchlistItemUseCase,
    required RemoveWatchlistItemUseCase removeWatchlistItemUseCase,
    required GetPriceStreamUseCase getPriceStreamUseCase,
  }) : _getWatchStreamUseCase = getWatchStreamUseCase,
       _addWatchlistItemUseCase = addWatchlistItemUseCase,
       _removeWatchlistItemUseCase = removeWatchlistItemUseCase,
       _getPriceStreamUseCase = getPriceStreamUseCase {
    _init();
  }

  void _init() {
    _watchlistSubscription = _getWatchStreamUseCase().listen((watchlist) {
      _watchlist = watchlist;
      _watchedStockCodes.clear();
      _watchedStockCodes.addAll(watchlist.map((item) => item.stockCode));

      notifyListeners();
    });

    _priceSubscription = _getPriceStreamUseCase().listen((stock) {
      _priceMap[stock.stockCode] = stock;
      _checkAlerts(stock);
      notifyListeners();
    });
  }

  void _checkAlerts(StockEntity stock) {
    final items = _watchlist.where((item) => item.stockCode == stock.stockCode);

    for (var item in items) {
      if (item.targetPrice == null) continue;

      bool trigger = false;
      AlertType effectiveType = item.alertType;
      final target = item.targetPrice!;
      final current = stock.currentPrice;

      if (item.alertType == AlertType.upper) {
        if (current >= target) {
          trigger = true;
          effectiveType = AlertType.upper;
        }
      } else if (item.alertType == AlertType.lower) {
        if (current <= target) {
          trigger = true;
          effectiveType = AlertType.lower;
        }
      } else if (item.alertType == AlertType.bidir) {
        if (current >= target) {
          trigger = true;
          effectiveType = AlertType.upper;
        } else if (current <= target) {
          trigger = true;
          effectiveType = AlertType.lower;
        }
      }

      if (trigger) {
        final alertKey =
            "${item.stockCode}_${item.targetPrice}_${item.alertType}";

        if (!_alertedConditions.contains(alertKey)) {
          _alertedConditions.add(alertKey);

          final directionText = effectiveType == AlertType.upper ? '이상' : '이하';
          _alertController.add(
            AlertEvent(
              '${stock.stockName ?? stock.stockCode} 목표가 도달! ($directionText $target KRW)',
              effectiveType,
            ),
          );
        }
      } else {
        final alertKey =
            "${item.stockCode}_${item.targetPrice}_${item.alertType}";
        if (_alertedConditions.contains(alertKey)) {
          _alertedConditions.remove(alertKey);
        }
      }
    }
  }

  @override
  void dispose() {
    _watchlistSubscription?.cancel();
    _priceSubscription?.cancel();
    _alertController.close();
    super.dispose();
  }

  /// 특정 종목이 관심 종목인지 여부 확인
  bool isWatched(String stockCode) {
    return _watchedStockCodes.contains(stockCode);
  }

  /// 특정 종목의 최신 가격 정보 가져오기 (없으면 null)
  StockEntity? getPrice(String stockCode) {
    return _priceMap[stockCode];
  }

  /// 관심 종목 추가
  Future<void> addWatchlistItem(WatchlistItem item) async {
    await _addWatchlistItemUseCase(item);
  }

  /// 관심 종목 제거
  Future<void> removeWatchlistItem(String stockCode) async {
    await _removeWatchlistItemUseCase(stockCode);
    // Remove alerts related to this stock
    _alertedConditions.removeWhere((key) => key.startsWith("${stockCode}_"));
  }

  List<WatchlistItem> get watchlist => _watchlist;
}
