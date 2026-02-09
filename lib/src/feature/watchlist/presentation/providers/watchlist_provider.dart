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

class AlertEvent {
  final String stockName;
  final int targetPrice;
  final AlertType type;
  final String stockCode;

  AlertEvent({
    required this.stockName,
    required this.targetPrice,
    required this.type,
    required this.stockCode,
  });
}

class WatchlistProvider extends ChangeNotifier {
  // UseCases
  final GetWatchStreamUseCase _getWatchStreamUseCase;
  final AddWatchlistItemUseCase _addWatchlistItemUseCase;
  final RemoveWatchlistItemUseCase _removeWatchlistItemUseCase;
  final GetPriceStreamUseCase _getPriceStreamUseCase;
  final GetStockUseCase _getStockUseCase;

  // ✅ RxDart: 모든 구독을 한 번에 관리하는 가방
  final CompositeSubscription _subscriptions = CompositeSubscription();

  // State
  List<WatchlistItem> _watchlist = [];
  final Set<String> _watchedStockCodes = {};
  final Map<String, StockEntity> _priceMap = {};
  final Set<String> _alertedConditions = {};

  // Controllers & Streams
  final _alertController = StreamController<AlertEvent>.broadcast();
  Stream<AlertEvent> get alertStream => _alertController.stream;

  // O(1) 성능을 위한 직접 배송용 컨트롤러들
  final Map<String, StreamController<StockEntity>> _stockControllers = {};
  final Map<String, Stream<StockEntity>> _throttledStreams = {};

  // 생성자
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
    // 1. 관심 목록 관리 (Watchlist Stream)
    _getWatchStreamUseCase()
        .listen((watchlist) {
          _watchlist = watchlist;
          _watchedStockCodes.clear();
          _watchedStockCodes.addAll(watchlist.map((item) => item.stockCode));

          // 초기 데이터 로딩 (필요한 경우만)
          _fetchMissingInitialData(watchlist);

          notifyListeners();
        })
        .addTo(_subscriptions); // ✅ 구독 가방에 담기

    // 2. 가격 데이터 처리 파이프라인 (Price Stream Pipeline)
    // RxDart를 사용하여 로직을 단계별로 분리
    final priceStream = _getPriceStreamUseCase().asBroadcastStream();

    priceStream
        .doOnData(_updateLocalState) // 2-1. 로컬 상태(_priceMap) 업데이트
        .doOnData(_dispatchToIndividual) // 2-2. 개별 종목 컨트롤러로 배송
        .listen(null) // 그냥 흐르게 둠 (데이터 소비)
        .addTo(_subscriptions);

    // 3. 알림 로직 분리 (Alert Stream) - 여기가 핵심!
    // 가격이 들어올 때마다(trigger), 최신 관심목록(reference)을 참조하여 알림 생성
    priceStream
        .withLatestFrom<List<WatchlistItem>, List<AlertEvent>>(
          _getWatchStreamUseCase(), // 관심 목록 스트림 참조
          (price, watchlist) => _generateAlerts(price, watchlist),
        )
        .expand((events) => events) // List<AlertEvent> -> 개별 Event로 풀기
        .listen((event) {
          _alertController.add(event); // 최종적으로 알림 발송
        })
        .addTo(_subscriptions);
  }
  // --- Helper Methods (로직 분리) ---

  // 2-1. 상태 업데이트 (Side Effect)
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

  // 2-2. 개별 배송 (O(1) Dispatch)
  void _dispatchToIndividual(StockEntity priceUpdate) {
    // 맵에 이미 업데이트된 데이터가 있으므로 그걸 가져옴 (Merge된 데이터)
    final mergedData = _priceMap[priceUpdate.stockCode]!;

    if (_stockControllers.containsKey(mergedData.stockCode)) {
      _stockControllers[mergedData.stockCode]!.add(mergedData);
    }
  }

  // 3. 알림 생성 로직 (Pure Function에 가까움)
  List<AlertEvent> _generateAlerts(
    StockEntity stock,
    List<WatchlistItem> watchlist,
  ) {
    final events = <AlertEvent>[];
    // 해당 종목의 관심 항목 찾기 (여러 개일 수도 있다고 가정)
    final items = watchlist.where((item) => item.stockCode == stock.stockCode);

    for (var item in items) {
      if (item.targetPrice == null) continue;

      bool trigger = false;
      AlertType effectiveType = item.alertType;
      final target = item.targetPrice!;
      final current = stock.currentPrice;

      // ... (기존 알림 조건 비교 로직 동일) ...
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
              stockName: stock.stockName ?? stock.stockCode,
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
    // 데이터가 늦게 로딩되면 화면 갱신 필요
    notifyListeners();
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

          _alertController.add(
            AlertEvent(
              stockName: stock.stockName ?? stock.stockCode,
              targetPrice: target,
              type: effectiveType,
              stockCode: stock.stockCode,
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
    // ✅ RxDart: 가방만 비우면 모든 구독이 취소됨
    _subscriptions.dispose();

    // 컨트롤러 정리
    for (var controller in _stockControllers.values) {
      controller.close();
    }
    _stockControllers.clear();
    _alertController.close();
    _throttledStreams.clear();
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
