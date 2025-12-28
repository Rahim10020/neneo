import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // Singleton pattern
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Fedapay configuration (use environment variables in production)
  static const String _fedapayApiKey =
      'YOUR_FEDAPAY_API_KEY'; // Replace with actual key
  static const String _fedapayBaseUrl = 'https://api.fedapay.com/v1';

  // Subscription price
  static const int _monthlyPriceXOF = 500;

  // ========== PAYMENT METHODS ==========

  Future<PaymentResponse> initializePayment({
    required String phoneNumber,
    required PaymentProvider provider,
    required String userId,
  }) async {
    try {
      // Create transaction
      final url = Uri.parse('$_fedapayBaseUrl/transactions');

      final body = {
        'description': 'Abonnement Pro neneo? - 1 mois',
        'amount': _monthlyPriceXOF,
        'currency': {'iso': 'XOF'},
        'customer': {
          'firstname': 'User',
          'lastname': userId,
          'email': '$userId@neneo.app',
          'phone_number': {'number': phoneNumber, 'country': 'tg'},
        },
        'callback_url': 'https://neneo.app/payment/callback',
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_fedapayApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentResponse(
          success: true,
          transactionId: data['id'] as String,
          message: 'Transaction initialisée',
        );
      }

      return PaymentResponse(
        success: false,
        message: 'Erreur lors de l\'initialisation',
      );
    } catch (e) {
      print('Payment initialization error: $e');
      return PaymentResponse(success: false, message: 'Erreur réseau: $e');
    }
  }

  // Verify payment status
  Future<PaymentStatus> verifyPayment(String transactionId) async {
    try {
      final url = Uri.parse('$_fedapayBaseUrl/transactions/$transactionId');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_fedapayApiKey'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String;

        switch (status.toLowerCase()) {
          case 'approved':
          case 'success':
            return PaymentStatus.success;
          case 'pending':
            return PaymentStatus.pending;
          case 'failed':
          case 'declined':
            return PaymentStatus.failed;
          default:
            return PaymentStatus.unknown;
        }
      }

      return PaymentStatus.unknown;
    } catch (e) {
      print('Payment verification error: $e');
      return PaymentStatus.unknown;
    }
  }

  // ========== SUBSCRIPTION MANAGEMENT ==========

  // Calculate subscription end date
  DateTime calculateSubscriptionEndDate({DateTime? startDate}) {
    final start = startDate ?? DateTime.now();
    return DateTime(start.year, start.month + 1, start.day);
  }

  // Check if subscription is active
  bool isSubscriptionActive(DateTime? expiryDate) {
    if (expiryDate == null) return false;
    return DateTime.now().isBefore(expiryDate);
  }

  // Days remaining in subscription
  int daysRemaining(DateTime? expiryDate) {
    if (expiryDate == null) return 0;
    if (!isSubscriptionActive(expiryDate)) return 0;
    return expiryDate.difference(DateTime.now()).inDays;
  }

  // ========== MOCK PAYMENT (for testing) ==========

  Future<PaymentResponse> mockPayment({
    required String phoneNumber,
    required PaymentProvider provider,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // 90% success rate in testing
    final random = DateTime.now().millisecond;
    final success = random % 10 != 0;

    return PaymentResponse(
      success: success,
      transactionId: success
          ? 'MOCK_${DateTime.now().millisecondsSinceEpoch}'
          : null,
      message: success ? 'Paiement réussi' : 'Paiement échoué',
    );
  }
}

// Payment provider enum
enum PaymentProvider { moov, mtn, togocom }

// Payment response model
class PaymentResponse {
  final bool success;
  final String? transactionId;
  final String message;

  PaymentResponse({
    required this.success,
    this.transactionId,
    required this.message,
  });
}

// Payment status enum
enum PaymentStatus { success, pending, failed, unknown }
