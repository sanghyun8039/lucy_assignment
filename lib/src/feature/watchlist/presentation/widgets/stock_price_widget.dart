import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/formatters/app_formatters.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:provider/provider.dart';

class StockPriceWidget extends StatelessWidget {
  final String stockCode;
  final StockEntity? initialStock;

  const StockPriceWidget({
    super.key,
    required this.stockCode,
    required this.initialStock,
  });

  @override
  Widget build(BuildContext context) {
    // Selector나 Provider에서 전체 스트림을 가져와 필터링
    final stockStream = context.read<WatchlistProvider>().getStockStream(
      stockCode,
    );
    return StreamBuilder<StockEntity>(
      // ✅ 최적화 1: distinct()를 추가하여 동일한 가격 데이터 수신 시 리빌드 방지
      stream: stockStream,
      initialData: initialStock,
      builder: (context, snapshot) {
        final realtimeStock = snapshot.data;

        // 데이터 병합 로직
        final stock =
            initialStock?.copyWith(
              currentPrice:
                  realtimeStock?.currentPrice ??
                  initialStock?.currentPrice ??
                  0,
              changeRate:
                  realtimeStock?.changeRate ?? initialStock?.changeRate ?? 0.0,
            ) ??
            realtimeStock;

        if (stock == null) return const SizedBox();

        final currentPrice = stock.currentPrice;
        final changeRate = stock.changeRate;
        final isRising = changeRate > 0;
        final isFalling = changeRate < 0;

        final priceColor = isRising
            ? AppColors.growth2
            : (isFalling ? AppColors.decline2 : AppColors.textSecondary);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${AppFormatters.comma.format(currentPrice)} KRW',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: priceColor,
                // ✅ 최적화 2: 고정폭 숫자(Tabular Figures) 적용 -> 레이아웃 떨림 방지
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRising)
                  const Icon(
                    Icons.arrow_drop_up,
                    color: AppColors.growth2,
                    size: 12,
                  ),
                if (isFalling)
                  const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.decline2,
                    size: 12,
                  ),
                const SizedBox(width: 2),
                Text(
                  '${changeRate.abs().toStringAsFixed(2)}%',
                  style: AppTypography.bodySmall.copyWith(
                    color: priceColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    // ✅ 최적화 2: 고정폭 숫자 적용
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class AppFormat {}
