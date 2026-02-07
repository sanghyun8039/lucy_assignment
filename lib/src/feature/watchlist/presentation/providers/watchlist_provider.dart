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
  final AlertType
  type; // The *effective* type for color (upper->red, lower->blue)

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

  // 알림 스트림 컨트롤러
  final _alertController = StreamController<AlertEvent>.broadcast();
  Stream<AlertEvent> get alertStream => _alertController.stream;

  // 이미 알림을 보낸 종목/조건 추적 (단순 중복 방지)
  // key: "stockCode_targetPrice_alertType"
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
    // Watchlist 변경 감지
    _watchlistSubscription = _getWatchStreamUseCase().listen((watchlist) {
      _watchlist = watchlist;
      _watchedStockCodes.clear();
      _watchedStockCodes.addAll(watchlist.map((item) => item.stockCode));

      // watchlist가 변경되면 기존 알림 상태 초기화 (또는 로직에 따라 유지)
      // 여기서는 목록이 바뀌면 다시 알림 받을 수 있게 일부러 초기화하지 않음.
      // 다만, 항목이 삭제되면 해당 알림 상태도 지워주는게 좋음.

      notifyListeners();
    });

    // 실시간 가격 변경 감지
    _priceSubscription = _getPriceStreamUseCase().listen((stock) {
      _priceMap[stock.stockCode] = stock;
      _checkAlerts(stock);
      notifyListeners();
    });
  }

  void _checkAlerts(StockEntity stock) {
    // 현재 수신된 주식 코드를 가진 관심 종목들을 찾음
    final items = _watchlist.where((item) => item.stockCode == stock.stockCode);

    for (var item in items) {
      if (item.targetPrice == null) continue;

      bool trigger = false;
      AlertType effectiveType = item.alertType;
      final target = item.targetPrice!;
      final current = stock.currentPrice;

      // Check specific conditions
      if (item.alertType == AlertType.upper) {
        if (current >= target) {
          trigger = true;
          effectiveType = AlertType.upper; // Red
        }
      } else if (item.alertType == AlertType.lower) {
        if (current <= target) {
          trigger = true;
          effectiveType = AlertType.lower; // Blue
        }
      } else if (item.alertType == AlertType.bidir) {
        // BIDIR logic
        if (current >= target) {
          trigger = true;
          effectiveType = AlertType.upper; // Treat as Upper (Red)
        } else if (current <= target) {
          trigger = true;
          effectiveType = AlertType.lower; // Treat as Lower (Blue)
        }
      }

      if (trigger) {
        // Key includes effectiveType to distinguish upper/lower crossing in bidir logic if needed,
        // but typically bidir alerts once per target regardless of direction?
        // Let's use item.alertType in key to simple lock per item configuration.
        // Wait, if bidir, and it crosses up, we alert. If it then crosses down, we might want to alert again?
        // User requested "BIDIR also needed".
        // Let's stick to unique key per item config to avoid spam.
        final alertKey =
            "${item.stockCode}_${item.targetPrice}_${item.alertType}";

        if (!_alertedConditions.contains(alertKey)) {
          _alertedConditions.add(alertKey);

          final directionText = effectiveType == AlertType.upper ? '이상' : '이하';
          _alertController.add(
            AlertEvent(
              '${stock.stockName ?? stock.stockCode} 목표가 도달! ($directionText $target원)',
              effectiveType,
            ),
          );
        }
      } else {
        // Reset condition if price moves away
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
