class AppConstants {
  // App Info
  static const String appName = 'neneo?';
  static const String version = '1.0.0';

  // Routes
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeHome = '/home';
  static const String routeResult = '/result';
  static const String routeSettings = '/settings';
  static const String routeHistory = '/history';
  static const String routeLogin = '/login';
  static const String routePhoneVerification = '/phone-verification';
  static const String routePayment = '/payment';

  // Storage Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyCurrentUser = 'current_user';
  static const String keyLanguage = 'language';
  static const String keyDefaultVehicle = 'default_vehicle';
  static const String keyHistoryEnabled = 'history_enabled';

  // Languages
  static const String langFrench = 'fr';
  static const String langEwe = 'ewe';

  // Vehicle Types
  static const String vehicleMoto = 'moto';
  static const String vehicleTaxi = 'taxi';

  // Pricing
  static const int motoBaseRate = 100; // CFA per km
  static const int taxiBaseRate = 150; // CFA per km
  static const int motoMinPrice = 200; // CFA
  static const int taxiMinPrice = 500; // CFA
  static const double nightMultiplier = 1.30; // +30%
  static const double weekendMultiplier = 1.20; // +20%

  // Tarifs
  static const String tarifNuit = "Tarif de nuit: +30%";
  static const String tariWeekend = "Tarif de weekend: +20%";

  // Pro Subscription
  static const int proMonthlyPrice = 500; // CFA
  static const int proYearlyPrice = 5000; // CFA (save 1000)

  // Limits
  static const int freeTripsPerDay = 10;
  static const int maxHistoryFree = 0; // No history for free users

  // Contact
  static const String supportEmail = 'rahim100codeur@gmail.com';
  static const String supportPhone = '+228 91 79 61 15';
  static const String supportWhatsApp = '+228 91 79 61 15';
  static const String indicatifNumero = '+228';
  static const String hintNumber = '90 00 00 00';

  // URLs
  static const String privacyPolicyUrl = 'https://neneo.app/privacy';
  static const String termsOfServiceUrl = 'https://neneo.app/terms';
  static const String websiteUrl = 'https://neneo.app';

  // Lomé Coordinates (default map center)
  static const double lomeDefaultLat = 6.1319;
  static const double lomeDefaultLng = 1.2227;
}
