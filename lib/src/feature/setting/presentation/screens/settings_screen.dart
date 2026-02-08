import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:lucy_assignment/src/feature/setting/presentation/widgets/localization_section_widget.dart';
import 'package:lucy_assignment/src/feature/setting/presentation/widgets/theme_section_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.l10n.settings,
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.theme.brightness == Brightness.light
            ? AppColors.backgroundLight
            : AppColors.backgroundDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          children: [
            ThemeSectionWidget(),
            Gap(32.h),
            LocalizationSectionWidget(),
            Gap(32.h),
          ],
        ),
      ),
    );
  }
}
