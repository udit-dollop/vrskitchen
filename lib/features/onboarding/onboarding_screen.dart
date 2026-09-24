import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/vrs_button.dart';

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
      "title": "Fresh Meals, Every Day",
      "subtitle": "Homestyle meals prepared fresh with pure desi ingredients for your daily needs.",
      "image": "assets/images/thali_special.png",
      "tag": "100% Homemade Taste",
    },
    {
      "title": "Choose Your Meal",
      "subtitle": "Customize sabzi, roti, rice and delicious add-ons every single day before cutoff.",
      "image": "assets/images/onboarding_plans.png",
      "tag": "Daily Customization",
    },
    {
      "title": "Subscribe Your Way",
      "subtitle": "Flexible 30 or 56 meal plans with wallet credit refund whenever you pause.",
      "image": "assets/images/onboarding_delivery.png",
      "tag": "Zero Commitment Loss",
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _getStarted();
    }
  }

  void _getStarted() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _getStarted,
            child: Text(
              "Skip",
              style: AppTypography.button.copyWith(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.space12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.goldBackground,
                            borderRadius: AppDimens.borderFull,
                            border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            item["tag"]!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.space20),

                        // Image Container with gentle shadow
                        Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: AppDimens.borderXL,
                            boxShadow: AppDimens.mediumShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: AppDimens.borderXL,
                            child: Image.asset(
                              item["image"]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.space32),

                        // Title
                        Text(
                          item["title"]!,
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.navyPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimens.space12),

                        // Subtitle
                        Text(
                          item["subtitle"]!,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator and Navigation Controls
            Padding(
              padding: const EdgeInsets.all(AppDimens.space24),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.goldPrimary
                              : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),

                  // Action Buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: AppDimens.space12),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navyPrimary),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ),
                        ),
                      Expanded(
                        child: VrsButton(
                          text: _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                          onPressed: _onNext,
                          variant: VrsButtonVariant.gold,
                          icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.navyDark, size: 20),
                        ),
                      ),
                    ],
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
