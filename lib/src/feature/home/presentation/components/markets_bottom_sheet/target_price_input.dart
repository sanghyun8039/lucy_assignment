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
            context.s.targetPrice,
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
              PriceInputFormatter(),
            ],
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              suffixText: '원',
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
