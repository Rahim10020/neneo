import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'widgets/price_card.dart';
import 'widgets/price_breakdown.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const ResultScreen({super.key, required this.tripData});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showBreakdown = false;

  // Mock calculation - replace with actual service
  Map<String, int> _calculatePrice() {
    return {'min': 680, 'ideal': 800, 'max': 920};
  }

  void _sharePrice() {
    final price = _calculatePrice();
    Share.share(
      'Prix estimé pour mon trajet:\n'
      '${widget.tripData['origin']} → ${widget.tripData['destination']}\n'
      '${price['ideal']} CFA (${price['min']}-${price['max']} CFA)\n\n'
      'Télécharge neneo? pour ne plus te faire arnaquer!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final prices = _calculatePrice();

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
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Distance badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.motorcycle,
                          color: AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text('4.2 km', style: AppTextStyles.h3),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Price Card
                    PriceCard(
                      idealPrice: prices['ideal']!,
                      minPrice: prices['min']!,
                      maxPrice: prices['max']!,
                    ),

                    const SizedBox(height: 24),

                    // Breakdown toggle
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showBreakdown = !_showBreakdown;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Comment nous calculons',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _showBreakdown
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_showBreakdown) ...[
                      const SizedBox(height: 16),
                      const PriceBreakdown(
                        basePrice: 600,
                        nightSurcharge: 180,
                        total: 780,
                      ),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sharePrice,
                      icon: Icon(
                        Icons.share_outlined,
                        color: AppColors.textPrimary,
                      ),
                      label: Text(
                        'Partager',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.gray300, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.directions_walk,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      label: Text('Nouvelle'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
