import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/result/result_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/phone_verification_screen.dart';
import '../../features/payment/payment_screen.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeSplash:
        return _buildRoute(const SplashScreen());

      case AppConstants.routeOnboarding:
        return _buildRoute(const OnboardingScreen());

      case AppConstants.routeHome:
        return _buildRoute(const HomeScreen());

      case AppConstants.routeResult:
        final args = settings.arguments as Map<String, dynamic>;
        final trip = args['trip'];
        return _buildRoute(ResultScreen(trip: trip));

      case AppConstants.routeSettings:
        return _buildRoute(const SettingsScreen());

      case AppConstants.routeHistory:
        return _buildRoute(const HistoryScreen());

      case '/login':
        return _buildRoute(const LoginScreen());

      case '/phone-verification':
        final phoneNumber = settings.arguments as String;
        return _buildRoute(PhoneVerificationScreen(phoneNumber: phoneNumber));

      case '/payment':
        return _buildRoute(const PaymentScreen());

      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
