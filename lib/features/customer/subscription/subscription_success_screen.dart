import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/subscription_model.dart';
import '../../../state/app_state_provider.dart';

class SubscriptionSuccessScreen extends StatelessWidget {
  const SubscriptionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final sub = appState.currentSubscription;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppDimens.goldGlow,
                ),
                child: const Center(
                  child: Icon(
                    Icons.stars_rounded,
                    color: AppColors.navyDark,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.space24),

              Text(
                "Subscription Activated! 🎉",
                style: AppTypography.displayMedium.copyWith(color: AppColors.navyPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                "Welcome to the VR's Kitchen family. Fresh, hot, customized meals are ready for your schedule.",
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.space32),

              VrsCard(
                padding: const EdgeInsets.all(AppDimens.space20),
                backgroundColor: AppColors.backgroundWarm,
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Active Plan", style: AppTypography.bodySmall),
                        Text(
                          sub?.packageType == PackageType.premium ? "Premium Plan" : "Standard Plan",
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.navyPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Meals", style: AppTypography.bodySmall),
                        Text(
                          "${sub?.totalMeals ?? 30} Meals (${sub?.slot ?? 'Lunch'})",
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Flexi-Pause Option", style: AppTypography.bodySmall),
                        Text(
                          "Available in Wallet",
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.vegGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              VrsButton(
                text: "Customize Your Schedule",
                icon: const Icon(Icons.calendar_month_rounded, color: AppColors.navyDark, size: 20),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.calendarSchedule);
                },
                variant: VrsButtonVariant.gold,
              ),

              const SizedBox(height: AppDimens.space12),

              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.customerHome,
                    (route) => false,
                  );
                },
                child: Text(
                  "Return to Home Dashboard",
                  style: AppTypography.button.copyWith(color: AppColors.navyPrimary, fontSize: 14),
                ),
              ),

              const SizedBox(height: AppDimens.space16),
            ],
          ),
        ),
      ),
    );
  }
}
