import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class LocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;

  const LocationSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Rechercher un lieu...',
          hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray500),
          prefixIcon: const Icon(Icons.search, color: AppColors.gray500),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.gray500),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: AppColors.gray100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
