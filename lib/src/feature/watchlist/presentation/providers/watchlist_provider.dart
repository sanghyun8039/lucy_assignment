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
import 'package:rxdart/rxdart.dart';

import 'package:lucy_assignment/src/feature/watchlist/domain/entities/alert_event.dart';

class WatchlistProvider extends ChangeNotifier {
  final GetWatchStreamUseCase _getWatchStreamUseCase;
  final AddWatchlistItemUseCase _addWatchlistItemUseCase;
  final RemoveWatchlistItemUseCase _removeWatchlistItemUseCase;
  final GetPriceStreamUseCase _getPriceStreamUseCase;
  final GetStockUseCase _getStockUseCase;

  final CompositeSubscription _subscriptions = CompositeSubscription();

  List<WatchlistItem> _watchlist = [];
  final Set<String> _watchedStockCodes = {};
  final Map<String, StockEntity> _priceMap = {};
  final Set<String> _alertedConditions = {};

  final _alertController = StreamController<AlertEvent>.broadcast();
  Stream<AlertEvent> get alertStream => _alertController.stream;
  List<WatchlistItem> get watchlist => _watchlist;

  final Map<String, StreamController<StockEntity>> _stockControllers = {};
  final Map<String, Stream<StockEntity>> _throttledStreams = {};

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
    _getWatchStreamUseCase()
        .listen((watchlist) {
          _watchlist = watchlist;
          _watchedStockCodes.clear();
          _watchedStockCodes.addAll(watchlist.map((item) => item.stockCode));

          _fetchMissingInitialData(watchlist);

          notifyListeners();
        })
        .addTo(_subscriptions);

    final priceStream = _getPriceStreamUseCase().asBroadcastStream();

    priceStream
        .doOnData(_updateLocalState)
        .doOnData(_dispatchToIndividual)
        .listen(null)
        .addTo(_subscriptions);

    priceStream
        .withLatestFrom<List<WatchlistItem>, List<AlertEvent>>(
          _getWatchStreamUseCase(),
          (price, watchlist) => _generateAlerts(price, watchlist),
        )
        .expand((events) => events)
        .listen((event) {
          _alertController.add(event);
        })
        .addTo(_subscriptions);
  }

  void _updateLocalState(StockEntity priceUpdate) {
    final existingStock = _priceMap[priceUpdate.stockCode];
    final mergedStock =
        existingStock?.copyWith(
          currentPrice: priceUpdate.currentPrice,
          changeRate: priceUpdate.changeRate,
          timestamp: priceUpdate.timestamp,
        ) ??
        priceUpdate;
    _priceMap[mergedStock.stockCode] = mergedStock;
  }

  void _dispatchToIndividual(StockEntity priceUpdate) {
    final mergedData = _priceMap[priceUpdate.stockCode]!;

    if (_stockControllers.containsKey(mergedData.stockCode)) {
      _stockControllers[mergedData.stockCode]!.add(mergedData);
    }
  }

  List<AlertEvent> _generateAlerts(
    StockEntity stock,
    List<WatchlistItem> watchlist,
  ) {
    final events = <AlertEvent>[];
    final items = watchlist.where((item) => item.stockCode == stock.stockCode);

    final cachedStock = _priceMap[stock.stockCode];
    final stockName =
        cachedStock?.stockName ?? stock.stockName ?? stock.stockCode;

    for (var item in items) {
      if (item.targetPrice == null) continue;

      bool trigger = false;
      AlertType effectiveType = item.alertType;
      final target = item.targetPrice!;
      final current = stock.currentPrice;

      if (item.alertType == AlertType.upper && current >= target) {
        trigger = true;
      } else if (item.alertType == AlertType.lower && current <= target) {
        trigger = true;
      } else if (item.alertType == AlertType.bidir) {
        if (current >= target) {
          trigger = true;
          effectiveType = AlertType.upper;
        } else if (current <= target) {
          trigger = true;
          effectiveType = AlertType.lower;
        }
      }

      final alertKey = "${item.stockCode}_${target}_${item.alertType}";

      if (trigger) {
        if (!_alertedConditions.contains(alertKey)) {
          _alertedConditions.add(alertKey);
          events.add(
            AlertEvent(
              stockName: stockName,
              targetPrice: target,
              type: effectiveType,
              stockCode: stock.stockCode,
            ),
          );
        }
      } else {
        _alertedConditions.remove(alertKey);
      }
    }
    return events;
  }

  Future<void> _fetchMissingInitialData(List<WatchlistItem> watchlist) async {
    for (var item in watchlist) {
      if (!_priceMap.containsKey(item.stockCode)) {
        final stock = await _getStockUseCase(item.stockCode);
        if (stock != null) {
          _priceMap[item.stockCode] = stock;
        }
      }
    }
    notifyListeners();
  }

  Stream<StockEntity> getStockStream(String stockCode) {
    if (_throttledStreams.containsKey(stockCode)) {
      return _throttledStreams[stockCode]!;
    }
    if (!_stockControllers.containsKey(stockCode)) {
      final controller = StreamController<StockEntity>.broadcast();
      _stockControllers[stockCode] = controller;

      if (_priceMap.containsKey(stockCode)) {
        Future.microtask(() {
          if (!controller.isClosed) controller.add(_priceMap[stockCode]!);
        });
      }
    }

    final throttledStream = _stockControllers[stockCode]!.stream
        .throttleTime(
          const Duration(milliseconds: 500),
          trailing: true,
          leading: true,
        )
        .asBroadcastStream();

    _throttledStreams[stockCode] = throttledStream;

    return throttledStream;
  }

  bool isWatched(String stockCode) {
    return _watchedStockCodes.contains(stockCode);
  }

  StockEntity? getPrice(String stockCode) {
    return _priceMap[stockCode];
  }

  Future<void> addWatchlistItem(WatchlistItem item) async {
    await _addWatchlistItemUseCase(item);
  }

  Future<void> removeWatchlistItem(String stockCode) async {
    await _removeWatchlistItemUseCase(stockCode);
    _alertedConditions.removeWhere((key) => key.startsWith("${stockCode}_"));
  }

  @override
  void dispose() {
    _subscriptions.dispose();

    for (var controller in _stockControllers.values) {
      controller.close();
    }
    _stockControllers.clear();
    _alertController.close();
    _throttledStreams.clear();
    super.dispose();
  }
}
