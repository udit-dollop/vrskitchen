import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/widgets/vrs_button.dart';
import '../../state/app_state_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scanAnimation;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _simulateScan() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    // Find first unverified stop
    final unverified = appState.riderStops.where((s) => !s.isQrVerified).firstOrNull;
    final orderId = unverified?.orderId ?? "VR10245";

    appState.verifyStopQr(orderId);

    setState(() => _isScanned = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        UiHelpers.showSuccessSnackbar(context, "Sticker for #$orderId Verified Successfully!");
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Scan Tiffin QR Sticker"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppDimens.space24),
            Text(
              "Align Sticker QR Code in the frame",
              style: AppTypography.titleMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              "Verify meal package before loading to delivery bag",
              style: AppTypography.caption.copyWith(color: Colors.white38),
            ),

            const Spacer(),

            // Viewfinder box
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: _isScanned ? AppColors.vegGreen : AppColors.goldPrimary, width: 3),
                  borderRadius: AppDimens.borderLG,
                ),
                child: Stack(
                  children: [
                    if (!_isScanned)
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 260 * _scanAnimation.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                boxShadow: AppDimens.goldGlow,
                              ),
                            ),
                          );
                        },
                      ),

                    if (_isScanned)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.vegGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Demo Simulation Button
            Padding(
              padding: const EdgeInsets.all(AppDimens.space24),
              child: Column(
                children: [
                  VrsButton(
                    text: _isScanned ? "Verified Successfully!" : "Simulate QR Scan (Camera Demo)",
                    icon: Icon(
                      _isScanned ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                      color: AppColors.navyDark,
                      size: 20,
                    ),
                    onPressed: _isScanned ? null : _simulateScan,
                    variant: VrsButtonVariant.gold,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Simulates physical optical scanning of thermal QR sticker",
                    style: AppTypography.caption.copyWith(color: Colors.white54, fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
