import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_dimens.dart';

class UiHelpers {
  UiHelpers._();

  static String formatCurrency(num amount) {
    return '₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }

  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.navyPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppDimens.space16),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.borderMD,
          side: const BorderSide(color: AppColors.goldPrimary, width: 1),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.goldPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.navyDark,
                size: 16,
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.statusError,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppDimens.space16),
        shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMD),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.navyRoyal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppDimens.space16),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.borderMD,
          side: const BorderSide(color: AppColors.goldMuted, width: 1),
        ),
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.goldLight, size: 20),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
