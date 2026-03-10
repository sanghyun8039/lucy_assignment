import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_price_update.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';
import 'package:rxdart/rxdart.dart';

class GetPriceStreamUseCase {
  final WatchlistRepository _watchlistRepository;

  GetPriceStreamUseCase({required WatchlistRepository watchlistRepository})
    : _watchlistRepository = watchlistRepository;

  Stream<StockPriceUpdate> call() {
    return _watchlistRepository
        .getPriceStream()
        .withLatestFrom<List<WatchlistItem>, StockPriceUpdate?>(
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
