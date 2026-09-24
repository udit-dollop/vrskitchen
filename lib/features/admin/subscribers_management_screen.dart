import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_card.dart';

class SubscribersManagementScreen extends StatelessWidget {
  const SubscribersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subscribers = [
      {
        "name": "Rahul Sharma",
        "phone": "+91 98765 43210",
        "plan": "Standard Monthly",
        "totalMeals": 30,
        "remaining": 18,
        "status": "Active",
        "address": "Tech Park, Vijay Nagar (Office)",
        "diet": "Veg • Medium Spice",
      },
      {
        "name": "Amit Kumar",
        "phone": "+91 98111 22334",
        "plan": "Premium Monthly",
        "totalMeals": 56,
        "remaining": 42,
        "status": "Active",
        "address": "Flat 204, Scheme 78 (Home)",
        "diet": "Pure Veg • Mild Spice",
      },
      {
        "name": "Priya Jain",
        "phone": "+91 98222 33445",
        "plan": "Standard Monthly",
        "totalMeals": 30,
        "remaining": 10,
        "status": "Paused",
        "address": "Corporate Tower, AB Road (Office)",
        "diet": "Jain • Mild Spice",
      },
      {
        "name": "Neha Singh",
        "phone": "+91 98333 44556",
        "plan": "Standard Monthly",
        "totalMeals": 30,
        "remaining": 22,
        "status": "Active",
        "address": "Old Palasia (Home)",
        "diet": "Veg • Spicy",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Subscribers Directory", showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            Text("Active Subscription Accounts", style: AppTypography.headingMedium),
            const SizedBox(height: 4),
            Text(
              "Total 42 active subscribers in Indore North & Central cluster.",
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimens.space16),

            ...subscribers.map((sub) {
              final isActive = sub["status"] == "Active";

              return VrsCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppDimens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sub["name"] as String,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.vegGreen.withValues(alpha: 0.15)
                                : AppColors.statusWarning.withValues(alpha: 0.15),
                            borderRadius: AppDimens.borderFull,
                          ),
                          child: Text(
                            sub["status"] as String,
                            style: AppTypography.caption.copyWith(
                              color: isActive ? AppColors.vegGreen : AppColors.statusWarning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${sub["plan"]} • ${sub["phone"]}",
                      style: AppTypography.caption.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Meals Remaining", style: AppTypography.caption),
                            Text(
                              "${sub["remaining"]} / ${sub["totalMeals"]}",
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.navyPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Dietary Note", style: AppTypography.caption),
                            Text(
                              sub["diet"] as String,
                              style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Delivery: ${sub["address"]}",
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }
}
