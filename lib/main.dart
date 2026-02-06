import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
          ),
        ),
      ],
      child: MaterialApp.router(
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.darkTheme,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoute.router,
        locale: Locale('ko'), // 현재 선택된 언어
        localizationsDelegates: [
          AppLocalizations.delegate, // 우리가 만든 번역 delegate
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // 영어
          Locale('ko'), // 한국어
        ],
        builder: (context, child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            // making sure the text scale not affected by system font size
            data: data.copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
