import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_typography.dart';

class VrsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showBack;
  final bool showRoleBadge;
  final List<Widget>? actions;

  const VrsAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.showBack = false,
    this.showRoleBadge = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.navyPrimary,
      foregroundColor: AppColors.textWhite,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.goldLight, size: 20),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 38,
                    width: 38,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppDimens.space10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "VR's KITCHEN",
                      style: AppTypography.headingSmall.copyWith(
                        color: AppColors.goldLight,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "YOUR MEALS. YOUR WAY.",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.goldMuted,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Text(
              title ?? "",
              style: AppTypography.headingMedium.copyWith(color: AppColors.textWhite),
            ),
      centerTitle: !showLogo,
      actions: actions,
    );
  }
}
