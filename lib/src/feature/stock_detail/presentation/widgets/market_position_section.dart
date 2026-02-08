import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/core/utils/parsers.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/widgets/detail_sections.dart';

class MarketPositionSection extends StatelessWidget {
  final int rank;
  final double weight;

  const MarketPositionSection({
    super.key,
    required this.rank,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: context.l10n.marketPosition),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildRankCard(context, rank),
              Gap(12),
              _buildWeightCard(context, weight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard(BuildContext context, int rank) {
    // 1~3위는 특별한 색상 적용 (아이콘/텍스트 색상만 유지, 배경은 카드 스타일로 통일)
    Color contentColor;
    IconData icon;

    switch (rank) {
      case 1:
        contentColor = const Color(0xFFFFB800); // 금색
        icon = Icons.emoji_events; // 트로피
        break;
      case 2:
        contentColor = const Color(0xFF9E9E9E); // 은색
        icon = Icons.emoji_events_outlined;
        break;
      case 3:
        contentColor = const Color(0xFFCD7F32); // 동색
        icon = Icons.emoji_events_outlined;
        break;
      default:
        contentColor = AppColors.textSecondary;
        icon = Icons.leaderboard;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: contentColor, size: 32),
          const SizedBox(height: 8),
          Text(
            context.l10n.kospiMarketCap,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "#$rank",
            style: AppTypography.headlineMedium.copyWith(
              color: contentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, double weight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 원형 차트 (CustomPaint 대신 간단히 CircularProgressIndicator 사용)
          SizedBox(
            height: 48,
            width: 48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: Parsers.parseDoubleToPercent(weight),
                  strokeWidth: 6,
                  backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    "$weight%",
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.marketWeight,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$weight%",
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
