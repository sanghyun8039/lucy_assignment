import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/setting/presentation/providers/settings_provider.dart';
import 'package:lucy_assignment/src/feature/setting/presentation/components/language_item.dart';
import 'package:provider/provider.dart';

class LocalizationSectionWidget extends StatelessWidget {
  const LocalizationSectionWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currentLocale = settings.locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            context.l10n.localization,
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  color: context.theme.brightness == Brightness.light
                      ? Colors.grey[50]
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  context.l10n.language,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              LanguageItem(
                locale: const Locale('en'),
                title: context.l10n.english,
                isSelected: currentLocale.languageCode == 'en',
                onTap: () => settings.setLocale(const Locale('en')),
              ),
              Divider(
                height: 1,
                color: context.theme.dividerColor.withValues(alpha: 0.1),
              ),
              LanguageItem(
                locale: const Locale('ko'),
                title: context.l10n.korean,
                isSelected: currentLocale.languageCode == 'ko',
                onTap: () => settings.setLocale(const Locale('ko')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
