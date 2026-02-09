import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/get_logo_file_usecase.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class StockDetailAppBar extends StatelessWidget {
  final StockEntity stock;

  const StockDetailAppBar({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLight.withValues(alpha: 0.3),
              ),
            ),
            child: ClipOval(
              child: FutureBuilder<File?>(
                future: sl<GetLogoFileUseCase>().call(stock.stockCode),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.file(snapshot.data!, fit: BoxFit.contain);
                  }
                  return Container(
                    alignment: Alignment.center,
                    color: AppColors.backgroundLight,
                    child: Text(
                      stock.stockCode.isNotEmpty ? stock.stockCode[0] : '',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryDark, // Fallback
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stock.stockName ?? stock.stockCode,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${stock.stockCode} · KOSPI",
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: context.theme.brightness == Brightness.light
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,
      surfaceTintColor: context.theme.brightness == Brightness.light
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: context.theme.brightness == Brightness.light
              ? Colors.grey[200]
              : Colors.grey[800],
          height: 1.0,
        ),
      ),
    );
  }
}
