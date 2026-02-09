import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/setting/presentation/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class ThemeSectionWidget extends StatelessWidget {
  const ThemeSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.themeMode == ThemeMode.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            context.l10n.theme,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
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
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.dark_mode,
                        color: Colors.blue,
                        size: 20.sp,
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Text(
                        context.l10n.themeMode,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Segmented Control Style
                    Container(
                      height: 36.h,
                      width: 160.w,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: context.theme.brightness == Brightness.light
                            ? Colors.grey[100]
                            : Colors.grey[900],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  settings.setThemeMode(ThemeMode.light),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isDark
                                      ? context.theme.cardColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6.r),
                                  boxShadow: !isDark
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  context.l10n.light,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: !isDark
                                        ? context
                                              .theme
                                              .textTheme
                                              .bodyMedium!
                                              .color
                                        : AppColors.textSecondary,
                                    fontWeight: !isDark
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  settings.setThemeMode(ThemeMode.dark),
                              child: Container(
                                decoration: BoxDecoration(
                                  // In dark mode, cardColor is dark, so better use lighter gray for 'selected' look or just context.cardColor
                                  // Actually, simple logic:
                                  /*color: isDark
                                      ? (context.theme.brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors
                                                  .grey[800]) // Adjust for dark context if needed
                                      : Colors.transparent,*/
                                  // In dark mode, cardColor is dark, so better use lighter gray for 'selected' look or just context.cardColor
                                  // Actually, simple logic:
                                  color: isDark
                                      ? context
                                            .theme
                                            .cardColor // This should be distinct from background
                                      : Colors.transparent,
                                  boxShadow: isDark
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  context.l10n.dark,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isDark
                                        ? context
                                              .theme
                                              .textTheme
                                              .bodyMedium!
                                              .color
                                        : AppColors.textSecondary,
                                    fontWeight: isDark
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
