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

class BatchChecklistScreen extends StatelessWidget {
  const BatchChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final stops = appState.riderStops;
    final verifiedCount = stops.where((s) => s.isQrVerified).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Batch Tiffin Checklist", showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.space16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    decoration: BoxDecoration(
                      color: AppColors.goldBackground,
                      borderRadius: AppDimens.borderMD,
                      border: Border.all(color: AppColors.goldPrimary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Batch #B102 Verification",
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.navyDark,
                              ),
                            ),
                            Text(
                              "Scan each box QR sticker before loading into delivery bag.",
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                        Text(
                          "$verifiedCount / ${stops.length}",
                          style: AppTypography.headingLarge.copyWith(
                            color: AppColors.navyPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space20),

                  Text("Tiffin Packaging Checklist", style: AppTypography.headingSmall),
                  const SizedBox(height: AppDimens.space12),

                  ...stops.map((stop) {
                    return VrsCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(AppDimens.space14),
                      backgroundColor: stop.isQrVerified ? AppColors.surfaceWhite : AppColors.backgroundWarm,
                      border: Border.all(
                        color: stop.isQrVerified ? AppColors.vegGreen : AppColors.borderLight,
                        width: stop.isQrVerified ? 1.5 : 1.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: stop.isQrVerified
                                  ? AppColors.vegGreen.withValues(alpha: 0.15)
                                  : AppColors.borderLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              stop.isQrVerified ? Icons.check_circle_rounded : Icons.crop_free_rounded,
                              color: stop.isQrVerified ? AppColors.vegGreen : AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppDimens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "#${stop.orderId}",
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.navyPrimary,
                                      ),
                                    ),
                                    Text(
                                      stop.isQrVerified ? "QR VERIFIED" : "PENDING SCAN",
                                      style: AppTypography.caption.copyWith(
                                        color: stop.isQrVerified ? AppColors.vegGreen : AppColors.goldDark,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text("${stop.customerName} • ${stop.addressTag}", style: AppTypography.bodySmall),
                                Text(stop.items.join(", "), style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Bottom Actions
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VrsButton(
                      text: "Scan QR Stickers with Camera",
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.navyDark, size: 20),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.qrScanner),
                      variant: VrsButtonVariant.gold,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.deliveryRoute),
                      child: const Text("Start Delivery Route Map"),
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
}
