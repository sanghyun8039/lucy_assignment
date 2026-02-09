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

    Future.delayed(duration, () {
      _isProgrammaticScroll = false;
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

    final sortedEntries = _visibilityMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (var entry in sortedEntries) {
      if (entry.value > maxFraction) {
        maxFraction = entry.value;
        newIndex = entry.key;
      }
    }
    if (_activeIndex != newIndex && maxFraction > 0.05) {
      _activeIndex = newIndex;
      notifyListeners();
    }
  }
}
