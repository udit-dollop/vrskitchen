import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_typography.dart';
import 'vrs_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.space32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.navyPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 38,
                color: AppColors.goldDark,
              ),
            ),
            const SizedBox(height: AppDimens.space20),
            Text(
              title,
              style: AppTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.space8),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppDimens.space24),
              VrsButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                variant: VrsButtonVariant.gold,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
