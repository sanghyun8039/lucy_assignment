import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';

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

          return ListView.builder(
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final item = watchlist[index];
              final stockPrice = provider.getPrice(item.stockCode);

              // stockPrice가 아직 없으면 (초기 로딩 등) 로딩 표시 혹은 기본값
              final priceText = stockPrice != null
                  ? '${stockPrice.currentPrice}원'
                  : '...';

              final changeRateText = stockPrice != null
                  ? '${stockPrice.changeRate.toStringAsFixed(2)}%'
                  : '';

              final changeColor = (stockPrice?.changeRate ?? 0) > 0
                  ? Colors.red
                  : ((stockPrice?.changeRate ?? 0) < 0
                        ? Colors.blue
                        : Colors.grey);

              return ListTile(
                title: Text(
                  item.stockCode,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '$priceText  $changeRateText',
                  style: TextStyle(color: changeColor),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    provider.removeWatchlistItem(item.stockCode);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
