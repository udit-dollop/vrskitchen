import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_card.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Live Order Tracking", showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            // Map-Style Visual Header with animated rider & route
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  // Stylized Map Background
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE8ECEF),
                    child: CustomPaint(
                      painter: _MapRoadsPainter(),
                    ),
                  ),

                  // Route Line & Markers
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.navyPrimary.withValues(alpha: 0.95),
                        borderRadius: AppDimens.borderFull,
                        boxShadow: AppDimens.navyShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.two_wheeler_rounded, color: AppColors.goldLight, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "Rajesh is 1.2 km away • Arriving in 18 mins",
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Destination Pin
                  Positioned(
                    top: 40,
                    right: 60,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.navyPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: AppColors.goldPrimary, size: 24),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: AppDimens.softShadow,
                          ),
                          child: Text("Tech Park (Office)", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // Kitchen Pin
                  Positioned(
                    bottom: 30,
                    left: 50,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.goldDark,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.soup_kitchen_rounded, color: Colors.white, size: 20),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: AppDimens.softShadow,
                          ),
                          child: Text("VR's Main Kitchen", style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tracking Info Bottom Sheet
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimens.radiusXL),
                    topRight: Radius.circular(AppDimens.radiusXL),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.all(AppDimens.space20),
                  children: [
                    // Delivery Partner Card
                    VrsCard(
                      padding: const EdgeInsets.all(AppDimens.space14),
                      backgroundColor: AppColors.backgroundWarm,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.goldPrimary,
                            child: Text(
                              "RK",
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.navyDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rajesh Kumar",
                                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 14, color: AppColors.goldDark),
                                    const SizedBox(width: 2),
                                    Text(
                                      "4.9 • Delivery Partner",
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Calling Rajesh Kumar (+91 98765 01234)...")),
                              );
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.vegGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimens.space20),

                    Text("Order Status Timeline", style: AppTypography.headingSmall),
                    const SizedBox(height: AppDimens.space16),

                    // Milestone Tracker
                    _buildTimelineStep(
                      title: "Order Received & Confirmed",
                      subtitle: "Token #10245 assigned",
                      time: "11:30 AM",
                      isDone: true,
                      isCurrent: false,
                    ),
                    _buildTimelineStep(
                      title: "Fresh Preparation in Kitchen",
                      subtitle: "Cooked with pure desi ghee & spices",
                      time: "12:15 PM",
                      isDone: true,
                      isCurrent: false,
                    ),
                    _buildTimelineStep(
                      title: "Packed in Insulated Tiffin",
                      subtitle: "QR security seal verified",
                      time: "12:40 PM",
                      isDone: true,
                      isCurrent: false,
                    ),
                    _buildTimelineStep(
                      title: "Out for Delivery",
                      subtitle: "Partner on the way on Hero Electric",
                      time: "12:50 PM",
                      isDone: true,
                      isCurrent: true,
                    ),
                    _buildTimelineStep(
                      title: "Delivered at Desk / Doorstep",
                      subtitle: "Handed over with smile",
                      time: "Est. 1:15 PM",
                      isDone: false,
                      isCurrent: false,
                      isLast: true,
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

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String time,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone
                    ? (isCurrent ? AppColors.goldPrimary : AppColors.vegGreen)
                    : AppColors.borderLight,
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(color: AppColors.navyPrimary, width: 2) : null,
              ),
              child: Center(
                child: isDone
                    ? (isCurrent
                        ? const Icon(Icons.delivery_dining_rounded, size: 12, color: AppColors.navyDark)
                        : const Icon(Icons.check, size: 12, color: Colors.white))
                    : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isDone ? AppColors.vegGreen : AppColors.borderLight,
              ),
          ],
        ),
        const SizedBox(width: AppDimens.space12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: isCurrent ? AppColors.navyPrimary : AppColors.textDark,
                      ),
                    ),
                    Text(time, style: AppTypography.caption),
                  ],
                ),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final routePaint = Paint()
      ..color = AppColors.navyPrimary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background road lines
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.45), roadPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.4, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.7), secondaryRoadPaint);

    // Active Delivery Route Line
    final path = Path()
      ..moveTo(65, size.height - 40)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.6, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.35, size.width - 70, 60);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
