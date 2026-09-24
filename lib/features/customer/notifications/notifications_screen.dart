import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Customize tomorrow's meal",
        "body": "Cutoff closes at 10:00 PM tonight. Pick your favorite Paneer or Dal dish.",
        "time": "10 mins ago",
        "icon": Icons.tune_rounded,
        "color": AppColors.goldDark,
        "isUnread": true,
        "route": AppRoutes.mealCustomizer,
      },
      {
        "title": "Your tiffin is out for delivery",
        "body": "Rajesh Kumar has picked up your meal #VR10245 and is 18 mins away.",
        "time": "12:50 PM",
        "icon": Icons.delivery_dining_rounded,
        "color": AppColors.statusInfo,
        "isUnread": true,
        "route": AppRoutes.orderTracking,
      },
      {
        "title": "Your meal is being prepared",
        "body": "Fresh rotis are on the tawa and sabzi has been portioned.",
        "time": "12:15 PM",
        "icon": Icons.soup_kitchen_rounded,
        "color": AppColors.statusWarning,
        "isUnread": false,
        "route": AppRoutes.orderTracking,
      },
      {
        "title": "₹80 added to your wallet",
        "body": "Credit for paused dinner on 8th Sep has been added to your Flexi Wallet.",
        "time": "Yesterday",
        "icon": Icons.account_balance_wallet_rounded,
        "color": AppColors.vegGreen,
        "isUnread": false,
        "route": AppRoutes.wallet,
      },
      {
        "title": "Subscription renewed smoothly",
        "body": "Your Standard Monthly Plan (30 Meals) is active.",
        "time": "3 days ago",
        "icon": Icons.stars_rounded,
        "color": AppColors.goldDark,
        "isUnread": false,
        "route": AppRoutes.subscriptionPlans,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Notifications", showBack: true),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppDimens.space16),
          itemCount: notifications.length,
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final n = notifications[index];
            final isUnread = n["isUnread"] as bool;

            return VrsCard(
              onTap: () {
                final route = n["route"] as String;
                Navigator.pushNamed(context, route);
              },
              padding: const EdgeInsets.all(AppDimens.space16),
              backgroundColor: isUnread ? AppColors.goldBackground.withValues(alpha: 0.5) : AppColors.surfaceWhite,
              border: Border.all(
                color: isUnread ? AppColors.goldPrimary : AppColors.borderLight,
                width: isUnread ? 1.5 : 1.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (n["color"] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(n["icon"] as IconData, color: n["color"] as Color, size: 20),
                  ),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              n["title"] as String,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                color: AppColors.navyPrimary,
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.goldDark,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(n["body"] as String, style: AppTypography.bodySmall),
                        const SizedBox(height: 6),
                        Text(
                          n["time"] as String,
                          style: AppTypography.caption.copyWith(fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
