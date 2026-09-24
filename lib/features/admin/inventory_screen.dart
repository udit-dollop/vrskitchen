import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_card.dart';
import '../../state/app_state_provider.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  void _showAddStockDialog(BuildContext context, String itemId, String itemName) {
    double added = 10;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimens.borderLG),
        title: Text("Replenish $itemName", style: AppTypography.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add standard procurement batch (+10 kg) to current stock?", style: AppTypography.bodySmall),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              appState.addInventoryStock(itemId, added);
              Navigator.pop(ctx);
              UiHelpers.showSuccessSnackbar(context, "+10 kg added to $itemName stock!");
            },
            child: const Text("Confirm Stock"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final items = appState.inventoryItems;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Kitchen Inventory", showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            Text("Raw Ingredients Stock", style: AppTypography.headingMedium),
            const SizedBox(height: 4),
            Text(
              "Monitored live against daily forecasted subscriber consumption.",
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimens.space16),

            ...items.map((item) {
              final progress = (item.currentStock / (item.minRequired * 1.8)).clamp(0.0, 1.0);

              return VrsCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppDimens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.isLowStock
                                ? AppColors.statusError.withValues(alpha: 0.15)
                                : AppColors.vegGreen.withValues(alpha: 0.15),
                            borderRadius: AppDimens.borderFull,
                          ),
                          child: Text(
                            item.isLowStock ? "Low Stock" : "Available",
                            style: AppTypography.caption.copyWith(
                              color: item.isLowStock ? AppColors.statusError : AppColors.vegGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${item.currentStock.toInt()} ${item.unit} in pantry",
                          style: AppTypography.headingSmall.copyWith(
                            color: AppColors.navyPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "Min required: ${item.minRequired.toInt()} ${item.unit}",
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.borderLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.isLowStock ? AppColors.statusError : AppColors.vegGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            UiHelpers.showSuccessSnackbar(context, "Procurement log opened for ${item.name}");
                          },
                          child: const Text("View Usage", style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showAddStockDialog(context, item.id, item.name),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            foregroundColor: AppColors.navyDark,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          child: const Text("Add Stock", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }
}
