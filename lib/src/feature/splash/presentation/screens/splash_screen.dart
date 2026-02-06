import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucy_assignment/src/core/design_system/colors.dart';
import 'package:lucy_assignment/src/core/router/app_route_name.dart';
import 'package:lucy_assignment/src/core/di/service_locator.dart';
import 'package:lucy_assignment/src/feature/logo/domain/usecases/sync_logos_usecase.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Run minimal delay and logo sync in parallel
    // Ensuring splash shows for at least 2 seconds
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      sl<SyncLogosUseCase>().call(),
    ]);

    if (mounted) {
      context.goNamed(AppRouteName.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.overlayLight,
      body: Center(child: SvgPicture.asset('assets/images/lucy_logo.svg')),
    );
  }
}
