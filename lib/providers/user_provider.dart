import 'package:flutter/foundation.dart';
import '../shared/models/user_model.dart';
import '../services/storage_service.dart';
import '../services/payment_service.dart';

class UserProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final PaymentService _paymentService = PaymentService();

  UserModel _user = UserModel.guest();
  bool _isLoading = false;

  UserModel get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user.id != 'guest';
  bool get isPro => _user.isProActive;

  // Initialize user from storage
  Future<void> init() async {
    _setLoading(true);

    final savedUser = await _storageService.getCurrentUser();
    if (savedUser != null) {
      _user = savedUser;
    }

    _setLoading(false);
  }

  // Login with phone number
  Future<bool> login(String phoneNumber) async {
    _setLoading(true);

    try {
      // Create new user
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Save to storage
      await _storageService.saveUser(newUser);
      _user = newUser;

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearUser();
    _user = UserModel.guest();
    notifyListeners();
  }

  // Update user settings
  Future<void> updateLanguage(String language) async {
    _user = _user.copyWith(preferredLanguage: language);
    await _storageService.saveUser(_user);
    await _storageService.saveLanguage(language);
    notifyListeners();
  }

  Future<void> updateDefaultVehicle(String vehicle) async {
    _user = _user.copyWith(defaultVehicle: vehicle);
    await _storageService.saveUser(_user);
    await _storageService.saveDefaultVehicle(vehicle);
    notifyListeners();
  }

  Future<void> updateHistoryEnabled(bool enabled) async {
    _user = _user.copyWith(historyEnabled: enabled);
    await _storageService.saveUser(_user);
    await _storageService.saveHistoryEnabled(enabled);
    notifyListeners();
  }

  // Upgrade to Pro
  Future<bool> upgradeToPro(String transactionId) async {
    _setLoading(true);

    try {
      // Verify payment
      final status = await _paymentService.verifyPayment(transactionId);

      if (status == PaymentStatus.success) {
        // Calculate expiry date (1 month)
        final expiryDate = _paymentService.calculateSubscriptionEndDate();

        // Update user
        _user = _user.copyWith(
          isPro: true,
          proExpiresAt: expiryDate,
          historyEnabled: true,
        );

        await _storageService.saveUser(_user);

        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      print('Upgrade error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Cancel Pro subscription
  Future<void> cancelPro() async {
    _user = _user.copyWith(
      isPro: false,
      proExpiresAt: null,
      historyEnabled: false,
    );

    await _storageService.saveUser(_user);
    notifyListeners();
  }

  // Check and update Pro status
  Future<void> checkProStatus() async {
    if (_user.isPro && !_user.isProActive) {
      // Subscription expired
      await cancelPro();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
