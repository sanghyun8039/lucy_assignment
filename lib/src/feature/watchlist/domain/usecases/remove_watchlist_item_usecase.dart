import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';

class RemoveWatchlistItemUseCase {
  final WatchlistRepository _watchlistRepository;

  RemoveWatchlistItemUseCase({required WatchlistRepository watchlistRepository})
    : _watchlistRepository = watchlistRepository;

  Future<void> call(String stockCode) {
    return _watchlistRepository.removeWatchlistItem(stockCode);
  }
}
