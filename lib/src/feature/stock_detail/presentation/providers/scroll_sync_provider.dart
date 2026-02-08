import 'package:flutter/material.dart';

class ScrollSyncProvider extends ChangeNotifier {
  final Map<int, double> _visibilityMap = {};
  int _activeIndex = 0;

  int get activeIndex => _activeIndex;
  bool _isProgrammaticScroll = false;

  void setTargetIndex(
    int index, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _activeIndex = index;
    _isProgrammaticScroll = true;
    notifyListeners();

    // Reset flag after animation completes
    Future.delayed(duration, () {
      _isProgrammaticScroll = false;
      // Optional: re-check visibility after scroll finishes?
      // _recalculateActiveIndex();
    });
  }

  void updateVisibility(int index, double fraction) {
    _visibilityMap[index] = fraction;
    if (!_isProgrammaticScroll) {
      _recalculateActiveIndex();
    }
  }

  void _recalculateActiveIndex() {
    int newIndex = _activeIndex;
    double maxFraction = -1.0;

    // Sort entries by index to prioritize top sections in case of ties
    final sortedEntries = _visibilityMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (var entry in sortedEntries) {
      if (entry.value > maxFraction) {
        maxFraction = entry.value;
        newIndex = entry.key;
      }
    }

    // Only update if there's a change and the new section is significantly visible
    // (e.g. at least 10% visible to avoid flickering on tiny overlaps)
    // However, if we scroll up, we want the top one.
    // The "maxFraction" logic handles most cases.
    // If multiple sections are 1.0 visible (small sections), the first one (sorted) wins.

    // We add a small condition: if the current active section is still > 0.5 visible, maybe keep it?
    // But "max fraction" is usually robust enough for standard lists.

    if (_activeIndex != newIndex && maxFraction > 0.05) {
      _activeIndex = newIndex;
      notifyListeners();
    }
  }
}
