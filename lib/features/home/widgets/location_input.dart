import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../services/location_service.dart';

class LocationInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final List<PlaceResult> suggestions;
  final bool isLoading;
  final Function(PlaceResult) onSuggestionSelected;

  const LocationInput({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.suggestions,
    required this.isLoading,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray100,
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
                    child: TextField(
                      controller: controller,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un lieu...',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.gray500,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        suffixIcon: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Suggestions dropdown
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.gray300, height: 1),
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return InkWell(
                  onTap: () => onSuggestionSelected(suggestion),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForType(suggestion.type),
                          color: AppColors.gray500,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.shortName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (suggestion.neighbourhood != null ||
                                  suggestion.road != null)
                                Text(
                                  suggestion.neighbourhood ??
                                      suggestion.road ??
                                      '',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 12,
                                    color: AppColors.gray500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'airport':
        return Icons.flight;
      case 'market':
        return Icons.shopping_bag;
      case 'university':
        return Icons.school;
      case 'hospital':
        return Icons.local_hospital;
      case 'stadium':
        return Icons.stadium;
      case 'current':
        return Icons.my_location;
      default:
        return Icons.place;
    }
  }
}
