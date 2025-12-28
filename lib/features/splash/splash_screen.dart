import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait 2 seconds for splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if first launch
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool(AppConstants.keyFirstLaunch) ?? true;

    if (isFirstLaunch) {
      // Go to onboarding
      Navigator.pushReplacementNamed(context, AppConstants.routeOnboarding);
    } else {
      // Go directly to home
      Navigator.pushReplacementNamed(context, AppConstants.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(AppConstants.appName, style: AppTextStyles.splashBrand),
      ),
    );
  }
}
