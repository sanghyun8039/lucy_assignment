import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';
import 'package:rxdart/rxdart.dart';

class GetPriceStreamUseCase {
  final WatchlistRepository _watchlistRepository;

  GetPriceStreamUseCase({required WatchlistRepository watchlistRepository})
    : _watchlistRepository = watchlistRepository;

  Stream<StockEntity> call() {
    return _watchlistRepository
        .getPriceStream()
        .withLatestFrom<List<WatchlistItem>, StockEntity?>(
          _watchlistRepository.getWatchlistStream(),
          (priceUpdate, watchlist) {
            final isWatched = watchlist.any(
              (item) => item.stockCode == priceUpdate.stockCode,
            );

            return isWatched ? priceUpdate : null;
          },
        )
        .whereNotNull();
  }
}
