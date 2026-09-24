import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

class FoodImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const FoodImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppDimens.borderMD;

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.navyLight.withValues(alpha: 0.1),
                  AppColors.goldLight.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: effectiveRadius,
            ),
            child: const Center(
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.goldPrimary,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}
