import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/feature/index/domain/entities/bottom_navbar_item_entity.dart';
import 'package:lucy_assignment/src/feature/index/widgets/bottom_navbar_widget.dart';

class IndexScreen extends StatefulWidget {
  final GoRouterState state;
  final StatefulNavigationShell child;

  const IndexScreen({super.key, required this.state, required this.child});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  List<BottomNavbarItemEntity> bottomNavbarItems = [
    BottomNavbarItemEntity(
      destinationRoute: "/home",
      item: BottomNavigationBarItem(
        icon: Icon(Icons.home, color: AppColors.textSecondary),
        activeIcon: Icon(Icons.home, color: AppColors.primary),
        label: "Home",
      ),
    ),
    BottomNavbarItemEntity(
      destinationRoute: "/watchlist",
      item: BottomNavigationBarItem(
        icon: Icon(Icons.watch_later, color: AppColors.textSecondary),
        activeIcon: Icon(Icons.watch_later, color: AppColors.primary),
        label: "Watchlist",
      ),
    ),
  ];

  void onItemClicked(int index) {
    widget.child.goBranch(
      index,
      initialLocation: index == widget.child.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [Flexible(child: widget.child)]),
      bottomNavigationBar: BottomNavbarWidget(
        currentIndex: widget.child.currentIndex,
        onTap: onItemClicked,
        bottomNavigationBarItems: bottomNavbarItems
            .map((item) => item.item)
            .toList(),
      ),
    );
  }
}
