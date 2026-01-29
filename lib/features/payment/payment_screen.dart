import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../services/payment_service.dart';
import 'widgets/payment_method_card.dart';
import 'widgets/payment_header.dart';
import 'widgets/payment_amount.dart';
import 'widgets/payment_pay_button_bar.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selectedMethod;
  bool _isProcessing = false;

  void _processPayment() async {
    if (_selectedMethod == null) {
      _showError('Veuillez sélectionner un mode de paiement');
      return;
    }

    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user.phoneNumber.isEmpty) {
      _showError(
        'Aucun numéro associé. Connectez-vous avant de procéder au paiement.',
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Utiliser le paiement mock pour simuler l’appel Fedapay
    final paymentProvider = _mapToPaymentProvider(_selectedMethod!);
    final paymentResponse = await PaymentService().mockPayment(
      phoneNumber: user.phoneNumber,
      provider: paymentProvider,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (!paymentResponse.success || paymentResponse.transactionId == null) {
      _showError(paymentResponse.message);
      return;
    }

    // Activer réellement le compte Pro
    final upgraded = await userProvider.upgradeToPro(
      paymentResponse.transactionId!,
    );

    if (!upgraded) {
      _showError(
        'Votre paiement a été validé, mais nous n\'avons pas pu activer votre abonnement. Réessayez plus tard.',
      );
      return;
    }

    // Afficher le succes une fois le compte Pro active
    _showSuccess();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Paiement réussi !',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vous êtes maintenant membre Pro',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Continuer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            PaymentHeader(onBack: () => Navigator.pop(context)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount
                    const PaymentAmount(),

                    const SizedBox(height: 40),

                    Text(
                      'CHOISIR UN MODE DE PAIEMENT',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 11,
                        color: AppColors.gray500,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment methods
                    PaymentMethodCard(
                      method: PaymentMethod.moov,
                      label: 'Moov Money',
                      icon: Icons.phone_android,
                      isSelected: _selectedMethod == PaymentMethod.moov,
                      onTap: () =>
                          setState(() => _selectedMethod = PaymentMethod.moov),
                    ),

                    const SizedBox(height: 12),

                    PaymentMethodCard(
                      method: PaymentMethod.mtn,
                      label: 'MTN Mobile Money',
                      icon: Icons.phone_iphone,
                      isSelected: _selectedMethod == PaymentMethod.mtn,
                      onTap: () =>
                          setState(() => _selectedMethod = PaymentMethod.mtn),
                    ),

                    const SizedBox(height: 12),

                    PaymentMethodCard(
                      method: PaymentMethod.togocom,
                      label: 'Togocom Money',
                      icon: Icons.smartphone,
                      isSelected: _selectedMethod == PaymentMethod.togocom,
                      onTap: () => setState(
                        () => _selectedMethod = PaymentMethod.togocom,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pay button
            PaymentPayButtonBar(
              isProcessing: _isProcessing,
              onPay: _processPayment,
            ),
          ],
        ),
      ),
    );
  }

  PaymentProvider _mapToPaymentProvider(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.moov:
        return PaymentProvider.moov;
      case PaymentMethod.mtn:
        return PaymentProvider.mtn;
      case PaymentMethod.togocom:
        return PaymentProvider.togocom;
    }
  }
}
