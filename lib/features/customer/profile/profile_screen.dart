import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/subscription_model.dart';
import '../../../state/app_state_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final user = appState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "My Profile"),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            // User Header Card
            VrsCard(
              padding: const EdgeInsets.all(AppDimens.space20),
              backgroundColor: AppColors.navyPrimary,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.goldLight,
                    child: CircleAvatar(
                      radius: 31,
                      backgroundColor: AppColors.navyDark,
                      child: Text(
                        user.name.trim().isNotEmpty
                            ? user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                            : 'U',
                        style: AppTypography.headingMedium.copyWith(color: AppColors.goldLight),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? user.name : "VRS User",
                          style: AppTypography.headingSmall.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.phone.isNotEmpty ? user.phone : "Not set",
                          style: AppTypography.caption.copyWith(color: AppColors.goldLight),
                        ),
                        if (user.email.isNotEmpty)
                          Text(
                            user.email,
                            style: AppTypography.caption.copyWith(color: Colors.white70),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space20),

            // Settings List
            _buildSectionHeader("Account & Subscriptions"),
            _buildSettingTile(
              icon: Icons.stars_rounded,
              title: "My Subscription Plan",
              subtitle: appState.hasActiveSubscription
                  ? "${appState.currentSubscription?.packageType == PackageType.standard ? 'Standard' : 'Premium'} (${appState.currentSubscription?.remainingMeals ?? 0} Meals Remaining)"
                  : "No active plan",
              onTap: () => Navigator.pushNamed(context, AppRoutes.subscriptionPlans),
            ),
            _buildSettingTile(
              icon: Icons.calendar_month_rounded,
              title: "Meal Calendar & Schedule",
              subtitle: "Plan ahead and pause meals",
              onTap: () => Navigator.pushNamed(context, AppRoutes.calendarSchedule),
            ),
            _buildSettingTile(
              icon: Icons.account_balance_wallet_outlined,
              title: "Flexi Wallet",
              subtitle: "Balance: ₹${appState.walletBalance.toInt()}",
              onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
            ),
            _buildSettingTile(
              icon: Icons.location_on_outlined,
              title: "Delivery Addresses",
              subtitle: "Office and Home addresses",
              onTap: () => Navigator.pushNamed(context, AppRoutes.savedAddresses),
            ),
            _buildSettingTile(
              icon: Icons.health_and_safety_outlined,
              title: "Food Allergies",
              subtitle: user.allergies.isNotEmpty &&
                      !user.allergies.contains("No Allergies") &&
                      !user.allergies.contains("None")
                  ? "${user.allergies.length} active restrictions recorded"
                  : "Personalize your safe meal experience",
              extraWidget: (user.allergies.isNotEmpty &&
                      !user.allergies.contains("No Allergies") &&
                      !user.allergies.contains("None"))
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...user.allergies.take(3).map((allergy) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.spicyRed.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.spicyRed.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.block_rounded, size: 10, color: AppColors.spicyRed),
                                  const SizedBox(width: 4),
                                  Text(
                                    allergy,
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.navyPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (user.allergies.length > 3)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "+${user.allergies.length - 3} more",
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : null,
              onTap: () => Navigator.pushNamed(context, AppRoutes.dietarySetup),
            ),

            const SizedBox(height: AppDimens.space20),

            _buildSectionHeader("Support & Legal"),
            _buildSettingTile(
              icon: Icons.headset_mic_outlined,
              title: "Help & Support",
              subtitle: "Reach our customer care & WhatsApp",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Support desk: support@vrskitchen.com / +91 98765 43210")),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.description_outlined,
              title: "Terms & Conditions",
              subtitle: "Subscription & Refund rules",
              onTap: () {},
            ),

            const SizedBox(height: AppDimens.space20),

            // Logout
            ListTile(
              onTap: () async {
                await appState.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                }
              },
              leading: const Icon(Icons.logout_rounded, color: AppColors.statusError),
              title: Text(
                "Logout",
                style: AppTypography.titleMedium.copyWith(color: AppColors.statusError, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Exit active session"),
            ),

            const SizedBox(height: AppDimens.space40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? extraWidget,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppDimens.borderMD,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.navyPrimary.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.navyPrimary, size: 20),
        ),
        title: Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subtitle, style: AppTypography.caption),
            ?extraWidget,
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
      ),
    );
  }
}
