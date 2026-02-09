import 'package:flutter/widgets.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/section_widget.dart';
import 'package:lucy_assignment/src/feature/stock/domain/entities/stock_entity.dart';

class SummarySection extends StatelessWidget {
  final StockEntity stock;
  const SummarySection({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: context.l10n.summary),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              stock.summary,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
