import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:lucy_assignment/src/feature/stock_detail/presentation/providers/scroll_sync_provider.dart';

class SectionDetector extends StatelessWidget {
  final int index;
  final Widget child;

  const SectionDetector({required this.index, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('section_$index'),
      onVisibilityChanged: (info) {
        if (!context.mounted) return;
        context.read<ScrollSyncProvider>().updateVisibility(
          index,
          info.visibleFraction,
        );
      },
      child: child,
    );
  }
}
