import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../state/app_state_provider.dart';
import '../pause_meal/pause_meal_modal.dart';

class CalendarScheduleScreen extends StatelessWidget {
  const CalendarScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    if (appState.weeklyMenu.isEmpty && appState.orders.isEmpty && appState.selectedSabzi.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWarm,
        appBar: VrsAppBar(title: "Weekly Schedule", showBack: true),
        body: EmptyStateWidget(
          icon: Icons.calendar_month_outlined,
          title: "No Scheduled Meals",
          subtitle: "You don't have any meals customized or scheduled yet.",
        ),
      );
    }

    final now = DateTime.now();

    final List<Map<String, dynamic>> days = [
      {
        "date": now,
        "dayName": "Today",
        "dateNum": "${now.day} Sep",
        "status": "Customized",
        "sabzi": appState.selectedSabzi,
        "roti": appState.selectedRoti,
        "isLocked": false,
      },
      {
        "date": now.add(const Duration(days: 1)),
        "dayName": "Tomorrow",
        "dateNum": "${now.day + 1} Sep",
        "status": appState.currentSubscription?.isPaused == true ? "Paused" : "Pending",
        "sabzi": "Bhindi Masala",
        "roti": "5 Butter Roti",
        "isLocked": false,
      },
      {
        "date": now.add(const Duration(days: 2)),
        "dayName": "Wednesday",
        "dateNum": "${now.day + 2} Sep",
        "status": "Customized",
        "sabzi": "Mix Veg Handi",
        "roti": "5 Tawa Roti",
        "isLocked": false,
      },
      {
        "date": now.add(const Duration(days: 3)),
        "dayName": "Thursday",
        "dateNum": "${now.day + 3} Sep",
        "status": "Pending",
        "sabzi": "Aloo Gobhi Adraki",
        "roti": "5 Butter Roti",
        "isLocked": false,
      },
      {
        "date": now.add(const Duration(days: 4)),
        "dayName": "Friday",
        "dateNum": "${now.day + 4} Sep",
        "status": "Customized",
        "sabzi": "Shahi Paneer",
        "roti": "5 Butter Roti",
        "isLocked": false,
      },
      {
        "date": now.subtract(const Duration(days: 1)),
        "dayName": "Yesterday",
        "dateNum": "${now.day - 1} Sep",
        "status": "Locked",
        "sabzi": "Delivered",
        "roti": "Standard Meal",
        "isLocked": true,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Meal Calendar", showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            // Notification reminder banner
            Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: AppColors.goldBackground,
                borderRadius: AppDimens.borderMD,
                border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: AppColors.goldDark, size: 24),
                  const SizedBox(width: AppDimens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Don't forget to customize tomorrow's meal.",
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.navyPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Cutoff time: 10:00 PM tonight for tomorrow's lunch.",
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
                Text("Next 7 Days Schedule", style: AppTypography.headingMedium),
                Text(
                  "September 2026",
                  style: AppTypography.caption.copyWith(
                    color: AppColors.navyPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.space12),

            ...days.map((item) {
              final status = item["status"] as String;
              final isLocked = item["isLocked"] as bool;

              Color statusColor = AppColors.statusSuccess;
              IconData statusIcon = Icons.check_circle_rounded;

              if (status == "Pending") {
                statusColor = AppColors.goldDark;
                statusIcon = Icons.edit_note_rounded;
              } else if (status == "Paused") {
                statusColor = AppColors.statusWarning;
                statusIcon = Icons.pause_circle_outline_rounded;
              } else if (status == "Locked") {
                statusColor = AppColors.textMuted;
                statusIcon = Icons.lock_outline_rounded;
              }

              return VrsCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppDimens.space16),
                onTap: isLocked
                    ? null
                    : () {
                        if (status == "Paused") {
                          PauseMealModal.show(context);
                        } else {
                          final selectedDate = item["date"] as DateTime;
                          final dateStr =
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                          Navigator.pushNamed(
                            context,
                            AppRoutes.mealCustomizer,
                            arguments: {
                              'menuDate': dateStr,
                              'initialSlot': 'LUNCH',
                            },
                          );
                        }
                      },
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isLocked ? AppColors.borderLight : AppColors.navyPrimary,
                        borderRadius: AppDimens.borderMD,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (item["dayName"] as String).substring(0, 3).toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: isLocked ? AppColors.textMuted : AppColors.goldLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (item["dateNum"] as String).split(' ').first,
                            style: AppTypography.titleMedium.copyWith(
                              color: isLocked ? AppColors.textMuted : AppColors.textWhite,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item["dayName"] as String,
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: AppDimens.borderFull,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, size: 12, color: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      status,
                                      style: AppTypography.caption.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${item["sabzi"]} • ${item["roti"]}",
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    if (!isLocked)
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                  ],
                ),
              );
            }),

            const SizedBox(height: AppDimens.space24),
          ],
        ),
      ),
    );
  }
}
