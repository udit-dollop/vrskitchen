import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/cutoff_helper.dart';

class CutoffTimerBanner extends StatefulWidget {
  const CutoffTimerBanner({super.key});

  @override
  State<CutoffTimerBanner> createState() => _CutoffTimerBannerState();
}

class _CutoffTimerBannerState extends State<CutoffTimerBanner> {
  late Timer _timer;
  String _timeString = "04:32:18";

  @override
  void initState() {
    super.initState();
    _timeString = CutoffHelper.getRemainingTimeString();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _timeString = CutoffHelper.getRemainingTimeString();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: AppDimens.space12),
      decoration: BoxDecoration(
        color: AppColors.goldBackground,
        borderRadius: AppDimens.borderMD,
        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: AppColors.navyDark,
              size: 18,
            ),
          ),
          const SizedBox(width: AppDimens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Customization closes in ",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _timeString,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.navyPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Customize before cutoff time to lock your choices.",
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
