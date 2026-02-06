import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/add_watchlist_item_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/get_watch_stream_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/remove_watchlist_item_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/get_price_stream_usecase.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class WatchlistProvider extends ChangeNotifier {
  final GetWatchStreamUseCase _getWatchStreamUseCase;
  final AddWatchlistItemUseCase _addWatchlistItemUseCase;
  final RemoveWatchlistItemUseCase _removeWatchlistItemUseCase;

  final GetPriceStreamUseCase _getPriceStreamUseCase;

  StreamSubscription<List<WatchlistItem>>? _watchlistSubscription;
  StreamSubscription<StockEntity>? _priceSubscription;

  List<WatchlistItem> _watchlist = [];
  final Set<String> _watchedStockCodes = {};

  // 가격 정보를 저장할 Map (StockCode -> StockEntity)
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
      notifyListeners();
    });

    // 실시간 가격 변경 감지
    _priceSubscription = _getPriceStreamUseCase().listen((stock) {
      _priceMap[stock.stockCode] = stock;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _watchlistSubscription?.cancel();
    _priceSubscription?.cancel();
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
  }

  List<WatchlistItem> get watchlist => _watchlist;
}
