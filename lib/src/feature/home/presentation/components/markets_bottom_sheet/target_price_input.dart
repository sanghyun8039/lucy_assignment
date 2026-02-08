import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/core/utils/formatters/price_input_formatter.dart';

class TargetPriceInput extends StatelessWidget {
  final TextEditingController controller;
  const TargetPriceInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.targetPrice,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textAlign: TextAlign.end,
            cursorRadius: Radius.circular(16),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              MaxValueInputFormatter(),
              PriceInputFormatter(),
            ],
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              suffixText: 'KRW',
              suffixStyle: AppTypography.titleLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: context.theme.brightness == Brightness.light
                  ? Colors.grey[50]
                  : AppColors.surfaceDark.withValues(alpha: 0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: context.theme.brightness == Brightness.light
                      ? Colors.grey[100]!
                      : Colors.grey[800]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: context.theme.brightness == Brightness.light
                      ? Colors.grey[100]!
                      : Colors.grey[800]!,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MaxValueInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // 숫자만 추출
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 비어있으면 허용 (삭제 시)
    if (newText.isEmpty) return newValue;

    // int 범위 체크 (tryParse가 실패하면 오버플로우)
    if (int.tryParse(newText) == null) {
      return oldValue;
    }

    return newValue;
  }
}
