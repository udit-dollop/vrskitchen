enum PrepStatus { pending, preparing, ready, completed }

class KitchenPrepItem {
  final String id;
  final String itemName;
  final int totalPortions;
  final String unit;
  PrepStatus status;

  KitchenPrepItem({
    required this.id,
    required this.itemName,
    required this.totalPortions,
    this.unit = "portions",
    this.status = PrepStatus.preparing,
  });
}

class InventoryItemModel {
  final String id;
  final String name;
  final double currentStock;
  final double minRequired;
  final String unit;
  final bool isLowStock;

  const InventoryItemModel({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minRequired,
    required this.unit,
    required this.isLowStock,
  });
}
