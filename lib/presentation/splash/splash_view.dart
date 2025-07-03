import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {


  final prefs = getIt<SharedPreferenceHelper>();

  void checkLoginStatus() {
    final isLoggedIn = prefs.isLoggedIn;
    debugPrint('Is user logged in: $isLoggedIn');
    if (isLoggedIn) {
      // Navigate to home or main screen
      context.goNamed(AppRoutes.mainNav);
    } else {
      // Navigate to login screen
      context.goNamed(AppRoutes.login);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Image.asset('assets/splash.png', fit: BoxFit.fitHeight)),
      ),
    );
  }
}
