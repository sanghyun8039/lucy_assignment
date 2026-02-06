import 'dart:async';
import 'dart:math';

import 'package:rxdart/rxdart.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_local_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/stock_model.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

abstract class StockRemoteDataSource {
  Stream<StockEntity> getPriceStream();
  void setWatchedStocks(List<String> stockCodes);
}

class MockStockRemoteDataSource implements StockRemoteDataSource {
  final StockLocalDataSource _localDataSource;
  final Random _random = Random();

  // 감시 대상 종목 코드를 관리하는 Subject
  final BehaviorSubject<List<String>> _watchedStocksSubject =
      BehaviorSubject.seeded([]);

  // 전체 주식 리스트 캐시
  List<StockModel> _allStocksCache = [];

  MockStockRemoteDataSource({required StockLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  void setWatchedStocks(List<String> stockCodes) {
    _watchedStocksSubject.add(stockCodes);
  }

  @override
  Stream<StockEntity> getPriceStream() {
    // 1. 초기 데이터 로딩 (Stream 생성 시점)
    // fromFuture를 사용하여 비동기 로딩 후 switchMap으로 연결
    return Stream.fromFuture(_localDataSource.getStocks()).switchMap((stocks) {
      _allStocksCache = stocks;

      // 2. _watchedStocksSubject가 변할 때마다 스트림 재구성
      return _watchedStocksSubject.switchMap((watchedCodes) {
        if (watchedCodes.isEmpty || _allStocksCache.isEmpty) {
          return Stream<StockEntity>.empty();
        }

        // 3. 각 관싱 종목별로 개별적인 타이머 스트림 생성 (병렬 효과)
        final individualStreams = watchedCodes.map((code) {
          final stockModel = _allStocksCache.firstWhere(
            (element) => element.stockCode == code,
            orElse: () => _allStocksCache.first,
          );

          // 일치하는 종목이 없으면 빈 스트림
          if (stockModel.stockCode != code) return Stream<StockEntity>.empty();

          // 각 종목마다 랜덤한 주기로 업데이트 (0.5초 ~ 2초)
          final interval = Duration(milliseconds: 500 + _random.nextInt(1500));

          return Stream.periodic(interval, (_) {
            return _generateRandomUpdate(stockModel);
          });
        });

        // 4. 모든 개별 스트림을 하나로 병합 (Merge)
        // 각 스트림은 독립적인 타이머를 가지므로 "병렬적"으로 동작함
        return Rx.merge(individualStreams);
      });
    });
  }

  StockEntity _generateRandomUpdate(StockModel originalStock) {
    final volatility = (_random.nextDouble() * 0.02) - 0.01; // -1% ~ +1%
    final newPrice = (originalStock.currentPrice * (1 + volatility)).round();
    final changeRate = volatility * 100;

    return StockEntity(
      type: "price_update",
      stockCode: originalStock.stockCode,
      currentPrice: newPrice,
      changeRate: changeRate,
      timestamp: DateTime.now(),
    );
  }
}
