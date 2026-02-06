import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';

class GetWatchStreamUseCase {
  final WatchlistRepository _watchlistRepository;

  GetWatchStreamUseCase({required WatchlistRepository watchlistRepository})
    : _watchlistRepository = watchlistRepository;

  Stream<List<WatchlistItem>> call() {
    return _watchlistRepository.getWatchlistStream();
  }
}
