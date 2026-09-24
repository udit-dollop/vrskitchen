import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/vrs_badge.dart';
import '../../../../core/widgets/vrs_button.dart';

class TodayMealCard extends StatelessWidget {
  final String sabzi;
  final String dal;
  final String roti;
  final String rice;
  final List<String> addons;

  const TodayMealCard({
    super.key,
    required this.sabzi,
    required this.dal,
    required this.roti,
    required this.rice,
    required this.addons,
  });

  @override
  Widget build(BuildContext context) {
    if (sabzi.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppDimens.space32, horizontal: AppDimens.space20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: AppDimens.borderXL,
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppDimens.softShadow,
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.goldBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.goldDark, size: 36),
              ),
              const SizedBox(height: AppDimens.space16),
              Text(
                "No Meal Menu Available",
                style: AppTypography.headingSmall.copyWith(color: AppColors.navyPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                "Today's menu hasn't been published by the kitchen yet. Please check back later or explore subscriptions.",
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppDimens.borderXL,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppDimens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image and badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radiusXL),
                  topRight: Radius.circular(AppDimens.radiusXL),
                ),
                child: Image.asset(
                  "assets/images/thali_special.png",
                  height: 175,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.navyPrimary.withValues(alpha: 0.9),
                    borderRadius: AppDimens.borderFull,
                    border: Border.all(color: AppColors.goldPrimary, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const VegBadge(size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "Today's Special",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.goldLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: AppDimens.borderFull,
                  ),
                  child: Text(
                    "Lunch Slot • 1:00 PM",
                    style: AppTypography.caption.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          // Meal Components Breakdown
          Padding(
            padding: const EdgeInsets.all(AppDimens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Standard Homestyle Thali",
                  style: AppTypography.headingMedium.copyWith(color: AppColors.navyPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  "Freshly cooked in pure mustard oil & desi ghee. Healthy & light.",
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppDimens.space16),

                // Meal items grid/chips
                _buildItemRow("Sabzi", sabzi, Icons.eco_rounded, AppColors.vegGreen),
                const SizedBox(height: 8),
                _buildItemRow("Dal", dal, Icons.soup_kitchen_rounded, AppColors.goldDark),
                const SizedBox(height: 8),
                _buildItemRow("Roti", roti, Icons.circle_outlined, AppColors.navyPrimary),
                const SizedBox(height: 8),
                _buildItemRow("Rice", rice, Icons.grain_rounded, Colors.orange),
                if (addons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildItemRow("Add-ons", addons.join(", "), Icons.add_circle_outline, AppColors.goldDark),
                ],

                const SizedBox(height: AppDimens.space20),

                // Customize Button
                VrsButton(
                  text: "Customize Today's Meal",
                  icon: const Icon(Icons.tune_rounded, color: AppColors.navyDark, size: 18),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.mealCustomizer),
                  variant: VrsButtonVariant.gold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            "$label:",
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.navyPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
