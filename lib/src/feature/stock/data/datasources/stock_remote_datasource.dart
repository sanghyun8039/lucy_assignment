import 'dart:async';

import 'package:lucy_assignment/src/feature/watchlist/data/models/watchlist_model.dart';
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
      // 기존 구독 취소 로직이 필요하다면 추가 (여기서는 단순 추가만 예시)
      // 실제로는 이전 목록과 비교해서 차이만큼만 구독/해지 하는게 좋음
      for (var code in watchedCodes) {
        final stock = _allStocksCache.firstWhere(
          (s) => s.stockCode == code,
          orElse: () => StockModel(
            stockCode: '',
            currentPrice: 0,
            changeRate: 0,
            type: '',
          ),
        );
        if (stock.stockCode.isNotEmpty) {
          _socketManager.subscribeToStock(
            stock.stockCode,
            stock.currentPrice.toDouble(),
          );
        }
      }
    });
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
      final currentWatched = _watchedStocksSubject.value;
      if (currentWatched.isNotEmpty) {
        for (var code in currentWatched) {
          final stock = _allStocksCache.firstWhere(
            (s) => s.stockCode == code,
            orElse: () => StockModel(
              stockCode: '',
              currentPrice: 0,
              changeRate: 0,
              type: '',
            ),
          );
          if (stock.stockCode.isNotEmpty) {
            _socketManager.subscribeToStock(
              stock.stockCode,
              stock.currentPrice.toDouble(),
            );
          }
        }
      }

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
            // 다른 메시지 타입은 무시하거나 적절히 처리
            return StockEntity(
              stockCode: '',
              currentPrice: 0,
              changeRate: 0,
              type: 'unknown',
              timestamp: DateTime.now(),
            );
            // 실제로는 filter 등을 써서 unknown은 걸러내는 게 좋음
          })
          .where((entity) => entity.type != 'unknown');
    });
  }
}
