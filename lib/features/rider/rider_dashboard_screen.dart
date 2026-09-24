import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_button.dart';
import '../../core/widgets/vrs_card.dart';
import '../../state/app_state_provider.dart';

class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isOnDuty = appState.isRiderOnDuty;
    final stops = appState.riderStops;
    final verifiedCount = stops.where((s) => s.isQrVerified).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(
        title: "Delivery Partner Portal",
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            // Rider Duty Status Hero Card
            VrsCard(
              padding: const EdgeInsets.all(AppDimens.space20),
              backgroundColor: AppColors.navyPrimary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Good Morning, Rajesh 👋",
                            style: AppTypography.headingLarge.copyWith(color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Vehicle: Hero Electric • Zone: Vijay Nagar",
                            style: AppTypography.caption.copyWith(color: AppColors.goldLight),
                          ),
                        ],
                      ),
                      Switch(
                        value: isOnDuty,
                        activeThumbColor: AppColors.goldPrimary,
                        activeTrackColor: AppColors.goldDark,
                        onChanged: (val) {
                          appState.toggleRiderDuty(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOnDuty ? AppColors.vegGreen : AppColors.statusError,
                      borderRadius: AppDimens.borderFull,
                    ),
                    child: Text(
                      isOnDuty ? "DUTY: ONLINE" : "DUTY: OFFLINE",
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),

                  const Divider(height: 24, color: Colors.white24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat("Assigned Batch", "Batch #B102"),
                      _buildStat("Total Tiffins", "${stops.length}"),
                      _buildStat("QR Verified", "$verifiedCount / ${stops.length}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space20),

            // Today's Batch Card
            VrsCard(
              padding: const EdgeInsets.all(AppDimens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Assigned Batch",
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Ready for Pickup",
                          style: AppTypography.caption.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Batch #B102 • 12 Tiffins Total (8 Lunch, 4 Dinner)",
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.navyPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hub: VR's Main Kitchen, Scheme 54, Vijay Nagar",
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppDimens.space16),

                  VrsButton(
                    text: "Start Batch Pickup & Scan QR",
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.navyDark, size: 20),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.batchChecklist),
                    variant: VrsButtonVariant.gold,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space20),

            // Navigation Map Preview Tile
            VrsCard(
              onTap: () => Navigator.pushNamed(context, AppRoutes.deliveryRoute),
              padding: const EdgeInsets.all(AppDimens.space16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.navyPrimary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.map_rounded, color: AppColors.navyPrimary, size: 26),
                  ),
                  const SizedBox(width: AppDimens.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Delivery Route Map",
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Optimized GPS route with 4 stops in Vijay Nagar",
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textLight),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(color: AppColors.goldLight, fontWeight: FontWeight.bold)),
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
