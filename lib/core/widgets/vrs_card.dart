import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';

class VrsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Border? border;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const VrsCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.borderRadius,
    this.onTap,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppDimens.borderLG;
    final effectivePadding = padding ?? const EdgeInsets.all(AppDimens.space16);

    Widget content = Container(
      margin: margin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.surfaceWhite) : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: border ?? Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: boxShadow ?? AppDimens.softShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
