import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

abstract class StockRepository {
  Future<List<StockEntity>> getStocks();
  Future<StockEntity?> getStock(String stockCode);
}
