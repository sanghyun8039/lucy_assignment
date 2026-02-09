import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/core/utils/formatters/app_formatters.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart'; // Provider import
import 'package:provider/provider.dart'; // Provider import

class PriceInfoCard extends StatelessWidget {
  final StockEntity? stock;
  final bool? isEditMode;
  const PriceInfoCard({super.key, required this.stock, this.isEditMode});

  @override
  Widget build(BuildContext context) {
    if (stock == null) return const SizedBox();

    return StreamBuilder<StockEntity>(
      stream: context.read<WatchlistProvider>().getStockStream(
        stock!.stockCode,
      ),
      initialData: stock,
      builder: (context, snapshot) {
        final currentStock = snapshot.data ?? stock!;

        final isRising = currentStock.changeRate > 0;
        final isFalling = currentStock.changeRate < 0;

        final Color priceColor = isRising
            ? AppColors.growth2
            : (isFalling
                  ? AppColors.decline2
                  : context.theme.brightness == Brightness.light
                  ? AppColors.textPrimaryLight
                  : AppColors.textPrimaryDark);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.theme.brightness == Brightness.light
                ? Colors.grey[50]
                : AppColors.surfaceDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.theme.brightness == Brightness.light
                  ? Colors.grey[100]!
                  : Colors.grey[800]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditMode == true
                    ? context.l10n.currentPrice
                    : context.l10n.closingPrice,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '${AppFormatters.comma.format(currentStock.currentPrice)} KRW',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: priceColor,
                          // ✅ [핵심 2] 숫자가 바뀔 때 너비가 흔들리지 않도록 고정폭 숫자 적용
                          fontFeatures: [const FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
