import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/feature/home/presentation/widgets/markets_bottom_sheet.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/get_logo_file_usecase.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';

class StockListTile extends StatelessWidget {
  final StockEntity stock;
  final String searchQuery;

  const StockListTile({super.key, required this.stock, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLight.withValues(alpha: 0.5),
              ),
            ),
            child: ClipOval(
              child: FutureBuilder<File?>(
                future: sl<GetLogoFileUseCase>().call(stock.stockCode),
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
                      stock.stockName?.isNotEmpty ?? false
                          ? stock.stockName![0]
                          : '',
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
          ),
          const SizedBox(width: 12),

          // Name & Code
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(
                  text: stock.stockName ?? "",
                  query: searchQuery,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.textPrimaryLight
                        : AppColors.textPrimaryDark,
                  ),
                  highlightColor: AppColors.primary,
                ),
                _buildHighlightedText(
                  text: stock.stockCode,
                  query: searchQuery,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  highlightColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // // Price & Rate
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Text(
          //       '${currencyFormat.format(stock.currentPrice)}원',
          //       style: AppTypography.bodyLarge.copyWith(
          //         fontWeight: FontWeight.w600,
          //         color: Theme.of(context).brightness == Brightness.light
          //             ? AppColors.textPrimaryLight
          //             : AppColors.textPrimaryDark,
          //       ),
          //     ),
          //     Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         if (isRising)
          //           const Icon(
          //             Icons.arrow_drop_up,
          //             color: AppColors.growth2,
          //             size: 16,
          //           ),
          //         if (isFalling)
          //           const Icon(
          //             Icons.arrow_drop_down,
          //             color: AppColors.decline2,
          //             size: 16,
          //           ),

          //         Text(
          //           '${stock.changeRate.abs().toStringAsFixed(1)}%',
          //           style: AppTypography.bodySmall.copyWith(
          //             color: priceColor,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),

          // const SizedBox(width: 16),
          // Star Icon
          Consumer<WatchlistProvider>(
            builder: (context, provider, child) {
              final isWatched = provider.isWatched(stock.stockCode);
              return GestureDetector(
                onTap: isWatched
                    ? () {
                        context.read<WatchlistProvider>().removeWatchlistItem(
                          stock.stockCode,
                        );
                      }
                    : () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              MarketsBottomSheet(stock: stock),
                        );
                      },
                child: Icon(
                  isWatched ? Icons.star_rounded : Icons.star_border_rounded,
                  color: isWatched
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 28,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText({
    required String text,
    required String query,
    required TextStyle style,
    required Color highlightColor,
  }) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text, style: style);
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(
          TextSpan(text: text.substring(start, indexOfHighlight), style: style),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(
            indexOfHighlight,
            indexOfHighlight + lowerQuery.length,
          ),
          style: style.copyWith(color: highlightColor),
        ),
      );
      start = indexOfHighlight + lowerQuery.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
