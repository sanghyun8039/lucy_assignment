import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/core/router/app_route.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:lucy_assignment/src/l10n/app_localizations.dart';
import 'package:lucy_assignment/src/core/utils/global_alert_listener.dart';
import 'package:lucy_assignment/src/feature/setting/presentation/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  await Hive.initFlutter();
  Hive.registerAdapter(WatchlistItemAdapter());
  Hive.registerAdapter(AlertTypeAdapter());
  await Hive.openBox<WatchlistItem>('watchlist');

  await dotenv.load(fileName: ".env");

  //세로모드로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WatchlistProvider(
            getWatchStreamUseCase: sl(),
            addWatchlistItemUseCase: sl(),
            removeWatchlistItemUseCase: sl(),
            getPriceStreamUseCase: sl(),
            getStockUseCase: sl(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          // Access SettingsProvider
          final settings = context.watch<SettingsProvider>();

          return MaterialApp.router(
            themeMode: settings.themeMode,
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            routerConfig: AppRoute.router,
            locale: settings.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ko')],
            builder: (context, child) {
              final MediaQueryData data = MediaQuery.of(context);
              return GlobalAlertListener(
                navigatorKey: rootNavigatorKey,
                child: MediaQuery(
                  data: data.copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child ?? const SizedBox(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
