import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';

class AlertCondition extends StatelessWidget {
  final AlertType selectedType;
  final ValueChanged<AlertType> onChanged;

  const AlertCondition({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = selectedType.index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.s.alertCondition,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 44, // 고정 높이 지정이 애니메이션 구현에 유리합니다
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.theme.brightness == Brightness.light
                  ? Colors.grey[100]
                  : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              // Stack을 사용하여 배경 레이어와 버튼 레이어를 분리
              children: [
                // 1. 움직이는 배경 (Indicator)
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: Alignment(
                    -1.0 + (selectedIndex * 1.0), // -1.0(왼쪽), 0.0(중앙), 1.0(오른쪽)
                    0,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3, // 전체의 1/3 크기
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.theme.brightness == Brightness.light
                            ? Colors.grey[100]
                            : AppColors.overlayDark,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 2. 버튼 텍스트들 (투명한 버튼 레이어)
                Row(
                  children: [
                    _buildTextButton("상한가", AlertType.upper),
                    _buildTextButton("하한가", AlertType.lower),
                    _buildTextButton("양방향", AlertType.bidir),
                  ],
                ),
              ],
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(4),
          //   decoration: BoxDecoration(
          //     color: context.theme.brightness == Brightness.light
          //         ? Colors.grey[100]
          //         : AppColors.surfaceDark,
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: _buildSegmentButton(
          //           context,
          //           context.s.upper,
          //           AlertType.upper,
          //         ),
          //       ),
          //       Expanded(
          //         child: _buildSegmentButton(
          //           context,
          //           context.s.lower,
          //           AlertType.lower,
          //         ),
          //       ),
          //       Expanded(
          //         child: _buildSegmentButton(
          //           context,
          //           context.s.bidir,
          //           AlertType.bidir,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTextButton(String text, AlertType type) {
    final isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(type),
        child: Center(
          child: AnimatedDefaultTextStyle(
            // 글자 색상도 부드럽게 변경
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  // Widget _buildSegmentButton(
  //   BuildContext context,
  //   String text,
  //   AlertType type,
  // ) {
  //   final isSelected = selectedType == type;

  //   return GestureDetector(
  //     onTap: () => onChanged(type),
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 8),
  //       decoration: BoxDecoration(
  //         color: isSelected
  //             ? (context.theme.brightness == Brightness.light
  //                   ? Colors.white
  //                   : Colors.grey[700])
  //             : Colors.transparent,
  //         borderRadius: BorderRadius.circular(8),
  //         boxShadow: isSelected
  //             ? [
  //                 BoxShadow(
  //                   color: Colors.black.withValues(alpha: 0.05),
  //                   blurRadius: 2,
  //                   offset: const Offset(0, 1),
  //                 ),
  //               ]
  //             : null,
  //       ),
  //       child: Center(
  //         child: Text(
  //           text,
  //           style: AppTypography.bodySmall.copyWith(
  //             fontWeight: FontWeight.w600,
  //             color: isSelected ? AppColors.primary : AppColors.textSecondary,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
