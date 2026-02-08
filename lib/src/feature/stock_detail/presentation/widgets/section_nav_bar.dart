import 'package:flutter/material.dart';
import 'package:lucy_assignment/src/core/utils/extensions/context_extension.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/core/design_system/design_system.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/providers/scroll_sync_provider.dart';

class SectionNavBarDelegate extends SliverPersistentHeaderDelegate {
  final Future<void> Function(int index) onTabTap;

  SectionNavBarDelegate({required this.onTabTap});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _SectionNavBarBody(onTabTap: onTabTap);
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _SectionNavBarBody extends StatefulWidget {
  final Future<void> Function(int index) onTabTap;

  const _SectionNavBarBody({required this.onTabTap});

  @override
  State<_SectionNavBarBody> createState() => _SectionNavBarBodyState();
}

class _SectionNavBarBodyState extends State<_SectionNavBarBody> {
  late List<String> _tabs;
  late List<GlobalKey> _tabKeys;
  final GlobalKey _listKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabs = [
      context.l10n.price,
      context.l10n.summary,
      context.l10n.input,
      context.l10n.details,
      context.l10n.investmentIndicators,
      context.l10n.marketPosition,
    ];
    _tabKeys = List.generate(_tabs.length, (_) => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ScrollSyncProvider>().addListener(_onActiveIndexChanged);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onActiveIndexChanged() {
    if (!mounted) return;
    final provider = context.read<ScrollSyncProvider>();
    final index = provider.activeIndex;

    final key = _tabKeys[index];
    final tabContext = key.currentContext;
    final listContext = _listKey.currentContext;

    if (tabContext != null && listContext != null) {
      final RenderBox tabBox = tabContext.findRenderObject() as RenderBox;
      final RenderBox listBox = listContext.findRenderObject() as RenderBox;

      final tabGlobal = tabBox.localToGlobal(Offset.zero);
      final listGlobal = listBox.localToGlobal(Offset.zero);

      final relativeX = tabGlobal.dx - listGlobal.dx;
      final currentScroll = _scrollController.offset;

      // Target position to center the tab
      final targetScroll =
          (currentScroll + relativeX) -
          (listBox.size.width / 2) +
          (tabBox.size.width / 2);

      _scrollController.animateTo(
        targetScroll.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.brightness == Brightness.light
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              key: _listKey,
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == _tabs.length - 1 ? 0 : 8,
                    ),
                    child: Center(
                      // Assign GlobalKey to each tab for scrolling
                      key: _tabKeys[index],
                      child: _TabButton(
                        label: _tabs[index],
                        index: index,
                        onTap: () => widget.onTabTap(index),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int index;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // We still use Selector to rebuild JUST the button style when active index changes
    return Selector<ScrollSyncProvider, int>(
      selector: (_, provider) => provider.activeIndex,
      builder: (context, activeIndex, _) {
        final isActive = activeIndex == index;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : (context.theme.brightness == Brightness.light
                        ? Colors.grey[200]
                        : AppColors.surfaceDark),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isActive
                    ? Colors.white
                    : (context.theme.brightness == Brightness.light
                          ? Colors.grey[700]
                          : Colors.grey[400]),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
