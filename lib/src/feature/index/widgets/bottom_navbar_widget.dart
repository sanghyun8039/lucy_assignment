import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';

class BottomNavbarWidget extends StatelessWidget {
  final int currentIndex;
  final void Function(int index) onTap;
  final List<BottomNavigationBarItem> bottomNavigationBarItems;
  const BottomNavbarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.bottomNavigationBarItems,
  });

  @override
  Widget build(BuildContext context) {
    final entries = bottomNavigationBarItems.asMap().entries;

    final navItems = entries.map((entry) {
      final isSelected = currentIndex == entry.key;
      return _buildBottomNavItem(context, entry.key, entry.value, isSelected);
    }).toList();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(
        8,
      ).add(EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: navItems,
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    int index,
    BottomNavigationBarItem item,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 24.h,
                width: 24.w,
                child: isSelected ? item.activeIcon : item.icon,
              ),
              Gap(6),
              Text(
                item.label ?? "",
                style: isSelected
                    ? theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                      )
                    : theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
