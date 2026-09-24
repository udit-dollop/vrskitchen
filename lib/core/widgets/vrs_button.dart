import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_typography.dart';

enum VrsButtonVariant { gold, navy, outline, text }

class VrsButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final VrsButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const VrsButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = VrsButtonVariant.gold,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.borderRadius,
  });

  @override
  State<VrsButton> createState() => _VrsButtonState();
}

class _VrsButtonState extends State<VrsButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;
    final radius = widget.borderRadius ?? AppDimens.borderMD;

    Widget buttonContent = widget.isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: widget.variant == VrsButtonVariant.gold
                  ? AppColors.navyDark
                  : AppColors.goldPrimary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: AppDimens.space8),
              ],
              Text(
                widget.text,
                style: AppTypography.button.copyWith(
                  color: _getTextColor(isDisabled),
                ),
              ),
            ],
          );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: _getBoxDecoration(isDisabled, radius),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: isDisabled ? null : widget.onPressed,
              child: Center(child: buttonContent),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) return AppColors.textLight;
    switch (widget.variant) {
      case VrsButtonVariant.gold:
        return AppColors.navyDark;
      case VrsButtonVariant.navy:
        return AppColors.goldLight;
      case VrsButtonVariant.outline:
        return AppColors.navyPrimary;
      case VrsButtonVariant.text:
        return AppColors.navyPrimary;
    }
  }

  BoxDecoration _getBoxDecoration(bool isDisabled, BorderRadius radius) {
    if (isDisabled) {
      return BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: radius,
      );
    }

    switch (widget.variant) {
      case VrsButtonVariant.gold:
        return BoxDecoration(
          gradient: AppColors.goldGradient,
          borderRadius: radius,
          boxShadow: AppDimens.goldGlow,
        );
      case VrsButtonVariant.navy:
        return BoxDecoration(
          color: AppColors.navyPrimary,
          borderRadius: radius,
          boxShadow: AppDimens.navyShadow,
        );
      case VrsButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
          border: Border.all(color: AppColors.navyPrimary, width: 1.5),
        );
      case VrsButtonVariant.text:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
        );
    }
  }
}
