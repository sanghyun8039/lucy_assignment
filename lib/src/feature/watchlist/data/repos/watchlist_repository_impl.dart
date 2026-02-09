import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_remote_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';
import 'package:rxdart/rxdart.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource _localDataSource;
  final StockRemoteDataSource _remoteDataSource;

  WatchlistRepositoryImpl({
    required WatchlistLocalDataSource localDataSource,
    required StockRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
  Stream<List<WatchlistItem>> getWatchlistStream() {
    return _localDataSource.watchWatchlist().doOnData((list) {
      final codes = list.map((e) => e.stockCode).toList();
      _remoteDataSource.setWatchedStocks(codes);
    });
  }

  @override
  Future<void> addWatchlistItem(WatchlistItem item) {
    return _localDataSource.addWatchlistItem(item);
  }

  @override
  Stream<StockEntity> getPriceStream() {
    return _remoteDataSource.getPriceStream();
  }

  @override
  Future<void> removeWatchlistItem(String stockCode) {
    return _localDataSource.removeWatchlistItem(stockCode);
  }

  @override
  Future<void> updateWatchlistItem(WatchlistItem item) {
    return _localDataSource.updateWatchlistItem(item);
  }
}
