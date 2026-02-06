import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/home/presentation/components/markets_bottom_sheet/alert_condition.dart';
import 'package:lucy_assignment/src/feature/home/presentation/components/markets_bottom_sheet/header.dart';
import 'package:lucy_assignment/src/feature/home/presentation/components/markets_bottom_sheet/price_info_card.dart';
import 'package:lucy_assignment/src/feature/home/presentation/components/markets_bottom_sheet/target_price_input.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/get_logo_file_usecase.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class MarketsBottomSheet extends StatefulWidget {
  final StockEntity stock;

  const MarketsBottomSheet({super.key, required this.stock});

  @override
  State<MarketsBottomSheet> createState() => _MarketsBottomSheetState();
}

class _MarketsBottomSheetState extends State<MarketsBottomSheet> {
  final TextEditingController _targetPriceController = TextEditingController();
  AlertType _selectedType = AlertType.upper;

  @override
  Widget build(BuildContext context) {
    final isRising = widget.stock.changeRate > 0;
    final isFalling = widget.stock.changeRate < 0;

    final Color priceColor = isRising
        ? AppColors.growth2
        : (isFalling
              ? AppColors.decline2
              : context.theme.brightness == Brightness.light
              ? AppColors.textPrimaryLight
              : AppColors.textPrimaryDark);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: context.theme.brightness == Brightness.light
                ? AppColors.backgroundLight
                : AppColors.backgroundDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.theme.brightness == Brightness.light
                        ? Colors.grey[300]
                        : Colors.grey[700],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header
              MarketsBottomSheetHeader(stock: widget.stock),
              // Price Info Card
              PriceInfoCard(stock: widget.stock),

              const SizedBox(height: 24),

              // Target Price Input
              TargetPriceInput(controller: _targetPriceController),
              const SizedBox(height: 24),

              // Alert Condition
              AlertCondition(
                selectedType: _selectedType,
                onChanged: (type) {
                  FocusScope.of(context).unfocus(); // 키보드 숨기기
                  setState(() {
                    _selectedType = type;
                  });
                },
              ),
              const SizedBox(height: 24),

              // // Push Notifications
              // const SizedBox(height: 24),

              // Add to Watchlist Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      context.s.addToWatchlist,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
