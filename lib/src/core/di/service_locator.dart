import 'package:get_it/get_it.dart';
import 'package:lucy_assignment/src/feature/logo/data/datasources/logo_local_datasource.dart';
import 'package:lucy_assignment/src/feature/logo/data/datasources/logo_remote_datasource.dart';
import 'package:lucy_assignment/src/feature/logo/data/repos/logo_repository_impl.dart';
import 'package:lucy_assignment/src/feature/logo/domain/repos/logo_repository.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/get_logo_file_usecase.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/sync_logos_usecase.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_local_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/data/datasources/stock_remote_datasource.dart';
import 'package:lucy_assignment/src/feature/stock/data/repos/stock_repository_impl.dart';
import 'package:lucy_assignment/src/feature/stock/domain/repos/stock_repository.dart';
import 'package:lucy_assignment/src/feature/stock/domain/usecases/get_stocks_usecase.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Feature: Logo
  // UseCases
  sl.registerLazySingleton(() => SyncLogosUseCase(logoRepository: sl()));
  sl.registerLazySingleton(() => GetLogoFileUseCase(logoRepository: sl()));

  // Repository
  sl.registerLazySingleton<LogoRepository>(
    () => LogoRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<LogoRemoteDataSource>(
    () => LogoRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<LogoLocalDataSource>(
    () => LogoLocalDataSourceImpl(),
  );

  // Feature: Stock
  // UseCases
  sl.registerLazySingleton(() => GetStocksUseCase(stockRepository: sl()));

  // Repository
  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<StockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<StockLocalDataSource>(
    () => StockLocalDataSourceImpl(),
  );
}
