import 'package:flutter/material.dart';
import 'package:neneo/core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum VehicleType { zemidjan, taxi }

class VehicleSelector extends StatelessWidget {
  final VehicleType selectedVehicle;
  final Function(VehicleType) onVehicleSelected;

  const VehicleSelector({
    super.key,
    required this.selectedVehicle,
    required this.onVehicleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _VehicleCard(
            type: VehicleType.zemidjan,
            icon: Icons.motorcycle,
            label: 'Zemidjan',
            pricePerKm: "${AppConstants.motoBaseRate} CFA/km",
            isSelected: selectedVehicle == VehicleType.zemidjan,
            onTap: () => onVehicleSelected(VehicleType.zemidjan),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _VehicleCard(
            type: VehicleType.taxi,
            icon: Icons.local_taxi,
            label: 'Taxi',
            pricePerKm: "${AppConstants.taxiBaseRate} CFA/km",
            isSelected: selectedVehicle == VehicleType.taxi,
            onTap: () => onVehicleSelected(VehicleType.taxi),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleType type;
  final IconData icon;
  final String label;
  final String pricePerKm;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.type,
    required this.icon,
    required this.label,
    required this.pricePerKm,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 32, color: AppColors.textPrimary),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(pricePerKm, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
