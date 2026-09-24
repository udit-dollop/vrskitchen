import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';

class TrialSlotPickerScreen extends StatefulWidget {
  const TrialSlotPickerScreen({super.key});

  @override
  State<TrialSlotPickerScreen> createState() => _TrialSlotPickerScreenState();
}

class _TrialSlotPickerScreenState extends State<TrialSlotPickerScreen> {
  String _selectedSlot = "Lunch";
  String _selectedDay = "Today";
  String _selectedPlan = "Standard"; // Standard (₹110) or Premium (₹150)

  @override
  Widget build(BuildContext context) {
    final price = _selectedPlan == "Standard" ? 110.0 : 150.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Order a Trial Meal", showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.space16),
                children: [
                  Text("Try Fresh Homemade Taste", style: AppTypography.headingLarge),
                  const SizedBox(height: 4),
                  Text(
                    "No subscription needed. Test our food quality and prompt delivery before subscribing.",
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppDimens.space24),

                  // Package Option
                  Text("1. Select Meal Experience", style: AppTypography.headingSmall),
                  const SizedBox(height: AppDimens.space12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPlanOption(
                          title: "Standard",
                          price: "₹110",
                          subtitle: "1 Veg Sabzi, Dal, 5 Butter Roti, Rice, Salad",
                          isSelected: _selectedPlan == "Standard",
                          onTap: () => setState(() => _selectedPlan = "Standard"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPlanOption(
                          title: "Premium",
                          price: "₹150",
                          subtitle: "Paneer Sabzi, Sabzi, Dal, 5 Roti, Sweet, Salad",
                          isSelected: _selectedPlan == "Premium",
                          onTap: () => setState(() => _selectedPlan = "Premium"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimens.space24),

                  // Slot Selection
                  Text("2. Select Meal Slot", style: AppTypography.headingSmall),
                  const SizedBox(height: AppDimens.space12),
                  _buildSlotTile(
                    title: "Lunch Slot",
                    timing: "12:00 PM - 2:00 PM",
                    icon: Icons.wb_sunny_rounded,
                    isSelected: _selectedSlot == "Lunch",
                    onTap: () => setState(() => _selectedSlot = "Lunch"),
                  ),
                  const SizedBox(height: 10),
                  _buildSlotTile(
                    title: "Dinner Slot",
                    timing: "8:00 PM - 10:00 PM",
                    icon: Icons.nightlight_round,
                    isSelected: _selectedSlot == "Dinner",
                    onTap: () => setState(() => _selectedSlot = "Dinner"),
                  ),
                  const SizedBox(height: 10),
                  _buildSlotTile(
                    title: "Both (Lunch & Dinner)",
                    timing: "Lunch & Dinner full day trial",
                    icon: Icons.all_inclusive_rounded,
                    isSelected: _selectedSlot == "Both",
                    onTap: () => setState(() => _selectedSlot = "Both"),
                  ),

                  const SizedBox(height: AppDimens.space24),

                  // Delivery Date
                  Text("3. Delivery Date", style: AppTypography.headingSmall),
                  const SizedBox(height: AppDimens.space12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTile(
                          title: "Today",
                          date: "10 Sep",
                          isSelected: _selectedDay == "Today",
                          onTap: () => setState(() => _selectedDay = "Today"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTile(
                          title: "Tomorrow",
                          date: "11 Sep",
                          isSelected: _selectedDay == "Tomorrow",
                          onTap: () => setState(() => _selectedDay = "Tomorrow"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Trial Total", style: AppTypography.caption),
                        Text(
                          "₹${(_selectedSlot == 'Both' ? price * 2 : price).toInt()}",
                          style: AppTypography.priceTag,
                        ),
                      ],
                    ),
                    const SizedBox(width: AppDimens.space20),
                    Expanded(
                      child: VrsButton(
                        text: "Proceed to Checkout",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.trialCheckout,
                            arguments: {
                              "plan": _selectedPlan,
                              "slot": _selectedSlot,
                              "day": _selectedDay,
                              "price": _selectedSlot == 'Both' ? price * 2 : price,
                            },
                          );
                        },
                        variant: VrsButtonVariant.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption({
    required String title,
    required String price,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return VrsCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimens.space12),
      backgroundColor: isSelected ? AppColors.goldBackground : AppColors.surfaceWhite,
      border: Border.all(
        color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
        width: isSelected ? 1.8 : 1.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              Text(
                price,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTypography.caption,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotTile({
    required String title,
    required String timing,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.borderMD,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldBackground : AppColors.surfaceWhite,
          borderRadius: AppDimens.borderMD,
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.goldDark : AppColors.navyPrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.navyDark : AppColors.textDark,
                    ),
                  ),
                  Text(timing, style: AppTypography.caption),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.goldDark : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required String title,
    required String date,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.borderMD,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldBackground : AppColors.surfaceWhite,
          borderRadius: AppDimens.borderMD,
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.navyDark : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(date, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
