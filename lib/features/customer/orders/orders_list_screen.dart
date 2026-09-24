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
import '../../../data/models/order_model.dart';
import '../../../state/app_state_provider.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final allOrders = appState.orders;

    final upcomingOrders = allOrders.where((o) =>
        o.status == OrderStatus.preparing ||
        o.status == OrderStatus.outForDelivery ||
        o.status == OrderStatus.scheduled).toList();

    final completedOrders = allOrders.where((o) => o.status == OrderStatus.delivered).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "My Orders"),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surfaceWhite,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.navyPrimary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.goldPrimary,
                indicatorWeight: 3,
                labelStyle: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Upcoming (${upcomingOrders.length})"),
                  Tab(text: "Completed (${completedOrders.length})"),
                  const Tab(text: "Cancelled (0)"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Upcoming Orders
                  upcomingOrders.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.receipt_long_rounded,
                          title: "No meals yet",
                          subtitle: "Your next delicious meal is waiting to be scheduled.",
                          buttonText: "Try a Meal",
                          onButtonPressed: () => Navigator.pushNamed(context, AppRoutes.trialSlot),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppDimens.space16),
                          itemCount: upcomingOrders.length,
                          itemBuilder: (context, index) => _buildOrderCard(upcomingOrders[index]),
                        ),

                  // Completed Orders
                  completedOrders.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.check_circle_outline_rounded,
                          title: "No completed meals yet",
                          subtitle: "Delivered meals will appear in this history.",
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppDimens.space16),
                          itemCount: completedOrders.length,
                          itemBuilder: (context, index) => _buildOrderCard(completedOrders[index]),
                        ),

                  // Cancelled Orders
                  const EmptyStateWidget(
                    icon: Icons.cancel_outlined,
                    title: "No cancelled orders",
                    subtitle: "Enjoy uninterrupted daily wholesome dining.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderItemModel order) {
    final isUpcoming = order.status != OrderStatus.delivered;

    return VrsCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const VegBadge(size: 14),
                  const SizedBox(width: 8),
                  Text(
                    "#${order.orderId}",
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyPrimary,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.planName,
            style: AppTypography.titleMedium.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "${order.sabzi} • ${order.roti} • ${order.dal} • ${order.rice}",
            style: AppTypography.bodySmall,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Slot Timing", style: AppTypography.caption),
                  Text(
                    order.slot,
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                "₹${order.amount.toInt()}",
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyPrimary,
                ),
              ),
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: AppDimens.space16),
            VrsButton(
              text: "Track Order Live",
              height: 44,
              icon: const Icon(Icons.near_me_rounded, color: AppColors.navyDark, size: 16),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.orderTracking);
              },
              variant: VrsButtonVariant.gold,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    switch (status) {
      case OrderStatus.preparing:
        return VrsStatusBadge.preparing();
      case OrderStatus.outForDelivery:
        return VrsStatusBadge.outForDelivery();
      case OrderStatus.delivered:
        return VrsStatusBadge.delivered();
      case OrderStatus.scheduled:
        return const VrsStatusBadge(
          label: "Scheduled",
          backgroundColor: Color(0xFFE0E7FF),
          textColor: Color(0xFF3730A3),
          icon: Icons.schedule_rounded,
        );
      case OrderStatus.paused:
        return const VrsStatusBadge(
          label: "Paused",
          backgroundColor: Color(0xFFFEE2E2),
          textColor: Color(0xFF991B1B),
          icon: Icons.pause_circle_outline,
        );
    }
  }
}
