import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucy_assignment/src/core/router/app_route_name.dart';
import 'package:lucy_assignment/src/feature/home/presentation/screens/home_screen.dart';
import 'package:lucy_assignment/src/feature/index/presentation/index_screen.dart';
import 'package:lucy_assignment/src/feature/setting/presentation/screens/settings_screen.dart';
import 'package:lucy_assignment/src/feature/splash/presentation/screens/splash_screen.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/stock_detail_screen.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/screens/watchlist_screen.dart';

import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/providers/scroll_sync_provider.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final bottomNavigatorKey = GlobalKey<StatefulNavigationShellState>(
  debugLabel: 'bottom',
);

class AppRoute {
  AppRoute._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(path: "/", redirect: (context, state) => "/splash"),
      GoRoute(
        path: "/splash",
        name: AppRouteName.splash,
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        key: bottomNavigatorKey,
        builder: (context, state, child) {
          return IndexScreen(state: state, child: child);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/home",
                name: AppRouteName.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/watchlist",
                name: AppRouteName.watchlist,
                builder: (context, state) => const WatchlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/settings",
                name: AppRouteName.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/stock_detail/:stockCode',
        name: AppRouteName.stockDetail,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => ScrollSyncProvider(),
          child: const StockDetailScreen(),
        ),
      ),
    ],
  );
}
