import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_button.dart';
import '../../core/widgets/vrs_card.dart';
import '../../data/models/rider_delivery_model.dart';
import '../../state/app_state_provider.dart';

class DeliveryConfirmationScreen extends StatefulWidget {
  const DeliveryConfirmationScreen({super.key});

  @override
  State<DeliveryConfirmationScreen> createState() => _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState extends State<DeliveryConfirmationScreen> {
  bool _isPhotoTaken = false;
  bool _isDelivering = false;

  void _confirmDelivery(String orderId) {
    setState(() => _isDelivering = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.markStopDelivered(orderId);

        setState(() => _isDelivering = false);
        UiHelpers.showSuccessSnackbar(context, "Order #$orderId Marked as Delivered successfully!");
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stop = ModalRoute.of(context)?.settings.arguments as DeliveryStopModel? ??
        DeliveryStopModel(
          orderId: "VR10245",
          customerName: "Rahul Sharma",
          phone: "+91 98765 43210",
          address: "Tech Park, 4th Floor, Vijay Nagar",
          addressTag: "Office",
          distanceKm: "1.2 km",
          mealType: "Lunch",
          items: ["Paneer Butter Masala", "Dal Tadka", "5 Butter Roti", "Jeera Rice"],
        );

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Delivery Handover", showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            // Customer Info Card
            VrsCard(
              padding: const EdgeInsets.all(AppDimens.space20),
              backgroundColor: AppColors.navyPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stop.customerName,
                        style: AppTypography.headingMedium.copyWith(color: Colors.white),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary,
                          borderRadius: AppDimens.borderFull,
                        ),
                        child: Text(
                          "#${stop.orderId}",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.navyDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stop.address,
                    style: AppTypography.caption.copyWith(color: AppColors.goldLight),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Calling ${stop.customerName} (${stop.phone})...")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vegGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text("Call Customer", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space20),

            // Package Contents Verification
            VrsCard(
              padding: const EdgeInsets.all(AppDimens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Package Items to Handover", style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...stop.items.map((it) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 16, color: AppColors.vegGreen),
                        const SizedBox(width: 8),
                        Text(it, style: AppTypography.bodySmall),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space20),

            // Leave at Gate / Photo Proof Section
            VrsCard(
              padding: const EdgeInsets.all(AppDimens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Proof of Delivery (Optional)", style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      if (_isPhotoTaken)
                        const Icon(Icons.check_circle, color: AppColors.vegGreen, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Take photo if customer is unavailable or asked to leave at security/door.",
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () {
                      setState(() => _isPhotoTaken = !_isPhotoTaken);
                      UiHelpers.showSuccessSnackbar(
                        context,
                        _isPhotoTaken ? "Delivery photo proof captured!" : "Photo cleared",
                      );
                    },
                    borderRadius: AppDimens.borderMD,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: AppDimens.borderMD,
                        border: Border.all(
                          color: _isPhotoTaken ? AppColors.vegGreen : AppColors.borderLight,
                          width: _isPhotoTaken ? 1.8 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isPhotoTaken ? Icons.camera_alt_rounded : Icons.add_a_photo_outlined,
                              color: _isPhotoTaken ? AppColors.vegGreen : AppColors.navyPrimary,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isPhotoTaken ? "Photo Proof Attached ✓" : "Tap to Capture Tiffin Photo",
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isPhotoTaken ? AppColors.vegGreen : AppColors.navyPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space28),

            // Delivery Action Buttons
            VrsButton(
              text: "Mark Order Delivered",
              isLoading: _isDelivering,
              icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.navyDark, size: 20),
              onPressed: () => _confirmDelivery(stop.orderId),
              variant: VrsButtonVariant.gold,
            ),

            const SizedBox(height: AppDimens.space12),

            OutlinedButton(
              onPressed: () {
                UiHelpers.showSuccessSnackbar(context, "Status set: Left at Security Gate with photo confirmation.");
                _confirmDelivery(stop.orderId);
              },
              child: const Text("Customer Unavailable • Leave at Gate"),
            ),

            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }
}
