import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_local_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/stock_model.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/socket/stock_socket_manager.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/socket/stock_socket_message.dart';

abstract class StockRemoteDataSource {
  Stream<StockEntity> getPriceStream();
  void setWatchedStocks(List<String> stockCodes);
}

class MockStockRemoteDataSource implements StockRemoteDataSource {
  final StockLocalDataSource _localDataSource;
  final StockSocketManager _socketManager;

  // 감시 대상 종목 코드를 관리하는 Subject
  final BehaviorSubject<List<String>> _watchedStocksSubject =
      BehaviorSubject.seeded([]);

  // 현재 구독 중인 종목 관리 (중복 구독 방지)
  final Set<String> _currentSubscriptions = {};

  // 전체 주식 리스트 캐시
  List<StockModel> _allStocksCache = [];

  MockStockRemoteDataSource({
    required StockLocalDataSource localDataSource,
    required StockSocketManager socketManager,
  }) : _localDataSource = localDataSource,
       _socketManager = socketManager {
    _socketManager.connect();

    // 소켓 연결 및 구독 상태 관리
    _watchedStocksSubject.distinct().listen((watchedCodes) {
      _syncSubscriptions(watchedCodes);
    });
  }

  void _syncSubscriptions(List<String> desiredCodes) {
    if (_allStocksCache.isEmpty) return; // 캐시가 없으면 아직 구독 불가

    final desiredSet = desiredCodes.toSet();
    final toSubscribe = desiredSet.difference(_currentSubscriptions);
    final toUnsubscribe = _currentSubscriptions.difference(desiredSet);

    // 구독 해지
    for (var code in toUnsubscribe) {
      _socketManager.unsubscribeFromStock(code);
      _currentSubscriptions.remove(code);
    }

    // 신규 구독
    for (var code in toSubscribe) {
      final stockIndex = _allStocksCache.indexWhere((s) => s.stockCode == code);
      if (stockIndex != -1) {
        final stock = _allStocksCache[stockIndex];
        _socketManager.subscribeToStock(
          stock.stockCode,
          stock.currentPrice.toDouble(),
        );
        _currentSubscriptions.add(code);
      }
    }
  }

  @override
  void setWatchedStocks(List<String> stockCodes) {
    _watchedStocksSubject.add(stockCodes);
  }

  @override
  Stream<StockEntity> getPriceStream() {
    // 1. 초기 데이터 로딩 (Stream 생성 시점)
    return Stream.fromFuture(_localDataSource.getStocks()).switchMap((stocks) {
      _allStocksCache = stocks;

      // 초기 로딩 시 이미 감시 종목이 있다면 구독 수행
      // 초기 로딩 시 키시된 감시 종목 구독 동기화
      _syncSubscriptions(_watchedStocksSubject.value);

      // 2. 소켓 메시지 스트림을 StockEntity 스트림으로 변환
      return _socketManager.messageStream
          .map((message) {
            if (message is StockSocketMessagePriceUpdate) {
              return StockEntity(
                type: message.type,
                stockCode: message.stockCode,
                currentPrice: message.currentPrice.toInt(),
                changeRate: message.changeRate,
                timestamp: message.timestamp,
              );
            }
            return StockEntity(
              stockCode: '',
              currentPrice: 0,
              changeRate: 0,
              type: 'unknown',
              timestamp: DateTime.now(),
            );
          })
          .where((entity) => entity.type != 'unknown');
    });
  }
}
