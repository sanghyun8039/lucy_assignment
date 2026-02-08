import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/domain/usecases/get_stock_usecase.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/widgets/watchlist_tile.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.watchlist,
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.theme.brightness == Brightness.light
            ? AppColors.backgroundLight
            : AppColors.backgroundDark,
        elevation: 0,
      ),
      body: Selector<WatchlistProvider, List<WatchlistItem>>(
        selector: (context, provider) => provider.watchlist,
        builder: (context, watchlist, child) {
          if (watchlist.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noWatchlist,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.theme.brightness == Brightness.light
                      ? AppColors.textPrimaryLight
                      : AppColors.textPrimaryDark,
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: watchlist.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.borderLight),
            itemBuilder: (context, index) {
              final item = watchlist[index];
              return FutureBuilder<StockEntity?>(
                future: sl<GetStockUseCase>().call(item.stockCode),
                builder: (context, snapshot) {
                  return WatchlistTile(item: item, stockEntity: snapshot.data);
                },
              );
            },
          );
        },
      ),
    );
  }
}
