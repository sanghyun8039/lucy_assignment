import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/domain/repos/stock_repository.dart';

class GetStocksUseCase {
  final StockRepository _stockRepository;

  GetStocksUseCase({required StockRepository stockRepository})
    : _stockRepository = stockRepository;

  Future<List<StockEntity>> call() async {
    return await _stockRepository.getStocks();
  }
}
