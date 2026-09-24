import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/vrs_app_bar.dart';
import '../../core/widgets/vrs_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(
        title: "Kitchen & Operations Admin",
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.space16),
          children: [
            // Admin Welcome Card
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
                        "Good Morning, Admin 👋",
                        style: AppTypography.headingLarge.copyWith(color: AppColors.textWhite),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary,
                          borderRadius: AppDimens.borderFull,
                        ),
                        child: Text(
                          "LIVE OPERATIONS",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.navyDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Today's Batch #B102 • Lunch Delivery Hub",
                    style: AppTypography.caption.copyWith(color: AppColors.goldLight),
                  ),
                  const SizedBox(height: AppDimens.space16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderStat("Today's Orders", "75"),
                      _buildHeaderStat("Total Revenue", "₹8,450"),
                      _buildHeaderStat("Active Subscribers", "42"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space20),

            // Order Status Pipeline
            Text("Order Fulfillment Pipeline", style: AppTypography.headingSmall),
            const SizedBox(height: AppDimens.space12),

            Row(
              children: [
                Expanded(
                  child: _buildPipelineCard(
                    count: "45",
                    label: "Preparing",
                    color: AppColors.statusWarning,
                    icon: Icons.soup_kitchen_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPipelineCard(
                    count: "20",
                    label: "Packed",
                    color: AppColors.goldDark,
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPipelineCard(
                    count: "10",
                    label: "On Route",
                    color: AppColors.statusInfo,
                    icon: Icons.delivery_dining_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimens.space24),

            // Operations Modules Grid
            Text("Kitchen Management Modules", style: AppTypography.headingSmall),
            const SizedBox(height: AppDimens.space12),

            _buildModuleTile(
              title: "Kitchen Demand Aggregation",
              subtitle: "Aggregated portions for gravies, dal, rotis and rice",
              icon: Icons.restaurant_rounded,
              badge: "6 Items",
              route: AppRoutes.kitchenPrep,
              context: context,
            ),
            _buildModuleTile(
              title: "QR Sticker Generation",
              subtitle: "Print automated meal token stickers with packing details",
              icon: Icons.qr_code_2_rounded,
              badge: "Token #10245",
              route: AppRoutes.qrStickers,
              context: context,
            ),
            _buildModuleTile(
              title: "Weekly Menu Management",
              subtitle: "Set lunch/dinner menu, cutoff rules & add dishes",
              icon: Icons.calendar_today_rounded,
              badge: "Cutoff Active",
              route: AppRoutes.adminMenu,
              context: context,
            ),
            _buildModuleTile(
              title: "Raw Inventory & Stock",
              subtitle: "Track paneer, wheat, rice and alert low stock",
              icon: Icons.inventory_rounded,
              badge: "2 Low Stock",
              badgeColor: AppColors.statusError,
              route: AppRoutes.inventory,
              context: context,
            ),
            _buildModuleTile(
              title: "Subscribers Directory",
              subtitle: "Manage monthly subscriptions, remaining counts & status",
              icon: Icons.people_alt_rounded,
              badge: "Active",
              route: AppRoutes.subscribers,
              context: context,
            ),

            const SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.headingLarge.copyWith(color: AppColors.goldLight)),
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10.5)),
      ],
    );
  }

  Widget _buildPipelineCard({
    required String count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return VrsCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            count,
            style: AppTypography.headingLarge.copyWith(
              color: AppColors.navyPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    Color? badgeColor,
    required String route,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppDimens.borderMD,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, route),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.navyPrimary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.navyPrimary, size: 22),
        ),
        title: Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: AppTypography.caption),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (badgeColor ?? AppColors.goldPrimary).withValues(alpha: 0.15),
            borderRadius: AppDimens.borderFull,
          ),
          child: Text(
            badge,
            style: AppTypography.caption.copyWith(
              color: badgeColor ?? AppColors.goldDark,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
