import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PriceCard extends StatelessWidget {
  final int idealPrice;
  final int minPrice;
  final int maxPrice;

  const PriceCard({
    super.key,
    required this.idealPrice,
    required this.minPrice,
    required this.maxPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Main price
          Text(
            '$idealPrice CFA',
            style: AppTextStyles.h1.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarif recommande',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // Price range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PriceLabel(label: 'Min', price: minPrice),
              _PriceLabel(label: 'Moyen', price: idealPrice),
              _PriceLabel(label: 'Max', price: maxPrice),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  final String label;
  final int price;

  const _PriceLabel({required this.label, required this.price});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '$price',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
