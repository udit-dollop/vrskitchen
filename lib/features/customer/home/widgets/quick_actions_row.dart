import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../pause_meal/pause_meal_modal.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAction(
          context: context,
          label: "Customize\nMeal",
          icon: Icons.tune_rounded,
          onTap: () => Navigator.pushNamed(context, AppRoutes.mealCustomizer),
        ),
        _buildAction(
          context: context,
          label: "Pause\nMeal",
          icon: Icons.pause_circle_outline_rounded,
          onTap: () => PauseMealModal.show(context),
        ),
        _buildAction(
          context: context,
          label: "Track\nOrder",
          icon: Icons.near_me_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.orderTracking),
        ),
        _buildAction(
          context: context,
          label: "Flexi\nWallet",
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => Navigator.pushNamed(context, AppRoutes.wallet),
        ),
      ],
    );
  }

  Widget _buildAction({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimens.borderMD,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.space12, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: AppDimens.borderMD,
              border: Border.all(color: AppColors.borderLight),
              boxShadow: AppDimens.softShadow,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.goldBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.goldDark, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyPrimary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
