import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_button.dart';

class QrStickersScreen extends StatefulWidget {
  const QrStickersScreen({super.key});

  @override
  State<QrStickersScreen> createState() => _QrStickersScreenState();
}

class _QrStickersScreenState extends State<QrStickersScreen> {
  String _selectedToken = "#10245";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Tiffin Packaging Sticker", showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            Text("Automated Thermal QR Sticker", style: AppTypography.headingMedium),
            const SizedBox(height: 4),
            Text(
              "Generated at packaging station for dispatch verification by delivery riders.",
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimens.space20),

            // Printable Sticker Card Visual
            Center(
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(AppDimens.space20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: AppDimens.borderLG,
                  border: Border.all(color: AppColors.navyPrimary, width: 2),
                  boxShadow: AppDimens.mediumShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset("assets/images/logo.png", width: 28, height: 28),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "VR's KITCHEN",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "YOUR MEALS. YOUR WAY. EVERY DAY.",
                      style: AppTypography.caption.copyWith(fontSize: 8, letterSpacing: 0.8),
                    ),
                    const Divider(height: 20, thickness: 1.5),

                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: AppDimens.borderMD,
                      ),
                      child: QrImageView(
                        data: "VR_TIFFIN_$_selectedToken",
                        version: QrVersions.auto,
                        size: 140,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.navyPrimary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.navyPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      "DISPATCH TOKEN: $_selectedToken",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.navyPrimary,
                      ),
                    ),
                    const Divider(height: 20, thickness: 1.2),

                    // Order & Customer Details
                    _buildStickerRow("Customer", "Rahul Sharma"),
                    _buildStickerRow("Order ID", "#VR10245"),
                    _buildStickerRow("Meal Slot", "Lunch (Today)"),
                    _buildStickerRow("Sabzi", "Paneer Butter Masala"),
                    _buildStickerRow("Dal / Rice", "Dal Tadka • Jeera Rice"),
                    _buildStickerRow("Breads", "5 Butter Roti"),
                    _buildStickerRow("Delivery Point", "Office (Tech Park, 4th Flr)"),

                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.navyPrimary,
                      child: Center(
                        child: Text(
                          "PACKED HOT & FRESH • CONSUME WITHIN 3 HOURS",
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimens.space24),

            // Print Action
            VrsButton(
              text: "Print Thermal Sticker",
              icon: const Icon(Icons.print_rounded, color: AppColors.navyDark, size: 20),
              onPressed: () {
                UiHelpers.showSuccessSnackbar(context, "Demo print successful! Sticker sent to kitchen thermal printer.");
              },
              variant: VrsButtonVariant.gold,
            ),

            const SizedBox(height: AppDimens.space12),

            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedToken = "#${10245 + (DateTime.now().millisecond % 50)}";
                });
                UiHelpers.showSuccessSnackbar(context, "Regenerated sticker for $_selectedToken");
              },
              child: const Text("Generate Next Token Sticker"),
            ),

            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
          Text(value, style: AppTypography.caption.copyWith(color: AppColors.navyPrimary, fontSize: 10.5)),
        ],
      ),
    );
  }
}
