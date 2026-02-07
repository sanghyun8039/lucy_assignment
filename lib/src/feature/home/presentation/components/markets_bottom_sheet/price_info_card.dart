import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class PriceInfoCard extends StatelessWidget {
  final StockEntity? stock;
  const PriceInfoCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,###");

    final isRising = (stock?.changeRate ?? 0) > 0;
    final isFalling = (stock?.changeRate ?? 0) < 0;
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
            context.s.closingPrice,
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
                    '${currencyFormat.format(stock?.currentPrice ?? 0)} 원',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: priceColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
