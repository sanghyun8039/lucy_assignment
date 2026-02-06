import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';

class RemoveWatchlistItemUseCase {
  final WatchlistRepository _repository;

  RemoveWatchlistItemUseCase(this._repository);

  Future<void> call(String stockCode) {
    return _repository.removeWatchlistItem(stockCode);
  }
}
