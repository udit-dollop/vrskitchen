import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/models/subscription_model.dart';

class SubscriptionHeroCard extends StatelessWidget {
  final UserSubscriptionModel? subscription;

  const SubscriptionHeroCard({super.key, this.subscription});

  @override
  Widget build(BuildContext context) {
    if (subscription == null || !subscription!.isActive) {
      // No active subscription: Promotion Card
      return Container(
        padding: const EdgeInsets.all(AppDimens.space20),
        decoration: BoxDecoration(
          gradient: AppColors.navyCardGradient,
          borderRadius: AppDimens.borderXL,
          boxShadow: AppDimens.navyShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary,
                    borderRadius: AppDimens.borderFull,
                  ),
                  child: Text(
                    "SPECIAL OFFER",
                    style: AppTypography.caption.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  "Starts ₹80/meal",
                  style: AppTypography.titleMedium.copyWith(color: AppColors.goldLight),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              "Choose Your Daily Tiffin Plan",
              style: AppTypography.headingMedium.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Fresh homemade meals delivered right to your desk or home with daily custom choices.",
              style: AppTypography.bodySmall.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: AppDimens.space16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.subscriptionPlans),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: AppColors.navyDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Start Subscription",
                      style: AppTypography.button.copyWith(color: AppColors.navyDark, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.space10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.trialSlot),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.goldLight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Try a Meal (₹110)",
                      style: AppTypography.button.copyWith(color: AppColors.goldLight, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Active Subscription Card
    final progress = subscription!.remainingMeals / subscription!.totalMeals;
    final isPremium = subscription!.packageType == PackageType.premium;

    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(
        gradient: AppColors.navyCardGradient,
        borderRadius: AppDimens.borderXL,
        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.35), width: 1.2),
        boxShadow: AppDimens.navyShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: AppColors.goldLight, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPremium ? "Premium Monthly Plan" : "Standard Monthly Plan",
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: subscription!.isPaused
                      ? AppColors.statusWarning.withValues(alpha: 0.2)
                      : AppColors.statusSuccess.withValues(alpha: 0.2),
                  borderRadius: AppDimens.borderFull,
                  border: Border.all(
                    color: subscription!.isPaused ? AppColors.statusWarning : AppColors.statusSuccess,
                  ),
                ),
                child: Text(
                  subscription!.isPaused ? "PAUSED" : "ACTIVE",
                  style: AppTypography.caption.copyWith(
                    color: subscription!.isPaused ? AppColors.statusWarning : AppColors.statusSuccess,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${subscription!.remainingMeals} meals remaining",
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "out of ${subscription!.totalMeals} meals • ${subscription!.slot} Slot",
                    style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              Text(
                "₹${subscription!.amountPaid.toInt()}",
                style: AppTypography.headingLarge.copyWith(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimens.space16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
            ),
          ),

          const SizedBox(height: AppDimens.space12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Valid until 30 Sep 2026",
                style: AppTypography.caption.copyWith(color: Colors.white60),
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.calendarSchedule),
                child: Row(
                  children: [
                    Text(
                      "View Calendar",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.goldLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.goldLight),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
