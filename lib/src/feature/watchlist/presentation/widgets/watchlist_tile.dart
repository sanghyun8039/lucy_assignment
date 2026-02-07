import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
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
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, child) {
        // Use provider's realtime data if available, otherwise fallback to passed initial data
        final realtimeStock = provider.getPrice(item.stockCode);
        final stock = realtimeStock ?? stockEntity;

        final currentPrice = stock?.currentPrice ?? 0;
        final changeRate = stock?.changeRate ?? 0.0;
        final stockName =
            stock?.stockName ??
            stockEntity?.stockName ??
            item.stockCode; // Fallback to code if name missing

        final isRising = changeRate > 0;
        final isFalling = changeRate < 0;

        // Colors based on design intent
        final priceColor = isRising
            ? AppColors
                  .growth2 // Red/Growth color
            : (isFalling
                  ? AppColors.decline2
                  : AppColors.textSecondary); // Blue/Decline

        final currencyFormat = NumberFormat("#,###");

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: context.theme.brightness == Brightness.light
              ? AppColors.backgroundLight
              : AppColors.backgroundDark, // Match background from design
          child: Row(
            children: [
              // 1. Logo
              _buildLogo(context),

              const SizedBox(width: 16),

              // 2. Stock Info (Name, Code, Target)
              Expanded(
                child: Column(
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
                        color: AppColors.textSecondary, // Gray 500 equivalent
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Target Price Row
                    Row(
                      children: [
                        Text(
                          '${context.s.targetPrice}: ${item.targetPrice != null ? currencyFormat.format(item.targetPrice) : '-'} KRW',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ), // Gray 400
                            fontSize: 11,
                          ),
                        ),
                        if (item.targetPrice != null && stock != null) ...[
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
                ),
              ),

              const SizedBox(width: 16),

              // 3. Price & Change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stock != null
                        ? '${currencyFormat.format(currentPrice)}원'
                        : '-',
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
              ),

              const SizedBox(width: 12),

              // 4. Edit Button (Mock)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.edit_outlined, // Design uses 'edit' symbol
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  if (stock != null) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => MarketsBottomSheet(
                        stock: stockEntity,
                        existingItem: item,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
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
