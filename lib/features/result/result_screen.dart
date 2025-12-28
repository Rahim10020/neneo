import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../shared/models/trip_model.dart';
import '../../providers/trip_provider.dart';
import 'widgets/price_card.dart';
import 'widgets/price_breakdown.dart';

class ResultScreen extends StatefulWidget {
  final Trip trip;

  const ResultScreen({super.key, required this.trip});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showBreakdown = false;

  void _sharePrice() {
    final vehicleName = widget.trip.vehicleDisplayName;

    Share.share(
      '🚕 Prix estimé pour mon trajet neneo?\n\n'
      '📍 ${widget.trip.route}\n'
      '🛵 $vehicleName\n'
      '📏 ${widget.trip.distance.toStringAsFixed(1)} km\n'
      '💰 ${widget.trip.price} CFA (${widget.trip.minPrice}-${widget.trip.maxPrice} CFA)\n\n'
      '${widget.trip.isNightRate ? "🌙 Tarif de nuit (+30%)\n" : ""}'
      '${widget.trip.isWeekendRate ? "📅 Tarif weekend (+20%)\n" : ""}\n'
      'Télécharge neneo? pour ne plus te faire arnaquer !\n'
      'https://play.google.com/store/apps/details?id=com.neneo.taxifare',
    );
  }

  void _reportPrice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Signaler un prix incorrect', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quel prix vous a-t-on demandé ?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex: 1000',
                suffixText: 'CFA',
                filled: true,
                fillColor: AppColors.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Merci de nous aider à améliorer nos estimations !',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Merci pour votre retour !'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _newCalculation() {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    tripProvider.resetCurrentTrip();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);
    final breakdown = tripProvider.getPriceBreakdown();

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
                          widget.trip.vehicleType == 'moto'
                              ? Icons.motorcycle
                              : Icons.local_taxi,
                          color: widget.trip.vehicleType == 'moto'
                              ? AppColors.textPrimary
                              : AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.trip.distance.toStringAsFixed(1)} km',
                          style: AppTextStyles.h3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Route
                    Text(
                      widget.trip.route,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Price Card
                    PriceCard(
                      idealPrice: widget.trip.price,
                      minPrice: widget.trip.minPrice,
                      maxPrice: widget.trip.maxPrice,
                    ),

                    const SizedBox(height: 16),

                    // Active multipliers badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (widget.trip.isNightRate)
                          _MultiplierBadge(
                            icon: Icons.nightlight_round,
                            label: 'Tarif nuit +30%',
                          ),
                        if (widget.trip.isWeekendRate)
                          _MultiplierBadge(
                            icon: Icons.calendar_today,
                            label: 'Weekend +20%',
                          ),
                      ],
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

                    if (_showBreakdown && breakdown != null) ...[
                      const SizedBox(height: 16),
                      PriceBreakdown(
                        items: breakdown['items'],
                        total: breakdown['total'],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Report incorrect price button
                    TextButton.icon(
                      onPressed: _reportPrice,
                      icon: Icon(
                        Icons.flag_outlined,
                        color: AppColors.error,
                        size: 18,
                      ),
                      label: Text(
                        'Signaler un prix incorrect',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

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
                    color: Colors.black.withValues(alpha: 0.05),
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
                      onPressed: _newCalculation,
                      icon: Icon(
                        Icons.directions_walk,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      label: const Text('Nouvelle'),
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

class _MultiplierBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MultiplierBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
