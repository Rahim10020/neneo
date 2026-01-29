import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class NoResultsState extends StatelessWidget {
  const NoResultsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.gray500),
          const SizedBox(height: 16),
          Text(
            'Aucun lieu trouvé',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}
