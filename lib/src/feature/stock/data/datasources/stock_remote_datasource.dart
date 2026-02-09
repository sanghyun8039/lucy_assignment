import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_local_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/stock_model.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/realtime/stock_realtime_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/socket/stock_socket_message.dart';

abstract class StockRemoteDataSource {
  Stream<StockEntity> getPriceStream();
  void setWatchedStocks(List<String> stockCodes);
}

class MockStockRemoteDataSource implements StockRemoteDataSource {
  final StockLocalDataSource _localDataSource;
  final StockRealtimeDataSource _realtimeDataSource;

  // 감시 대상 종목 관리
  final BehaviorSubject<List<String>> _watchedStocksSubject =
      BehaviorSubject.seeded([]);

  // 현재 소켓에 실제 구독 요청된 종목들 (중복 호출 방지용)
  final Set<String> _activeSocketSubscriptions = {};

  // 캐시 데이터 (메모리)
  List<StockModel> _allStocksCache = [];
  bool _isInitialized = false;

  MockStockRemoteDataSource({
    required StockLocalDataSource localDataSource,
    required StockRealtimeDataSource realtimeDataSource,
  }) : _localDataSource = localDataSource,
       _realtimeDataSource = realtimeDataSource {
    _init();
  }

  void _init() async {
    _realtimeDataSource.connect();

    // 1. 로컬 데이터 미리 로드 (캐싱)
    try {
      _allStocksCache = await _localDataSource.getStocks();
      _isInitialized = true;

      // 2. 데이터 로드 후, 혹시 대기 중인 구독 요청이 있다면 처리
      _syncSubscriptions(_watchedStocksSubject.value);
    } catch (e) {
      debugPrint('Error loading initial stocks: $e');
    }

    // 3. 이후 감시 목록 변경 시마다 동기화 수행
    _watchedStocksSubject.distinct().listen((watchedCodes) {
      if (_isInitialized) {
        _syncSubscriptions(watchedCodes);
      }
    });
  }

  void _syncSubscriptions(List<String> desiredCodes) {
    if (!_isInitialized) return;

    final desiredSet = desiredCodes.toSet();

    // 제거해야 할 것들 (현재 구독 중 - 원하는 목록)
    final toUnsubscribe = _activeSocketSubscriptions.difference(desiredSet);
    for (var code in toUnsubscribe) {
      _realtimeDataSource.unsubscribeFromStock(code);
      _activeSocketSubscriptions.remove(code);
    }

    // 추가해야 할 것들 (원하는 목록 - 현재 구독 중)
    final toSubscribe = desiredSet.difference(_activeSocketSubscriptions);
    for (var code in toSubscribe) {
      // 캐시에서 현재가 찾기
      final stock = _allStocksCache.firstWhere(
        (s) => s.stockCode == code,
        orElse: () => StockModel(
          stockCode: '',
          stockName: '',
          currentPrice: 0,
          changeRate: 0,
          timestamp: DateTime.now(),
          type: 'unknown',
        ),
      );

      if (stock.stockCode.isNotEmpty) {
        _realtimeDataSource.subscribeToStock(
          stock.stockCode,
          stock.currentPrice.toDouble(),
        );
        _activeSocketSubscriptions.add(code);
      }
    }
  }

  @override
  void setWatchedStocks(List<String> stockCodes) {
    _watchedStocksSubject.add(stockCodes);
  }

  @override
  Stream<StockEntity> getPriceStream() {
    return _realtimeDataSource.messageStream
        // 1. 타입 필터링을 먼저 수행 (GC 부하 감소)
        .whereType<StockSocketMessagePriceUpdate>()
        // 2. 필요한 데이터만 변환
        .map((message) {
          return StockEntity(
            type:
                'stock', // Message doesn't have type field anymore, defaulting
            stockCode: message.stockCode,
            currentPrice: message.currentPrice.toInt(),
            changeRate: message.changeRate,
            timestamp: message.timestamp,
          );
        });
  }
}
