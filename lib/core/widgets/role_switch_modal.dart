import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_typography.dart';
import '../routes/app_routes.dart';

class RoleSwitchModal extends StatelessWidget {
  const RoleSwitchModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const RoleSwitchModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.space24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusXL),
          topRight: Radius.circular(AppDimens.radiusXL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.space20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.goldBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.goldDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppDimens.space12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select App Demo Role", style: AppTypography.headingMedium),
                    Text(
                      "Switch perspectives instantly for client demo",
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space20),
            _RoleOptionCard(
              title: "Customer App",
              subtitle: "Browse menu, customize meals, subscribe, flexi-wallet",
              icon: Icons.person_rounded,
              role: DemoRole.customer,
              isSelected: appState.activeRole == DemoRole.customer,
              onTap: () {
                appState.setRole(DemoRole.customer);
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.customerHome,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: AppDimens.space12),
            _RoleOptionCard(
              title: "Kitchen & Admin App",
              subtitle: "Portion demand aggregation, inventory, QR stickers",
              icon: Icons.soup_kitchen_rounded,
              role: DemoRole.admin,
              isSelected: appState.activeRole == DemoRole.admin,
              onTap: () {
                appState.setRole(DemoRole.admin);
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.adminDashboard,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: AppDimens.space12),
            _RoleOptionCard(
              title: "Delivery Partner (Rider)",
              subtitle: "Tiffin batch checklist, QR scanner, GPS delivery route",
              icon: Icons.two_wheeler_rounded,
              role: DemoRole.rider,
              isSelected: appState.activeRole == DemoRole.rider,
              onTap: () {
                appState.setRole(DemoRole.rider);
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.riderDashboard,
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: AppDimens.space16),
          ],
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final DemoRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.borderMD,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldBackground : AppColors.surfaceWhite,
          borderRadius: AppDimens.borderMD,
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.goldPrimary : AppColors.navyPrimary.withValues(alpha: 0.06),
                borderRadius: AppDimens.borderSM,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.navyDark : AppColors.navyPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimens.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.navyDark : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.goldDark,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
