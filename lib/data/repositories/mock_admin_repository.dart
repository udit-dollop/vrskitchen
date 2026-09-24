import '../models/kitchen_prep_model.dart';
import '../mock/mock_data.dart';

abstract class AdminRepository {
  Future<List<KitchenPrepItem>> getKitchenPrepItems();
  Future<List<InventoryItemModel>> getInventoryItems();
}

class MockAdminRepository implements AdminRepository {
  @override
  Future<List<KitchenPrepItem>> getKitchenPrepItems() async {
    return MockData.initialKitchenPrep;
  }

  @override
  Future<List<InventoryItemModel>> getInventoryItems() async {
    return MockData.initialInventory;
  }
}
