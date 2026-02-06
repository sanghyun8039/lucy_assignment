import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/domain/repos/stock_repository.dart';

class GetStockUseCase {
  final StockRepository _stockRepository;

  GetStockUseCase({required StockRepository stockRepository})
    : _stockRepository = stockRepository;

  Future<StockEntity?> call(String stockCode) async {
    return await _stockRepository.getStock(stockCode);
  }
}
