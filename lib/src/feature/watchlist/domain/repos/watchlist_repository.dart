import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

abstract class WatchlistRepository {
  /// 관심 종목 리스트 스트림 (로컬 DB 변경 감지)
  Stream<List<WatchlistItem>> getWatchlistStream();

  /// 실시간 주가 스트림 (Mock WebSocket)
  /// 전체 종목의 가격 변동을 방출하지만, UseCase/Provider 레벨에서 필터링하여 사용
  Stream<StockEntity> getPriceStream();

  /// 관심 종목 추가
  Future<void> addWatchlistItem(WatchlistItem item);

  /// 관심 종목 삭제
  Future<void> removeWatchlistItem(String stockCode);

  /// 목표가/알림 설정 업데이트
  Future<void> updateWatchlistItem(WatchlistItem item);
}
