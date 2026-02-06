import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';
import 'package:rxdart/rxdart.dart';

class GetPriceStreamUseCase {
  final WatchlistRepository _watchlistRepository;

  GetPriceStreamUseCase({required WatchlistRepository watchlistRepository})
    : _watchlistRepository = watchlistRepository;

  // Anti-Gravity: "즐겨찾기 한 것만 가격 추적"
  // 전체 가격 스트림과 관심 종목 리스트를 결합하여,
  // "관심 종목에 해당하는 가격 변동"만 필터링하여 방출하는 스트림
  Stream<StockEntity> call() {
    return Rx.combineLatest2<StockEntity, List<WatchlistItem>, StockEntity?>(
      _watchlistRepository.getPriceStream(),
      _watchlistRepository.getWatchlistStream(),
      (priceUpdate, watchlist) {
        // 가격 업데이트된 종목이 내 관심 목록에 있는지 확인
        final isWatched = watchlist.any(
          (item) => item.stockCode == priceUpdate.stockCode,
        );
        return isWatched ? priceUpdate : null;
      },
    ).whereNotNull(); // null (관심 없는 종목의 변동)은 무시
  }
}
