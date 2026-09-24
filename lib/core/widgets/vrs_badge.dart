import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_typography.dart';

class VegBadge extends StatelessWidget {
  final double size;
  final bool isVeg;

  const VegBadge({
    super.key,
    this.size = 16,
    this.isVeg = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AppColors.vegGreen : AppColors.nonVegRed;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: size * 0.45,
          height: size * 0.45,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class VrsStatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const VrsStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory VrsStatusBadge.preparing() => const VrsStatusBadge(
        label: "Preparing",
        backgroundColor: Color(0xFFFEF3C7),
        textColor: Color(0xFFB45309),
        icon: Icons.soup_kitchen_outlined,
      );

  factory VrsStatusBadge.outForDelivery() => const VrsStatusBadge(
        label: "Out for Delivery",
        backgroundColor: Color(0xFFDBEAFE),
        textColor: Color(0xFF1E40AF),
        icon: Icons.delivery_dining_outlined,
      );

  factory VrsStatusBadge.delivered() => const VrsStatusBadge(
        label: "Delivered",
        backgroundColor: Color(0xFFD1FAE5),
        textColor: Color(0xFF065F46),
        icon: Icons.check_circle_outline,
      );

  factory VrsStatusBadge.gold(String text) => VrsStatusBadge(
        label: text,
        backgroundColor: AppColors.goldBackground,
        textColor: AppColors.goldDark,
        icon: Icons.star_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimens.borderFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
