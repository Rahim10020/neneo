import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final bool canAccessHistory;
  final VoidCallback onTapHistory;
  final VoidCallback onTapHistoryLocked;
  final VoidCallback onTapSettings;

  const HomeHeader({
    super.key,
    required this.canAccessHistory,
    required this.onTapHistory,
    required this.onTapHistoryLocked,
    required this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppConstants.appName, style: AppTextStyles.brandLogoSmall),
        Row(
          children: [
            GestureDetector(
              onTap: canAccessHistory ? onTapHistory : onTapHistoryLocked,
              child: Icon(
                Icons.motorcycle,
                color: canAccessHistory
                    ? AppColors.textPrimary
                    : AppColors.gray300,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onTapSettings,
              child: Icon(
                Icons.settings_outlined,
                color: AppColors.textPrimary,
                size: 26,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
