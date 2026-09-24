import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/order_model.dart';

class TrialConfirmationScreen extends StatelessWidget {
  const TrialConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)?.settings.arguments as OrderItemModel?;
    final orderId = order?.orderId ?? "VR10245";
    final slot = order?.slot ?? "Lunch (1:00 PM - 2:00 PM)";

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

              // Success checkmark animation badge
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
                    Icons.check_rounded,
                    color: AppColors.navyDark,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.space24),

              Text(
                "Your meal is confirmed! 🎉",
                style: AppTypography.displayMedium.copyWith(color: AppColors.navyPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.space8),
              Text(
                "Our chefs have received your order and fresh preparation has started.",
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimens.space32),

              // Order Details Card
              VrsCard(
                padding: const EdgeInsets.all(AppDimens.space20),
                backgroundColor: AppColors.backgroundWarm,
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order ID", style: AppTypography.bodySmall),
                        Text(
                          "#$orderId",
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
                        Text("Estimated Delivery", style: AppTypography.bodySmall),
                        Text(
                          "Today, $slot",
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Delivery Partner", style: AppTypography.bodySmall),
                        Text(
                          "Rajesh Kumar",
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              VrsButton(
                text: "Track Order Live",
                icon: const Icon(Icons.near_me_rounded, color: AppColors.navyDark, size: 20),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.orderTracking);
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
