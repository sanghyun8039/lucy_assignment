import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:rxdart/rxdart.dart';

abstract class WatchlistLocalDataSource {
  Future<void> addWatchlistItem(WatchlistItem item);
  Future<void> removeWatchlistItem(String stockCode);
  Future<void> updateWatchlistItem(WatchlistItem item);
  List<WatchlistItem> getWatchlist();
  Stream<List<WatchlistItem>> watchWatchlist();
}

class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  final Box<WatchlistItem> _box;

  WatchlistLocalDataSourceImpl(this._box);

  @override
  Future<void> addWatchlistItem(WatchlistItem item) async {
    await _box.put(item.stockCode, item);
  }

  @override
  Future<void> removeWatchlistItem(String stockCode) async {
    await _box.delete(stockCode);
  }

  @override
  Future<void> updateWatchlistItem(WatchlistItem item) async {
    await _box.put(item.stockCode, item);
  }

  @override
  List<WatchlistItem> getWatchlist() {
    return _box.values.toList();
  }

  @override
  Stream<List<WatchlistItem>> watchWatchlist() {
    return _box.watch().map((_) => getWatchlist()).startWith(getWatchlist());
  }
}
