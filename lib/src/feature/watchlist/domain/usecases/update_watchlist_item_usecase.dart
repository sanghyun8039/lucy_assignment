import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';

class UpdateWatchlistItemUseCase {
  final WatchlistRepository _repository;

  UpdateWatchlistItemUseCase(this._repository);

  Future<void> call(WatchlistItem item) {
    return _repository.updateWatchlistItem(item);
  }
}
