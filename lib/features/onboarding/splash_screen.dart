import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/api_client.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _glowAnim = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2800), _checkSessionAndNavigate);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _skip() {
    _navigationTimer?.cancel();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    _navigationTimer?.cancel();
    if (!mounted) return;

    final apiClient = ApiClient();
    await apiClient.init();

    // If access token is expired or absent, but refresh token exists, refresh session
    if (!apiClient.isAuthenticated && apiClient.refreshToken != null && apiClient.refreshToken!.isNotEmpty) {
      await apiClient.refreshTokenSession();
    }

    if (!mounted) return;

    if (apiClient.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: GestureDetector(
        onTap: _skip,
        child: Stack(
          children: [
            // Background radial glow
            Center(
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (context, child) {
                  return Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.goldPrimary.withValues(alpha: 0.18 * _glowAnim.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldPrimary.withValues(alpha: 0.35),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              "assets/images/logo.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.space32),

                    // Tagline
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        children: [
                          Text(
                            "VR's KITCHEN",
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.goldLight,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppDimens.space8),
                          Container(
                            height: 1.5,
                            width: 80,
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: AppDimens.space12),
                          Text(
                            AppStrings.brandTagline,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.goldMuted,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimens.space6),
                          Text(
                            AppStrings.pureVegTag,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Gold circular spinner
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.goldPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Skip Hint
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Tap anywhere to start",
                  style: AppTypography.caption.copyWith(
                    color: Colors.white30,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
