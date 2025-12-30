import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/debut.png',
      'titleStart': 'Connaissez le juste',
      'titleEnd': 'avant de partir',
      'highlight': 'prix',
      'subtitle':
          'Finis les negociations interminables, payer le prix normal sans surcharge.',
    },
    {
      'image': 'assets/images/moto.png',
      'titleStart': 'Rapide et',
      'titleEnd': '',
      'highlight': 'Simple',
      'subtitle': 'Entre le depart et l\'arrivee, obtenez un prix instantane.',
    },
    {
      'image': 'assets/images/motorcycle.png',
      'titleStart': 'Economisez',
      'titleEnd': 'jours',
      'highlight': 'chaque',
      'subtitle':
          'Ne payer plus jamais trop cher. Obtenez le prix juste pour chaque course a Lome.',
    },
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyFirstLaunch, false);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppConstants.routeHome);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPage(
                    imagePath: page['image']!,
                    titleStart: page['titleStart']!,
                    titleEnd: page['titleEnd']!,
                    titleHighlight: page['highlight']!,
                    subtitle: page['subtitle']!,
                  );
                },
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Page Indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.gray300,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 8,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  if (_currentPage == _pages.length - 1)
                    // Last page - "Get Started" button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('C\'est parti', style: AppTextStyles.button),
                            const SizedBox(width: 8),
                            const Icon(Icons.directions_run, size: 20),
                          ],
                        ),
                      ),
                    )
                  else
                    // Other pages - Next arrow button
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.textPrimary,
                              width: 1.5,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
