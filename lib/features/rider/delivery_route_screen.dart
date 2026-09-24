import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_card.dart';
import '../../data/models/rider_delivery_model.dart';
import '../../state/app_state_provider.dart';

class DeliveryRouteScreen extends StatelessWidget {
  const DeliveryRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final stops = appState.riderStops;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Optimized Delivery Route", showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            // Map Visual Header
            Container(
              height: 140,
              width: double.infinity,
              color: const Color(0xFFE2E8F0),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.navyPrimary,
                        borderRadius: AppDimens.borderFull,
                        boxShadow: AppDimens.navyShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.navigation_rounded, color: AppColors.goldLight, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "Total Route: 8.4 km • 4 Stops • Vijay Nagar Cluster",
                            style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimens.space16),
                itemCount: stops.length,
                itemBuilder: (context, index) {
                  final stop = stops[index];
                  final isDelivered = stop.status == DeliveryStatus.delivered;

                  return VrsCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(AppDimens.space16),
                    backgroundColor: isDelivered ? const Color(0xFFF0FDF4) : AppColors.surfaceWhite,
                    border: Border.all(
                      color: isDelivered ? AppColors.vegGreen : AppColors.borderLight,
                      width: isDelivered ? 1.5 : 1.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: isDelivered ? AppColors.vegGreen : AppColors.navyPrimary,
                                  child: Text(
                                    "${index + 1}",
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  stop.customerName,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navyPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.goldBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                stop.distanceKm,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Order #${stop.orderId} • ${stop.items.join(', ')}",
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Address: ${stop.address} (${stop.addressTag})",
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isDelivered)
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.vegGreen, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    "DELIVERED",
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.vegGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.deliveryConfirmation,
                                    arguments: stop,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.goldPrimary,
                                  foregroundColor: AppColors.navyDark,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                icon: const Icon(Icons.check_circle_outline, size: 16),
                                label: const Text("Deliver This Stop", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
