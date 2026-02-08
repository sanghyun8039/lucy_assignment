import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/detail_sections.dart';

class KeyStatsSection extends StatelessWidget {
  final StockEntity stock;

  const KeyStatsSection({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: context.l10n.investmentIndicators),
          Gap(16),

          // 2열 Grid Layout
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatItem(
                context,
                context.l10n.volume,
                "${formatter.format(stock.accumulatedVolume)}주",
              ),
              _buildStatItem(
                context,
                context.l10n.marketCap,
                "${formatter.format(stock.marketCap)}억",
              ), // 단위 변환 필요 가정
              _buildStatItem(
                context,
                context.l10n.listedShares,
                "${formatter.format(stock.listedShares)}주",
              ),
              _buildStatItem(
                context,
                context.l10n.marketWeight,
                "${stock.marketWeight}%",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (MediaQuery.of(context).size.width - 32 - 16) / 2;
        return Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.theme.brightness == Brightness.light
                  ? Colors.grey[200]!
                  : Colors.grey[800]!,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
