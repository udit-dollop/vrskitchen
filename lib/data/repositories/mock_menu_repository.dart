import '../models/daily_menu_model.dart';
import '../models/add_on_model.dart';
import '../mock/mock_data.dart';

abstract class MenuRepository {
  Future<List<DailyMenuModel>> getWeeklyMenu();
  Future<List<AddOnItem>> getAvailableAddOns();
}

class MockMenuRepository implements MenuRepository {
  @override
  Future<List<DailyMenuModel>> getWeeklyMenu() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MockData.generateWeeklyMenu();
  }

  @override
  Future<List<AddOnItem>> getAvailableAddOns() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockData.addOnsList;
  }
}
