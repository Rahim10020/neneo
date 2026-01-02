import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../services/location_service.dart';

class LocationSuggestionTile extends StatelessWidget {
  final PlaceResult place;
  final VoidCallback onTap;

  const LocationSuggestionTile({
    super.key,
    required this.place,
    required this.onTap,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'airport':
        return Icons.flight;
      case 'market':
        return Icons.store;
      case 'port':
        return Icons.directions_boat;
      case 'university':
        return Icons.school;
      case 'stadium':
        return Icons.sports_soccer;
      case 'hospital':
        return Icons.local_hospital;
      case 'neighborhood':
        return Icons.location_city;
      case 'road':
        return Icons.route;
      case 'junction':
        return Icons.merge_type;
      default:
        return Icons.place;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'airport':
        return AppColors.primary;
      case 'market':
        return AppColors.success;
      case 'neighborhood':
        return AppColors.secondary;
      default:
        return AppColors.gray500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.gray100, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColorForType(place.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(place.type),
                color: _getColorForType(place.type),
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.shortName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (place.neighbourhood != null || place.road != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      place.neighbourhood ?? place.road ?? '',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Flèche
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.gray500,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
