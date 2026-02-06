import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_remote_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource _localDataSource;
  final StockRemoteDataSource _remoteDataSource;

  WatchlistRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<void> addWatchlistItem(WatchlistItem item) {
    return _localDataSource.addWatchlistItem(item);
  }

  @override
  Stream<StockEntity> getPriceStream() {
    return _remoteDataSource.getPriceStream();
  }

  @override
  Stream<List<WatchlistItem>> getWatchlistStream() {
    return _localDataSource.watchWatchlist();
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
