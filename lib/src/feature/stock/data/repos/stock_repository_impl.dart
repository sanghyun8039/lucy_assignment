import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_local_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_remote_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/domain/repos/stock_repository.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource _remoteDataSource;
  final StockLocalDataSource _localDataSource;

  StockRepositoryImpl({
    required StockRemoteDataSource remoteDataSource,
    required StockLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<List<StockEntity>> getStocks() async {
    final stocks = await _localDataSource.getStocks();
    return stocks.map((e) => e.toEntity()).toList();
  }

  @override
  Future<StockEntity?> getStock(String stockCode) async {
    final stock = await _localDataSource.getStock(stockCode);
    return stock?.toEntity();
  }
}
