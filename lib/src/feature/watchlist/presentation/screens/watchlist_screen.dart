import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock/domain/usecases/get_stock_usecase.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/widgets/watchlist_tile.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WatchlistProvider>(
        builder: (context, provider, child) {
          final watchlist = provider.watchlist;

          if (watchlist.isEmpty) {
            return const Center(
              child: Text(
                '관심 종목을 추가해주세요.',
                style: TextStyle(color: Colors.white),
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
                  if (snapshot.hasData && snapshot.data != null) {
                    return WatchlistTile(item: snapshot.data!);
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          );
        },
      ),
    );
  }
}
