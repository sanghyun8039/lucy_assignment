import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/core/router/app_route_name.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/get_logo_file_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:lucy_assignment/src/feature/home/presentation/widgets/markets_bottom_sheet.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';

class WatchlistTile extends StatelessWidget {
  final WatchlistItem item;
  final StockEntity? stockEntity;

  const WatchlistTile({
    super.key,
    required this.item,
    required this.stockEntity,
  });
  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final realtimeStock = context.read<WatchlistProvider>().getPrice(
          item.stockCode,
        );
        final stock =
            stockEntity?.copyWith(
              currentPrice:
                  realtimeStock?.currentPrice ?? stockEntity?.currentPrice ?? 0,
              changeRate:
                  realtimeStock?.changeRate ?? stockEntity?.changeRate ?? 0.0,
            ) ??
            realtimeStock;

        context.pushNamed(
          AppRouteName.stockDetail,
          extra: stock ?? stockEntity,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: context.theme.brightness == Brightness.light
            ? AppColors.backgroundLight
            : AppColors.backgroundDark,
        child: Row(
          children: [
            _buildLogo(context),
            const SizedBox(width: 16),
            Expanded(child: _buildStockInfo(context)),
            const SizedBox(width: 16),
            _buildPriceInfo(context),
            _buildEditButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo(BuildContext context) {
    final currencyFormat = NumberFormat("#,###");
    final stockName =
        stockEntity?.stockName ??
        item.stockCode; // Use initial data for name/code

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stockName,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.textPrimaryLight
                : AppColors.textPrimaryDark,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          item.stockCode,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${context.l10n.targetPrice}: ${item.targetPrice != null ? currencyFormat.format(item.targetPrice) : '-'} KRW',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            if (item.targetPrice != null) ...[
              const SizedBox(width: 4),
              Icon(
                switch (item.alertType) {
                  AlertType.upper => Icons.arrow_upward,
                  AlertType.lower => Icons.arrow_downward,
                  AlertType.bidir => Icons.swap_vert,
                },
                size: 14,
                color: switch (item.alertType) {
                  AlertType.upper => AppColors.growth2,
                  AlertType.lower => AppColors.decline2,
                  AlertType.bidir => AppColors.primary,
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInfo(BuildContext context) {
    return Selector<WatchlistProvider, StockEntity?>(
      selector: (context, provider) => provider.getPrice(item.stockCode),
      builder: (context, realtimeStock, child) {
        final stock =
            stockEntity?.copyWith(
              currentPrice:
                  realtimeStock?.currentPrice ?? stockEntity?.currentPrice ?? 0,
              changeRate:
                  realtimeStock?.changeRate ?? stockEntity?.changeRate ?? 0.0,
            ) ??
            realtimeStock;

        final currentPrice = stock?.currentPrice ?? 0;
        final changeRate = stock?.changeRate ?? 0.0;
        final isRising = changeRate > 0;
        final isFalling = changeRate < 0;

        final priceColor = isRising
            ? AppColors.growth2
            : (isFalling ? AppColors.decline2 : AppColors.textSecondary);

        final currencyFormat = NumberFormat("#,###");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              stock != null ? '${currencyFormat.format(currentPrice)} KRW' : '',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: priceColor,
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
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(
        Icons.edit_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onPressed: () {
        if (stockEntity != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                MarketsBottomSheet(stock: stockEntity, existingItem: item),
          );
        }
      },
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 48, // Design uses w-12 (3rem = 48px)
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black, // bg-white/black based on logo
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.3),
        ), // border-gray-700 equivalent
      ),
      child: ClipOval(
        child: FutureBuilder<File?>(
          future: sl<GetLogoFileUseCase>().call(item.stockCode),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.file(
                snapshot.data!,
                fit: BoxFit.contain,
              ); // box-fit contain in design
            }
            return Container(
              alignment: Alignment.center,
              color: AppColors.backgroundLight,
              child: Text(
                item.stockCode.isNotEmpty ? item.stockCode[0] : '',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark, // Fallback
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
