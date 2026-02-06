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
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucy_assignment/src/feature/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'package:lucy_assignment/src/feature/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/repos/watchlist_repository.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/add_watchlist_item_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/get_price_stream_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/get_watch_stream_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/remove_watchlist_item_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/usecases/update_watchlist_item_usecase.dart';

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
    () => MockStockRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<StockLocalDataSource>(
    () => StockLocalDataSourceImpl(),
  );

  // Feature: Watchlist
  // UseCases
  sl.registerLazySingleton(() => GetPriceStreamUseCase(sl()));
  sl.registerLazySingleton(() => GetWatchStreamUseCase(sl()));
  sl.registerLazySingleton(() => AddWatchlistItemUseCase(sl()));
  sl.registerLazySingleton(() => RemoveWatchlistItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateWatchlistItemUseCase(sl()));

  // Repository
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(sl(), sl()),
  );

  // DataSources
  sl.registerLazySingleton<WatchlistLocalDataSource>(
    () => WatchlistLocalDataSourceImpl(Hive.box<WatchlistItem>('watchlist')),
  );
}
