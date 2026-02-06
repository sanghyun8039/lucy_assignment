import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';

class StockSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const StockSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: context.s.searchBarPlaceholder,
          hintStyle: AppTypography.bodyLarge.copyWith(
            color: context.theme.brightness == Brightness.light
                ? AppColors.textPrimaryLight.withValues(alpha: 0.5)
                : AppColors.textPrimaryDark.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: context.theme.brightness == Brightness.light
              ? AppColors.backgroundLight
              : AppColors.backgroundDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
        style: AppTypography.bodyLarge.copyWith(
          color: context.theme.brightness == Brightness.light
              ? AppColors.textPrimaryLight
              : AppColors.textPrimaryDark,
        ),
      ),
    );
  }
}
