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
  final BehaviorSubject<List<String>> _watchedStocksSubject =
      BehaviorSubject.seeded([]);
  final Set<String> _activeSocketSubscriptions = {};

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

    try {
      _allStocksCache = await _localDataSource.getStocks();
      _isInitialized = true;
      _syncSubscriptions(_watchedStocksSubject.value);
    } catch (e) {
      debugPrint('Error loading initial stocks: $e');
    }

    _watchedStocksSubject.distinct().listen((watchedCodes) {
      if (_isInitialized) {
        _syncSubscriptions(watchedCodes);
      }
    });
  }

  @override
  void setWatchedStocks(List<String> stockCodes) {
    _watchedStocksSubject.add(stockCodes);
  }

  @override
  Stream<StockEntity> getPriceStream() {
    return _realtimeDataSource.messageStream
        .whereType<StockSocketMessagePriceUpdate>()
        .map((message) {
          return StockEntity(
            stockCode: message.stockCode,
            currentPrice: message.currentPrice.toInt(),
            changeRate: message.changeRate,
            timestamp: message.timestamp,
          );
        });
  }

  void _syncSubscriptions(List<String> desiredCodes) {
    if (!_isInitialized) return;

    final desiredSet = desiredCodes.toSet();

    final toUnsubscribe = _activeSocketSubscriptions.difference(desiredSet);
    for (var code in toUnsubscribe) {
      _realtimeDataSource.unsubscribeFromStock(code);
      _activeSocketSubscriptions.remove(code);
    }

    final toSubscribe = desiredSet.difference(_activeSocketSubscriptions);
    for (var code in toSubscribe) {
      final stock = _allStocksCache.firstWhere(
        (s) => s.stockCode == code,
        orElse: () => StockModel(
          stockCode: '',
          stockName: '',
          currentPrice: 0,
          changeRate: 0,
          timestamp: DateTime.now(),
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
}
