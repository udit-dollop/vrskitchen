import 'meal_item_model.dart';
import 'add_on_model.dart';

class DailyMenuModel {
  final DateTime date;
  final String dayName;
  final List<MealItemModel> lunchSabzis;
  final MealItemModel lunchDal;
  final List<MealItemModel> lunchRotis;
  final List<MealItemModel> lunchRice;
  final List<AddOnItem> lunchAddons;

  final List<MealItemModel> dinnerSabzis;
  final MealItemModel dinnerDal;
  final List<MealItemModel> dinnerRotis;
  final List<MealItemModel> dinnerRice;
  final List<AddOnItem> dinnerAddons;

  const DailyMenuModel({
    required this.date,
    required this.dayName,
    required this.lunchSabzis,
    required this.lunchDal,
    required this.lunchRotis,
    required this.lunchRice,
    required this.lunchAddons,
    required this.dinnerSabzis,
    required this.dinnerDal,
    required this.dinnerRotis,
    required this.dinnerRice,
    required this.dinnerAddons,
  });
}
