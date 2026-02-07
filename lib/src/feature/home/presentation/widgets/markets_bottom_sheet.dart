import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/home/presentation/components/markets_bottom_sheet/alert_condition.dart';
import 'package:lucy_assignment/src/feature/home/presentation/components/markets_bottom_sheet/header.dart';
import 'package:lucy_assignment/src/feature/home/presentation/components/markets_bottom_sheet/price_info_card.dart';
import 'package:lucy_assignment/src/feature/home/presentation/components/markets_bottom_sheet/target_price_input.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/get_logo_file_usecase.dart';
import 'package:lucy_assignment/src/feature/watchlist/domain/entities/watchlist_item.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class MarketsBottomSheet extends StatefulWidget {
  final StockEntity? stock;
  final WatchlistItem? existingItem;

  const MarketsBottomSheet({super.key, required this.stock, this.existingItem});

  @override
  State<MarketsBottomSheet> createState() => _MarketsBottomSheetState();
}

class _MarketsBottomSheetState extends State<MarketsBottomSheet> {
  late final TextEditingController _targetPriceController;
  late AlertType _selectedType;

  @override
  void initState() {
    super.initState();
    final initialPrice = widget.existingItem?.targetPrice;
    _targetPriceController = TextEditingController(
      text: initialPrice != null
          ? NumberFormat("#,###").format(initialPrice)
          : '-',
    );
    _selectedType = widget.existingItem?.alertType ?? AlertType.upper;
  }

  @override
  void dispose() {
    _targetPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingItem != null;

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

              // Add/Update Watchlist Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final targetPrice = int.tryParse(
                        _targetPriceController.text.replaceAll(',', ''),
                      );
                      final item = WatchlistItem(
                        stockCode: widget.stock?.stockCode ?? "",
                        targetPrice: targetPrice,
                        alertType: _selectedType,
                        createdAt:
                            widget.existingItem?.createdAt ?? DateTime.now(),
                      );

                      await context.read<WatchlistProvider>().addWatchlistItem(
                        item,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditMode
                                  ? context.s.watchlistUpdated
                                  : context.s.watchlistAdded,
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
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
                      isEditMode ? context.s.update : context.s.addToWatchlist,
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
