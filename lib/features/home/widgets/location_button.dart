import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../services/location_service.dart';

class LocationButton extends StatelessWidget {
  final String label;
  final PlaceResult? selectedPlace;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const LocationButton({
    super.key,
    required this.label,
    this.selectedPlace,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          border: Border.all(color: AppColors.gray500, width: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 11,
                color: AppColors.gray500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedPlace?.shortName ?? 'Choisir un lieu...',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selectedPlace != null
                          ? AppColors.textPrimary
                          : AppColors.gray500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.gray500, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
