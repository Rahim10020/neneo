import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String titleHighlight;
  final String subtitle;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.title,
    this.titleHighlight = '',
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder (replace with actual asset)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 80,
                color: AppColors.gray500,
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Title with highlight
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: AppTextStyles.h1,
              children: [
                TextSpan(text: title),
                if (titleHighlight.isNotEmpty)
                  TextSpan(
                    text: ' $titleHighlight',
                    style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
