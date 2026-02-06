import 'dart:async';
import 'dart:math';

import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_local_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/data/models/stock_model.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

abstract class StockRemoteDataSource {
  Stream<StockEntity> getPriceStream();
}

class MockStockRemoteDataSource implements StockRemoteDataSource {
  final StockLocalDataSource _localDataSource;
  final Random _random = Random();

  MockStockRemoteDataSource(this._localDataSource);

  @override
  Stream<StockEntity> getPriceStream() async* {
    List<StockModel> stockModels = [];
    try {
      stockModels = await _localDataSource.getStocks();
    } catch (e) {
      // 에러 발생 시 빈 스트림 반환
      return;
    }

    if (stockModels.isEmpty) return;

    // 무한 루프로 1초마다 가격 업데이트 방출
    // Stream.periodic 대신 while loop 사용 (async* 내부)
    while (true) {
      await Future.delayed(const Duration(seconds: 1));

      // 30개 중 10개 랜덤 선택 (중복 허용)하여 업데이트
      // 더 자주 바뀌는 느낌을 주기 위함
      final countToUpdate = min(stockModels.length, 10);

      for (int i = 0; i < countToUpdate; i++) {
        final targetStock = stockModels[_random.nextInt(stockModels.length)];
        final volatility = (_random.nextDouble() * 0.1) - 0.05; // -5% ~ +5%

        final newPrice = (targetStock.currentPrice * (1 + volatility)).round();
        final changeRate = volatility * 100;

        yield StockEntity(
          type: "price_update",
          stockCode: targetStock.stockCode,
          currentPrice: newPrice,
          changeRate: changeRate,
          timestamp: DateTime.now(),
        );
      }
    }
  }
}
