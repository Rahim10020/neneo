import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/trip_provider.dart';

class CalculatePriceButton extends StatelessWidget {
  final bool canCalculate;
  final VoidCallback onPressed;

  const CalculatePriceButton({
    super.key,
    required this.canCalculate,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canCalculate && !tripProvider.isCalculating
                ? onPressed
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: canCalculate
                  ? AppColors.primary
                  : AppColors.gray300,
              disabledBackgroundColor: AppColors.gray300,
            ),
            child: tripProvider.isCalculating
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Calculer le prix',
                        style: AppTextStyles.button.copyWith(
                          color: canCalculate
                              ? AppColors.textPrimary
                              : AppColors.gray500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.calculate,
                        size: 20,
                        color: canCalculate
                            ? AppColors.textPrimary
                            : AppColors.gray500,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
