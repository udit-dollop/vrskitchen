import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_badge.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/subscription_model.dart';
import '../../../state/app_state_provider.dart';

class PlanSelectorScreen extends StatefulWidget {
  const PlanSelectorScreen({super.key});

  @override
  State<PlanSelectorScreen> createState() => _PlanSelectorScreenState();
}

class _PlanSelectorScreenState extends State<PlanSelectorScreen> {
  int _selectedPlanIndex = 0;
  String _selectedSlot = "Lunch"; // Lunch, Dinner, Both
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlans();
    });
  }

  Future<void> _loadPlans() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    setState(() => _isLoading = true);
    await appState.syncSubscriptionPlans();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final plans = appState.subscriptionPlans;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Subscription Plans", showBack: true),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.goldPrimary),
              )
            : plans.isEmpty
                ? RefreshIndicator(
                    onRefresh: _loadPlans,
                    color: AppColors.goldPrimary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        EmptyStateWidget(
                          icon: Icons.card_membership_rounded,
                          title: "No Subscription Plans Available",
                          subtitle: "The kitchen has not published any subscription plans yet. Please check back later or pull down to refresh.",
                          buttonText: "Refresh Plans",
                          onButtonPressed: _loadPlans,
                        ),
                      ],
                    ),
                  )
                : _buildPlanContent(context, appState, plans),
      ),
    );
  }

  Widget _buildPlanContent(
    BuildContext context,
    AppStateProvider appState,
    List<SubscriptionPackageModel> plans,
  ) {
    if (_selectedPlanIndex >= plans.length) {
      _selectedPlanIndex = 0;
    }
    final activePlan = plans[_selectedPlanIndex];
    final totalPrice = activePlan.basePrice;

    // Available slots based on plan.mealSlot
    List<String> slotOptions = ["Lunch", "Dinner"];
    if (activePlan.mealSlot.toUpperCase() == 'BOTH') {
      slotOptions = ["Lunch", "Dinner", "Both"];
    } else if (activePlan.mealSlot.toUpperCase() == 'LUNCH') {
      slotOptions = ["Lunch"];
    } else if (activePlan.mealSlot.toUpperCase() == 'DINNER') {
      slotOptions = ["Dinner"];
    }

    if (!slotOptions.contains(_selectedSlot)) {
      _selectedSlot = slotOptions.first;
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPlans,
            color: AppColors.goldPrimary,
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.space16),
              children: [
                Text("Flexible Daily Tiffin Plans", style: AppTypography.headingLarge),
                const SizedBox(height: 4),
                Text(
                  "Authentic homestyle cooking with zero commitment anxiety. Pause anytime and receive wallet credit.",
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppDimens.space20),

                // 1. Available Live Plans from API
                Text("Select Subscription Plan", style: AppTypography.headingSmall),
                const SizedBox(height: AppDimens.space12),

                ...List.generate(plans.length, (index) {
                  final p = plans[index];
                  final isSelected = _selectedPlanIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildPlanCard(
                      plan: p,
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedPlanIndex = index),
                    ),
                  );
                }),

                const SizedBox(height: AppDimens.space16),

                // 2. Meal Delivery Slot Selection
                Text("Meal Delivery Slot", style: AppTypography.headingSmall),
                const SizedBox(height: AppDimens.space12),
                Wrap(
                  spacing: 10,
                  children: slotOptions.map((slot) {
                    final isSelected = _selectedSlot == slot;
                    return ChoiceChip(
                      label: Text(slot == "Both" ? "Both (Lunch & Dinner)" : "$slot Slot"),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedSlot = slot);
                      },
                      selectedColor: AppColors.goldBackground,
                      backgroundColor: AppColors.surfaceWhite,
                      labelStyle: AppTypography.titleSmall.copyWith(
                        color: isSelected ? AppColors.navyDark : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppDimens.space24),

                // 3. Plan Inclusions & Quotas Card (from API)
                if (activePlan.inclusions.isNotEmpty)
                  VrsCard(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    backgroundColor: AppColors.surfaceWhite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${activePlan.title} Includes:",
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const VegBadge(size: 14),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...activePlan.inclusions.map((inc) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.check_circle_rounded, color: AppColors.vegGreen, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(inc, style: AppTypography.bodyMedium),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                const SizedBox(height: AppDimens.space32),
              ],
            ),
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
                    Text("Subscription Total", style: AppTypography.caption),
                    Text(
                      "₹${totalPrice.toInt()}",
                      style: AppTypography.priceTag,
                    ),
                  ],
                ),
                const SizedBox(width: AppDimens.space20),
                Expanded(
                  child: VrsButton(
                    text: "Continue to Add-ons",
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.subscriptionAddons,
                        arguments: {
                          "planId": activePlan.id,
                          "planName": activePlan.title,
                          "packageType": activePlan.type,
                          "meals": activePlan.durationDays,
                          "slot": _selectedSlot,
                          "basePrice": totalPrice,
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
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPackageModel plan,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimens.borderLG,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.space16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navyPrimary : AppColors.surfaceWhite,
          borderRadius: AppDimens.borderLG,
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected ? AppDimens.navyShadow : AppDimens.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.goldPrimary : AppColors.navyPrimary.withValues(alpha: 0.08),
                        borderRadius: AppDimens.borderFull,
                      ),
                      child: Text(
                        "${plan.durationDays} DAYS PLAN",
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? AppColors.navyDark : AppColors.navyPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white12 : AppColors.backgroundLight,
                        borderRadius: AppDimens.borderFull,
                      ),
                      child: Text(
                        plan.mealSlot.toUpperCase() == 'BOTH' ? 'LUNCH & DINNER' : plan.mealSlot.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? Colors.white70 : AppColors.textMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
                  color: isSelected ? AppColors.goldPrimary : AppColors.textLight,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan.title,
              style: AppTypography.headingMedium.copyWith(
                color: isSelected ? AppColors.goldLight : AppColors.navyPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              plan.subtitle,
              style: AppTypography.caption.copyWith(
                color: isSelected ? Colors.white70 : AppColors.textMuted,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${plan.basePrice.toInt()}",
                      style: AppTypography.headingLarge.copyWith(
                        color: isSelected ? AppColors.textWhite : AppColors.navyPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                      ),
                    ),
                    Text(
                      "Total for ${plan.durationDays} Days",
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? Colors.white60 : AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.goldBackground : AppColors.vegGreen.withValues(alpha: 0.1),
                    borderRadius: AppDimens.borderMD,
                  ),
                  child: Text(
                    "₹${plan.pricePerMeal.toInt()}/meal",
                    style: AppTypography.titleSmall.copyWith(
                      color: isSelected ? AppColors.navyDark : AppColors.vegGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
