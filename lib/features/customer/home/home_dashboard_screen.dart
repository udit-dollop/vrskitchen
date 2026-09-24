import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../state/app_state_provider.dart';
import 'widgets/subscription_hero_card.dart';
import 'widgets/cutoff_timer_banner.dart';
import 'widgets/today_meal_card.dart';
import 'widgets/quick_actions_row.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final user = appState.user;
    final subscription = appState.currentSubscription;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: VrsAppBar(
        showLogo: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.goldLight),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.goldPrimary,
          onRefresh: () => appState.initBackendSession(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Good Morning, ${user.name.trim().isNotEmpty ? user.name.trim().split(' ').first : 'Foodie'}",
                              style: AppTypography.headingLarge.copyWith(color: AppColors.navyPrimary),
                            ),
                            const SizedBox(width: 6),
                            const Text("👋", style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "What's cooking for you today?",
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                        ),
                        if (appState.isBackendConnected)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.vegGreen,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Live Kitchen Connected",
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.vegGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.savedAddresses),
                    borderRadius: AppDimens.borderFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppDimens.borderFull,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.goldDark),
                          const SizedBox(width: 4),
                          Text(
                            user.selectedAddress?.tag ?? "Office",
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.space16),

              // 2. Subscription Hero Card
              SubscriptionHeroCard(subscription: subscription),

              const SizedBox(height: AppDimens.space16),

              // 3. Cutoff Timer Banner
              const CutoffTimerBanner(),

              const SizedBox(height: AppDimens.space16),

              // 4. Quick Actions
              const QuickActionsRow(),

              const SizedBox(height: AppDimens.space24),

              // 5. Today's Meal Card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Meal", style: AppTypography.headingMedium),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.calendarSchedule),
                    child: Text(
                      "Weekly Schedule",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.space10),

              TodayMealCard(
                sabzi: appState.selectedSabzi,
                dal: "Dal Tadka",
                roti: appState.selectedRoti,
                rice: appState.selectedRice,
                addons: appState.selectedAddOns.keys.toList(),
              ),

              const SizedBox(height: AppDimens.space24),

              // 6. Weekly Menu Preview Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("This Week's Specials", style: AppTypography.headingMedium),
                  InkWell(
                    onTap: () {
                      // Handled in main shell Menu tab
                    },
                    child: Text(
                      "Full Menu",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.space12),

              appState.weeklyMenu.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: AppDimens.space24, horizontal: AppDimens.space16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppDimens.borderMD,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_month_outlined, color: AppColors.textMuted, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              "No weekly menu published yet",
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 145,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: appState.weeklyMenu.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = appState.weeklyMenu[index];
                          return Container(
                            width: 200,
                      padding: const EdgeInsets.all(AppDimens.space12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppDimens.borderMD,
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: AppDimens.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.dayName,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navyPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.goldBackground,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "Lunch",
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.goldDark,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.lunchSabzis.isNotEmpty
                                ? item.lunchSabzis.first.name
                                : (item.dinnerSabzis.isNotEmpty
                                    ? item.dinnerSabzis.first.name
                                    : "Chef's Special Sabzi"),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${item.lunchDal.name.isNotEmpty ? item.lunchDal.name : 'Dal Tadka'} • ${item.lunchRotis.isNotEmpty ? item.lunchRotis.first.name : 'Butter Roti'}",
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            "Pure Desi Ghee & Fresh",
                            style: AppTypography.caption.copyWith(
                              color: AppColors.vegGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppDimens.space24),

              // 7. Source Menu Banner Card
              VrsCard(
                onTap: () => Navigator.pushNamed(context, AppRoutes.subscriptionPlans),
                padding: const EdgeInsets.all(AppDimens.space16),
                backgroundColor: AppColors.navyPrimary,
                borderRadius: AppDimens.borderXL,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppDimens.borderMD,
                      child: Image.asset(
                        "assets/images/mess_menu.png",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: AppDimens.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Monthly Tiffin Packages",
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Standard ₹80/meal • Premium ₹120/meal with dessert & surprise dish!",
                            style: AppTypography.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.goldPrimary, size: 16),
                  ],
                ),
              ),

              const SizedBox(height: AppDimens.space32),
            ],
          ),
        ),
      ),
    ),
  );
}
}
