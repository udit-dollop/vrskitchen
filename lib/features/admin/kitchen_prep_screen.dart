import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_button.dart';
import '../../core/widgets/vrs_card.dart';
import '../../data/models/kitchen_prep_model.dart';
import '../../state/app_state_provider.dart';

class KitchenPrepScreen extends StatelessWidget {
  const KitchenPrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final items = appState.kitchenPrepItems;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Kitchen Prep Sheet", showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            // Demand Aggregation Header Card
            Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: AppColors.goldBackground,
                borderRadius: AppDimens.borderLG,
                border: Border.all(color: AppColors.goldPrimary),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: AppColors.goldDark, size: 28),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Aggregated Demand",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyDark,
                          ),
                        ),
                        Text(
                          "Aggregated directly from subscriber custom choices before 10:00 PM cutoff.",
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Required Portions", style: AppTypography.headingMedium),
                Text("Lunch Slot (75 Meals)", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: AppDimens.space12),

            ...items.map((item) {
              Color statusColor = AppColors.statusWarning;
              String statusText = "Preparing";

              if (item.status == PrepStatus.ready) {
                statusColor = AppColors.goldDark;
                statusText = "Ready to Pack";
              } else if (item.status == PrepStatus.completed) {
                statusColor = AppColors.vegGreen;
                statusText = "Packed & Ready";
              }

              return VrsCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppDimens.space16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: AppDimens.borderFull,
                          ),
                          child: Text(
                            statusText,
                            style: AppTypography.caption.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Required Quantity", style: AppTypography.caption),
                            Text(
                              "${item.totalPortions} ${item.unit}",
                              style: AppTypography.headingSmall.copyWith(
                                color: AppColors.navyPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (item.status == PrepStatus.preparing)
                              ElevatedButton(
                                onPressed: () {
                                  appState.updateKitchenItemStatus(item.id, PrepStatus.ready);
                                  UiHelpers.showSuccessSnackbar(context, "${item.itemName} marked Ready!");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.goldPrimary,
                                  foregroundColor: AppColors.navyDark,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text("Mark Ready", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            else if (item.status == PrepStatus.ready)
                              ElevatedButton(
                                onPressed: () {
                                  appState.updateKitchenItemStatus(item.id, PrepStatus.completed);
                                  UiHelpers.showSuccessSnackbar(context, "${item.itemName} marked Packed!");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.vegGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text("Mark Packed", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            else
                              const Icon(Icons.check_circle_rounded, color: AppColors.vegGreen, size: 28),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppDimens.space24),

            VrsButton(
              text: "Download Demand Summary PDF",
              icon: const Icon(Icons.download_rounded, color: AppColors.navyDark, size: 18),
              onPressed: () {
                UiHelpers.showSuccessSnackbar(context, "Demand summary sheet generated successfully.");
              },
              variant: VrsButtonVariant.gold,
            ),
            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }
}
