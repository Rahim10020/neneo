import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'widgets/payment_method_card.dart';

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

    setState(() => _isProcessing = true);

    // Simulate payment
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    // Show success
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
                color: AppColors.success.withOpacity(0.1),
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
              'Paiement réussi!',
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Paiement', style: AppTextStyles.h2),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '500 FCFA',
                            style: AppTextStyles.h1.copyWith(fontSize: 48),
                          ),
                          Text('par mois', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),

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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  child: _isProcessing
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : Text('Payer 500 FCFA'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
