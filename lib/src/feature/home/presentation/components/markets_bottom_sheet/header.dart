import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/get_logo_file_usecase.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class MarketsBottomSheetHeader extends StatelessWidget {
  final StockEntity stock;
  const MarketsBottomSheetHeader({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Logo
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.theme.brightness == Brightness.light
                      ? Colors.grey[100]
                      : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<File?>(
                  future: sl<GetLogoFileUseCase>().call(stock.stockCode),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return ClipOval(
                        child: Image.file(snapshot.data!, fit: BoxFit.cover),
                      );
                    }
                    return Icon(Icons.laptop_mac, color: AppColors.primary);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.stockName,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    stock.stockCode,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // IconButton(
          //   onPressed: () => Navigator.pop(context),
          //   icon: Icon(Icons.close, color: AppColors.textSecondary),
          //   style: IconButton.styleFrom(
          //     backgroundColor: context.theme.brightness == Brightness.light
          //         ? Colors.grey[100]
          //         : AppColors.surfaceDark,
          //   ),
          // ),
        ],
      ),
    );
  }
}
