enum DeliveryStatus { assigned, pickedUp, inTransit, delivered, failed }

class DeliveryStopModel {
  final String orderId;
  final String customerName;
  final String phone;
  final String address;
  final String addressTag; // Office, Home
  final String distanceKm;
  final String mealType; // Lunch, Dinner
  final List<String> items;
  bool isQrVerified;
  DeliveryStatus status;

  DeliveryStopModel({
    required this.orderId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.addressTag,
    required this.distanceKm,
    required this.mealType,
    required this.items,
    this.isQrVerified = false,
    this.status = DeliveryStatus.assigned,
  });
}
