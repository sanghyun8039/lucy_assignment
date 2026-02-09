import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/add_watchlist_item_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/get_watch_stream_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/remove_watchlist_item_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/get_price_stream_usecase.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/domain/usecases/get_stock_usecase.dart';
import 'package:lucy_assignment/src/core/utils/app_formatters.dart';
import 'package:rxdart/rxdart.dart';

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
  final GetStockUseCase _getStockUseCase;

  StreamSubscription<List<WatchlistItem>>? _watchlistSubscription;
  StreamSubscription<StockEntity>? _priceSubscription;

  List<WatchlistItem> _watchlist = [];
  final Set<String> _watchedStockCodes = {};

  final _alertController = StreamController<AlertEvent>.broadcast();
  Stream<AlertEvent> get alertStream => _alertController.stream;
  final Set<String> _alertedConditions = {};

  final Map<String, StockEntity> _priceMap = {};
  final Map<String, StreamController<StockEntity>> _stockControllers = {};
  final Map<String, Stream<StockEntity>> _throttledStreams = {};

  // Broadcast stream for price updates
  final _priceStreamController = StreamController<StockEntity>.broadcast();
  Stream<StockEntity> get priceStream => _priceStreamController.stream;
  WatchlistProvider({
    required GetWatchStreamUseCase getWatchStreamUseCase,
    required AddWatchlistItemUseCase addWatchlistItemUseCase,
    required RemoveWatchlistItemUseCase removeWatchlistItemUseCase,
    required GetPriceStreamUseCase getPriceStreamUseCase,
    required GetStockUseCase getStockUseCase,
  }) : _getWatchStreamUseCase = getWatchStreamUseCase,
       _addWatchlistItemUseCase = addWatchlistItemUseCase,
       _removeWatchlistItemUseCase = removeWatchlistItemUseCase,
       _getPriceStreamUseCase = getPriceStreamUseCase,
       _getStockUseCase = getStockUseCase {
    _init();
  }

  void _init() {
    _watchlistSubscription = _getWatchStreamUseCase().listen((watchlist) async {
      _watchlist = watchlist;
      _watchedStockCodes.clear();
      _watchedStockCodes.addAll(watchlist.map((item) => item.stockCode));

      // Fetch initial data for items not in priceMap
      for (var item in watchlist) {
        if (!_priceMap.containsKey(item.stockCode)) {
          final stock = await _getStockUseCase(item.stockCode);
          if (stock != null) {
            _priceMap[item.stockCode] = stock;
          }
        }
      }

      notifyListeners();
    });

    _priceSubscription = _getPriceStreamUseCase().listen((priceUpdate) {
      final existingStock = _priceMap[priceUpdate.stockCode];

      final StockEntity mergedStock;
      if (existingStock != null) {
        // Merge dynamic data into existing static data
        mergedStock = existingStock.copyWith(
          currentPrice: priceUpdate.currentPrice,
          changeRate: priceUpdate.changeRate,
          timestamp: priceUpdate.timestamp,
        );
      } else {
        mergedStock = priceUpdate;
      }

      _priceMap[mergedStock.stockCode] = mergedStock;
      _checkAlerts(mergedStock);
      // ✅ 변경 2: 전체 방송 대신, 해당 종목을 듣고 있는 컨트롤러에만 쏙 넣어줍니다.
      // 리스너가 없는 종목의 업데이트는 무시되어 성능이 절약됩니다.
      if (_stockControllers.containsKey(mergedStock.stockCode)) {
        _stockControllers[mergedStock.stockCode]!.add(mergedStock);
      }
    });
  }

  Stream<StockEntity> getStockStream(String stockCode) {
    if (_throttledStreams.containsKey(stockCode)) {
      return _throttledStreams[stockCode]!;
    }
    if (!_stockControllers.containsKey(stockCode)) {
      final controller = StreamController<StockEntity>.broadcast();
      _stockControllers[stockCode] = controller;

      // 초기값 주입
      if (_priceMap.containsKey(stockCode)) {
        Future.microtask(() {
          if (!controller.isClosed) controller.add(_priceMap[stockCode]!);
        });
      }
    }

    // 3. 스로틀링 스트림 생성 및 'Broadcast' 변환
    // asBroadcastStream()을 해야 여러 곳(위젯)에서 구독해도 에러가 안 납니다.
    final throttledStream = _stockControllers[stockCode]!.stream
        .throttleTime(
          const Duration(milliseconds: 500),
          trailing: true,
          leading: true, // ✅ 수정 제안: true로 하면 첫 데이터가 0.5초 기다리지 않고 즉시 뜸 (반응성 향상)
        )
        .asBroadcastStream();

    // 4. 캐시에 저장
    _throttledStreams[stockCode] = throttledStream;

    return throttledStream;
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
              '${stock.stockName ?? stock.stockCode} 목표가 도달! ($directionText ${AppFormatters.comma.format(target)} KRW)',
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
    for (var controller in _stockControllers.values) {
      controller.close();
    }
    _stockControllers.clear();
    _watchlistSubscription?.cancel();
    _priceSubscription?.cancel();
    _alertController.close();
    _throttledStreams.clear(); // 캐시도 비움
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
