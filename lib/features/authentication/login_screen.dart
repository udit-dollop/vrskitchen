import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/vrs_button.dart';
import '../../state/app_state_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: "9826012345");
  bool _isLoading = false;

  void _onContinue() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit mobile number")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<AppStateProvider>(context, listen: false);

    Map<String, dynamic> otpData = {};
    try {
      otpData = await provider.sendOtpForLogin(phone);
    } catch (_) {
      // Offline fallback
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    final verificationToken = otpData['verificationToken']?.toString() ?? '';
    final devOtp = otpData['devOtp']?.toString() ?? '123456';

    Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: {
        'displayPhone': "+91 $phone",
        'phone': phone,
        'verificationToken': verificationToken,
        'devOtp': devOtp,
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.space40),

              // Logo Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: AppDimens.goldGlow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset("assets/images/logo.png", fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: AppDimens.space16),
                    Text(
                      "VR's KITCHEN",
                      style: AppTypography.headingLarge.copyWith(
                        color: AppColors.navyPrimary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "YOUR MEALS. YOUR WAY. EVERY DAY.",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.space48),

              Text(
                AppStrings.welcomeTitle,
                style: AppTypography.displayMedium.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                "Enter your mobile number to subscribe or manage your customized daily tiffins.",
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              ),

              const SizedBox(height: AppDimens.space32),

              Text(
                "Mobile Number",
                style: AppTypography.titleSmall.copyWith(color: AppColors.navyPrimary),
              ),
              const SizedBox(height: AppDimens.space8),

              // Phone Field with +91 Country Code
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: AppDimens.borderMD,
                  border: Border.all(color: AppColors.borderLight, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppColors.borderLight)),
                      ),
                      child: Row(
                        children: [
                          const Text("🇮🇳", style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            "+91",
                            style: AppTypography.titleMedium.copyWith(color: AppColors.navyPrimary),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: AppTypography.headingSmall.copyWith(letterSpacing: 1.5),
                        decoration: InputDecoration(
                          hintText: "98765 43210",
                          counterText: "",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.space24),

              VrsButton(
                text: "Continue",
                onPressed: _onContinue,
                isLoading: _isLoading,
                variant: VrsButtonVariant.gold,
              ),

              const SizedBox(height: AppDimens.space24),

              // Demo quick tip
              Container(
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: AppColors.goldBackground,
                  borderRadius: AppDimens.borderMD,
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.goldDark, size: 20),
                    const SizedBox(width: AppDimens.space10),
                    Expanded(
                      child: Text(
                        "Demo mode active. Any 10-digit number will receive Demo OTP: 123456.",
                        style: AppTypography.caption.copyWith(color: AppColors.navyDark),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.space32),
              Center(
                child: Text(
                  "By continuing, you agree to our Terms of Service & Privacy Policy",
                  style: AppTypography.caption.copyWith(color: AppColors.textLight, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
