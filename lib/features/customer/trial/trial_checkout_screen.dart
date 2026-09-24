import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_badge.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/order_model.dart';
import '../../../state/app_state_provider.dart';

class TrialCheckoutScreen extends StatefulWidget {
  const TrialCheckoutScreen({super.key});

  @override
  State<TrialCheckoutScreen> createState() => _TrialCheckoutScreenState();
}

class _TrialCheckoutScreenState extends State<TrialCheckoutScreen> {
  String _selectedPaymentMethod = "UPI";
  bool _isProcessing = false;

  void _onConfirmPayment(Map<String, dynamic> args) {
    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        final price = (args["price"] as num?)?.toDouble() ?? 110.0;
        final plan = args["plan"] as String? ?? "Standard";
        final slot = args["slot"] as String? ?? "Lunch";

        final newOrder = OrderItemModel(
          orderId: "VR${10250 + (DateTime.now().millisecond % 500)}",
          planName: "$plan Trial Meal",
          date: DateTime.now(),
          slot: slot == "Dinner" ? "Dinner (8:00 PM - 10:00 PM)" : "Lunch (1:00 PM - 2:00 PM)",
          sabzi: appState.selectedSabzi,
          dal: "Dal Tadka",
          roti: appState.selectedRoti,
          rice: appState.selectedRice,
          addOns: ["Salad"],
          amount: price,
          status: OrderStatus.preparing,
          deliveryAddress: appState.user.selectedAddress?.addressLine ?? "Vijay Nagar, Indore",
          riderName: "Rajesh Kumar",
          riderPhone: "+91 98765 01234",
          estimatedMinutes: 25,
        );

        appState.addNewOrder(newOrder);

        setState(() => _isProcessing = false);
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.trialConfirmation,
          arguments: newOrder,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {
      "plan": "Standard",
      "slot": "Lunch",
      "day": "Today",
      "price": 110.0,
    };

    final appState = Provider.of<AppStateProvider>(context);
    final user = appState.user;
    final price = (args["price"] as num?)?.toDouble() ?? 110.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Order Review", showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.space16),
                children: [
                  // 1. Meal Summary
                  VrsCard(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const VegBadge(size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "${args['plan']} Trial Meal",
                                  style: AppTypography.headingSmall,
                                ),
                              ],
                            ),
                            Text(
                              "₹${price.toInt()}",
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.navyPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Slot: ${args['slot']} • ${args['day']}",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildItemLine("Sabzi", appState.selectedSabzi),
                        const SizedBox(height: 4),
                        _buildItemLine("Dal", "Dal Tadka"),
                        const SizedBox(height: 4),
                        _buildItemLine("Roti", appState.selectedRoti),
                        const SizedBox(height: 4),
                        _buildItemLine("Rice", appState.selectedRice),
                        const SizedBox(height: 4),
                        _buildItemLine("Complimentary", "Salad"),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space16),

                  // 2. Delivery Address
                  VrsCard(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Delivery Address", style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.savedAddresses),
                              child: Text(
                                "Change",
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.goldBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on, size: 16, color: AppColors.goldDark),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.selectedAddress?.tag ?? "Office",
                                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    user.selectedAddress?.addressLine ?? "Vijay Nagar, Indore",
                                    style: AppTypography.bodySmall,
                                  ),
                                  Text(
                                    user.selectedAddress?.landmark ?? "Near Brilliant Convention Centre",
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space16),

                  // 3. Payment Method Selection
                  VrsCard(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Payment Method", style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          title: "UPI (Google Pay / PhonePe / Paytm)",
                          subtitle: "Instant & Recommended",
                          icon: Icons.qr_code_2_rounded,
                          id: "UPI",
                        ),
                        _buildPaymentOption(
                          title: "Flexi Wallet",
                          subtitle: "Balance: ₹${appState.walletBalance.toInt()}",
                          icon: Icons.account_balance_wallet_outlined,
                          id: "WALLET",
                        ),
                        _buildPaymentOption(
                          title: "Credit / Debit Card",
                          subtitle: "Visa, Mastercard, RuPay",
                          icon: Icons.credit_card_rounded,
                          id: "CARD",
                        ),
                        _buildPaymentOption(
                          title: "Net Banking",
                          subtitle: "All Indian Banks supported",
                          icon: Icons.account_balance_rounded,
                          id: "NETBANKING",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space16),

                  // 4. Bill Summary
                  VrsCard(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    child: Column(
                      children: [
                        _buildBillRow("Meal Base Total", "₹${price.toInt()}"),
                        const SizedBox(height: 6),
                        _buildBillRow("Tiffin Packing & Box", "FREE"),
                        const SizedBox(height: 6),
                        _buildBillRow("Delivery Partner Fee", "FREE"),
                        const Divider(height: 20),
                        _buildBillRow("Grand Total", "₹${price.toInt()}", isBold: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space32),
                ],
              ),
            ),

            // Sticky Pay CTA
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
                child: VrsButton(
                  text: "Pay ₹${price.toInt()} & Confirm Order",
                  isLoading: _isProcessing,
                  onPressed: () => _onConfirmPayment(args),
                  variant: VrsButtonVariant.gold,
                  icon: const Icon(Icons.lock_outline_rounded, color: AppColors.navyDark, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemLine(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.navyPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String id,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: AppDimens.borderMD,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldBackground : AppColors.surfaceWhite,
          borderRadius: AppDimens.borderMD,
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.goldDark : AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)
              : AppTypography.bodySmall,
        ),
        Text(
          value,
          style: isBold
              ? AppTypography.headingSmall.copyWith(color: AppColors.navyPrimary, fontWeight: FontWeight.w800)
              : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
