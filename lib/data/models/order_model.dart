enum OrderStatus { preparing, outForDelivery, delivered, scheduled, paused }

class OrderItemModel {
  final String orderId;
  final String planName;
  final DateTime date;
  final String slot; // Lunch (12:00 PM - 2:00 PM) or Dinner (8:00 PM - 10:00 PM)
  final String sabzi;
  final String dal;
  final String roti;
  final String rice;
  final List<String> addOns;
  final double amount;
  OrderStatus status;
  final String deliveryAddress;
  final String riderName;
  final String riderPhone;
  final int estimatedMinutes;

  OrderItemModel({
    required this.orderId,
    required this.planName,
    required this.date,
    required this.slot,
    required this.sabzi,
    required this.dal,
    required this.roti,
    required this.rice,
    required this.addOns,
    required this.amount,
    required this.status,
    required this.deliveryAddress,
    this.riderName = "Rajesh Kumar",
    this.riderPhone = "+91 98765 01234",
    this.estimatedMinutes = 18,
  });
}
