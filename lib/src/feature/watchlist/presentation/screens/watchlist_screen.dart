import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
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
        scrolledUnderElevation: 0,
      ),
      body: Selector<WatchlistProvider, List<WatchlistItem>>(
        selector: (context, provider) => provider.watchlist,
        builder: (context, watchlist, child) {
          if (watchlist.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noWatchlist,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            itemExtent: 100.0.h,
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final item = watchlist[index];
              // Get cached stock entity from provider (initial data)
              final stock = context.read<WatchlistProvider>().getPrice(
                item.stockCode,
              );

              return WatchlistTile(
                item: item,
                stockEntity: stock,
                showDivider: index != watchlist.length - 1,
              );
            },
          );
        },
      ),
    );
  }
}
