import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/get_logo_file_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';

class WatchlistTile extends StatelessWidget {
  final StockEntity item;

  const WatchlistTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistProvider>(
      builder: (context, provider, child) {
        final stockEntity = provider.getPrice(item.stockCode);
        final currentPrice = stockEntity?.currentPrice ?? 0;
        final changeRate = stockEntity?.changeRate ?? 0.0;

        final isRising = changeRate > 0;
        final isFalling = changeRate < 0;

        final priceColor = isRising
            ? AppColors.growth2
            : (isFalling ? AppColors.decline2 : AppColors.textSecondary);

        final currencyFormat = NumberFormat("#,###");

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderLight, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // 1. Logo
              _buildLogo(context),

              const SizedBox(width: 12),

              // 2. Stock Name & Code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.stockName ?? "",
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.textPrimaryLight
                            : AppColors.textPrimaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.stockCode,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Price & Change Rate
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stockEntity != null
                        ? '${currencyFormat.format(currentPrice)}원'
                        : '-',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: priceColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRising)
                        const Icon(
                          Icons.arrow_drop_up,
                          color: AppColors.growth2,
                          size: 16,
                        ),
                      if (isFalling)
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.decline2,
                          size: 16,
                        ),
                      Text(
                        '${changeRate.abs().toStringAsFixed(2)}%',
                        style: AppTypography.bodySmall.copyWith(
                          color: priceColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // 4. Delete Button
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  provider.removeWatchlistItem(item.stockCode);
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: ClipOval(
        child: FutureBuilder<File?>(
          future: sl<GetLogoFileUseCase>().call(item.stockCode),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.file(snapshot.data!, fit: BoxFit.cover);
            }
            return Container(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.backgroundLight
                  : AppColors.backgroundDark,
              alignment: Alignment.center,
              child: Text(
                item.stockCode.isNotEmpty ? item.stockCode[0] : '',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.textPrimaryLight
                      : AppColors.textPrimaryDark,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
