import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String titleStart;
  final String titleEnd;
  final String titleHighlight;
  final String subtitle;

  const OnboardingPage({
    super.key,
    required this.imagePath,
    required this.titleStart,
    required this.titleEnd,
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
          Image.asset(imagePath),
          const SizedBox(height: 40),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with highlight
              RichText(
                textAlign: TextAlign.left,
                softWrap: true,
                text: TextSpan(
                  style: AppTextStyles.h1,
                  children: [
                    TextSpan(text: "$titleStart "),
                    if (titleHighlight.isNotEmpty)
                      TextSpan(
                        text: ' $titleHighlight',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    TextSpan(text: " $titleEnd"),
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
        ],
      ),
    );
  }
}
