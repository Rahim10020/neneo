import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../services/location_service.dart';
import 'location_button.dart';

class TripLocationsCard extends StatelessWidget {
  final PlaceResult? originPlace;
  final PlaceResult? destinationPlace;
  final VoidCallback onSelectOrigin;
  final VoidCallback onSelectDestination;
  final VoidCallback onSwapLocations;

  const TripLocationsCard({
    super.key,
    required this.originPlace,
    required this.destinationPlace,
    required this.onSelectOrigin,
    required this.onSelectDestination,
    required this.onSwapLocations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline verticale (origine / destination)
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error,
                ),
              ),
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Contenu des deux champs
          Expanded(
            child: Column(
              children: [
                // Ligne origine
                GestureDetector(
                  onTap: onSelectOrigin,
                  child: LocationButton(
                    label: 'POINT DE DÉPART',
                    selectedPlace: originPlace,
                    icon: Icons.radio_button_checked,
                    iconColor: AppColors.error,
                    onTap: onSelectOrigin,
                  ),
                ),
                const Divider(
                  height: 16,
                  thickness: 0.7,
                  color: AppColors.gray300,
                ),
                // Ligne destination
                GestureDetector(
                  onTap: onSelectDestination,
                  child: LocationButton(
                    label: 'DESTINATION',
                    selectedPlace: destinationPlace,
                    icon: Icons.location_on,
                    iconColor: AppColors.success,
                    onTap: onSelectDestination,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Bouton swap
          GestureDetector(
            onTap: onSwapLocations,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray300, width: 1),
              ),
              child: const Icon(
                Icons.swap_vert,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
