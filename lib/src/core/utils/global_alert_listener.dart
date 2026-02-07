import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/design_system/typography.dart';
import 'package:lucy_assignment/src/core/constants/alert_type.dart';
import 'package:lucy_assignment/src/feature/watchlist/presentation/providers/watchlist_provider.dart';

class GlobalAlertListener extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalAlertListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<GlobalAlertListener> createState() => _GlobalAlertListenerState();
}

class _GlobalAlertListenerState extends State<GlobalAlertListener>
    with SingleTickerProviderStateMixin {
  StreamSubscription<AlertEvent>? _alertSubscription;
  OverlayEntry? _overlayEntry;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _alertSubscription = context.read<WatchlistProvider>().alertStream.listen(
        (event) {
          if (mounted) {
            _showTopToast(event);
          }
        },
      );
    });
  }

  void _showTopToast(AlertEvent event) {
    _overlayEntry?.remove();
    _timer?.cancel();
    _animationController.reset();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: event.type == AlertType.upper
                    ? AppColors
                          .growth // Red
                    : AppColors.decline, // Blue
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    event.type == AlertType.upper
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.message,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final overlay = widget.navigatorKey.currentState?.overlay;
    if (overlay != null) {
      overlay.insert(_overlayEntry!);
      _animationController.forward();

      _timer = Timer(const Duration(seconds: 3), () async {
        await _animationController.reverse();
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    _timer?.cancel();
    _overlayEntry?.remove();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
