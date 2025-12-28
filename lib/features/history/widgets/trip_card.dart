import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/models/trip_model.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route
          Row(
            children: [
              Expanded(
                child: Text(
                  '${trip.origin} → ${trip.destination}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${trip.price} F',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Vehicle info & distance
          Row(
            children: [
              Icon(
                trip.vehicleType == 'moto'
                    ? Icons.motorcycle
                    : Icons.local_taxi,
                color: trip.vehicleType == 'moto'
                    ? AppColors.textPrimary
                    : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                trip.vehicleType == 'moto' ? 'Moto' : 'Taxi',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('EEE, HH:mm').format(trip.timestamp),
                style: AppTextStyles.bodyMedium,
              ),
              const Spacer(),
              Text(
                '${trip.distance.toStringAsFixed(1)} km',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
