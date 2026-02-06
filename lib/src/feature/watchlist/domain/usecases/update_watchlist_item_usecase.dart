import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';

class UpdateWatchlistItemUseCase {
  final WatchlistRepository _watchlistRepository;

  UpdateWatchlistItemUseCase({required WatchlistRepository watchlistRepository})
    : _watchlistRepository = watchlistRepository;

  Future<void> call(WatchlistItem item) {
    return _watchlistRepository.updateWatchlistItem(item);
  }
}
