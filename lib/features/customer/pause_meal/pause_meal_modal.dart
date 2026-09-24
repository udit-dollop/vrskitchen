import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../state/app_state_provider.dart';

class PauseMealModal extends StatefulWidget {
  const PauseMealModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const PauseMealModal(),
    );
  }

  @override
  State<PauseMealModal> createState() => _PauseMealModalState();
}

class _PauseMealModalState extends State<PauseMealModal> {
  final DateTime _pauseDate = DateTime.now().add(const Duration(days: 1));
  final DateTime _resumeDate = DateTime.now().add(const Duration(days: 2));
  bool _isSuccess = false;

  void _onConfirmPause() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.pauseMeal(
      fromDate: _pauseDate,
      toDate: _resumeDate,
      credit: 80.0,
    );

    setState(() => _isSuccess = true);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
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
              decoration: BoxDecoration(
                color: AppColors.statusWarning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pause_circle_filled_rounded, color: AppColors.statusWarning, size: 24),
            ),
            const SizedBox(width: AppDimens.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pause Your Meal?", style: AppTypography.headingMedium),
                Text("Going out of town or busy? No problem!", style: AppTypography.caption),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppDimens.space20),

        // Date selection cards
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: AppDimens.borderMD,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pause Date", style: AppTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      "Tomorrow, ${_pauseDate.day}/${_pauseDate.month}",
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppDimens.space12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: AppDimens.borderMD,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Resume Date", style: AppTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      "${_resumeDate.day}/${_resumeDate.month}",
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.space16),

        // Credit notice
        Container(
          padding: const EdgeInsets.all(AppDimens.space16),
          decoration: BoxDecoration(
            color: AppColors.goldBackground,
            borderRadius: AppDimens.borderMD,
            border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.goldPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.navyDark, size: 18),
              ),
              const SizedBox(width: AppDimens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Credit to Flexi Wallet",
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "+ ₹80",
                          style: AppTypography.headingSmall.copyWith(
                            color: AppColors.vegGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Your unused meal credit will be added to your Flexi Wallet instantly.",
                      style: AppTypography.caption.copyWith(color: AppColors.navyDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.space24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: AppDimens.space12),
            Expanded(
              child: VrsButton(
                text: "Pause Meal",
                onPressed: _onConfirmPause,
                variant: VrsButtonVariant.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.space12),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.space32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldPrimary, width: 2),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.goldDark,
              size: 48,
            ),
          ),
          const SizedBox(height: AppDimens.space16),
          Text(
            "Meal Paused Successfully",
            style: AppTypography.headingLarge.copyWith(color: AppColors.navyPrimary),
          ),
          const SizedBox(height: AppDimens.space8),
          Text(
            "₹80 has been added to your Flexi Wallet.",
            style: AppTypography.bodyMedium.copyWith(color: AppColors.vegGreen, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
