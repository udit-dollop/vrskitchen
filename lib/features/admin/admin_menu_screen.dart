import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_card.dart';
import '../../state/app_state_provider.dart';

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  void _showAddDishDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppDimens.borderLG),
        title: Text("Add Dish to Master Menu", style: AppTypography.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Dish Name")),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Ingredients / Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              UiHelpers.showSuccessSnackbar(context, "Dish added to master catalog!");
            },
            child: const Text("Add Dish"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final weeklyMenu = appState.weeklyMenu;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Menu & Cutoff Management", showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            // Cutoff Info Rules
            VrsCard(
              padding: const EdgeInsets.all(AppDimens.space16),
              backgroundColor: AppColors.navyPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Automated Cutoff Policy",
                        style: AppTypography.titleMedium.copyWith(color: AppColors.goldLight, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.lock_clock_rounded, color: AppColors.goldLight, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCutoffRow("Lunch Cutoff", "10:00 PM previous night", "Active"),
                  const SizedBox(height: 8),
                  _buildCutoffRow("Dinner Cutoff", "2:00 PM same day", "Active"),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Weekly Menu Roster", style: AppTypography.headingMedium),
                ElevatedButton.icon(
                  onPressed: () => _showAddDishDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: AppColors.navyDark,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Dish", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),

            ...weeklyMenu.map((day) {
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
                          day.dayName,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.navyPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            UiHelpers.showSuccessSnackbar(context, "Editing ${day.dayName} menu");
                          },
                          child: Text(
                            "Edit Menu",
                            style: AppTypography.caption.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lunch Offering",
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.goldDark),
                              ),
                              const SizedBox(height: 4),
                              Text(day.lunchSabzis.isNotEmpty ? day.lunchSabzis.first.name : "Special Sabzi", style: AppTypography.titleSmall),
                              Text("${day.lunchDal.name.isNotEmpty ? day.lunchDal.name : 'Dal Tadka'} • 5 Butter Roti", style: AppTypography.caption),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dinner Offering",
                                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.navyPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(day.dinnerSabzis.isNotEmpty ? day.dinnerSabzis.first.name : "Special Sabzi", style: AppTypography.titleSmall),
                              Text("${day.dinnerDal.name.isNotEmpty ? day.dinnerDal.name : 'Dal Tadka'} • 5 Tawa Roti", style: AppTypography.caption),
                            ],
                          ),
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

  Widget _buildCutoffRow(String label, String timing, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(timing, style: AppTypography.caption.copyWith(color: Colors.white70)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.vegGreen.withValues(alpha: 0.3),
            borderRadius: AppDimens.borderFull,
            border: Border.all(color: AppColors.vegGreen),
          ),
          child: Text(
            status,
            style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
      ],
    );
  }
}
